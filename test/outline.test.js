import { test } from 'node:test';
import assert from 'node:assert/strict';
import { healOutline, smooth, decimate, insetPolygon } from '../src/gcode/outline.js';
import { loadConfig } from '../src/config.js';
import { shapePolygon, pointInPolygon } from '../src/gcode/geometry.js';
import { prepareStrokes } from '../src/gcode/strokes.js';

const cfg = loadConfig({ exampleOnly: true });

const area = (P) => {
  let a = 0;
  for (let i = 0; i < P.length; i++) { const p = P[i], q = P[(i + 1) % P.length]; a += p.x * q.y - q.x * p.y; }
  return Math.abs(a / 2);
};
/** Sharpest interior angle. For open paths the endpoints have no angle, so
 *  `closed=false` measures only the genuine interior corners. */
const sharpestAngle = (P, closed = true) => {
  let worst = 180;
  const from = closed ? 0 : 1, to = closed ? P.length : P.length - 1;
  for (let i = from; i < to; i++) {
    const a = P[(i - 1 + P.length) % P.length], b = P[i], c = P[(i + 1) % P.length];
    let d = Math.abs(Math.atan2(a.y - b.y, a.x - b.x) - Math.atan2(c.y - b.y, c.x - b.x)) * 180 / Math.PI;
    if (d > 180) d = 360 - d;
    if (d < worst) worst = d;
  }
  return worst;
};

/** A star loop that does NOT close and has a hair-thin needle spike. */
function messyLoop() {
  const pts = [];
  const arms = 6, R = 35, r = 14, cx = 40, cy = 40;
  for (let i = 0; i < arms; i++) {
    const a0 = (2 * Math.PI * i) / arms, a1 = a0 + Math.PI / arms;
    pts.push({ x: cx + R * Math.cos(a0), y: cy + R * Math.sin(a0) });
    pts.push({ x: cx + r * Math.cos(a1), y: cy + r * Math.sin(a1) });
  }
  pts.push({ x: cx + 20, y: cy + 8 }, { x: cx + 34, y: cy + 9 }, { x: cx + 20, y: cy + 8.6 }); // needle
  pts.push({ x: cx + R - 6, y: cy - 6 });                                                       // gap: unclosed
  return pts;
}

test('healing removes the needle spike from an unclosed loop', () => {
  const raw = messyLoop();
  assert.ok(sharpestAngle(raw) < 10, 'the raw loop really does contain a needle');
  const healed = healOutline(raw, { cell: 0.4, closeR: 1.4, openR: 1.6, smooth: 2 });
  assert.ok(healed.length > 20, 'healed outline has points');
  assert.ok(sharpestAngle(healed) > 60, `spike survived — sharpest ${sharpestAngle(healed).toFixed(1)}deg`);
});

test('healing keeps most of the drawn area (still reads as the same shape)', () => {
  const raw = messyLoop();
  const healed = healOutline(raw, { cell: 0.4, closeR: 1.4, openR: 1.6, smooth: 2 });
  const ratio = area(healed) / area(raw);
  assert.ok(ratio > 0.8 && ratio < 1.2, `area changed too much: ${ratio.toFixed(2)}x`);
});

test('healing is stable when applied twice (client heals, server re-heals)', () => {
  const opts = { cell: 0.4, closeR: 1.4, openR: 1.6, smooth: 2 };
  const once = healOutline(messyLoop(), opts);
  const twice = healOutline(once, opts);
  const ratio = area(twice) / area(once);
  assert.ok(ratio > 0.9 && ratio < 1.1, `double-heal drifted: ${ratio.toFixed(3)}x`);
});

test('a shape too thin to print heals away to nothing', () => {
  // a 0.5mm-wide sliver: below the nozzle's printable width
  const sliver = [{ x: 0, y: 0 }, { x: 40, y: 0.5 }, { x: 40, y: 0 }, { x: 0, y: 0.2 }];
  const healed = healOutline(sliver, { cell: 0.4, closeR: 1.4, openR: 1.6, smooth: 2 });
  assert.equal(healed.length, 0, 'unprintable sliver should be rejected, not printed');
});

