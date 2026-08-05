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

/* --------------------- thin features: one bead, one pass -------------------- */
//
// A drawn line narrower than about two line widths must be printed as a SINGLE
// pass down its middle, not as a loop around it.
//
// The perimeter path below traces the boundary of whatever it is given. On a
// wide shape that is right. On a thin one the boundary runs up one side of the
// ribbon and back down the other, a fraction of a millimetre apart, and each
// pass extrudes a full bead — so a 0.5mm line was getting 1.68x the plastic the
// space can hold, measured on the generated file. That is the same
// stack-it-in-one-spot failure the coverage mask exists to prevent, arriving by
// a different route, and it reads on the plate as a raised, blobby line.
//
// So thin regions are reduced to their centreline and drawn once, at the width
// the feature actually is.

/**
 * Zhang-Suen thinning: erode a mask to an 8-connected, one-cell-wide skeleton
 * without breaking it apart. Standard algorithm — the conditions below are
 * deliberately verbatim, because a "simplification" of any of them severs
 * strokes at junctions, and a severed stroke is a gap in the drawing.
 */
export function skeletonize(mask, w, h) {
  const m = Uint8Array.from(mask);
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? m[y * w + x] : 0);
  // p2..p9, clockwise from north
  const ring = (x, y) => [
    at(x, y - 1), at(x + 1, y - 1), at(x + 1, y), at(x + 1, y + 1),
    at(x, y + 1), at(x - 1, y + 1), at(x - 1, y), at(x - 1, y - 1),
  ];
  const transitions = (p) => {
    let n = 0;
    for (let i = 0; i < 8; i++) if (!p[i] && p[(i + 1) % 8]) n++;
    return n;
  };
  for (let pass = 0; pass < 200; pass++) {
    let removed = 0;
    for (const step of [0, 1]) {
      const drop = [];
      for (let y = 1; y < h - 1; y++) {
        for (let x = 1; x < w - 1; x++) {
          if (!m[y * w + x]) continue;
          const p = ring(x, y);
          const b = p.reduce((a, v) => a + v, 0);
          if (b < 2 || b > 6) continue;
          if (transitions(p) !== 1) continue;
          const [p2, p3, p4, p5, p6, p7, p8, p9] = p;
          if (step === 0) {
            if (p2 && p4 && p6) continue;
            if (p4 && p6 && p8) continue;
          } else {
            if (p2 && p4 && p8) continue;
            if (p2 && p6 && p8) continue;
          }
          drop.push(y * w + x);
        }
      }
      for (const i of drop) m[i] = 0;
      removed += drop.length;
    }
    if (!removed) break;
  }
  return m;
}

const SKEL_NB = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]];

/**
 * Remove the whiskers thinning leaves behind, without shortening real strokes.
 *
 * Skeletonising anything wider than a hair throws off little branches a few
 * cells long — at a crossing, at a corner, anywhere the shape bulges. They are
 * not strokes, but each one is a junction, and a junction breaks the walk below
 * into more pieces: a plain drawn ring came out as 27 separate runs needing 27
 * retractions, against the 5 the old path used, which is a lot of stringing
 * over a keychain to draw one circle.
 *
 * A branch is only cut if it runs from a loose end into a junction within
 * `maxCells`. A stroke that simply ends — the tail of a letter, a hair on a
 * drawn head — never reaches a junction at all and is left alone however short.
 */
export function pruneSpurs(mask, w, h, maxCells) {
  const m = Uint8Array.from(mask);
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? m[y * w + x] : 0);
  const nb = (x, y) => {
    const out = [];
    for (const [dx, dy] of SKEL_NB) if (at(x + dx, y + dy)) out.push([x + dx, y + dy]);
    return out;
  };
  for (let pass = 0; pass < 8; pass++) {
    const drop = [];
    for (let y = 0; y < h; y++) {
      for (let x = 0; x < w; x++) {
        if (!at(x, y) || nb(x, y).length !== 1) continue;   // loose ends only
        const branch = [[x, y]];
        let cur = [x, y], prev = null;
        for (let step = 0; step < maxCells; step++) {
          const ns = nb(cur[0], cur[1]).filter((n) => !prev || n[0] !== prev[0] || n[1] !== prev[1]);
          if (ns.length !== 1) break;                       // fork or dead end
          prev = cur;
          cur = ns[0];
          if (nb(cur[0], cur[1]).length > 2) {              // ran into a junction
            for (const [bx, by] of branch) drop.push(by * w + bx);
            break;
          }
          branch.push(cur);
        }
      }
    }
    if (!drop.length) break;
    for (const i of drop) m[i] = 0;
  }
  return m;
}

