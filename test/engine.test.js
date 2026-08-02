import { test } from 'node:test';
import assert from 'node:assert/strict';
import nodeFs from 'node:fs';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { shapePolygon, pointInPolygon, distToBoundary, holeIsValid, presetHole } from '../src/gcode/geometry.js';
import { insetPolygon } from '../src/gcode/outline.js';

const cfg = loadConfig();
const SHAPES = ['square', 'circle', 'heart', 'custom'];

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
    // How the swap happens is a config choice: "purge" stops with M400 U1 and
    // waits for a person, "bambu" hands the whole thing to the printer with
    // T255. What must never happen is a two-colour file with no swap in it at
    // all, which would print the drawing in the backing colour.
    assert.ok(/^M400 U1\b/m.test(gcode) || /^T255\b/m.test(gcode),
      'the file must stop for the colour change one way or the other');
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
    const voids = [];
    for (let y = Math.min(...ys); y <= Math.max(...ys); y += CELL) {
      let run = 0;
      for (let x = Math.min(...xs); x <= Math.max(...xs); x += CELL) {
        if (!pointInPolygon({ x, y }, target) || Math.hypot(x - meta.hole.x, y - meta.hole.y) < hr) { run = 0; continue; }
        inside++;
        if (covered(x, y)) run = 0;
        else { blank++; voids.push({ x, y }); worst = Math.max(worst, ++run * CELL); }
      }
    }
    const pct = (100 * blank) / inside;
    // Before the fix the rectangle carried a 97mm unbroken groove down each
    // long edge; anything past a couple of line widths is a visible line.
    assert.ok(worst < 1.0, `${shape}: ${worst.toFixed(2)}mm unbroken gap on the top surface`);
    assert.ok(pct < 0.35, `${shape}: ${pct.toFixed(2)}% of the top surface has no material on it`);

    // The defect this guards was a BAND at one distance from the rim, not
    // scattered pinholes: the fill boundary sat a whole line width inside the
    // anchor loop, and the outermost fill line landed anywhere up to a pitch
    // further in again. Voids concentrated in one narrow band read as a dotted
    // line around the part; the same area scattered about is invisible.
    const band = new Map();
    for (const v of voids) {
      const k = (Math.floor(distToBoundary(v, poly) / 0.2) * 0.2).toFixed(1);
      band.set(k, (band.get(k) || 0) + 1);
    }
    const worstBand = Math.max(0, ...band.values()) / Math.max(1, voids.length);
    const bandArea = pct * worstBand;
    assert.ok(bandArea < 0.15,
      `${shape}: ${(100 * worstBand).toFixed(0)}% of the voids sit in one 0.2mm band (${bandArea.toFixed(3)}% of the surface) — that prints as a dotted line`);
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

  // The fill, not the walls: a top layer still has perimeter loops around it,
  // and those run at the perimeter feedrate on every layer. Take the feedrate
  // most of the moves use, which is the fill.
  const commonest = (feeds) => [...feeds.reduce((m, f) => m.set(f, (m.get(f) || 0) + 1), new Map())]
    .sort((a, b) => b[1] - a[1])[0][0];

  const top = feedsOf(layers[layers.length - 1]);
  const buried = feedsOf(layers[Math.floor(layers.length / 2)]);
  assert.ok(top.length && buried.length, 'found extrusions on both layers');
  assert.equal(commonest(top), cfg.speed.topSurface, 'the top layer runs at the top-surface feedrate');
  assert.ok(commonest(top) < commonest(buried), 'and slower than a buried layer');
  // The setting only means something if it sits below the volumetric ceiling —
  // otherwise the cap flattens it into the same speed as everything else.
  const cap = (cfg.speed.maxVolumetricMmps * 60) / (cfg.build.lineWidth * cfg.build.layerHeight);
  assert.ok(cfg.speed.topSurface < cap, `topSurface ${cfg.speed.topSurface} is above the flow cap ${cap.toFixed(0)}`);
});

const purgeCfg = { ...cfg, colourChange: { ...cfg.colourChange, mode: 'purge' } };

