import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { mazeSpec, mazeLayout, mazeMask, letterRect, mazeRoughMinutes, mazeSvg, seedFrom, rng } from '../src/gcode/maze.js';

const cfg = loadConfig({ exampleOnly: true });

const key = (c, r) => `${c},${r}`;
const wallKey = (a, b) => (a.c < b.c || (a.c === b.c && a.r < b.r)) ? `${a.c},${a.r}|${b.c},${b.r}` : `${b.c},${b.r}|${a.c},${a.r}`;

/** A small grid like the engine's, centred on the tray. */
function grid(outer, cell = 0.25) {
  const pad = Math.ceil(2 / cell);
  const w = Math.ceil(outer / cell) + pad * 2, h = w;
  const toCell = (p) => ({ x: (p.x + outer / 2) / cell + pad, y: (p.y + outer / 2) / cell + pad });
  const toMm = (c) => ({ x: (c.x - pad) * cell - outer / 2, y: (c.y - pad) * cell - outer / 2 });
  return { w, h, cell, pad, toCell, toMm };
}
const at = (mask, g, x, y) => { const c = g.toCell({ x, y }); return !!mask[Math.round(c.y) * g.w + Math.round(c.x)]; };

test('the spec derives the corridor from the tray, and refuses one the ball will not fit', () => {
  const sp = mazeSpec(cfg);
  assert.equal(sp.outer, 120);
  assert.equal(sp.cells, 9);
  assert.equal(sp.chamber, 3);
  // (120 - 2·2.7 - 8·1.8) / 9
  assert.ok(Math.abs(sp.corridor - (120 - 5.4 - 14.4) / 9) < 1e-9);
  assert.ok(sp.corridor >= sp.ball + 1);
  assert.equal(sp.floorLayers, 3, '1.2 mm of floor at 0.4 is three layers');
  assert.equal(sp.wallLayers, 15, '6 mm of wall at 0.4 is fifteen layers');
  assert.throws(() => mazeSpec({ ...cfg, maze: { ...cfg.maze, outerSize: 60 } }), /too narrow/);
  assert.throws(() => mazeSpec({ ...cfg, maze: { ...cfg.maze, chamberCells: 2 } }), /parity/);
});

test('every maze cell is reachable from the start, and by exactly one route', () => {
  for (const seed of [1, 2, 3, 17, 4242]) {
    const lay = mazeLayout(cfg, { seed });
    const N = lay.cells;
    // BFS over open walls, counting the edges used: a tree has cells-1 of them.
    const seen = new Set([key(lay.start.c, lay.start.r)]);
    const q = [lay.start];
    let edges = 0;
    while (q.length) {
      const cur = q.shift();
      for (const d of [{ dc: 1, dr: 0 }, { dc: -1, dr: 0 }, { dc: 0, dr: 1 }, { dc: 0, dr: -1 }]) {
        const n = { c: cur.c + d.dc, r: cur.r + d.dr };
        if (n.c < 0 || n.r < 0 || n.c >= N || n.r >= N || !lay.free.has(key(n.c, n.r))) continue;
        if (!lay.open.has(wallKey(cur, n))) continue;
        edges++;
        if (seen.has(key(n.c, n.r))) continue;
        seen.add(key(n.c, n.r));
        q.push(n);
      }
    }
    assert.equal(seen.size, lay.free.size, `seed ${seed}: every cell reachable`);
    // each open wall between maze cells is counted from both sides; the finish opening leads into the chamber and is not
    assert.equal(edges / 2, lay.free.size - 1, `seed ${seed}: a tree — no loops, no pockets`);
  }
});

test('the chamber opens onto the maze exactly once, and the solution ends there', () => {
  const lay = mazeLayout(cfg, { seed: 5 });
  const N = lay.cells, k = lay.chamber, i0 = (N - k) / 2, i1 = i0 + k;
  const inChamber = (c, r) => c >= i0 && c < i1 && r >= i0 && r < i1;
  let openings = 0;
  for (const w of lay.open) {
    const [a, b] = w.split('|').map((s) => { const [c, r] = s.split(',').map(Number); return { c, r }; });
    if (inChamber(a.c, a.r) !== inChamber(b.c, b.r)) openings++;
  }
  assert.equal(openings, 1);
  assert.ok(['left', 'right', 'top', 'bottom'].includes(lay.finish.side));
  assert.ok(inChamber(lay.finish.into.c, lay.finish.into.r));
  assert.ok(!inChamber(lay.finish.c, lay.finish.r));
  const last = lay.solution[lay.solution.length - 1];
  assert.deepEqual({ c: last.c, r: last.r }, { c: lay.finish.c, r: lay.finish.r });
  assert.deepEqual(lay.solution[0], { c: 0, r: 0 });
  assert.ok(lay.solution.length > N, 'the route is not a straight walk');
});

