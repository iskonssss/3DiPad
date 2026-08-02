// Stroke utilities. Each drawn stroke carries its own pen-tip width:
//   { w: <bead mm>, pts: [ {x,y}, ... ] }   (plate-local mm, y-up)
// We simplify the points and clip anything outside the backing polygon.

import { pointInPolygon, distToBoundary } from './geometry.js';
import { smooth, decimate } from './outline.js';

export function dist(a, b) { return Math.hypot(a.x - b.x, a.y - b.y); }

/** Total drawn length across all strokes (mm). */
export function totalLength(strokes) {
  let L = 0;
  for (const s of strokes) for (let i = 1; i < s.pts.length; i++) L += dist(s.pts[i - 1], s.pts[i]);
  return L;
}

/** Ramer–Douglas–Peucker simplification; tolerance in mm. */
export function simplify(points, tol = 0.3) {
  if (points.length < 3) return points.slice();
  const keep = new Array(points.length).fill(false);
  keep[0] = keep[points.length - 1] = true;
  const stack = [[0, points.length - 1]];
  while (stack.length) {
    const [s, e] = stack.pop();
    let maxD = 0, idx = -1;
    for (let i = s + 1; i < e; i++) {
      const d = perpDist(points[i], points[s], points[e]);
      if (d > maxD) { maxD = d; idx = i; }
    }
    if (maxD > tol && idx !== -1) { keep[idx] = true; stack.push([s, idx], [idx, e]); }
  }
  return points.filter((_, i) => keep[i]);
}
function perpDist(p, a, b) {
  const dx = b.x - a.x, dy = b.y - a.y, len = Math.hypot(dx, dy);
  if (len === 0) return dist(p, a);
  return Math.abs((p.x - a.x) * dy - (p.y - a.y) * dx) / len;
}

/**
 * Split a point list wherever it leaves the plate (staying `margin` inside the
 * outline) OR enters the keyring hole, so beads stay on solid plate and never
 * print over the void or hang off the edge. Uses the raw polygon (offset-free,
 * robust on concave shapes).
 */
function clipToRegion(points, poly, margin, hole) {
  const ok = (p) =>
    pointInPolygon(p, poly) &&
    distToBoundary(p, poly) >= margin &&
    (!hole || Math.hypot(p.x - hole.cx, p.y - hole.cy) > hole.r);
  const out = [];
  let cur = [];
  for (const p of points) {
    if (ok(p)) cur.push(p);
    else if (cur.length) { out.push(cur); cur = []; }
  }
  if (cur.length) out.push(cur);
  return out.filter((l) => l.length >= 1);
}

/**
 * Prepare drawn strokes for extrusion: simplify, clip inside the backing outline
 * (by `edgeMargin`) and around the hole, keep each stroke's pen width.
 * Strokes are {w, pts}.
 */
/**
 * Centripetal Catmull-Rom through `points`, sampled every `step` mm.
 *
 * Chaikin smoothing alone could not give a smooth bead, and it took a print to
 * see why. Chaikin rounds corners at whatever resolution the tablet happened to
 * sample at: a fast stroke gives points millimetres apart, two Chaikin passes
 * turn each of those into four straight segments, and four straight segments
 * across a 1.4 mm bead still reads as facets. It cannot add detail the input
 * never had. A spline can — this passes through the drawn points and fills in
 * between them at a fixed arc length, so how smooth the bead is stops depending
 * on how fast the child moved their hand.
 *
 * Centripetal rather than uniform parameterisation, which matters here: uniform
 * Catmull-Rom overshoots when points are unevenly spaced, and a stylus lifted
 * mid-stroke or dragged round a tight corner produces exactly that. The
 * overshoot shows up as a little loop of extruded plastic outside the line the
 * child drew.
 */
export function resample(points, step = 0.4) {
  if (points.length < 3 || !(step > 0)) return points.slice();
  const at = (i) => points[Math.max(0, Math.min(points.length - 1, i))];
  const out = [];
  for (let i = 0; i < points.length - 1; i++) {
    const p0 = at(i - 1), p1 = at(i), p2 = at(i + 1), p3 = at(i + 2);
    const seg = Math.hypot(p2.x - p1.x, p2.y - p1.y);
    const n = Math.max(1, Math.ceil(seg / step));
    // knots, spaced by the square root of the distance between points
    const k = [0];
    for (const [a, b] of [[p0, p1], [p1, p2], [p2, p3]]) {
      k.push(k[k.length - 1] + Math.max(1e-6, Math.sqrt(Math.hypot(b.x - a.x, b.y - a.y))));
    }
    for (let j = 0; j < n; j++) {
      out.push(barryGoldman(p0, p1, p2, p3, k, k[1] + ((k[2] - k[1]) * j) / n));
    }
  }
  out.push(points[points.length - 1]);
  return out;
}

/** Evaluate the spline at t by repeated linear interpolation between knots. */
function barryGoldman(p0, p1, p2, p3, k, t) {
  const mix = (a, b, t0, t1) => {
    const d = t1 - t0 || 1e-6, u = (t - t0) / d;
    return { x: a.x * (1 - u) + b.x * u, y: a.y * (1 - u) + b.y * u };
  };
  const a1 = mix(p0, p1, k[0], k[1]), a2 = mix(p1, p2, k[1], k[2]), a3 = mix(p2, p3, k[2], k[3]);
  const b1 = mix(a1, a2, k[0], k[2]), b2 = mix(a2, a3, k[1], k[3]);
  return mix(b1, b2, k[1], k[2]);
}

export function prepareStrokes(strokes, poly, cfg, hole = null, edgeMargin = 0) {
  if (!Array.isArray(strokes)) return [];
  const holeGuard = hole ? { cx: hole.cx, cy: hole.cy, r: hole.r + cfg.build.penRange[1] / 2 } : null;
  const iters = cfg.build.strokeSmooth ?? 2;
  const step = cfg.build.strokeStepMm ?? 0.4;
  const out = [];
  const defW = cfg.build.beadWidth;
  for (const stroke of strokes) {
    const pts = stroke && Array.isArray(stroke.pts) ? stroke.pts : Array.isArray(stroke) ? stroke : null;
    if (!pts || !pts.length) continue;
    const w = clampWidth(stroke && stroke.w != null ? stroke.w : defW, cfg);
    // Shed stylus jitter, round the corners, then lay the line out along a
    // spline at a fixed step so the bead is as smooth as the step and not as
    // smooth as the tablet's sampling happened to be.
    const tidy = pts.length > 2 ? resample(smooth(simplify(pts, 0.2), iters, true), step) : pts;
    for (const seg of clipToRegion(tidy, poly, edgeMargin, holeGuard)) {
      // Then drop the points a straight run does not need. 0.02mm is a fifth of
      // a layer height, so nothing visible is lost — but the old 0.25mm pass
      // here was throwing away most of the smoothing immediately after doing
      // it, which is the other half of why the bead came out faceted.
      if (seg.length >= 1) out.push({ w, pts: simplify(decimate(seg, 0.02, false), 0.02) });
    }
  }
  return out;
}

export function clampWidth(w, cfg) {
  const [lo, hi] = cfg.build.penRange;
  const v = +w;
  return Number.isFinite(v) ? Math.max(lo, Math.min(hi, v)) : cfg.build.beadWidth;
}
