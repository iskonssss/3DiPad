// Stroke utilities: the kid's drawing arrives as polylines in plate-local mm.
// We simplify them (fewer points => smaller/faster g-code) and clip anything
// that strays outside the plate, then the engine extrudes each as a raised bead.

import { insidePlate } from './geometry.js';

/** Euclidean distance between two points. */
export function dist(a, b) {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

/** Total drawn length across all polylines (mm). Used for the print-time budget. */
export function totalLength(polylines) {
  let L = 0;
  for (const line of polylines) {
    for (let i = 1; i < line.length; i++) L += dist(line[i - 1], line[i]);
  }
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
    let maxD = 0;
    let idx = -1;
    for (let i = s + 1; i < e; i++) {
      const d = perpDist(points[i], points[s], points[e]);
      if (d > maxD) {
        maxD = d;
        idx = i;
      }
    }
    if (maxD > tol && idx !== -1) {
      keep[idx] = true;
      stack.push([s, idx], [idx, e]);
    }
  }
  return points.filter((_, i) => keep[i]);
}

function perpDist(p, a, b) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const len = Math.hypot(dx, dy);
  if (len === 0) return dist(p, a);
  return Math.abs((p.x - a.x) * dy - (p.y - a.y) * dx) / len;
}

/**
 * Clip a polyline to the plate: split into sub-polylines wherever it leaves the
 * region, so beads never extrude off the plate edge or across the hole.
 */
export function clipToPlate(points, cfg, hole) {
  const out = [];
  let cur = [];
  for (const p of points) {
    if (insidePlate(p, cfg, hole)) {
      cur.push(p);
    } else if (cur.length) {
      out.push(cur);
      cur = [];
    }
  }
  if (cur.length) out.push(cur);
  return out.filter((l) => l.length >= 1);
}

/**
 * Prepare drawn strokes for extrusion: simplify, clip, drop empties.
 * Input & output are arrays of polylines (arrays of {x,y}) in plate-local mm.
 */
export function prepareStrokes(polylines, cfg, hole) {
  const prepared = [];
  for (const line of polylines) {
    if (!Array.isArray(line) || line.length === 0) continue;
    const simplified = simplify(line, 0.3);
    for (const seg of clipToPlate(simplified, cfg, hole)) {
      if (seg.length >= 1) prepared.push(seg);
    }
  }
  return prepared;
}
