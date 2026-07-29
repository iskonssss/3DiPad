import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { holeCircle, spanAtY, insidePlate } from '../src/gcode/geometry.js';

const cfg = loadConfig();

function design(hole) {
  return {
    hole,
    colours: { layer1: 'BLACK', layer2: 'WHITE' },
    design: [
      [{ x: 20, y: 10 }, { x: 40, y: 30 }],
      [{ x: 60, y: 30 }, { x: 80, y: 10 }],
    ],
  };
}

// Parse G1 extrusion segments (relative E > 0) into bed-coordinate points.
// Only the print body counts — the start-template prime line and end template
// legitimately extrude off-plate and are excluded.
function extrudePoints(gcode) {
  const pts = [];
  let pos = { x: 0, y: 0, z: 0 };
  let colour = 'back';
  let inBody = false;
  for (const line of gcode.split('\n')) {
    if (line.includes('BACKING (colour 1)')) inBody = true;
    if (line.includes('GENERIC END')) inBody = false;
    if (line.includes('COLOUR CHANGE')) colour = 'design';
    if (!line.startsWith('G1 ')) continue;
    const x = num(line, 'X');
    const y = num(line, 'Y');
    const z = num(line, 'Z');
    const e = num(line, 'E');
    const to = { x: x ?? pos.x, y: y ?? pos.y, z: z ?? pos.z };
    if (inBody && e != null && e > 0 && (x != null || y != null)) pts.push({ ...to, colour });
    pos = to;
  }
  return pts;
}
const num = (l, k) => {
  const m = l.match(new RegExp(`${k}(-?[0-9.]+)`));
  return m ? parseFloat(m[1]) : null;
};

// bed -> plate-local
function toLocal(p) {
  const b = cfg.build;
  return { x: p.x - b.bedCenter[0] + b.plateWidth / 2, y: p.y - b.bedCenter[1] + b.plateHeight / 2 };
}

for (const hole of ['left', 'right', 'centre']) {
  test(`generates for ${hole} hole with the expected structure`, () => {
    const { gcode, meta } = generate(design(hole), cfg);
    assert.ok(gcode.includes('COLOUR CHANGE'), 'has colour change');
    assert.ok(gcode.includes('M83'), 'relative extrusion set');
    assert.equal(meta.hole, hole);
    assert.ok(meta.backingLayers >= 5, 'has backing layers');
    assert.ok(meta.designLayers >= 5, 'has design layers');
    assert.ok(meta.strokeCount >= 1, 'design strokes survived');
  });

  test(`no extrusion inside the keyring hole for ${hole}`, () => {
    const { gcode } = generate(design(hole), cfg);
    const { cx, cy, r } = holeCircle(cfg.build, hole);
    for (const p of extrudePoints(gcode)) {
      const local = toLocal(p);
      const d = Math.hypot(local.x - cx, local.y - cy);
      // allow a hair of tolerance for perimeter laid *around* the hole
      assert.ok(d >= r - 0.6, `point ${d.toFixed(2)} inside hole r=${r}`);
    }
  });

  test(`all extrusion stays within the plate region for ${hole}`, () => {
    const { gcode } = generate(design(hole), cfg);
    for (const p of extrudePoints(gcode)) {
      const local = toLocal(p);
      // within a small margin of the solid region at that y
      const spans = spanAtY(local.y, cfg.build, hole, -0.6);
      const ok = spans.some(([a, c]) => local.x >= a - 0.6 && local.x <= c + 0.6);
      assert.ok(ok, `point (${local.x.toFixed(1)},${local.y.toFixed(1)}) outside plate`);
    }
  });

  test(`design colour prints above the backing for ${hole}`, () => {
    const { gcode } = generate(design(hole), cfg);
    const designPts = extrudePoints(gcode).filter((p) => p.colour === 'design');
    assert.ok(designPts.length > 0, 'has design extrusion');
    for (const p of designPts) {
      assert.ok(p.z > cfg.build.backingThickness - 1e-6, `design z=${p.z} not above backing`);
    }
  });
}

test('centre hole adds the bulge, left/right do not', () => {
  const b = cfg.build;
  assert.ok(spanAtY(b.plateHeight + 3, b, 'centre').length > 0, 'centre has material above top edge');
  assert.equal(spanAtY(b.plateHeight + 3, b, 'left').length, 0, 'left has none above top edge');
});

test('geometry: hole sits within plate bounds and is an actual void', () => {
  const b = cfg.build;
  for (const hole of ['left', 'right', 'centre']) {
    const { cx, cy, r } = holeCircle(b, hole);
    // the hole centre must lie within the overall footprint...
    assert.ok(cx > 0 && cx < b.plateWidth, `${hole} hole x in bounds`);
    assert.ok(cy > 0 && cy < b.plateHeight + b.bulgeRadius, `${hole} hole y in bounds`);
    // ...and it must be carved out (not solid) at its centre
    assert.ok(!insidePlate({ x: cx, y: cy }, b, hole), `${hole} hole centre is a void`);
    // ...while material exists just outside the hole rim
    assert.ok(insidePlate({ x: cx + r + 1, y: cy }, b, hole) || insidePlate({ x: cx - r - 1, y: cy }, b, hole),
      `${hole} has material beside the hole`);
  }
});

test('print-time budget: sample stays under the hard limit', () => {
  const { meta } = generate(design('centre'), cfg);
  assert.ok(meta.estMinutes < cfg.limits.maxPrintMinutes, `est ${meta.estMinutes} over budget`);
});