test('the colour change parks, pauses, purges and wipes', () => {
  // Shaped after Bambu Studio's "multi-colour with external spool", read off a
  // real A1 mini file. A bare pause left purging to the operator's own filament
  // menu, so whatever was still in the nozzle went into the first millimetres
  // of the drawing.
  const { gcode } = generate(design('rectangle'), purgeCfg);
  const block = gcode.slice(gcode.indexOf('COLOUR CHANGE'), gcode.indexOf('DESIGN (colour 2)'));

  const at = (re) => block.search(re);
  const park = at(/^G1 X\d+ Y\d+ F18000/m);
  const back = at(/^G1 E-[\d.]+ F1200/m);
  const pause = at(/^M400 U1/m);
  const heat = at(/^M109 S\d+/m);
  const purge = at(/^G1 E[\d.]+ F300/m);
  const wipe = at(/^G1 X-13\.5 F3000/m);

  for (const [name, i] of [['park', park], ['retract', back], ['pause', pause], ['reheat', heat], ['purge', purge], ['wipe', wipe]]) {
    assert.ok(i > -1, `the ${name} step is missing`);
  }
  assert.ok(park < back && back < pause, 'it parks and backs the old colour out BEFORE pausing');
  assert.ok(pause < heat && heat < purge && purge < wipe, 'and reheats, purges then wipes AFTER the swap');

  // enough new filament to actually clear the old colour out of the nozzle
  const pushed = [...block.matchAll(/^G1 E([\d.]+) F(?:300|50)$/gm)].reduce((a, m) => a + +m[1], 0);
  assert.ok(pushed >= 40, `only ${pushed.toFixed(0)}mm purged — the drawing would start in the old colour`);

  // the park must be clear of a 100mm-wide plate centred on the bed
  const [, px] = /^G1 X(\d+) Y\d+ F18000/m.exec(block);
  assert.ok(+px >= cfg.build.bedCenter[0] + 50, `parks at X${px}, which is over the plate`);
});

test('the colour change can be put back to a plain pause', () => {
  const plain = { ...cfg, colourChange: { ...cfg.colourChange, mode: 'pause' } };
  const { gcode } = generate(design('rectangle'), plain);
  const block = gcode.slice(gcode.indexOf('COLOUR CHANGE'), gcode.indexOf('DESIGN (colour 2)'));
  assert.match(block, /M400 U1/);
  assert.ok(!/F300/.test(block), 'no purge');

  // A hand-written block still replaces everything — but it has to stop the
  // print. M600 alone used to be accepted here, and M600 is exactly the kind of
  // plausible-looking command whose behaviour on a Bambu nobody has checked.
  const custom = { ...cfg, colourChange: { gcode: ['M400 U1 ; my own thing', 'M600 ; and this'] } };
  const g2 = generate(design('rectangle'), custom).gcode;
  const swap = g2.slice(g2.indexOf('COLOUR CHANGE'), g2.indexOf('DESIGN (colour 2)'));
  assert.match(swap, /M600 ; and this/, 'the rest of a custom block is passed through untouched');
  assert.match(swap, /M400 U1 ; my own thing/);
});

test('no move asks the hotend for more plastic than it can melt', () => {
  // ORANGE-BLACK_0010 failed three times, with three different filaments, and
  // always in the infill: it tore, blobbed, and finally knocked the plate off
  // the bed. The cause was flow, not filament — sparse infill was commanded at
  // 200mm/s, which at 0.28 x 0.45 is 25.2 mm3/s against an A1 mini hotend that
  // melts about 12. Nothing in the generator knew the ceiling existed.
  const cap = cfg.speed.maxVolumetricMmps;
  assert.ok(cap > 0, 'the config must carry a volumetric ceiling');

  const { gcode, meta } = generate(design('rectangle'), cfg);
  const area = Math.PI * (cfg.build.filamentDiameter / 2) ** 2;

  let x = 0, y = 0, feed = 0, worst = 0, worstLine = '';
  for (const raw of gcode.split('\n')) {
    const line = raw.split(';')[0].trim();
    if (!/^G[01]\b/.test(line)) continue;
    const g = Object.fromEntries([...line.matchAll(/([XYZEF])(-?[\d.]+)/g)].map((m) => [m[1], +m[2]]));
    if (g.F != null) feed = g.F;
    const nx = g.X ?? x, ny = g.Y ?? y;
    const d = Math.hypot(nx - x, ny - y);
    // Only printing moves: the purge and retracts move filament without moving
    // the head, and are not limited by the same thing.
    if ((g.E ?? 0) > 0 && d > 0.05) {
      const flow = (g.E * area / d) * (feed / 60);
      if (flow > worst) { worst = flow; worstLine = line; }
    }
    x = nx; y = ny;
  }
  assert.ok(worst <= cap * 1.02, `asks for ${worst.toFixed(1)} mm3/s, ceiling is ${cap}: ${worstLine}`);
  assert.ok(meta.flowClampedMoves > 0, 'the cap should be doing something at these speeds');
});

