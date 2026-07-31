import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { shapePolygon, pointInPolygon, distToBoundary, holeIsValid, presetHole } from '../src/gcode/geometry.js';
import { insetPolygon } from '../src/gcode/outline.js';

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
    assert.ok(/^G28\b/m.test(gcode), 'homes before printing');
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
  // Measured on the design section alone. Total estGrams is rounded to 0.1g and
  // the plate dwarfs the drawing, so a whole pen-width range vanishes into the
  // rounding — the test passed or failed on noise elsewhere in the part.
  const designFilament = (gcode) => {
    let inDesign = false, e = 0;
    for (const line of gcode.split('\n')) {
      if (line.includes('DESIGN (colour 2)')) inDesign = true;
      if (!inDesign || !line.startsWith('G1 ')) continue;
      const de = num(line, 'E');
      if (de != null && de > 0) e += de;
    }
    return e;
  };
  const stroke = (w) => generate({ ...design('rectangle'), design: [{ w, pts: [{ x: 20, y: 20 }, { x: 80, y: 20 }] }] }, cfg);
  const widths = [0.9, 1.4, 2.0, 2.5].map((w) => ({ w, e: designFilament(stroke(w).gcode) }));
  for (let i = 1; i < widths.length; i++) {
    assert.ok(widths[i].e > widths[i - 1].e,
      `pen ${widths[i].w}mm extruded ${widths[i].e.toFixed(2)}, not more than ${widths[i - 1].w}mm at ${widths[i - 1].e.toFixed(2)}`);
  }
  assert.ok(widths[3].e > widths[0].e * 2, 'the widest pen lays down far more than the finest');
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

test('no groove between the wall and the top shell', () => {
  // From a real print: a continuous dark line ran around the rim of the plate
  // where the top surface met the wall. Two causes, both here — the wall loops
  // were unevenly spaced (raster-quantised offsets), and the 45-degree fill
  // lines ended ON the fill boundary, so consecutive line-ends left scallops.
  // Measured as: how much of the surface that should be solid is untouched by
  // any extrusion, and how long an unbroken untouched run gets.
  const CELL = 0.15;
  for (const shape of ['rectangle', 'heart']) {
    const { gcode, meta } = generate(design(shape), cfg);
    const { poly } = shapePolygon(shape, cfg, customOutline);
    const [bx, by] = cfg.build.bedCenter;

    // extrusions on the top solid layer, in plate-local mm
    const byZ = new Map();
    let pos = { x: 0, y: 0, z: 0 }, inBody = false;
    for (const line of gcode.split('\n')) {
      if (line.includes('BACKING (colour 1)')) inBody = true;
      if (line.includes('COLOUR CHANGE')) inBody = false;
      if (!line.startsWith('G1 ')) continue;
      const x = num(line, 'X'), y = num(line, 'Y'), z = num(line, 'Z'), e = num(line, 'E');
      const to = { x: x ?? pos.x, y: y ?? pos.y, z: z ?? pos.z };
      if (inBody && e != null && e > 0 && (x != null || y != null)) {
        if (!byZ.has(to.z)) byZ.set(to.z, []);
        byZ.get(to.z).push([pos.x - bx + meta.bbox.w / 2, pos.y - by + meta.bbox.h / 2,
          to.x - bx + meta.bbox.w / 2, to.y - by + meta.bbox.h / 2]);
      }
      pos = to;
    }
    const segs = byZ.get(Math.max(...byZ.keys()));
    const half = cfg.build.lineWidth / 2;

    // bucket the segments so coverage is a local lookup, not a scan of them all
    const GS = 2, grid = new Map();
    segs.forEach((s, i) => {
      for (let gx = Math.floor((Math.min(s[0], s[2]) - half) / GS); gx <= Math.floor((Math.max(s[0], s[2]) + half) / GS); gx++) {
        for (let gy = Math.floor((Math.min(s[1], s[3]) - half) / GS); gy <= Math.floor((Math.max(s[1], s[3]) + half) / GS); gy++) {
          const k = gx + ',' + gy;
          if (!grid.has(k)) grid.set(k, []);
          grid.get(k).push(i);
        }
      }
    });
    const nearSeg = (px, py, [x1, y1, x2, y2]) => {
      const dx = x2 - x1, dy = y2 - y1, L = dx * dx + dy * dy;
      let t = L ? ((px - x1) * dx + (py - y1) * dy) / L : 0;
      t = t < 0 ? 0 : t > 1 ? 1 : t;
      return Math.hypot(px - (x1 + t * dx), py - (y1 + t * dy)) <= half;
    };
    const covered = (x, y) => (grid.get(Math.floor(x / GS) + ',' + Math.floor(y / GS)) || [])
      .some((i) => nearSeg(x, y, segs[i]));

    // the surface that should be solid: the shape less its chamfer, less the hole
    const target = insetPolygon(poly, cfg.build.chamferMm, { cell: 0.25 });
    const hr = cfg.build.holeDiameter / 2 + cfg.build.chamferMm + half;
    const xs = target.map((p) => p.x), ys = target.map((p) => p.y);
    let inside = 0, blank = 0, worst = 0;
    for (let y = Math.min(...ys); y <= Math.max(...ys); y += CELL) {
      let run = 0;
      for (let x = Math.min(...xs); x <= Math.max(...xs); x += CELL) {
        if (!pointInPolygon({ x, y }, target) || Math.hypot(x - meta.hole.x, y - meta.hole.y) < hr) { run = 0; continue; }
        inside++;
        if (covered(x, y)) run = 0;
        else { blank++; worst = Math.max(worst, ++run * CELL); }
      }
    }
    const pct = (100 * blank) / inside;
    // Before the fix the rectangle carried a 97mm unbroken groove down each
    // long edge; anything past a couple of line widths is a visible line.
    assert.ok(worst < 1.5, `${shape}: ${worst.toFixed(2)}mm unbroken gap on the top surface`);
    assert.ok(pct < 1.0, `${shape}: ${pct.toFixed(2)}% of the top surface has no material on it`);
  }
});

