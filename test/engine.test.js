import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { shapePolygon, pointInPolygon, distToBoundary, holeIsValid, presetHole } from '../src/gcode/geometry.js';

const cfg = loadConfig();
const SHAPES = ['rectangle', 'square', 'circle', 'heart', 'custom'];

const customOutline = [
  { x: 5, y: 20 }, { x: 20, y: 55 }, { x: 45, y: 60 }, { x: 70, y: 45 }, { x: 60, y: 10 }, { x: 25, y: 5 },
];
function design(shape) {
  return {
    shape, colours: { layer1: 'BLACK', layer2: 'WHITE' }, holePos: 'top', customOutline,
    design: [
      { w: 1.4, pts: [{ x: 22, y: 15 }, { x: 30, y: 28 }] },
      { w: 2.2, pts: [{ x: 34, y: 28 }, { x: 42, y: 15 }] },
    ],
  };
}

const num = (l, k) => { const m = l.match(new RegExp(`${k}(-?[0-9.]+)`)); return m ? parseFloat(m[1]) : null; };

// Parse print-body extrusion points into plate-local mm.
function bodyPoints(gcode, bbox) {
  const pts = [];
  let pos = { x: 0, y: 0, z: 0 }; let colour = 'back'; let inBody = false;
  for (const line of gcode.split('\n')) {
    if (line.includes('BACKING (colour 1)')) inBody = true;
    if (line.includes('A1 mini END')) inBody = false;
    if (line.includes('COLOUR CHANGE')) colour = 'design';
    if (!line.startsWith('G1 ')) continue;
    const x = num(line, 'X'), y = num(line, 'Y'), z = num(line, 'Z'), e = num(line, 'E');
    const to = { x: x ?? pos.x, y: y ?? pos.y, z: z ?? pos.z };
    if (inBody && e != null && e > 0 && (x != null || y != null)) {
      pts.push({ x: to.x - cfg.build.bedCenter[0] + bbox.w / 2, y: to.y - cfg.build.bedCenter[1] + bbox.h / 2, z: to.z, colour });
    }
    pos = to;
  }
  return pts;
}

for (const shape of SHAPES) {
  test(`${shape}: structure + real A1 template + M400 pause`, () => {
    const { gcode, meta } = generate(design(shape), cfg);
    assert.equal(meta.shape, shape);
    assert.ok(gcode.includes('G29'), 'auto bed levelling present');
    assert.ok(gcode.includes('M83'), 'relative extrusion');
    assert.ok(gcode.includes('M400 U1'), 'M400 U1 colour-change pause');
    assert.ok(meta.backingLayers >= 5, 'backing has several layers');
    assert.equal(meta.designLayers, cfg.build.designLayers, 'design height is the configured layer count');
    assert.ok(meta.strokeCount >= 1, 'strokes survived');
  });

  test(`${shape}: no extrusion inside the keyring hole`, () => {
    const { gcode, meta } = generate(design(shape), cfg);
    const r = cfg.build.holeDiameter / 2;
    for (const p of bodyPoints(gcode, meta.bbox)) {
      const d = Math.hypot(p.x - meta.hole.x, p.y - meta.hole.y);
      assert.ok(d >= r - 0.6, `point ${d.toFixed(2)}mm from hole (r=${r}) for ${shape}`);
    }
  });

  test(`${shape}: all extrusion stays within the backing shape`, () => {
    const { gcode, meta } = generate(design(shape), cfg);
    const { poly } = shapePolygon(shape, cfg, customOutline);
    for (const p of bodyPoints(gcode, meta.bbox)) {
      const ok = pointInPolygon(p, poly) || distToBoundary(p, poly) <= 1.0;
      assert.ok(ok, `point (${p.x.toFixed(1)},${p.y.toFixed(1)}) outside ${shape}`);
    }
  });

  test(`${shape}: design colour prints above the backing`, () => {
    const { gcode, meta } = generate(design(shape), cfg);
    const dz = bodyPoints(gcode, meta.bbox).filter((p) => p.colour === 'design');
    assert.ok(dz.length > 0);
    for (const p of dz) assert.ok(p.z > cfg.build.backingThickness - 1e-6, `design z=${p.z} not above backing`);
  });

  test(`${shape}: chamfered top layers still get a real perimeter`, () => {
    const { gcode } = generate(design(shape), cfg);
    assert.ok(gcode.includes('chamfer'), 'chamfer applied on top backing layers');
    // Regression: chamfer layers used to skip the perimeter, leaving the top
    // rim as ragged infill ends instead of a clean bevel.
    const layers = gcode.split(/^; layer /m).slice(1);
    const chamfered = layers.filter((L) => L.split('\n')[0].includes('chamfer'));
    assert.ok(chamfered.length >= 2, 'several layers are chamfered');
    for (const L of chamfered) {
      // a perimeter is a long unbroken run of extrusions with no retract
      const body = L.split('\n');
      let run = 0, best = 0;
      for (const line of body) {
        if (/^G1 X[-\d.]+ Y[-\d.]+ E[\d.]+/.test(line)) { run++; best = Math.max(best, run); }
        else if (/E-/.test(line)) run = 0;
      }
      assert.ok(best >= 20, `chamfer layer has no perimeter loop (longest run ${best})`);
    }
  });

  test(`${shape}: stays under the print-time limit`, () => {
    const { meta } = generate(design(shape), cfg);
    assert.ok(meta.estMinutes < cfg.limits.maxPrintMinutes, `est ${meta.estMinutes} over budget`);
  });
}

