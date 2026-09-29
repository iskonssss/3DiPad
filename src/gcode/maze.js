// The name maze — a third product on the same engine. Part 1: the layout.
//
// A square tray with rounded corners, a ball-bearing maze inside it, and a
// centre chamber whose floor carries the customer's initial (later: their
// whole name) inlaid in the second colour by a colour swap. A laser-cut clear
// acrylic lid (a standard part) sits on top, located by four corner holes.
// Pictured in the owner's reference photo: a blue tray, thick walls about as
// wide as the corridors, a black letter in the centre square, a 5 mm ball
// resting in the bottom-left corner, four holes in the corners.
//
// This file is the LAYOUT: where the walls are, in mm, before any g-code. The
// body is fixed and parametric (config.example.json, "maze"); the maze pattern
// is random per print but reproducible from a seed, so a design saved with its
// seed prints the same maze again, and a test can pin one down.
//
//   mazeSpec(cfg)              the resolved numbers
//   mazeLayout(cfg, opts)      the grid, the walls as mm segments, the solution
//   mazeMask(layout, g, kind)  a layer as a coverage mask: 'floor' | 'floorTop' | 'wall'
//   letterRect(layout)         where the initial goes (chamber floor, inset)
//   mazeRoughMinutes(layout)   a first print-time figure, from plastic volume
//   mazeSvg(layout)            a picture, for tools/maze-preview.mjs
//
// The grid. N×N cells; a cell is a corridor square `corridor` wide and inner
// walls are `wallT` thick, so the pitch is corridor + wallT; the rim is its
// own wall, `rimT` thick. The chamber is the k×k block of cells in the middle
// (same parity as N, so it centres) with no walls inside it, walled all round
// except for ONE opening, the finish. The ball starts in a corner cell, in a
// shallow dimple in the floor that holds it still until the game starts.
//
// The maze is a spanning tree of the free cells (recursive backtracker) with
// the chamber hung off it by its one opening, so there is exactly one route
// from start to finish and no pocket a ball can be trapped in. A spanning
// tree of cells means the WALLS are a forest whose every piece touches the
// rim — nothing floats — which is what lets the whole wall layer be drawn as
// one continuous loop later (the near-vase print the owner asked about).

import { fillPolygon } from './outline.js';

/** The resolved numbers for the maze tray. config.example.json documents them. */
export function mazeSpec(cfg) {
  const m = cfg.maze || {};
  const lid = m.lid || {};
  const layerH = m.layerHeight ?? 0.4;
  const first = m.firstLayerHeight ?? layerH;
  const outer = m.outerSize ?? 120;
  const wallT = m.wallThickness ?? 1.8;
  const rimT = m.rimThickness ?? 2.7;
  const cells = Math.max(3, m.cells ?? 9);
  const chamber = Math.max(1, Math.min(cells - 2, m.chamberCells ?? 3));
  // The chamber must centre on the grid: both odd or both even.
  if ((cells - chamber) % 2 !== 0) {
    throw new Error(`maze.chamberCells (${chamber}) must have the same parity as maze.cells (${cells}) to sit in the middle`);
  }
  // inner = N·corridor + (N−1)·wallT
  const inner = outer - 2 * rimT;
  const corridor = (inner - (cells - 1) * wallT) / cells;
  const ball = m.ballDiameter ?? 5;
  if (corridor < ball + 1) {
    throw new Error(`maze: ${cells} cells on a ${outer} mm tray leaves a ${corridor.toFixed(2)} mm corridor, too narrow for a ${ball} mm ball (needs ${ball + 1})`);
  }
  const floor = m.floorThickness ?? 1.2;
  const wallH = m.wallHeight ?? 6;
  const floorLayers = Math.max(2, Math.round((floor - first) / layerH) + 1);
  const wallLayers = Math.max(1, Math.round(wallH / layerH));
  return {
    outer, rimT, wallT, cells, chamber, corridor, pitch: corridor + wallT, inner, ball,
    cornerR: m.cornerRadius ?? 6,
    floor, wallH, layerH, first, floorLayers, wallLayers, layers: floorLayers + wallLayers,
    lineWidth: m.lineWidth ?? 0.9,
    beadModel: m.beadModel ?? 'rounded',
    start: m.start ?? 'bottom-left',
    // The start dimple: a disc this much wider than the ball, this many layers deep, in the floor.
    pocketClearance: m.startPocketClearance ?? 1.0,
    pocketLayers: Math.max(1, m.startPocketLayers ?? 1),
    // How many layers deep the initial is inlaid into the chamber floor.
    colourLayers: Math.max(1, m.colourLayers ?? 1),
    // The letter keeps this far inside the chamber's walls.
    letterMargin: m.letterMargin ?? 2,
    lid: {
      holeD: lid.holeDiameter ?? 3.2,
      inset: lid.holeInset ?? 4.0,      // hole centre, in from both edges
      bossR: lid.bossRadius ?? 3.4,     // solid round boss around each hole, merged into the rim
      throughFloor: lid.throughFloor ?? true,
    },
    maxFlow: m.maxVolumetricMmps ?? cfg.speed?.maxVolumetricMmps ?? 12,
    swapMinutes: m.swapMinutes ?? 1.0,
    maxPrintMinutes: m.maxPrintMinutes ?? 30,
    warnPrintMinutes: m.warnPrintMinutes ?? 25,
  };
}