test('progress reports keep moving through the slow first layer', () => {
  // The bar used to be updated only at layer boundaries. The first layer runs
  // at the first-layer feedrate and is roughly 40% of a keychain, so the
  // printer showed 0% for minutes and then jumped straight to the forties.
  const { gcode } = generate(design('rectangle'), cfg);
  const body = gcode.slice(gcode.indexOf('BACKING (colour 1)'));
  const firstLayerEnd = body.indexOf('; layer 2/');
  assert.ok(firstLayerEnd > 0, 'found the end of the first layer');

  const pcts = [...body.slice(0, firstLayerEnd).matchAll(/M73 P(\d+)/g)].map((m) => +m[1]);
  assert.ok(pcts.length >= 5, `only ${pcts.length} progress reports during the first layer`);
  assert.ok(Math.max(...pcts) >= 10, `the bar only reached ${Math.max(...pcts)}% by the end of layer 1`);

  const all = [...gcode.matchAll(/M73 P(\d+) R(\d+)/g)].map((m) => ({ p: +m[1], r: +m[2] }));
  for (let i = 1; i < all.length; i++) {
    assert.ok(all[i].p >= all[i - 1].p, `progress went backwards: ${all[i - 1].p} -> ${all[i].p}`);
    assert.ok(all[i].r <= all[i - 1].r, `time remaining went up: ${all[i - 1].r} -> ${all[i].r}`);
  }
  assert.equal(all[0].p, 0);
  assert.equal(all[all.length - 1].p, 100);
  assert.equal(all[all.length - 1].r, 0);
  // no long silent stretch: every report is within a few percent of the last
  const biggestJump = Math.max(...all.slice(1).map((v, i) => v.p - all[i].p));
  assert.ok(biggestJump <= 5, `the bar jumps ${biggestJump}% in one step`);
});

test('bed levelling is skipped unless the config asks for it', () => {
  // A G29 mesh probe costs over a minute on a 12-minute keychain — a tenth of
  // the booth's throughput, per kid.
  const off = generate(design('rectangle'), cfg);
  assert.ok(!/^G29\b/m.test(off.gcode), 'no bed levelling by default');
  assert.ok(/^G28\b/m.test(off.gcode), 'still homes — that part is not optional');
  assert.ok(off.gcode.includes('bed levelling skipped'), 'and says so in the file');

  const levelled = { ...cfg, calibration: { ...cfg.calibration, bedLevel: true } };
  const on = generate(design('rectangle'), levelled);
  assert.ok(/^G29\b/m.test(on.gcode), 'turning it on puts G29 back');
  assert.ok(on.meta.estMinutes > off.meta.estMinutes,
    'and the estimate accounts for the time it costs');
});

test('solid infill is one unbroken zigzag, not a line of nicks', () => {
  // From a real print: a dashed line ran around the rim just inside the wall.
  // Every serpentine turn was a dry hop, and every one of those turns lands on
  // the fill boundary — so each line left an un-extruded nick at the edge.
  for (const shape of SHAPES) {
    const { gcode } = generate(design(shape), cfg);
    const body = gcode.slice(gcode.indexOf('BACKING (colour 1)'), gcode.indexOf('COLOUR CHANGE'));

    let pos = { x: 0, y: 0 }, dry = 0, welded = 0;
    for (const line of body.split('\n')) {
      if (!line.startsWith('G1 ')) continue;
      const x = num(line, 'X'), y = num(line, 'Y'), e = num(line, 'E');
      if (x == null && y == null) continue;
      const to = { x: x ?? pos.x, y: y ?? pos.y };
      const L = Math.hypot(to.x - pos.x, to.y - pos.y);
      // a turn is a short join between two fill lines
      if (L > 0 && L <= cfg.build.lineWidth * 2) { if (e == null) dry++; else welded++; }
      pos = to;
    }
    assert.ok(welded > 100, `${shape}: only ${welded} welded turns — the fill is not continuous`);
    assert.ok(dry < welded / 20, `${shape}: ${dry} dry hops against ${welded} welded turns; each one is a nick at the rim`);
  }
});

test('the visible top layer is printed slower than the buried ones', () => {
  const { gcode } = generate(design('rectangle'), cfg);
  const layers = gcode.split(/^; layer /m).slice(1);
  const feedsOf = (L) => [...L.matchAll(/^G1 X[-\d.]+ Y[-\d.]+ E[\d.]+ F(\d+)/gm)].map((m) => +m[1]);

  const top = feedsOf(layers[layers.length - 1]);
  const buried = feedsOf(layers[Math.floor(layers.length / 2)]);
  assert.ok(top.length && buried.length, 'found extrusions on both layers');
  assert.equal(Math.max(...top), cfg.speed.topSurface, 'the top layer runs at the top-surface feedrate');
  assert.ok(Math.max(...top) < Math.max(...buried), 'and slower than a buried layer');
});
