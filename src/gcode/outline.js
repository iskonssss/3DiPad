// Turning a kid's freehand loop into a printable outline.
//
// A finger/pencil loop is never clean: it doesn't close exactly, it crosses
// itself, and it has hair-thin spikes where the stroke doubled back. Naively
// closing the path leaves needles the nozzle cannot print.
//
// So instead of editing the polyline, we work on the *area* it encloses:
//
//   1. rasterise the closed path into a bitmask (even-odd fill)
//   2. morphological CLOSE  — bridges the gap where the loop didn't meet
//   3. morphological OPEN   — deletes spikes/needles thinner than the nozzle
//   4. keep the largest blob — drops stray islands from a crossed stroke
//   5. trace its boundary, then Chaikin-smooth it into flowing curves
//
// The result is a clean, smooth, printable polygon that still reads as the
// shape the kid drew.

const ORTH = 1.0;
const DIAG = Math.SQRT2;

/** Chaikin corner-cutting. Closed curves by default; set open=true for strokes. */
export function smooth(points, iterations = 2, open = false) {
  let pts = points;
  for (let it = 0; it < iterations; it++) {
    if (pts.length < 3) return pts;
    const out = [];
    if (open) out.push(pts[0]);
    const n = pts.length;
    const last = open ? n - 1 : n;
    for (let i = 0; i < last; i++) {
      const a = pts[i], b = pts[(i + 1) % n];
      out.push({ x: a.x * 0.75 + b.x * 0.25, y: a.y * 0.75 + b.y * 0.25 });
      out.push({ x: a.x * 0.25 + b.x * 0.75, y: a.y * 0.25 + b.y * 0.75 });
    }
    if (open) out.push(pts[n - 1]);
    pts = out;
  }
  return pts;
}

/** Drop points closer together than `min` mm (keeps the last point). */
export function decimate(points, min, closed = true) {
  if (points.length < 3) return points.slice();
  const out = [points[0]];
  for (let i = 1; i < points.length; i++) {
    const p = points[i], q = out[out.length - 1];
    if (Math.hypot(p.x - q.x, p.y - q.y) >= min) out.push(p);
  }
  if (closed && out.length > 2) {
    const a = out[0], b = out[out.length - 1];
    if (Math.hypot(a.x - b.x, a.y - b.y) < min) out.pop();
  }
  return out;
}

/**
 * Heal a freehand loop into a smooth printable polygon.
 * `points` are plate-local mm. Returns a new point array (may be empty if the
 * drawing enclosed no printable area).
 */
export function healOutline(points, opts = {}) {
  const cell = opts.cell ?? 0.4;          // raster resolution, mm
  const closeR = opts.closeR ?? 1.4;      // bridge gaps up to ~2x this
  const openR = opts.openR ?? 1.6;        // delete features thinner than ~2x this
  const smoothIters = opts.smooth ?? 2;
  if (!Array.isArray(points) || points.length < 3) return [];

  // --- bounds with padding so morphology has room to work ---
  const pad = Math.ceil((closeR + openR) / cell) + 2;
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (const p of points) {
    if (p.x < minX) minX = p.x; if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y; if (p.y > maxY) maxY = p.y;
  }
  const w = Math.ceil((maxX - minX) / cell) + pad * 2;
  const h = Math.ceil((maxY - minY) / cell) + pad * 2;
  if (w < 4 || h < 4 || w * h > 4_000_000) return [];
  const gx = (x) => (x - minX) / cell + pad;
  const gy = (y) => (y - minY) / cell + pad;

  // --- 1. rasterise the closed path (even-odd scanline fill) ---
  const poly = points.map((p) => ({ x: gx(p.x), y: gy(p.y) }));
  let mask = new Uint8Array(w * h);
  for (let row = 0; row < h; row++) {
    const yc = row + 0.5;
    const xs = [];
    for (let i = 0; i < poly.length; i++) {
      const a = poly[i], b = poly[(i + 1) % poly.length]; // closes the loop
      if ((a.y <= yc && b.y > yc) || (b.y <= yc && a.y > yc)) {
        xs.push(a.x + ((yc - a.y) / (b.y - a.y)) * (b.x - a.x));
      }
    }
    xs.sort((p, q) => p - q);
    for (let k = 0; k + 1 < xs.length; k += 2) {
      const from = Math.max(0, Math.ceil(xs[k] - 0.5));
      const to = Math.min(w - 1, Math.floor(xs[k + 1] - 0.5));
      for (let col = from; col <= to; col++) mask[row * w + col] = 1;
    }
  }

  // --- 2. close (dilate then erode): bridges an unclosed loop ---
  mask = dilate(mask, w, h, closeR / cell);
  mask = erode(mask, w, h, closeR / cell);
  // --- 3. open (erode then dilate): removes thin spikes/needles ---
  mask = erode(mask, w, h, openR / cell);
  mask = dilate(mask, w, h, openR / cell);

  // --- 4. keep the largest blob ---
  const blob = largestBlob(mask, w, h);
  if (!blob) return [];

  // --- 5. trace + smooth ---
  const traced = traceBoundary(blob, w, h);
  if (traced.length < 8) return [];
  let out = traced.map((c) => ({ x: (c.x - pad) * cell + minX, y: (c.y - pad) * cell + minY }));
  out = decimate(out, cell * 1.5);
  out = smooth(out, smoothIters, false);
  // keep it smooth but not needlessly dense — long perimeters would bloat the
  // g-code and slow the print with thousands of micro-segments
  out = decimate(out, opts.minSeg ?? cell * 2.5);
  return out;
}