test('per-stroke pen width: thicker pen extrudes more filament', () => {
  const thin = generate({ ...design('rectangle'), design: [{ w: 0.9, pts: [{ x: 20, y: 20 }, { x: 80, y: 20 }] }] }, cfg);
  const thick = generate({ ...design('rectangle'), design: [{ w: 2.5, pts: [{ x: 20, y: 20 }, { x: 80, y: 20 }] }] }, cfg);
  assert.ok(thick.meta.estGrams > thin.meta.estGrams, 'thicker pen uses more material');
});

test('wide pen is drawn as multiple passes, not one over-extruded line', () => {
  // Regression from the first real print: a wide bead laid in a single pass
  // extruded ~2.5x the backing rate and came out lumpy and domed. Every line,
  // design included, must extrude at roughly the nominal line width.
  const flow = (gcode) => {
    let pos = { x: 0, y: 0 }, inDesign = false, back = { L: 0, E: 0 }, des = { L: 0, E: 0 };
    for (const line of gcode.split('\n')) {
      if (line.includes('DESIGN (colour 2)')) inDesign = true;
      if (!line.startsWith('G1 ')) continue;
      const x = num(line, 'X'), y = num(line, 'Y'), e = num(line, 'E');
      const to = { x: x ?? pos.x, y: y ?? pos.y };
      const L = Math.hypot(to.x - pos.x, to.y - pos.y);
      if (e != null && e > 0 && L > 0) { const t = inDesign ? des : back; t.L += L; t.E += e; }
      pos = to;
    }
    return { back: back.E / back.L, des: des.E / des.L };
  };

  for (const w of [1.0, 1.6, 2.4, 2.6]) {
    const { gcode } = generate({ ...design('rectangle'), design: [{ w, pts: [{ x: 20, y: 20 }, { x: 80, y: 22 }] }] }, cfg);
    const f = flow(gcode);
    const ratio = f.des / f.back;
    assert.ok(ratio > 0.8 && ratio < 1.25, `pen ${w}mm extrudes ${ratio.toFixed(2)}x the backing rate`);
  }
});

test('gcode drives the printer display: fan on after layer 1, M73 progress', () => {
  const { gcode } = generate(design('rectangle'), cfg);
  assert.ok(/M106 S(1\d\d|2\d\d)/.test(gcode), 'part cooling turned on');
  const m73 = gcode.match(/M73 P(\d+) R(\d+)/g) || [];
  assert.ok(m73.length >= 4, `expected several progress reports, got ${m73.length}`);
  const pcts = m73.map((l) => +l.match(/P(\d+)/)[1]);
  assert.equal(pcts[0], 0, 'starts at 0%');
  assert.equal(pcts[pcts.length - 1], 100, 'ends at 100%');
  for (let i = 1; i < pcts.length; i++) assert.ok(pcts[i] >= pcts[i - 1], 'progress never goes backwards');
  const lastR = +m73[m73.length - 1].match(/R(\d+)/)[1];
  assert.equal(lastR, 0, 'finishes with 0 minutes remaining');
});

test('hole placement: resolved hole is always valid; edge points are rejected', () => {
  for (const shape of SHAPES) {
    const { poly, bbox } = shapePolygon(shape, cfg, customOutline);
    // the engine resolves + nudges the hole to a valid spot for every shape
    const { meta } = generate(design(shape), cfg);
    assert.ok(holeIsValid({ x: meta.hole.x, y: meta.hole.y }, poly, cfg), `${shape} resolved hole valid`);
    const edge = { x: 0.5, y: bbox.h / 2 }; // hard against the left edge
    assert.ok(!holeIsValid(edge, poly, cfg), `${shape} edge point rejected`);
  }
});

test('invalid tapped hole is nudged inside, not left in the wall', () => {
  const { gcode, meta } = generate({ ...design('circle'), hole: { x: 0, y: 0 } }, cfg);
  const { poly } = shapePolygon('circle', cfg, customOutline);
  assert.ok(holeIsValid({ x: meta.hole.x, y: meta.hole.y }, poly, cfg), 'nudged hole is valid');
  assert.ok(gcode.length > 1000);
});

test('the design sits on the backing as an unbroken layer stack', () => {
  const { gcode, meta } = generate(design('rectangle'), cfg);
  const b = cfg.build;

  // Every Z the part itself extrudes at — the start template's prime line is
  // outside the body and would otherwise count as a layer.
  const zs = [];
  let z = 0; let inBody = false;
  for (const line of gcode.split('\n')) {
    if (line.includes('BACKING (colour 1)')) inBody = true;
    if (line.includes('A1 mini END')) inBody = false;
    if (!line.startsWith('G1 ')) continue;
    const nz = num(line, 'Z');
    if (nz != null) z = nz;
    const e = num(line, 'E');
    if (inBody && e != null && e > 0 && (line.includes('X') || line.includes('Y')) && !zs.includes(z)) zs.push(z);
  }
  const print = zs.slice().sort((a, c) => a - c);

  assert.equal(meta.designLayers, 2, 'design layer is two layers, not a slab');
  assert.equal(print.length, meta.backingLayers + meta.designLayers, 'no layer prints twice or goes missing');

  // The gap that matters: the backing tops out at nBack * layerHeight (1.96mm
  // for a nominal 2mm plate), so the first design layer must step up from THAT,
  // not from the rounded-up 2.0 — otherwise it is extruded thin into mid-air.
  for (let i = 1; i < print.length; i++) {
    const step = print[i] - print[i - 1];
    assert.ok(Math.abs(step - b.layerHeight) < 1e-6,
      `step ${i} is ${step.toFixed(3)}mm, expected one layer height (${b.layerHeight})`);
  }
  const top = print[print.length - 1];
  assert.ok(Math.abs(top - (meta.backingLayers + meta.designLayers) * b.layerHeight) < 1e-6,
    `finished height ${top} should be every layer stacked`);
});