test('healed custom shape flows through the engine geometry', () => {
  const { poly, bbox } = shapePolygon('custom', cfg, messyLoop());
  assert.ok(poly.length > 20);
  assert.ok(bbox.w > 10 && bbox.h > 10);
  assert.ok(sharpestAngle(poly) > 45, 'engine-side shape is smooth too');
});

test('Chaikin smoothing softens a jagged polyline', () => {
  const zig = [];
  for (let i = 0; i < 12; i++) zig.push({ x: i * 4, y: i % 2 ? 0 : 6 });
  const before = sharpestAngle(zig, false);
  const after = sharpestAngle(smooth(zig, 2, true), false);
  assert.ok(after > before + 10, `smoothing should widen angles: ${before.toFixed(0)} -> ${after.toFixed(0)}`);
  // endpoints must stay put so the pen line still starts/ends where drawn
  const sm = smooth(zig, 2, true);
  assert.deepEqual(sm[0], zig[0]);
  assert.deepEqual(sm[sm.length - 1], zig[zig.length - 1]);
});

test('decimate thins dense points but keeps the path', () => {
  const dense = Array.from({ length: 200 }, (_, i) => ({ x: i * 0.05, y: 0 }));
  const thin = decimate(dense, 0.5, false);
  assert.ok(thin.length < 30 && thin.length > 10, `unexpected count ${thin.length}`);
});

test('drawing outside the base is dropped, inside is kept', () => {
  const { poly } = shapePolygon('circle', cfg, null);
  const inside = { w: 1.6, pts: [{ x: 25, y: 30 }, { x: 35, y: 30 }] };
  const outside = { w: 1.6, pts: [{ x: -30, y: -30 }, { x: -20, y: -25 }] };
  const kept = prepareStrokes([inside, outside], poly, cfg, null, cfg.build.designEdgeMargin);
  assert.equal(kept.length, 1, 'only the in-bounds stroke survives');
  for (const p of kept[0].pts) assert.ok(pointInPolygon(p, poly), 'kept points are inside the shape');
});

test('a stroke crossing the edge is split, keeping only the inside part', () => {
  const { poly, bbox } = shapePolygon('circle', cfg, null);
  const crossing = { w: 1.6, pts: [] };
  for (let x = -10; x <= bbox.w / 2; x += 1) crossing.pts.push({ x, y: bbox.h / 2 });
  const kept = prepareStrokes([crossing], poly, cfg, null, cfg.build.designEdgeMargin);
  assert.ok(kept.length >= 1, 'the inside portion is kept');
  for (const seg of kept) for (const p of seg.pts) assert.ok(pointInPolygon(p, poly), 'no printed point is outside');
});

// --- wall spacing ---------------------------------------------------------
//
// Wall loops are cut from a raster, and the raster measures cell to cell — so a
// loop landed anywhere within about a cell of where it was asked to be. Two
// loops asked for one line width apart could come out 0.7mm apart, leaving a
// groove around the rim that shows on the finished part. Offsets have to be
// accurate to well under a line width.
//
// Measured mid-edge: at a corner the offset correctly sweeps an arc about the
// vertex, so the extreme point there is nearer the corner than `d` by design.

const rect = (w, h) => [{ x: 0, y: 0 }, { x: w, y: 0 }, { x: w, y: h }, { x: 0, y: h }];

/** Distance from the left edge, sampled well away from either corner. */
function leftEdgeInset(poly, loY, hiY) {
  const mid = poly.filter((p) => p.y > loY && p.y < hiY);
  assert.ok(mid.length, 'no vertices along the sampled edge');
  return Math.min(...mid.map((p) => p.x));
}

test('insetPolygon lands on the offset it was asked for', () => {
  const poly = rect(100, 40);
  for (const d of [0.225, 0.45, 0.675, 0.9, 1.125, 1.8]) {
    const got = insetPolygon(poly, d, { cell: 0.25 });
    const left = leftEdgeInset(got, 10, 30);
    assert.ok(Math.abs(left - d) < 0.05, `inset ${d}mm put the left edge at ${left.toFixed(3)}`);
  }
});