test('the flow cap slows the print rather than changing the part', () => {
  const uncapped = { ...cfg, speed: { ...cfg.speed, maxVolumetricMmps: 0 } };
  const a = generate(design('rectangle'), cfg);
  const b = generate(design('rectangle'), uncapped);
  // Same plastic, same toolpath — only the F words and the estimate differ.
  // (Line counts do differ: M73 progress marks are taken on a time tick, and a
  // slower print earns more of them.)
  const path = (g) => g.split('\n').filter((l) => /^G1 X/.test(l)).map((l) => l.replace(/ F\d+/, ''));
  assert.equal(a.meta.estGrams, b.meta.estGrams);
  assert.deepEqual(path(a.gcode), path(b.gcode));
  assert.ok(a.meta.estMinutes > b.meta.estMinutes, 'a capped print takes longer, honestly');
  assert.equal(b.meta.flowClampedMoves, 0, 'cap off means nothing is clamped');
});

test('the g-code is in the three blocks Bambu firmware reads', () => {
  // A file with no blocks around it loads onto the SD card and then will not
  // start: the printer has nothing to display and nothing to validate. Bambu's
  // own files — including the one that printed on this booth's A1 mini — are
  // always HEADER, CONFIG, then EXECUTABLE.
  const { gcode, meta } = generate(design('rectangle'), cfg);
  const lines = gcode.split('\n');
  const at = (tag) => lines.indexOf(tag);

  const order = ['; HEADER_BLOCK_START', '; HEADER_BLOCK_END', '; CONFIG_BLOCK_START',
    '; CONFIG_BLOCK_END', '; EXECUTABLE_BLOCK_START', '; EXECUTABLE_BLOCK_END'];
  for (const tag of order) assert.ok(at(tag) >= 0, `missing ${tag}`);
  for (let i = 1; i < order.length; i++) {
    assert.ok(at(order[i]) > at(order[i - 1]), `${order[i]} comes before ${order[i - 1]}`);
  }
  assert.equal(at('; HEADER_BLOCK_START'), 0, 'the header is the first thing in the file');

  // Every move must be inside the executable block — a G1 in the header is a
  // move the printer will not run.
  const first = lines.findIndex((l) => /^G[01] /.test(l));
  const last = lines.length - 1 - [...lines].reverse().findIndex((l) => /^G[01] /.test(l));
  assert.ok(first > at('; EXECUTABLE_BLOCK_START'), 'a move escaped above the executable block');
  assert.ok(last < at('; EXECUTABLE_BLOCK_END'), 'a move escaped below the executable block');

  // The header is what the printer's screen reads, so the numbers have to be
  // the real ones and in the units Bambu uses.
  const header = lines.slice(0, at('; HEADER_BLOCK_END')).join('\n');
  assert.match(header, /^; total layer number: \d+$/m);
  assert.match(header, /^; filament_density: 1\.24$/m, 'g/cm^3, as Bambu writes it — not our g/mm^3');
  assert.match(header, /^; filament_diameter: 1\.75$/m);
  assert.match(header, new RegExp(`^; total filament weight \\[g\\] : ${meta.estGrams.toFixed(1)}`, 'm'));
  assert.match(header, /^; max_z_height: \d+\.\d+$/m);
});