test('the same seed gives the same maze; a different seed a different one', () => {
  const a = mazeLayout(cfg, { seed: 99 }), b = mazeLayout(cfg, { seed: 99 }), c = mazeLayout(cfg, { seed: 100 });
  assert.deepEqual([...a.open].sort(), [...b.open].sort());
  assert.notDeepEqual([...a.open].sort(), [...c.open].sort());
  assert.equal(seedFrom('Kiara'), seedFrom('Kiara'));
  assert.notEqual(seedFrom('Kiara'), seedFrom('Kiaran'));
  const r = rng(7);
  for (let i = 0; i < 100; i++) { const v = r(); assert.ok(v >= 0 && v < 1); }
});

test('no wall floats: every standing wall connects back to the rim', () => {
  // The walls are drawn as one connected region later, so this is what makes
  // the near-vase print possible. Flood the wall mask from the rim and check
  // nothing is left.
  const lay = mazeLayout(cfg, { seed: 11 });
  const g = grid(lay.outer, 0.3);
  const mask = mazeMask(lay, g, 'wall');
  const seen = new Uint8Array(mask.length);
  const s = g.toCell({ x: 0, y: -lay.outer / 2 + lay.rimT / 2 });
  const stack = [Math.round(s.y) * g.w + Math.round(s.x)];
  assert.ok(mask[stack[0]], 'the rim is where we think');
  seen[stack[0]] = 1;
  while (stack.length) {
    const i = stack.pop();
    const x = i % g.w, y = (i - x) / g.w;
    for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
      const nx = x + dx, ny = y + dy;
      if (nx < 0 || ny < 0 || nx >= g.w || ny >= g.h) continue;
      const j = ny * g.w + nx;
      if (mask[j] && !seen[j]) { seen[j] = 1; stack.push(j); }
    }
  }
  let stray = 0;
  for (let i = 0; i < mask.length; i++) if (mask[i] && !seen[i]) stray++;
  assert.equal(stray, 0);
});

test('the masks: floor is solid but for the holes and the dimple, walls stand where the layout says', () => {
  const lay = mazeLayout(cfg, { seed: 2, letter: 'K' });
  const g = grid(lay.outer, 0.25);
  const floor = mazeMask(lay, g, 'floor'), top = mazeMask(lay, g, 'floorTop'), wall = mazeMask(lay, g, 'wall');
  // the chamber's centre: floor yes, wall no
  assert.ok(at(floor, g, 0, 0));
  assert.ok(!at(wall, g, 0, 0));
  // a lid hole goes through everything
  const h = lay.holes[0];
  assert.ok(!at(floor, g, h.x, h.y));
  assert.ok(!at(wall, g, h.x, h.y));
  // ...and sits in a boss that is solid on the wall layer
  assert.ok(at(wall, g, h.x + lay.spec.lid.holeD / 2 + 1, h.y));
  // the start dimple is only in the top floor layer
  const p = lay.startPocket;
  assert.ok(at(floor, g, p.x, p.y));
  assert.ok(!at(top, g, p.x, p.y));
  assert.ok(!at(wall, g, p.x, p.y), 'the start cell is a corridor');
  // the rim is a wall; just inside it is not, unless a wall lands there
  assert.ok(at(wall, g, 0, lay.outer / 2 - lay.rimT / 2));
  // every listed wall's midpoint is in the wall mask
  for (const w of lay.walls) assert.ok(at(wall, g, (w.a.x + w.b.x) / 2, (w.a.y + w.b.y) / 2));
  // the finish opening is clear: the point between the finish cell and the chamber
  const f = lay.cellCentre(lay.finish.c, lay.finish.r), into = lay.cellCentre(lay.finish.into.c, lay.finish.into.r);
  assert.ok(!at(wall, g, (f.x + into.x) / 2, (f.y + into.y) / 2));
  // the letter area is inside the chamber
  const lr = letterRect(lay);
  assert.ok(lr.x0 > lay.chamberRect.x0 && lr.x1 < lay.chamberRect.x1);
  // the picture mentions the letter
  assert.match(mazeSvg(lay), />K</);
});

test('the rough estimate is flow-bound: a bigger nozzle does not change it, a smaller tray does', () => {
  const big = mazeRoughMinutes(mazeLayout(cfg, { seed: 1 }), cfg);
  const fine = mazeRoughMinutes(mazeLayout({ ...cfg, maze: { ...cfg.maze, layerHeight: 0.2, firstLayerHeight: 0.2, lineWidth: 0.42 } }, { seed: 1 }), cfg);
  assert.ok(Math.abs(big.minutes - fine.minutes) < 0.5, `${big.minutes} vs ${fine.minutes}`);
  const small = mazeRoughMinutes(mazeLayout({ ...cfg, maze: { ...cfg.maze, outerSize: 80, cells: 7 } }, { seed: 1 }), cfg);
  assert.ok(small.minutes < big.minutes * 0.6, `${small.minutes} vs ${big.minutes}`);
  assert.ok(big.grams > 20 && big.grams < 60, `${big.grams} g`);
});
