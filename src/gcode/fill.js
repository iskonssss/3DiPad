// The design layer as an AREA, not as a pile of strokes.
//
// Drawing each stroke as its own bead is right for a signature and badly wrong
// for colouring-in. A kid shading a shape with a finger lays forty overlapping
// strokes across the same few square centimetres, and stroke-by-stroke every
// one of them extrudes a full bead — the same spot gets material four or five
// times over and comes out as a molten blob standing proud of the plate.
//
// So the strokes are painted into a coverage mask first: the union of every
// stroke widened by its own pen width. Whatever the kid did to build that
// shape — one stroke or a hundred — the mask is the same, and the toolpath is
// generated from the mask. Every square millimetre gets exactly one line width
// of plastic, which is what a bucket fill has to do to print at all.
//
// The mask is also where clipping belongs: a stroke's centreline can sit inside
// the plate while its bead hangs over the rim, and an area mask can simply be
// intersected with the plate.

import { smooth, decimate, fillPolygon, erode } from './outline.js';

/**
 * Paint every stroke into one coverage mask.
 * Returns { mask, w, h, cell, pad, toMm } in plate-local mm, or null if the
 * drawing is empty or too large to raster.
 */
export function buildCoverage(strokes, cfg, bbox, clipPoly, hole, edgeMargin) {
  const cell = cfg.build.designCell ?? 0.12;
  if (!strokes || !strokes.length) return null;
  const pad = Math.ceil(3 / cell);
  const w = Math.ceil(bbox.w / cell) + pad * 2;
  const h = Math.ceil(bbox.h / cell) + pad * 2;
  if (w < 4 || h < 4 || w * h > 6_000_000) return null;

  const mask = new Uint8Array(w * h);
  const toCell = (p) => ({ x: p.x / cell + pad, y: p.y / cell + pad });
  const minR = cfg.build.lineWidth / 2 / cell;

  for (const s of strokes) {
    const r = Math.max(minR, Math.max(cfg.build.lineWidth, s.w) / 2 / cell);
    const pts = s.pts.map(toCell);
    if (pts.length === 1) stampSegment(mask, w, h, pts[0], pts[0], r);
    else for (let i = 1; i < pts.length; i++) stampSegment(mask, w, h, pts[i - 1], pts[i], r);
  }

  // Clip as an area: the bead of a stroke whose centreline is legally inside can
  // still hang over the rim, and only the mask can see that.
  if (clipPoly && clipPoly.length >= 3) {
    let clip = fillPolygon(clipPoly.map(toCell), w, h);
    if (edgeMargin > 0) clip = erode(clip, w, h, edgeMargin / cell);
    for (let i = 0; i < mask.length; i++) if (!clip[i]) mask[i] = 0;
  }
  if (hole) {
    const c = toCell({ x: hole.cx, y: hole.cy });
    const r = (hole.r + cfg.build.lineWidth) / cell;
    clearDisc(mask, w, h, c.x, c.y, r);
  }

  let any = false;
  for (let i = 0; i < mask.length && !any; i++) if (mask[i]) any = true;
  if (!any) return null;

  return { mask, w, h, cell, pad, toMm: (c) => ({ x: (c.x - pad) * cell, y: (c.y - pad) * cell }) };
}

/** Mark every cell within `r` cells of the segment a-b. */
function stampSegment(mask, w, h, a, b, r) {
  const x0 = Math.max(0, Math.floor(Math.min(a.x, b.x) - r));
  const x1 = Math.min(w - 1, Math.ceil(Math.max(a.x, b.x) + r));
  const y0 = Math.max(0, Math.floor(Math.min(a.y, b.y) - r));
  const y1 = Math.min(h - 1, Math.ceil(Math.max(a.y, b.y) + r));
  const dx = b.x - a.x, dy = b.y - a.y;
  const len = dx * dx + dy * dy;
  const r2 = r * r;
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      let t = len > 1e-9 ? ((x - a.x) * dx + (y - a.y) * dy) / len : 0;
      t = t < 0 ? 0 : t > 1 ? 1 : t;
      const ex = x - (a.x + t * dx), ey = y - (a.y + t * dy);
      if (ex * ex + ey * ey <= r2) mask[y * w + x] = 1;
    }
  }
}