// ---------------------------------------------------------------------------
// A small seeded PRNG so a maze is reproducible from its seed (mulberry32).

export function rng(seed) {
  let a = (seed >>> 0) || 0x9e3779b9;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** A seed from a name, so the same name gets the same maze until reprinted with another. */
export function seedFrom(text) {
  let h = 2166136261;
  for (const ch of String(text || '')) { h ^= ch.codePointAt(0); h = Math.imul(h, 16777619); }
  return h >>> 0;
}

// ---------------------------------------------------------------------------

const CORNERS = {
  'bottom-left': (N) => ({ c: 0, r: 0 }),
  'bottom-right': (N) => ({ c: N - 1, r: 0 }),
  'top-left': (N) => ({ c: 0, r: N - 1 }),
  'top-right': (N) => ({ c: N - 1, r: N - 1 }),
};
const DIRS = [{ dc: 1, dr: 0 }, { dc: -1, dr: 0 }, { dc: 0, dr: 1 }, { dc: 0, dr: -1 }];
const key = (c, r) => `${c},${r}`;
const wallKey = (a, b) => (a.c < b.c || (a.c === b.c && a.r < b.r)) ? `${a.c},${a.r}|${b.c},${b.r}` : `${b.c},${b.r}|${a.c},${a.r}`;

/**
 * Lay out one maze.
 *
 * opts.seed    any integer; the same seed gives the same maze (default 1)
 * opts.start   'bottom-left' | 'bottom-right' | 'top-left' | 'top-right'
 * opts.letter  the initial, carried through to the picture
 *
 * Returns, all in tray-centred mm (y up, as the plate is):
 *   spec, seed, cells, chamber, corridor, wallT, rimT, pitch, outer
 *   free         Set of "c,r" keys: the maze cells (not the chamber)
 *   open         Set of wall keys that are knocked out (including the finish)
 *   walls        [{ a, b, dir }] centrelines of every standing inner wall,
 *                including the chamber's walls
 *   chamberRect  { x0, y0, x1, y1 } the chamber's floor (corridor edges)
 *   start        { c, r }; startPocket { x, y, r }
 *   finish       { c, r, side } the maze cell the chamber opens onto
 *   solution     [{ c, r }] the route, ending at the finish cell
 *   holes        [{ x, y, r }] the four lid holes
 *   cellCentre(c, r) → { x, y }
 */
export function mazeLayout(cfg, opts = {}) {
  const sp = mazeSpec(cfg);
  const N = sp.cells, k = sp.chamber;
  const seed = Number.isFinite(+opts.seed) ? +opts.seed : 1;
  const random = rng(seed);
  const startName = CORNERS[opts.start || sp.start] ? (opts.start || sp.start) : 'bottom-left';

  const i0 = (N - k) / 2, i1 = i0 + k;   // chamber cells: i0 <= c < i1, i0 <= r < i1
  const inChamber = (c, r) => c >= i0 && c < i1 && r >= i0 && r < i1;
  const inGrid = (c, r) => c >= 0 && r >= 0 && c < N && r < N;

  const free = new Set();
  for (let r = 0; r < N; r++) for (let c = 0; c < N; c++) if (!inChamber(c, r)) free.add(key(c, r));

  // Recursive backtracker over the free cells.
  const open = new Set();
  const start = CORNERS[startName](N);
  const visited = new Set([key(start.c, start.r)]);
  const stack = [start];
  while (stack.length) {
    const cur = stack[stack.length - 1];
    const next = DIRS
      .map((d) => ({ c: cur.c + d.dc, r: cur.r + d.dr }))
      .filter((n) => inGrid(n.c, n.r) && free.has(key(n.c, n.r)) && !visited.has(key(n.c, n.r)));
    if (!next.length) { stack.pop(); continue; }
    const n = next[Math.floor(random() * next.length)];
    open.add(wallKey(cur, n));
    visited.add(key(n.c, n.r));
    stack.push(n);
  }
  if (visited.size !== free.size) throw new Error('maze: the chamber cuts the grid in two');   // cannot happen with k <= N-2

  // The finish: the chamber opens onto the maze cell the maze makes hardest
  // to reach, on whichever side that cell sits.
  const candidates = [];
  for (const f of free) {
    const [c, r] = f.split(',').map(Number);
    if (r >= i0 && r < i1 && c === i0 - 1) candidates.push({ c, r, side: 'left', into: { c: i0, r } });
    if (r >= i0 && r < i1 && c === i1) candidates.push({ c, r, side: 'right', into: { c: i1 - 1, r } });
    if (c >= i0 && c < i1 && r === i0 - 1) candidates.push({ c, r, side: 'bottom', into: { c, r: i0 } });
    if (c >= i0 && c < i1 && r === i1) candidates.push({ c, r, side: 'top', into: { c, r: i1 - 1 } });
  }
  const dist = distances(start, free, open, N);
  candidates.sort((p, q) => (dist.get(key(q.c, q.r)) ?? -1) - (dist.get(key(p.c, p.r)) ?? -1));
  const finish = candidates[0];
  open.add(wallKey(finish, finish.into));

  const solution = pathTo(start, finish, free, open, N);

  // Geometry. Cell (0,0) is bottom-left. The corridor of cell c spans
  // x0 + c·pitch .. x0 + c·pitch + corridor, where x0 is the inner edge of the rim.
  const half = sp.outer / 2;
  const x0 = -half + sp.rimT;
  const lo = (i) => x0 + i * sp.pitch;               // low edge of corridor i
  const hi = (i) => lo(i) + sp.corridor;             // high edge of corridor i
  const wallMid = (i) => hi(i) + sp.wallT / 2;       // centreline of the wall after corridor i
  const cellCentre = (c, r) => ({ x: lo(c) + sp.corridor / 2, y: lo(r) + sp.corridor / 2 });

  // Every standing inner wall as a centreline segment, running a full pitch
  // so neighbouring walls overlap at their corners. A wall between two
  // chamber cells does not exist; a wall between a chamber cell and a maze
  // cell stands unless it is the finish.
  const walls = [];
  for (let r = 0; r < N; r++) {
    for (let c = 0; c < N; c++) {
      if (c + 1 < N) {   // wall to the right of (c, r)
        const a = { c, r }, b = { c: c + 1, r };
        if (!(inChamber(a.c, a.r) && inChamber(b.c, b.r)) && !open.has(wallKey(a, b))) {
          walls.push({ a: { x: wallMid(c), y: lo(r) - sp.wallT / 2 }, b: { x: wallMid(c), y: hi(r) + sp.wallT / 2 }, dir: 'v' });
        }
      }
      if (r + 1 < N) {   // wall above (c, r)
        const a = { c, r }, b = { c, r: r + 1 };
        if (!(inChamber(a.c, a.r) && inChamber(b.c, b.r)) && !open.has(wallKey(a, b))) {
          walls.push({ a: { x: lo(c) - sp.wallT / 2, y: wallMid(r) }, b: { x: hi(c) + sp.wallT / 2, y: wallMid(r) }, dir: 'h' });
        }
      }
    }
  }

  const chamberRect = { x0: lo(i0), y0: lo(i0), x1: hi(i1 - 1), y1: hi(i1 - 1) };
  const trayRect = { x0: -half, y0: -half, x1: half, y1: half, r: sp.cornerR };
  const hx = half - sp.lid.inset;
  const holes = [{ x: -hx, y: -hx }, { x: hx, y: -hx }, { x: hx, y: hx }, { x: -hx, y: hx }].map((p) => ({ ...p, r: sp.lid.holeD / 2 }));

  // The start dimple. The ball rests in a corner cell, and the lid's corner
  // boss bulges into that cell's outer corner; the dimple sits at the cell's
  // centre pushed diagonally inward until the ball clears the boss, as far as
  // the cell allows. Past that the tray is too small for both, and it is
  // better to hear so now than to print a ball that cannot sit still.
  const sc = cellCentre(start.c, start.r);
  const pocketR = (sp.ball + sp.pocketClearance) / 2;
  const hole = holes.reduce((best, h) => (Math.hypot(h.x - sc.x, h.y - sc.y) < Math.hypot(best.x - sc.x, best.y - sc.y) ? h : best));
  const need = sp.ball / 2 + sp.lid.bossR + 0.25;
  const inward = { x: Math.sign(-sc.x) || 1, y: Math.sign(-sc.y) || 1 };   // towards the tray's centre
  const maxShift = Math.max(0, sp.corridor / 2 - pocketR);              // keep the dimple inside the cell
  let shift = 0;
  const gap = () => Math.hypot(sc.x + inward.x * shift - hole.x, sc.y + inward.y * shift - hole.y);
  while (gap() < need && shift < maxShift) shift = Math.min(maxShift, shift + 0.1);
  if (gap() < need) {
    throw new Error(`maze: the lid's corner boss (r ${sp.lid.bossR} at ${sp.lid.inset} in) reaches the ball's start; ${sp.corridor.toFixed(1)} mm corridors are too narrow for both — fewer cells, a bigger tray, or a smaller lid.bossRadius`);
  }
  const startPocket = { x: sc.x + inward.x * shift, y: sc.y + inward.y * shift, r: pocketR };

  return {
    spec: sp, seed, letter: opts.letter || '', cells: N, chamber: k, corridor: sp.corridor, wallT: sp.wallT, rimT: sp.rimT, pitch: sp.pitch, outer: sp.outer,
    free, open, walls, chamberRect, trayRect, start, startPocket, finish, solution, holes, cellCentre,
    innerWallLength: walls.reduce((s, w) => s + Math.hypot(w.b.x - w.a.x, w.b.y - w.a.y), 0),
  };
}

/** BFS distances from `from` over open walls. */
function distances(from, free, open, N) {
  const dist = new Map([[key(from.c, from.r), 0]]);
  const q = [from];
  while (q.length) {
    const cur = q.shift();
    const d = dist.get(key(cur.c, cur.r));
    for (const dd of DIRS) {
      const n = { c: cur.c + dd.dc, r: cur.r + dd.dr };
      if (n.c < 0 || n.r < 0 || n.c >= N || n.r >= N || !free.has(key(n.c, n.r))) continue;
      if (!open.has(wallKey(cur, n)) || dist.has(key(n.c, n.r))) continue;
      dist.set(key(n.c, n.r), d + 1);
      q.push(n);
    }
  }
  return dist;
}

/** The route from `from` to `to` (a tree, so it is unique). */
function pathTo(from, to, free, open, N) {
  const prev = new Map([[key(from.c, from.r), null]]);
  const q = [from];
  while (q.length) {
    const cur = q.shift();
    if (cur.c === to.c && cur.r === to.r) break;
    for (const dd of DIRS) {
      const n = { c: cur.c + dd.dc, r: cur.r + dd.dr };
      if (n.c < 0 || n.r < 0 || n.c >= N || n.r >= N || !free.has(key(n.c, n.r))) continue;
      if (!open.has(wallKey(cur, n)) || prev.has(key(n.c, n.r))) continue;
      prev.set(key(n.c, n.r), cur);
      q.push(n);
    }
  }
  if (!prev.has(key(to.c, to.r))) return [];
  const path = [];
  for (let at = to; at; at = prev.get(key(at.c, at.r))) path.push({ c: at.c, r: at.r });
  return path.reverse();
}

// ---------------------------------------------------------------------------
// Rasterising, in the same grid the engine's coverage masks use.

function union(mask, m) { for (let i = 0; i < mask.length; i++) if (m[i]) mask[i] = 1; }
function subtract(mask, m) { for (let i = 0; i < mask.length; i++) if (m[i]) mask[i] = 0; }
function rectMask(g, x0, y0, x1, y1) {
  return fillPolygon([{ x: x0, y: y0 }, { x: x1, y: y0 }, { x: x1, y: y1 }, { x: x0, y: y1 }].map(g.toCell), g.w, g.h);
}
function discMask(g, cx, cy, r, n = 48) {
  const pts = [];
  for (let i = 0; i < n; i++) { const a = (i / n) * 2 * Math.PI; pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) }); }
  return fillPolygon(pts.map(g.toCell), g.w, g.h);
}