/* ---------------- morphology via chamfer distance transform ---------------- */

function distanceTo(mask, w, h, target) {
  const INF = 1e9;
  const d = new Float32Array(w * h);
  for (let i = 0; i < d.length; i++) d[i] = mask[i] === target ? 0 : INF;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const i = y * w + x;
      if (d[i] === 0) continue;
      let v = d[i];
      if (x > 0) v = Math.min(v, d[i - 1] + ORTH);
      if (y > 0) v = Math.min(v, d[i - w] + ORTH);
      if (x > 0 && y > 0) v = Math.min(v, d[i - w - 1] + DIAG);
      if (x < w - 1 && y > 0) v = Math.min(v, d[i - w + 1] + DIAG);
      d[i] = v;
    }
  }
  for (let y = h - 1; y >= 0; y--) {
    for (let x = w - 1; x >= 0; x--) {
      const i = y * w + x;
      let v = d[i];
      if (x < w - 1) v = Math.min(v, d[i + 1] + ORTH);
      if (y < h - 1) v = Math.min(v, d[i + w] + ORTH);
      if (x < w - 1 && y < h - 1) v = Math.min(v, d[i + w + 1] + DIAG);
      if (x > 0 && y < h - 1) v = Math.min(v, d[i + w - 1] + DIAG);
      d[i] = v;
    }
  }
  return d;
}

function erode(mask, w, h, r) {
  if (r <= 0) return mask;
  const d = distanceTo(mask, w, h, 0); // distance to background
  const out = new Uint8Array(w * h);
  for (let i = 0; i < out.length; i++) out[i] = d[i] > r ? 1 : 0;
  return out;
}
function dilate(mask, w, h, r) {
  if (r <= 0) return mask;
  const d = distanceTo(mask, w, h, 1); // distance to foreground
  const out = new Uint8Array(w * h);
  for (let i = 0; i < out.length; i++) out[i] = d[i] <= r ? 1 : 0;
  return out;
}

/** Flood-fill labelling; returns a mask containing only the biggest region. */
function largestBlob(mask, w, h) {
  const seen = new Uint8Array(w * h);
  let best = null, bestSize = 0;
  const stack = [];
  for (let start = 0; start < mask.length; start++) {
    if (!mask[start] || seen[start]) continue;
    stack.length = 0;
    stack.push(start);
    seen[start] = 1;
    const cells = [];
    while (stack.length) {
      const i = stack.pop();
      cells.push(i);
      const x = i % w, y = (i - x) / w;
      if (x > 0 && mask[i - 1] && !seen[i - 1]) { seen[i - 1] = 1; stack.push(i - 1); }
      if (x < w - 1 && mask[i + 1] && !seen[i + 1]) { seen[i + 1] = 1; stack.push(i + 1); }
      if (y > 0 && mask[i - w] && !seen[i - w]) { seen[i - w] = 1; stack.push(i - w); }
      if (y < h - 1 && mask[i + w] && !seen[i + w]) { seen[i + w] = 1; stack.push(i + w); }
    }
    if (cells.length > bestSize) { bestSize = cells.length; best = cells; }
  }
  if (!best || bestSize < 12) return null;
  const out = new Uint8Array(w * h);
  for (const i of best) out[i] = 1;
  return out;
}

// 8-neighbour offsets in clockwise order, used by the tracer below.
const CW = [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]];

/**
 * Moore-neighbour boundary tracing. Returns ordered cell coordinates.
 *
 * The correct algorithm tracks the cell we arrived *from* (always a background
 * cell) and sweeps clockwise from there — guessing a direction index instead
 * silently fails on some shapes, so keep `from` explicit.
 */
function traceBoundary(mask, w, h) {
  let startI = -1;
  for (let i = 0; i < mask.length; i++) if (mask[i]) { startI = i; break; }
  if (startI < 0) return [];
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? mask[y * w + x] : 0);

  const sx = startI % w, sy = (startI - sx) / w;
  // row-major scan guarantees the cell to the west is background
  let bx = sx, by = sy, fx = sx - 1, fy = sy;
  const contour = [{ x: bx, y: by }];
  const maxSteps = w * h * 4;

  for (let step = 0; step < maxSteps; step++) {
    // index of the "from" cell in the clockwise ring around b
    let idx = CW.findIndex(([dx, dy]) => bx + dx === fx && by + dy === fy);
    if (idx < 0) idx = 7;
    let moved = false;
    for (let k = 1; k <= 8; k++) {
      const j = (idx + k) % 8;
      const nx = bx + CW[j][0], ny = by + CW[j][1];
      if (at(nx, ny)) {
        // we came into the new cell from the previous (background) neighbour
        const prev = (j - 1 + 8) % 8;
        fx = bx + CW[prev][0]; fy = by + CW[prev][1];
        bx = nx; by = ny;
        contour.push({ x: bx, y: by });
        moved = true;
        break;
      }
    }
    if (!moved) break;                                    // isolated cell
    if (bx === sx && by === sy && contour.length > 3) break; // closed the loop
  }
  return contour;
}