/**
 * The A1 mini's own filament change.
 *
 * Transcribed from Bambu Studio's machine profile rather than reasoned out —
 * the commands are undocumented and the cutter is at a machine-specific
 * coordinate, so the only defensible source is the slicer's own file. These
 * assertions are here because a silent edit to any of them is a head driven
 * into the frame or a print that stalls half way through a child's keychain.
 */
test('the bambu colour change cuts, unloads and reloads, in that order', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const cfg = loadConfig();
  const lines = colourChangeBlock({ ...cfg, colourChange: { ...cfg.colourChange, mode: 'bambu' } }, 2.24);
  const at = (re) => lines.findIndex((l) => re.test(l));

  // 255 is the external spool. An AMS slot number here would send the printer
  // looking for a unit that is not attached.
  // 254 = the external spool, with no AMS suffix. Slot 1 with an "A" is AMS
  // addressing and produced "AMS Lite communication is abnormal" on a printer
  // that has no AMS attached.
  assert.ok(at(/^M620 S254$/) >= 0, 'the change must be opened against the external spool');
  assert.ok(at(/^M621 S254$/) > at(/^M620 S254$/), 'and closed again');

  // The cut is a move into the cutter followed by the long retraction. Either
  // one alone does nothing useful, and the order is not interchangeable.
  const cut = at(/^G1 X180 F18000/);
  const snip = at(/^M620\.11 S1 I254 E-18/);
  const unload = at(/^T254\b/);
  assert.ok(cut >= 0, 'no move to the cutter');
  assert.ok(snip > cut, 'the retraction that cuts must follow the move to the cutter');
  assert.ok(unload > snip, 'the unload must come after the cut, or it pulls uncut filament back');

  // Purge and wipe belong after the new colour is in, never before.
  const purge = at(/^G1 E23\.70/);
  assert.ok(purge > unload, 'the purge must happen after the reload');
  assert.ok(at(/^G1 X-13\.5/) > purge, 'the wipe must follow the purge');

  // The slicer's own conversion: mm^3/s -> mm/min of 1.75mm filament.
  const feed = Math.round((cfg.speed.maxVolumetricMmps / 2.4053) * 60);
  assert.ok(lines.some((l) => l.includes(`F${feed}`)), `purge feedrate should be ${feed} mm/min`);
});

test('the cutter coordinate is the mini bed, and stays inside it', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const cfg = loadConfig();
  const lines = colourChangeBlock({ ...cfg, colourChange: { ...cfg.colourChange, mode: 'bambu' } }, 2.24);
  const cutX = lines.find((l) => /^G1 X\d+ F18000/.test(l)).match(/X(\d+)/)[1];
  // The A1 (non-mini) puts this elsewhere on a bigger bed. Copying that value
  // onto a mini drives the head into the frame.
  assert.equal(Number(cutX), 180, 'the A1 mini cutter is at the 180mm edge');
  assert.ok(Number(cutX) <= 180, 'the cut position must be on the bed');
});

test('whatever the default swap is, it is a mode that exists and stops the print', async () => {
  const { loadConfig } = await import('../src/config.js');
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const cfg = loadConfig();
  const mode = cfg.colourChange.mode;
  assert.ok(['purge', 'pause', 'bambu'].includes(mode), `"${mode}" is not a colour-change mode`);

  // The one thing no mode may do is carry on printing. A block that neither
  // waits for a person nor hands over to the printer produces a two-colour
  // keychain in one colour, and nothing downstream would notice.
  const block = colourChangeBlock(cfg, 2.24).join('\n');
  assert.ok(/M400 U1|T255/.test(block), `the "${mode}" swap never stops the print`);
});

/**
 * A config carrying colourChange.gcode replaces the whole block and ignores
 * `mode` entirely.
 *
 * A booth had been set up that way with a bare "M400 U1" and was emitting only
 * that — no park, no retract, no purge — while every conversation about it
 * assumed the shipped block was running. From outside a generated file the two
 * are indistinguishable, which is what made it survive so long.
 */