/** A rounded rectangle outline, tray-centred mm, counter-clockwise. */
export function roundedRectPoly(x0, y0, x1, y1, r, seg = 12) {
  const pts = [];
  const corners = [
    { cx: x1 - r, cy: y1 - r, a0: 0 }, { cx: x0 + r, cy: y1 - r, a0: Math.PI / 2 },
    { cx: x0 + r, cy: y0 + r, a0: Math.PI }, { cx: x1 - r, cy: y0 + r, a0: (3 * Math.PI) / 2 },
  ];
  for (const c of corners) {
    for (let i = 0; i <= seg; i++) {
      const a = c.a0 + (i / seg) * (Math.PI / 2);
      pts.push({ x: c.cx + r * Math.cos(a), y: c.cy + r * Math.sin(a) });
    }
  }
  return pts;
}

/**
 * One layer of the tray as a mask. `g` is a grid like the engine's
 * ({ w, h, cell, pad, toCell, toMm }) whose origin is the tray's centre.
 *
 *   'floor'     the whole plate, less the lid holes if they go through
 *   'floorTop'  the floor's last layer(s): the same, less the start dimple
 *   'wall'      rim + corner bosses + inner walls + chamber walls, less the holes
 */
export function mazeMask(layout, g, kind = 'wall') {
  const { spec: sp, trayRect: t } = layout;
  const mask = new Uint8Array(g.w * g.h);
  const outer = fillPolygon(roundedRectPoly(t.x0, t.y0, t.x1, t.y1, t.r).map(g.toCell), g.w, g.h);

  if (kind === 'floor' || kind === 'floorTop') {
    union(mask, outer);
    if (sp.lid.throughFloor) for (const h of layout.holes) subtract(mask, discMask(g, h.x, h.y, h.r));
    if (kind === 'floorTop') subtract(mask, discMask(g, layout.startPocket.x, layout.startPocket.y, layout.startPocket.r));
    return mask;
  }

  // The rim: the rounded outer outline minus the rounded inner outline.
  const rIn = Math.max(0.2, t.r - sp.rimT);
  const inner = fillPolygon(roundedRectPoly(t.x0 + sp.rimT, t.y0 + sp.rimT, t.x1 - sp.rimT, t.y1 - sp.rimT, rIn).map(g.toCell), g.w, g.h);
  for (let i = 0; i < mask.length; i++) if (outer[i] && !inner[i]) mask[i] = 1;

  // Corner bosses around the lid holes, clipped to the tray.
  for (const h of layout.holes) {
    const boss = discMask(g, h.x, h.y, sp.lid.bossR);
    for (let i = 0; i < mask.length; i++) if (boss[i] && outer[i]) mask[i] = 1;
  }

  // Inner walls: each centreline widened to wallT.
  const hw = sp.wallT / 2;
  for (const w of layout.walls) {
    if (w.dir === 'v') union(mask, rectMask(g, w.a.x - hw, w.a.y, w.a.x + hw, w.b.y));
    else union(mask, rectMask(g, w.a.x, w.a.y - hw, w.b.x, w.a.y + hw));
  }

  for (const h of layout.holes) subtract(mask, discMask(g, h.x, h.y, h.r));
  return mask;
}

