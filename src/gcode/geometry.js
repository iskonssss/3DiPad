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

/** Build the backing outline polygon (closed ring, CCW) + its bounding box. */
export function shapePolygon(shape, cfg, customOutline) {
  const s = cfg.build.shapeSizes;
  switch (shape) {
    case 'rectangle': return rect(s.rectangle[0], s.rectangle[1]);
    case 'square': return rect(s.square[0], s.square[1]);
    case 'circle': return ellipse(s.circle[0], s.circle[0]);
    case 'heart': return heart(s.heart[0], s.heart[1]);
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
function customShape(outline, cfg) {
  const [maxW, maxH] = cfg.build.customMax;
  if (!Array.isArray(outline) || outline.length < 3) return rect(60, 40);
  // clamp to the allowed boundary, drop stray points
  const pts = outline
    .filter((p) => p && Number.isFinite(+p.x) && Number.isFinite(+p.y))
    .map((p) => ({ x: Math.max(0, Math.min(maxW, +p.x)), y: Math.max(0, Math.min(maxH, +p.y)) }));
  return finalize(pts.length >= 3 ? pts : [{ x: 0, y: 0 }, { x: 60, y: 0 }, { x: 60, y: 40 }, { x: 0, y: 40 }]);
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
