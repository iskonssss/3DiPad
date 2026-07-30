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
export function prepareStrokes(strokes, poly, cfg, hole = null, edgeMargin = 0) {
  if (!Array.isArray(strokes)) return [];
  const holeGuard = hole ? { cx: hole.cx, cy: hole.cy, r: hole.r + cfg.build.penRange[1] / 2 } : null;
  const iters = cfg.build.strokeSmooth ?? 2;
  const out = [];
  const defW = cfg.build.beadWidth;
  for (const stroke of strokes) {
    const pts = stroke && Array.isArray(stroke.pts) ? stroke.pts : Array.isArray(stroke) ? stroke : null;
    if (!pts || !pts.length) continue;
    const w = clampWidth(stroke && stroke.w != null ? stroke.w : defW, cfg);
    // light simplify to shed jitter, then Chaikin so the bead flows like a pen
    // line instead of a chain of straight segments
    const tidy = pts.length > 2 ? smooth(simplify(pts, 0.25), iters, true) : pts;
    for (const seg of clipToRegion(tidy, poly, edgeMargin, holeGuard)) {
      if (seg.length >= 1) out.push({ w, pts: decimate(seg, 0.25, false) });
    }
  }
  return out;
}

export function clampWidth(w, cfg) {
  const [lo, hi] = cfg.build.penRange;
  const v = +w;
  return Number.isFinite(v) ? Math.max(lo, Math.min(hi, v)) : cfg.build.beadWidth;
}
