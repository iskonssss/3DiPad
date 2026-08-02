// Plate geometry — polygon-based so every backing shape shares one code path.
//
// Coordinate frame: plate-local millimetres, origin at the bottom-left of the
// shape's bounding box, y-up (matches the drawing canvas after its y-flip).
//
// A backing shape is just a closed polygon. Rectangle/Square/Circle/Heart are
// generated; "custom" is the kid's own drawn outline. Everything downstream —
// perimeters, infill, the 0.8 mm top chamfer, hole placement — is derived from:
//   - shapePolygon()  : the outline
//   - offsetPolygon() : inward/outward offset (chamfer, walls, hole margin)
//   - scanlineSpans() : solid x-intervals of a polygon at height y

import { healOutline } from './outline.js';

/** Build the backing outline polygon (closed ring, CCW) + its bounding box. */
export function shapePolygon(shape, cfg, customOutline) {
  const s = cfg.build.shapeSizes;
  switch (shape) {
    case 'rectangle': return rect(s.rectangle[0], s.rectangle[1]);
    case 'square': return rect(s.square[0], s.square[1]);
    case 'circle': return ellipse(s.circle[0], s.circle[0]);
    case 'heart': return heart(s.heart[0], s.heart[1]);
    case 'jersey': return jersey(s.jersey[0], s.jersey[1]);
    case 'custom': return customShape(customOutline, cfg);
    default: return rect(s.rectangle[0], s.rectangle[1]);
  }
}

function finalize(pts) {
  let poly = ensureCCW(dedupe(pts));
  const xs = poly.map((p) => p.x), ys = poly.map((p) => p.y);
  const minX = Math.min(...xs), minY = Math.min(...ys);
  // shift so bbox starts at origin
  poly = poly.map((p) => ({ x: p.x - minX, y: p.y - minY }));
  const w = Math.max(...xs) - minX, h = Math.max(...ys) - minY;
  return { poly, bbox: { w, h } };
}

function rect(w, h) {
  return finalize([{ x: 0, y: 0 }, { x: w, y: 0 }, { x: w, y: h }, { x: 0, y: h }]);
}
function ellipse(w, h, seg = 96) {
  const pts = [];
  for (let i = 0; i < seg; i++) {
    const a = (2 * Math.PI * i) / seg;
    pts.push({ x: (w / 2) * (1 + Math.cos(a)), y: (h / 2) * (1 + Math.sin(a)) });
  }
  return finalize(pts);
}
// Classic parametric heart, scaled to fit w x h, point at the bottom.
function heart(w, h, seg = 120) {
  const pts = [];
  for (let i = 0; i < seg; i++) {
    const t = (2 * Math.PI * i) / seg;
    const x = 16 * Math.pow(Math.sin(t), 3);
    const y = 13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t);
    pts.push({ x, y });
  }
  // normalise to bbox
  const xs = pts.map((p) => p.x), ys = pts.map((p) => p.y);
  const minX = Math.min(...xs), maxX = Math.max(...xs), minY = Math.min(...ys), maxY = Math.max(...ys);
  const sx = w / (maxX - minX), sy = h / (maxY - minY);
  return finalize(pts.map((p) => ({ x: (p.x - minX) * sx, y: (p.y - minY) * sy })));
}
/**
 * A football jersey: straight torso, sleeves out at the shoulders, round collar.
 *
 * Drawn in a 0..1 box and scaled to w x h, so the proportions hold whatever
 * size the booth is set to. Traced counter-clockwise from the bottom-left of
 * the hem — round the right side, over the shoulders, back down the left.
 *
 * Two things are deliberate. The collar is an arc rather than a V notch,
 * because a sharp inward corner is where an inward offset (the 0.8 mm top
 * chamfer) folds over itself. And the cuffs stop short of a point for the same
 * reason a real one does: a tip narrower than the nozzle is not a shape, it is
 * a gap the slicer has to guess at.
 */