/**
 * Walk a one-cell-wide skeleton into polylines of cell coordinates.
 *
 * Edges are consumed, not cells, so a junction is passed through as many times
 * as it has arms — walking cells instead would abandon every branch after the
 * first and silently drop most of a drawing. Endpoints are used as seeds first
 * so a stroke is emitted end to end rather than starting from its middle.
 */
export function skeletonPaths(mask, w, h) {
  const at = (x, y) => (x >= 0 && y >= 0 && x < w && y < h ? mask[y * w + x] : 0);

  // Adjacency, with the redundant diagonals taken out.
  //
  // A one-cell-wide curve that is not axis-aligned is a staircase, and on an
  // 8-connected grid the corner of every step touches THREE cells: the two
  // along the curve and the diagonal shortcut across it. Read literally that is
  // a junction, and a curve made of them is hundreds of junctions — which is
  // how a plain drawn ring came out as 27 separate runs, each paying for its
  // own retraction, instead of one continuous loop.
  //
  // A diagonal whose two ends already share a neighbour is that shortcut, never
  // a branch, so it is dropped. Connectivity is untouched: the two-step route
  // through the shared cell is still there.
  const adj = new Map();
  const cells = [];
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (!at(x, y)) continue;
      const i = y * w + x;
      cells.push(i);
      const s = new Set();
      for (const [dx, dy] of SKEL_NB) if (at(x + dx, y + dy)) s.add((y + dy) * w + (x + dx));
      adj.set(i, s);
    }
  }
  for (const i of cells) {
    const xi = i % w, yi = (i - xi) / w;
    for (const j of [...adj.get(i)]) {
      const xj = j % w, yj = (j - xj) / w;
      if (Math.abs(xi - xj) + Math.abs(yi - yj) !== 2) continue;   // not a diagonal
      let shared = false;
      for (const k of adj.get(i)) if (k !== j && adj.get(j).has(k)) { shared = true; break; }
      if (shared) { adj.get(i).delete(j); adj.get(j).delete(i); }
    }
  }

  const used = new Set();
  const ek = (a, b) => (a < b ? a + ':' + b : b + ':' + a);
  const walkFrom = (start, paths) => {
    for (const first of [...adj.get(start)]) {
      if (used.has(ek(start, first))) continue;
      let cur = start, next = first;
      const path = [cur];
      for (;;) {
        used.add(ek(cur, next));
        path.push(next);
        cur = next;
        let step = null;
        for (const k of adj.get(cur)) if (!used.has(ek(cur, k))) { step = k; break; }
        if (step == null) break;
        next = step;
      }
      if (path.length >= 2) paths.push(path.map((i) => ({ x: i % w, y: (i - (i % w)) / w })));
    }
  };

  const paths = [];
  const deg = (i) => adj.get(i).size;
  // Loose ends first, so a stroke is drawn end to end rather than from its
  // middle; then real junctions; then whatever is left, which is a closed loop
  // — a drawn "O" has no end and no junction at all, and seeding only from
  // those would drop it without a word.
  for (const i of cells) if (deg(i) === 1) walkFrom(i, paths);
  for (const i of cells) if (deg(i) >= 3) walkFrom(i, paths);
  for (const i of cells) if (deg(i) === 2) walkFrom(i, paths);
  // A lone cell is a drawn dot — an eye, a full stop. It has no edge to walk,
  // so it would vanish here, and a dropped dot is a hole in the drawing.
  for (const i of cells) if (deg(i) === 0) paths.push([{ x: i % w, y: (i - (i % w)) / w }]);
  return paths;
}

/** Turn a traced cell contour into a smooth mm path. */
export function contourToMm(loop, cov, smoothIters = 1) {
  let pts = loop.map(cov.toMm);
  pts = decimate(pts, cov.cell * 1.5);
  pts = smooth(pts, smoothIters, false);
  return decimate(pts, cov.cell * 2.5);
}
