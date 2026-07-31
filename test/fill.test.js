import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { buildCoverage, maskContours, maskRows } from '../src/gcode/fill.js';
import { shapePolygon } from '../src/gcode/geometry.js';

const cfg = loadConfig();

/** Filament volume and path length laid down in the design section only. */
function designUsage(gcode) {
  let inDesign = false, e = 0, len = 0, pos = { x: 0, y: 0 };
  for (const line of gcode.split('\n')) {
    if (line.includes('DESIGN (colour 2)')) inDesign = true;
    if (!line.startsWith('G1 ')) continue;
    const gx = /X(-?[\d.]+)/.exec(line), gy = /Y(-?[\d.]+)/.exec(line), ge = /E([\d.]+)/.exec(line);
    const to = { x: gx ? +gx[1] : pos.x, y: gy ? +gy[1] : pos.y };
    if (inDesign && ge) { e += +ge[1]; len += Math.hypot(to.x - pos.x, to.y - pos.y); }
    pos = to;
  }
  return { mm3: e * Math.PI * Math.pow(cfg.build.filamentDiameter / 2, 2), len };
}

/** Back-and-forth strokes over the same patch — a kid shading with a finger. */
function scribble(passes) {
  const out = [];
  for (let i = 0; i < passes; i++) {
    const y = 22 + (i * 14) / passes;
    const pts = [];
    for (let x = 20; x <= 40; x += 1) pts.push({ x, y: y + 1.6 * Math.sin(x / 3 + i) });
    out.push({ w: 2.6, pts: i % 2 ? pts.reverse() : pts });
  }
  return out;
}

const withDesign = (strokes) => ({ shape: 'circle', colours: { layer1: 'BLACK', layer2: 'BLUE' }, holePos: 'left', design: strokes });

test('colouring an area in does not stack material on the same spot', () => {
  // From a real print: a shape shaded in with a finger came out as a molten
  // blob. Drawn stroke by stroke, forty overlapping strokes each extruded a
  // full bead over the last — nine times the plastic the space could hold.
  // The material a design costs must follow the AREA it covers, not how many
  // times the kid went over it.
  const usage = [1, 4, 10, 25, 50].map((n) => ({ n, ...designUsage(generate(withDesign(scribble(n)), cfg).gcode) }));
  const settled = usage.filter((u) => u.n >= 4);
  const lo = Math.min(...settled.map((u) => u.mm3));
  const hi = Math.max(...settled.map((u) => u.mm3));

  assert.ok(hi / lo < 1.3,
    `material grew ${(hi / lo).toFixed(1)}x from 4 to 50 passes over the same patch: ${settled.map((u) => `${u.n}:${u.mm3.toFixed(0)}mm3`).join(' ')}`);

  // and the patch is roughly its own volume of plastic, not a multiple of it
  const patch = 20 * 14 * cfg.build.designLayers * cfg.build.layerHeight;
  assert.ok(hi < patch * 2.5, `${hi.toFixed(0)}mm3 into a patch that holds about ${patch.toFixed(0)}mm3`);
});

test('a drawn ring prints as a ring, not a filled disc', () => {
  const R = 9, cx = 30, cy = 30;
  const ring = [{ w: 2.0, pts: Array.from({ length: 90 }, (_, i) => {
    const a = (i / 89) * Math.PI * 2;
    return { x: cx + R * Math.cos(a), y: cy + R * Math.sin(a) };
  }) }];
  const { gcode, meta } = generate(withDesign(ring), cfg);

  const [bx, by] = cfg.build.bedCenter;
  let inDesign = false, pos = { x: 0, y: 0 }, insideHole = 0, onRing = 0;
  for (const line of gcode.split('\n')) {
    if (line.includes('DESIGN (colour 2)')) inDesign = true;
    if (!line.startsWith('G1 ')) continue;
    const gx = /X(-?[\d.]+)/.exec(line), gy = /Y(-?[\d.]+)/.exec(line), ge = /E([\d.]+)/.exec(line);
    const to = { x: gx ? +gx[1] : pos.x, y: gy ? +gy[1] : pos.y };
    if (inDesign && ge && (gx || gy)) {
      for (let t = 0; t <= 1; t += 0.1) {
        const p = { x: pos.x + (to.x - pos.x) * t - bx + meta.bbox.w / 2, y: pos.y + (to.y - pos.y) * t - by + meta.bbox.h / 2 };
        const d = Math.hypot(p.x - cx, p.y - cy);
        if (d < R - 2) insideHole++; else if (Math.abs(d - R) < 1.5) onRing++;
      }
    }
    pos = to;
  }
  assert.ok(onRing > 100, 'the ring itself was printed');
  assert.equal(insideHole, 0, 'nothing was extruded in the middle of the O');
});