function jersey(w, h) {
  const neckHalf = 0.105;   // collar half-width, as a fraction of the width
  const neckDrop = 0.125;   // how far the collar cuts down from the shoulder line
  const pts = [
    { x: 0.285, y: 0.000 },  // hem, left
    { x: 0.715, y: 0.000 },  // hem, right
    { x: 0.735, y: 0.545 },  // right side, up to the armpit
    { x: 0.800, y: 0.590 },
    { x: 0.940, y: 0.635 },
    { x: 1.000, y: 0.690 },  // right cuff, bottom
    { x: 0.980, y: 0.845 },  // right cuff, top
    { x: 0.830, y: 0.910 },
    { x: 0.680, y: 0.965 },  // right shoulder
  ];
  // The collar, swept right to left so it stays in step with the winding.
  const seg = 16;
  for (let i = 0; i <= seg; i++) {
    const a = (Math.PI * i) / seg;
    pts.push({ x: 0.5 + neckHalf * Math.cos(a), y: 0.985 - neckDrop * Math.sin(a) });
  }
  pts.push(
    { x: 0.320, y: 0.965 },  // left shoulder
    { x: 0.170, y: 0.910 },
    { x: 0.020, y: 0.845 },  // left cuff, top
    { x: 0.000, y: 0.690 },  // left cuff, bottom
    { x: 0.060, y: 0.635 },
    { x: 0.200, y: 0.590 },
    { x: 0.265, y: 0.545 },  // left armpit
  );
  // Fit the drawn extents to w x h exactly, so shapeSizes means what it says —
  // the collar arc stops just short of the top of the box, and left alone that
  // would quietly make every jersey a millimetre shorter than configured.
  const xs = pts.map((p) => p.x), ys = pts.map((p) => p.y);
  const minX = Math.min(...xs), minY = Math.min(...ys);
  const sx = w / (Math.max(...xs) - minX), sy = h / (Math.max(...ys) - minY);
  return finalize(pts.map((p) => ({ x: (p.x - minX) * sx, y: (p.y - minY) * sy })));
}

function customShape(outline, cfg) {
  const [maxW, maxH] = cfg.build.customMax;
  if (!Array.isArray(outline) || outline.length < 3) return rect(60, 40);
  // clamp to the allowed boundary, drop stray points
  const pts = outline
    .filter((p) => p && Number.isFinite(+p.x) && Number.isFinite(+p.y))
    .map((p) => ({ x: Math.max(0, Math.min(maxW, +p.x)), y: Math.max(0, Math.min(maxH, +p.y)) }));
  if (pts.length < 3) return rect(60, 40);
  // Heal the freehand loop: bridge the gap where it didn't close, delete
  // hair-thin spikes the nozzle can't print, and smooth it into curves.
  const healed = healOutline(pts, {
    cell: cfg.build.outlineCell,
    closeR: cfg.build.outlineCloseMm,
    openR: cfg.build.outlineOpenMm,
    smooth: cfg.build.outlineSmooth,
  });
  return finalize(healed.length >= 3 ? healed : pts);
}

// ---------------------------------------------------------------------------

function dedupe(pts) {
  const out = [];
  for (const p of pts) {
    const q = out[out.length - 1];
    if (!q || Math.hypot(p.x - q.x, p.y - q.y) > 1e-4) out.push({ x: p.x, y: p.y });
  }
  if (out.length > 1) {
    const a = out[0], b = out[out.length - 1];
    if (Math.hypot(a.x - b.x, a.y - b.y) < 1e-4) out.pop();
  }
  return out;
}

export function signedArea(poly) {
  let a = 0;
  for (let i = 0; i < poly.length; i++) {
    const p = poly[i], q = poly[(i + 1) % poly.length];
    a += p.x * q.y - q.x * p.y;
  }
  return a / 2;
}
function ensureCCW(poly) {
  return signedArea(poly) < 0 ? poly.slice().reverse() : poly;
}

/**
 * Offset a CCW polygon inward by d (d>0 shrinks, d<0 expands) using per-edge
 * normal shift + re-intersection. Good for small offsets (walls, 0.8mm chamfer).
 */