/** The chamber floor where the initial goes: the chamber inset by letterMargin. */
export function letterRect(layout) {
  const c = layout.chamberRect;
  const m = layout.spec.letterMargin;
  return { x0: c.x0 + m, y0: c.y0 + m, x1: c.x1 - m, y1: c.y1 - m };
}

// ---------------------------------------------------------------------------
// A first print-time figure, and a picture.

/**
 * How long, roughly, before any g-code exists.
 *
 * On this printer the hotend is the limit, not the motion: it melts about
 * 12 mm³/s of PLA whatever the nozzle, and every extruding move is slowed to
 * fit (speed.maxVolumetricMmps). So the honest first estimate is plastic
 * VOLUME over that flow, plus a share for turns and travels, plus the
 * start-up and one colour swap. Nozzle size changes how many lines a wall
 * takes, not how much plastic it is; what a bigger nozzle buys is fewer
 * turns and taller layers, which is the overhead term, not the volume term.
 *
 * Returns minutes and the volumes, so a tray size can be judged for an
 * event. The generator's own estimate replaces this once it exists.
 */
export function mazeRoughMinutes(layout, cfg = {}) {
  const sp = layout.spec;
  const trayArea = sp.outer * sp.outer - (4 - Math.PI) * sp.cornerR * sp.cornerR;
  const holeArea = layout.holes.length * Math.PI * sp.lid.holeD * sp.lid.holeD / 4;
  const floorVol = (trayArea - (sp.lid.throughFloor ? holeArea : 0)) * (sp.first + (sp.floorLayers - 1) * sp.layerH);
  const rimLen = 4 * (sp.outer - 2 * sp.cornerR) + 2 * Math.PI * (sp.cornerR - sp.rimT / 2);
  const bossArea = layout.holes.length * (Math.PI * sp.lid.bossR * sp.lid.bossR * 0.55 - Math.PI * sp.lid.holeD * sp.lid.holeD / 4);
  const wallArea = rimLen * sp.rimT + layout.innerWallLength * sp.wallT + Math.max(0, bossArea);
  const wallVol = wallArea * sp.wallLayers * sp.layerH;
  const flow = sp.maxFlow;
  const overhead = 1.3;   // accelerating into every turn, travels between walls
  const startup = 2.5;    // heat, level, purge
  const floorMin = (floorVol / flow / 60) * overhead;
  const wallMin = (wallVol / flow / 60) * overhead;
  return {
    minutes: floorMin + wallMin + startup + sp.swapMinutes,
    floorMinutes: floorMin, wallMinutes: wallMin,
    floorVol, wallVol, grams: ((floorVol + wallVol) * 1.24) / 1000,
  };
}