test('successive wall loops sit exactly one line width apart', () => {
  const poly = rect(100, 40);
  const lw = cfg.build.lineWidth;
  const loops = [0, 1, 2, 3].map((i) => leftEdgeInset(insetPolygon(poly, lw * (i + 0.5), { cell: 0.25 }), 10, 30));
  for (let i = 1; i < loops.length; i++) {
    const gap = loops[i] - loops[i - 1];
    assert.ok(Math.abs(gap - lw) < 0.05,
      `loops ${i - 1}->${i} are ${gap.toFixed(3)}mm apart, expected ${lw} — a gap that size prints as a groove`);
  }
});

test('inset stays accurate on a curve, not just straight edges', () => {
  const R = 30, circle = Array.from({ length: 180 }, (_, i) => {
    const a = (i / 180) * Math.PI * 2;
    return { x: R + R * Math.cos(a), y: R + R * Math.sin(a) };
  });
  for (const d of [0.45, 0.9, 1.35]) {
    const radii = insetPolygon(circle, d, { cell: 0.25 }).map((p) => Math.hypot(p.x - R, p.y - R));
    const mean = radii.reduce((a, b) => a + b, 0) / radii.length;
    assert.ok(Math.abs(mean - (R - d)) < 0.05, `inset ${d} gave mean radius ${mean.toFixed(3)}, wanted ${(R - d).toFixed(3)}`);
    assert.ok(Math.max(...radii) - Math.min(...radii) < 0.1, 'the loop is round, not scalloped');
  }
});

test('inset still copes with a concave shape', () => {
  // The heart's cleft is why this is done on a raster at all: offsetting edges
  // directly self-intersects there and routes a perimeter across the notch.
  const { poly } = shapePolygon('heart', cfg, null);
  const inner = insetPolygon(poly, cfg.build.lineWidth * 1.5, { cell: 0.25 });
  assert.ok(inner.length > 8, 'the inset survives');
  for (const p of inner) assert.ok(pointInPolygon(p, poly), 'every inset point is inside the original');
});

test('every shape the booth offers is one the generator knows', async () => {
  const fs = await import('node:fs');
  const kiosk = fs.readFileSync(new URL('../src/kiosk/kiosk.html', import.meta.url), 'utf8');
  const server = fs.readFileSync(new URL('../src/server.js', import.meta.url), 'utf8');
  const { loadConfig } = await import('../src/config.js');
  const { shapePolygon } = await import('../src/gcode/geometry.js');
  const cfg = loadConfig({ exampleOnly: true });

  const offered = [...kiosk.matchAll(/\['(\w+)','[^']+'\]/g)].map((m) => m[1]);
  // The booth offers four: a shape a child draws themselves, and three presets.
  // Rectangle and a t-shirt were tried and dropped — the rectangle ran past the
  // print-time budget and the shirt did not look good enough to hand over.
  assert.deepEqual(offered.sort(), ['circle', 'custom', 'heart', 'square']);
  const accepted = server.match(/const SHAPES = \[([^\]]+)\]/)[1].match(/'(\w+)'/g).map((s) => s.slice(1, -1));

  for (const shape of offered) {
    assert.ok(accepted.includes(shape), `the kiosk offers "${shape}" but the server rejects it`);
    if (shape === 'custom') continue;
    assert.ok(cfg.build.shapeSizes[shape], `"${shape}" has no size in config`);
    const { poly } = shapePolygon(shape, cfg);
    assert.ok(poly.length >= 3, `"${shape}" does not generate an outline`);
  }
  // and an icon each, or the chip is a blank square on the tablet
  const icons = kiosk.slice(kiosk.indexOf('const SHAPE_ICONS'), kiosk.indexOf('const SHAPES='));
  for (const shape of offered) assert.ok(icons.includes(`${shape}:`), `"${shape}" has no chip icon`);
});


/** How many times does a closed ring cross itself? Zero, for anything printable. */
function crossings(ring) {
  const side = (p, q, r) => Math.sign((q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x));
  const crosses = (a, b, c, d) => side(a, b, c) !== side(a, b, d) && side(c, d, a) !== side(c, d, b);
  let n = 0;
  for (let i = 0; i < ring.length; i++) {
    for (let j = i + 2; j < ring.length; j++) {
      if (i === 0 && j === ring.length - 1) continue;
      if (crosses(ring[i], ring[(i + 1) % ring.length], ring[j], ring[(j + 1) % ring.length])) n++;
    }
  }
  return n;
}