export function offsetPolygon(poly, d) {
  if (Math.abs(d) < 1e-6) return poly.slice();
  const n = poly.length;
  const lines = [];
  for (let i = 0; i < n; i++) {
    const a = poly[i], b = poly[(i + 1) % n];
    let dx = b.x - a.x, dy = b.y - a.y;
    const len = Math.hypot(dx, dy) || 1;
    dx /= len; dy /= len;
    const nx = -dy, ny = dx; // inward normal for CCW
    lines.push({ px: a.x + nx * d, py: a.y + ny * d, dx, dy });
  }
  const out = [];
  for (let i = 0; i < n; i++) {
    const l0 = lines[(i - 1 + n) % n], l1 = lines[i];
    const p = intersect(l0, l1);
    out.push(p || { x: poly[i].x, y: poly[i].y });
  }
  return out;
}
function intersect(l0, l1) {
  const den = l0.dx * l1.dy - l0.dy * l1.dx;
  if (Math.abs(den) < 1e-9) return null; // parallel
  const t = ((l1.px - l0.px) * l1.dy - (l1.py - l0.py) * l1.dx) / den;
  return { x: l0.px + l0.dx * t, y: l0.py + l0.dy * t };
}

/** Solid x-intervals where a horizontal line at height y crosses the polygon. */
export function scanlineSpans(poly, y) {
  const xs = [];
  const n = poly.length;
  for (let i = 0; i < n; i++) {
    const a = poly[i], b = poly[(i + 1) % n];
    const y0 = a.y, y1 = b.y;
    if ((y0 <= y && y1 > y) || (y1 <= y && y0 > y)) {
      const t = (y - y0) / (y1 - y0);
      xs.push(a.x + t * (b.x - a.x));
    }
  }
  xs.sort((p, q) => p - q);
  const spans = [];
  for (let i = 0; i + 1 < xs.length; i += 2) {
    if (xs[i + 1] - xs[i] > 0.05) spans.push([xs[i], xs[i + 1]]);
  }
  return spans;
}

/** Remove [lo,hi] from a set of intervals, splitting where necessary. */
export function subtractInterval(intervals, lo, hi) {
  const out = [];
  for (const [a, b] of intervals) {
    if (hi <= a || lo >= b) out.push([a, b]);
    else { if (a < lo) out.push([a, lo]); if (hi < b) out.push([hi, b]); }
  }
  return out;
}

export function boundsY(poly) {
  let yMin = Infinity, yMax = -Infinity;
  for (const p of poly) { if (p.y < yMin) yMin = p.y; if (p.y > yMax) yMax = p.y; }
  return { yMin, yMax };
}

export function pointInPolygon(pt, poly) {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i], b = poly[j];
    if ((a.y > pt.y) !== (b.y > pt.y) && pt.x < ((b.x - a.x) * (pt.y - a.y)) / (b.y - a.y) + a.x) inside = !inside;
  }
  return inside;
}

/** Shortest distance from a point to the polygon boundary (edges). */
export function distToBoundary(pt, poly) {
  let min = Infinity;
  for (let i = 0; i < poly.length; i++) {
    const a = poly[i], b = poly[(i + 1) % poly.length];
    min = Math.min(min, segDist(pt, a, b));
  }
  return min;
}
function segDist(p, a, b) {
  const dx = b.x - a.x, dy = b.y - a.y;
  const l2 = dx * dx + dy * dy;
  let t = l2 ? ((p.x - a.x) * dx + (p.y - a.y) * dy) / l2 : 0;
  t = Math.max(0, Math.min(1, t));
  return Math.hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy));
}

/**
 * Is the keyring hole placement valid? The hole centre must sit far enough
 * inside the shape that a solid wall remains around it.
 */
export function holeIsValid(holePt, poly, cfg) {
  if (!pointInPolygon(holePt, poly)) return false;
  return distToBoundary(holePt, poly) >= holeEdgeMargin(cfg);
}
export function holeEdgeMargin(cfg) {
  return cfg.build.holeDiameter / 2 + cfg.build.holeWallMin;
}

/** Default hole point for a preset position within the shape's bounding box. */
export function presetHole(position, bbox, cfg) {
  const m = holeEdgeMargin(cfg) + 1;
  if (position === 'left') return { x: m, y: bbox.h / 2 };
  if (position === 'right') return { x: bbox.w - m, y: bbox.h / 2 };
  return { x: bbox.w / 2, y: bbox.h - m }; // top-centre
}

/** Translate a plate-local point to absolute bed coordinates (bbox centred on the bed). */
export function toBed(pt, bbox, cfg) {
  const [bx, by] = cfg.build.bedCenter;
  return { x: pt.x - bbox.w / 2 + bx, y: pt.y - bbox.h / 2 + by };
}
