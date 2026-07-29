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
    assert.ok(meta.backingLayers >= 5 && meta.designLayers >= 5);
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

  test(`${shape}: top layers carry a chamfer`, () => {
    const { gcode } = generate(design(shape), cfg);
    assert.ok(gcode.includes('chamfer'), 'chamfer applied on top backing layers');
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