export function clearDisc(mask, w, h, cx, cy, r) {
  const r2 = r * r;
  for (let y = Math.max(0, Math.floor(cy - r)); y <= Math.min(h - 1, Math.ceil(cy + r)); y++) {
    for (let x = Math.max(0, Math.floor(cx - r)); x <= Math.min(w - 1, Math.ceil(cx + r)); x++) {
      const ex = x - cx, ey = y - cy;
      if (ex * ex + ey * ey <= r2) mask[y * w + x] = 0;
    }
  }
}

/**
 * Every closed contour of a mask — the outside of each blob AND the inside of
 * each enclosed hole, so a drawn "O" prints as a ring rather than a disc.
 * Returns loops of cell coordinates.
 */
export function maskContours(mask, w, h) {
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? mask[y * w + x] : 0);
  const edge = (x, y) => at(x, y) && (!at(x - 1, y) || !at(x + 1, y) || !at(x, y - 1) || !at(x, y + 1));
  const seen = new Uint8Array(w * h);
  const loops = [];
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (seen[y * w + x] || !edge(x, y)) continue;
      const loop = traceLoop(mask, w, h, x, y);
      for (const p of loop) seen[p.y * w + p.x] = 1;
      seen[y * w + x] = 1;
      if (loop.length >= 8) loops.push(loop);
    }
  }
  return loops;
}

const RING = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]];

/** Moore-neighbour boundary trace starting at a known boundary cell. */
function traceLoop(mask, w, h, sx, sy) {
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? mask[y * w + x] : 0);
  // any background neighbour will do as the cell we "came from"
  let from = null;
  for (const [dx, dy] of RING) if (!at(sx + dx, sy + dy)) { from = { x: sx + dx, y: sy + dy }; break; }
  if (!from) return [];

  let bx = sx, by = sy, fx = from.x, fy = from.y;
  const contour = [{ x: bx, y: by }];
  const maxSteps = w * h * 4;
  for (let step = 0; step < maxSteps; step++) {
    let idx = RING.findIndex(([dx, dy]) => bx + dx === fx && by + dy === fy);
    if (idx < 0) idx = 7;
    let moved = false;
    for (let k = 1; k <= 8; k++) {
      const j = (idx + k) % 8;
      const nx = bx + RING[j][0], ny = by + RING[j][1];
      if (at(nx, ny)) {
        const prev = RING[(j + 7) % 8];
        fx = bx + prev[0]; fy = by + prev[1];
        bx = nx; by = ny;
        moved = true;
        break;
      }
    }
    if (!moved) break;
    if (bx === sx && by === sy) break;
    contour.push({ x: bx, y: by });
  }
  return contour;
}

/** Rows of set-cell spans through a mask, `step` cells apart. */
export function maskRows(mask, w, h, step, phase = 0, vertical = false) {
  const rows = [];
  const outer = vertical ? w : h;
  const inner = vertical ? h : w;
  for (let a = Math.max(0, Math.round(phase)); a < outer; a += step) {
    const line = Math.round(a);
    const spans = [];
    let start = -1;
    for (let b = 0; b < inner; b++) {
      const on = vertical ? mask[b * w + line] : mask[line * w + b];
      if (on && start < 0) start = b;
      else if (!on && start >= 0) { spans.push([start, b - 1]); start = -1; }
    }
    if (start >= 0) spans.push([start, inner - 1]);
    if (spans.length) rows.push({ y: line, spans });
  }
  return rows;
}

/** Turn a traced cell contour into a smooth mm path. */
export function contourToMm(loop, cov, smoothIters = 1) {
  let pts = loop.map(cov.toMm);
  pts = decimate(pts, cov.cell * 1.5);
  pts = smooth(pts, smoothIters, false);
  return decimate(pts, cov.cell * 2.5);
}