/** An SVG of the layout: rim, walls, chamber, letter area, lid holes, start ball, finish, and the solution faintly. */
export function mazeSvg(layout, { solution = true } = {}) {
  const sp = layout.spec, t = layout.trayRect;
  const pad = 4, S = 4;   // px per mm
  const W = (sp.outer + 2 * pad) * S;
  const X = (x) => ((x + sp.outer / 2 + pad) * S).toFixed(1);
  const Y = (y) => ((sp.outer / 2 - y + pad) * S).toFixed(1);
  const rect = (x0, y0, x1, y1, fill, extra = '') => `<rect x="${X(x0)}" y="${Y(y1)}" width="${((x1 - x0) * S).toFixed(1)}" height="${((y1 - y0) * S).toFixed(1)}" fill="${fill}" ${extra}/>`;
  const WALL = '#4da3e8', FLOOR = '#2f78b8';
  const out = [];
  out.push(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${W}" width="${W}" height="${W}">`);
  out.push(`<rect width="${W}" height="${W}" fill="#fff"/>`);
  out.push(rect(t.x0, t.y0, t.x1, t.y1, WALL, `rx="${t.r * S}"`));
  const rIn = Math.max(0.2, t.r - sp.rimT);
  out.push(rect(t.x0 + sp.rimT, t.y0 + sp.rimT, t.x1 - sp.rimT, t.y1 - sp.rimT, FLOOR, `rx="${rIn * S}"`));
  for (const h of layout.holes) out.push(`<circle cx="${X(h.x)}" cy="${Y(h.y)}" r="${sp.lid.bossR * S}" fill="${WALL}"/>`);
  const hw = sp.wallT / 2;
  for (const w of layout.walls) {
    if (w.dir === 'v') out.push(rect(w.a.x - hw, w.a.y, w.a.x + hw, w.b.y, WALL));
    else out.push(rect(w.a.x, w.a.y - hw, w.b.x, w.a.y + hw, WALL));
  }
  for (const h of layout.holes) out.push(`<circle cx="${X(h.x)}" cy="${Y(h.y)}" r="${h.r * S}" fill="#fff"/>`);
  const lr = letterRect(layout);
  out.push(rect(lr.x0, lr.y0, lr.x1, lr.y1, 'none', 'stroke="#222" stroke-dasharray="3 3" stroke-width="1"'));
  const cx = (lr.x0 + lr.x1) / 2, cy = (lr.y0 + lr.y1) / 2, fs = (lr.y1 - lr.y0) * S * 0.95;
  const letter = String(layout.letter || 'M').replace(/[<>&]/g, '');
  out.push(`<text x="${X(cx)}" y="${Y(cy)}" font-family="Arial Black, Arial, sans-serif" font-weight="900" font-size="${fs.toFixed(0)}" fill="#111" text-anchor="middle" dominant-baseline="central">${letter}</text>`);
  if (solution && layout.solution.length > 1) {
    const cells = [...layout.solution, layout.finish.into];
    const d = cells.map((cell, i) => { const p = layout.cellCentre(cell.c, cell.r); return `${i ? 'L' : 'M'}${X(p.x)} ${Y(p.y)}`; }).join(' ');
    out.push(`<path d="${d}" fill="none" stroke="#ffd54a" stroke-width="2" stroke-opacity="0.75" stroke-linejoin="round"/>`);
  }
  const sp0 = layout.startPocket;
  out.push(`<circle cx="${X(sp0.x)}" cy="${Y(sp0.y)}" r="${(sp0.r * S).toFixed(1)}" fill="#255f94"/>`);
  out.push(`<circle cx="${X(sp0.x)}" cy="${Y(sp0.y)}" r="${((sp.ball / 2) * S).toFixed(1)}" fill="#ddd" stroke="#666" stroke-width="1"/>`);
  out.push('</svg>');
  return out.join('\n');
}

/**
 * The layout as plain data for a preview page: every mm number it needs to
 * draw the tray in 3D, none of the Sets and closures.
 */
export function mazeLayoutJson(layout, cfg = {}) {
  const sp = layout.spec;
  const t = mazeRoughMinutes(layout, cfg);
  const c = (cell) => layout.cellCentre(cell.c, cell.r);
  return {
    letter: layout.letter, seed: layout.seed,
    outer: sp.outer, cornerR: sp.cornerR, rimT: sp.rimT, wallT: sp.wallT, cells: sp.cells, chamber: sp.chamber, corridor: +sp.corridor.toFixed(3),
    floor: sp.floor, wallH: sp.wallH, layerH: sp.layerH, ball: sp.ball,
    pocketDepth: sp.pocketLayers * sp.layerH, colourLayers: sp.colourLayers,
    lid: { ...sp.lid },
    walls: layout.walls.map((w) => ({ a: w.a, b: w.b, dir: w.dir })),
    chamberRect: layout.chamberRect, letterRect: letterRect(layout), holes: layout.holes, startPocket: layout.startPocket,
    start: c(layout.start), finish: c(layout.finish), into: c(layout.finish.into), finishSide: layout.finish.side,
    solution: [...layout.solution, layout.finish.into].map(c),
    innerWallMm: Math.round(layout.innerWallLength),
    rough: { minutes: +t.minutes.toFixed(1), floorMinutes: +t.floorMinutes.toFixed(1), wallMinutes: +t.wallMinutes.toFixed(1), grams: +t.grams.toFixed(1), flow: sp.maxFlow },
  };
}