test('an explicit gcode override beats every mode, and is not silently ignored', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const base = loadConfig();
  const mine = ['M400 U1 ; swap it yourself'];

  for (const mode of ['purge', 'pause', 'bambu']) {
    const block = colourChangeBlock({ ...base, colourChange: { ...base.colourChange, mode, gcode: mine } }, 2.24);
    assert.deepEqual(block, mine, `mode "${mode}" leaked into an explicit override`);
  }

  // …and with the override gone, the mode is honoured again.
  const { gcode, ...noOverride } = { ...base.colourChange, mode: 'bambu' };
  const back = colourChangeBlock({ ...base, colourChange: noOverride }, 2.24).join('\n');
  assert.match(back, /^T254\b/m, 'removing the override should give the printer its own change back');
});

test('the booth says which swap is really in effect, including the override', () => {
  const fs = nodeFs;
  const src = fs.readFileSync(new URL('../src/server.js', import.meta.url), 'utf8');
  const from = src.indexOf('if (cfg.colourChange?.gcode) {');
  const to = src.indexOf('const synced = syncedFolderWarning();');
  assert.ok(from >= 0 && to > from, 'the startup swap report moved');
  const report = src.slice(from, to);

  const say = (colourChange) => {
    const out = [];
    new Function('cfg', 'console', report)({ colourChange }, { log: (s) => out.push(s) });
    return out.join('\n');
  };

  // The override must name itself AND say to delete the key — telling someone
  // to change `mode` while `gcode` is set is advice that cannot work.
  const overridden = say({ gcode: ['M400 U1 ; swap it yourself'], mode: 'bambu' });
  assert.match(overridden, /mode is ignored/i);
  assert.match(overridden, /DELETE/);

  assert.match(say({ mode: 'bambu' }), /cuts and reloads by itself/);
  assert.match(say({ mode: 'purge' }), /operator unloads and loads/);
});

/**
 * The file must stop for the swap. Nothing else about it matters as much.
 *
 * A change block built from AMS commands was discarded whole by a printer with
 * no AMS — no refusal, no log line, no stall. The print ran straight through
 * and produced a two-colour keychain in one colour, which looks like a success
 * until someone picks it up. Every other property of that file was correct, so
 * only an explicit check could have caught it.
 *
 * M400 U1 is the one pause this machine has been observed to honour, so it is
 * what gets asserted — not "some plausible stop command".
 */
test('every colour change mode stops the print, whatever else it tries', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const base = loadConfig();
  for (const mode of ['purge', 'pause', 'bambu']) {
    const block = colourChangeBlock({ ...base, colourChange: { ...base.colourChange, mode } }, 2.24);
    assert.ok(block.some((l) => /^\s*M400\s+U1\b/.test(l)), `mode "${mode}" produces a file that never stops`);
  }
});

test('a file that would never stop is refused rather than written', async () => {
  const { generate } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const base = loadConfig();
  const d = {
    shape: 'rectangle', colours: { layer1: 'BLACK', layer2: 'PINK' }, hole: null,
    design: [{ w: 1.6, pts: [{ x: -12, y: 0 }, { x: 12, y: 0 }] }],
  };

  // An override with no pause in it: the exact shape of the bug.
  assert.throws(
    () => generate(d, { ...base, colourChange: { gcode: ['G4 P1 ; not a pause'] } }),
    /never stop/,
    'a non-stopping override must not produce a file',
  );

  // A hand-written override that does pause is still perfectly fine.
  const { gcode } = generate(d, { ...base, colourChange: { gcode: ['M400 U1 ; swap it'] } });
  assert.match(gcode, /^M400 U1\b/m);
});

/**
 * The A1 mini's start tune, note-for-note out of a Bambu Studio export.
 *
 * Not decoration at a booth. A child who has just handed over their drawing has
 * no other way to know their print is the one that started, and the sound
 * carries over a fair floor where the screen does not.
 */