test('coverage is clipped to the plate and around the hole', () => {
  const { poly, bbox } = shapePolygon('circle', cfg, null);
  const hole = { cx: 10, cy: 30, r: cfg.build.holeDiameter / 2 };
  // one long stroke straight across the plate, over the hole and off the edge
  const strokes = [{ w: 2.6, pts: Array.from({ length: 120 }, (_, i) => ({ x: -10 + i, y: 30 })) }];
  const cov = buildCoverage(strokes, cfg, bbox, poly, hole, cfg.build.designEdgeMargin);
  assert.ok(cov, 'the stroke produced coverage');

  for (let j = 0; j < cov.h; j++) {
    for (let i = 0; i < cov.w; i++) {
      if (!cov.mask[j * cov.w + i]) continue;
      const p = cov.toMm({ x: i, y: j });
      assert.ok(Math.hypot(p.x - hole.cx, p.y - hole.cy) > hole.r, `coverage at ${p.x.toFixed(1)},${p.y.toFixed(1)} sits in the hole`);
      assert.ok(p.x > -0.5 && p.x < bbox.w + 0.5 && p.y > -0.5 && p.y < bbox.h + 0.5, 'coverage stayed on the plate');
    }
  }
});

test('an empty drawing produces no coverage at all', () => {
  const { poly, bbox } = shapePolygon('circle', cfg, null);
  assert.equal(buildCoverage([], cfg, bbox, poly, null, 1.5), null);
  const { gcode } = generate(withDesign([]), cfg);
  assert.ok(gcode.includes('DESIGN (colour 2)'), 'the section still exists');
  assert.ok(!gcode.includes('design fill'), 'but nothing is filled');
});

test('maskContours finds the inside of a hole, not just the outside', () => {
  const w = 60, h = 60;
  const mask = new Uint8Array(w * h);
  // a thick annulus
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const d = Math.hypot(x - 30, y - 30);
      if (d < 24 && d > 12) mask[y * w + x] = 1;
    }
  }
  const loops = maskContours(mask, w, h);
  assert.equal(loops.length, 2, `expected an outer and an inner contour, got ${loops.length}`);
  const radii = loops.map((L) => L.reduce((a, p) => a + Math.hypot(p.x - 30, p.y - 30), 0) / L.length);
  radii.sort((a, b) => a - b);
  assert.ok(Math.abs(radii[0] - 12) < 2, `inner contour at r=${radii[0].toFixed(1)}, expected ~12`);
  assert.ok(Math.abs(radii[1] - 24) < 2, `outer contour at r=${radii[1].toFixed(1)}, expected ~24`);
});

test('maskRows scans both ways and skips empty lines', () => {
  const w = 20, h = 20;
  const mask = new Uint8Array(w * h);
  for (let y = 5; y < 15; y++) for (let x = 3; x < 8; x++) mask[y * w + x] = 1;

  const rows = maskRows(mask, w, h, 2, 0, false);
  assert.ok(rows.length >= 4 && rows.length <= 6, `got ${rows.length} rows across a 10-cell tall block`);
  for (const r of rows) assert.deepEqual(r.spans, [[3, 7]], 'each row spans the block');

  const cols = maskRows(mask, w, h, 2, 0, true);
  assert.ok(cols.length >= 2 && cols.length <= 3, `got ${cols.length} columns across a 5-cell wide block`);
  for (const c of cols) assert.deepEqual(c.spans, [[5, 14]]);
});

test('the two design layers cross-hatch instead of stacking one direction', () => {
  const { gcode } = generate(withDesign(scribble(8)), cfg);
  const design = gcode.slice(gcode.indexOf('DESIGN (colour 2)'));

  // Bucket extrusions by the Z they happen at. Splitting the text on Z moves
  // would split on every z-hop instead, which is a handful of moves each.
  let z = 0, px = null, py = null;
  const byZ = new Map();
  for (const line of design.split('\n')) {
    if (!line.startsWith('G1 ')) continue;
    const mz = /Z(-?[\d.]+)/.exec(line);
    if (mz) z = +mz[1];
    const mx = /X(-?[\d.]+)/.exec(line), my = /Y(-?[\d.]+)/.exec(line), me = /E([\d.]+)/.exec(line);
    const x = mx ? +mx[1] : px, y = my ? +my[1] : py;
    if (me && px != null && (mx || my)) {
      const k = z.toFixed(3);
      const v = byZ.get(k) || { dx: 0, dy: 0 };
      v.dx += Math.abs(x - px); v.dy += Math.abs(y - py);
      byZ.set(k, v);
    }
    px = x; py = y;
  }
  const heights = [...byZ.keys()].sort();
  assert.equal(heights.length, 2, `expected two design layers, got ${heights.length}`);
  const dir = heights.map((k) => (byZ.get(k).dx > byZ.get(k).dy ? 'x' : 'y'));
  assert.notEqual(dir[0], dir[1], 'the two layers run the same way — they should cross');
});