test('the printer plays its start tune, before it starts moving', async () => {
  const { generate } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const { gcode } = generate({
    shape: 'rectangle', colours: { layer1: 'BLACK', layer2: 'PINK' }, hole: null,
    design: [{ w: 1.6, pts: [{ x: -12, y: 0 }, { x: 12, y: 0 }] }],
  }, loadConfig());

  const notes = gcode.match(/^M1006 A\d+ B\d+ L\d+ C\d+ D\d+ M\d+ E\d+ F\d+ N\d+/gm) || [];
  assert.ok(notes.length >= 12, `only ${notes.length} notes — that is a chime, not a tune`);
  // Every pitch must be a rest or sit in the register Bambu's own tune uses.
  // The notes are played by the stepper motors, so pitch is not free: a melody
  // transposed two octaves up may simply not sound.
  for (const n of notes) {
    for (const p of n.match(/[ACE](\d+)/g).map((m) => Number(m.slice(1)))) {
      assert.ok(p === 0 || (p >= 36 && p <= 72), `pitch ${p} is outside the range this hardware is known to play`);
    }
  }
  assert.match(gcode, /^M1006 S1$/m, 'the tune has to be opened');
  assert.match(gcode, /^M1006 W$/m, 'and closed, or the notes are never played');
  // M17 energises the motors the tune is played on; without it there is silence.
  assert.ok(gcode.indexOf('M17') < gcode.indexOf('M1006 S1'), 'motors must be on before the tune');
  assert.ok(gcode.indexOf('M1006 W') < gcode.indexOf('G28'), 'it should play while the printer is still still');
});

/**
 * The manual colour change is a property of the print TASK, not of the g-code.
 * Read out of a .bbl Bambu Studio produced for an external-spool manual change
 * on this printer. Weeks went into trying to make the swap happen from g-code
 * alone; the T1 in the file is only half of it, and without this flag the
 * firmware has no reason to stop and ask anybody for anything.
 */
test('the print task asks for a manual colour change, on an external spool', async () => {
  const { buildPrintCommand } = await import('../src/integrations/bambu.js');
  const cmd = buildPrintCommand('/sdcard/x.3mf', { variant: 'project_file', gcodePath: 'Metadata/plate_1.gcode' });
  assert.equal(cmd.print.manual_color_change, true);
  assert.equal(cmd.print.use_ams, false, 'an AMS would do the change itself');
});

test('the change asks for a real filament slot, never 255', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const base = loadConfig();
  const block = colourChangeBlock({ ...base, colourChange: { ...base.colourChange, mode: 'bambu' } }, 2.24).join('\n');

  // 255 means "no next tool" and appears only in an end-of-print unload. Asking
  // for it takes the branch of Bambu's own template that does nothing, which is
  // how a two-colour keychain came out in one colour.
  assert.ok(!/\bT255\b/.test(block), '255 means no tool at all, and does nothing');
  assert.ok(!/\bT1\b|S1A\b/.test(block), 'AMS slot 1 on a printer with no AMS is a communication error');
  assert.match(block, /^T254\b/m, 'the external spool');
  assert.match(block, /^M620 S254$/m, 'and no "A" — that suffix is AMS addressing');
});

/**
 * "cut" — the half of the Bambu change that has actually been seen to work.
 *
 * On a real print the cut and the pull-back both happened; the toolchange then
 * left the printer on "the filament is not inserted" with no way to feed the
 * new colour in. Cutting is the fiddly part and it works. Loading from the
 * printer's own filament menu is twenty seconds an operator already knows.
 */
test('the "cut" mode cuts and unloads but leaves the loading to a person', async () => {
  const { colourChangeBlock } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const base = loadConfig();
  const cut = colourChangeBlock({ ...base, colourChange: { ...base.colourChange, mode: 'cut' } }, 2.24);
  const full = colourChangeBlock({ ...base, colourChange: { ...base.colourChange, mode: 'bambu' } }, 2.24);

  const has = (b, re) => b.some((l) => re.test(l));
  for (const [name, block] of [['cut', cut], ['bambu', full]]) {
    assert.ok(has(block, /^G1 X180 F18000/), `${name} should still go to the cutter`);
    assert.ok(has(block, /^M620\.11 S1 I254 E-18/), `${name} should still cut`);
    assert.ok(has(block, /^M400 U1\b/), `${name} must stop`);
    assert.ok(has(block, /^G1 E23\.70/), `${name} should still purge the new colour`);
  }
  // The one difference, and the whole point of the mode.
  assert.ok(!has(cut, /^T\d/), '"cut" must not ask for a toolchange');
  assert.ok(has(full, /^T254\b/), '"bambu" still does');
});
