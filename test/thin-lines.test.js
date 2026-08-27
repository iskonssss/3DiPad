// A drawn line narrower than two beads must be printed as ONE pass down its
// middle. These tests measure the file, not the intent: what matters is how
// much plastic lands in a given area, and how many times the nozzle goes over
// it.

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { imageCoverage } from '../src/gcode/image.js';
import { shapePolygon } from '../src/gcode/geometry.js';
import { skeletonize, skeletonPaths, pruneSpurs } from '../src/gcode/fill.js';

const cfg = loadConfig({ exampleOnly: true });
const XS = Math.PI * (cfg.build.filamentDiameter / 2) ** 2;
const N = 1000;

function bitmap(w, h, fn) {
  const ink = new Uint8Array(w * h);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) if (fn(x, y)) ink[y * w + x] = 1;
  return { w, h, ink };
}
function pack(bm) {
  const n = bm.w * bm.h, b = new Uint8Array(Math.ceil(n / 8));
  for (let i = 0; i < n; i++) if (bm.ink[i]) b[i >> 3] |= 1 << (7 - (i & 7));
  return { w: bm.w, h: bm.h, data: Buffer.from(b).toString('base64') };
}

/** Everything the design section actually lays down. */
function designStats(bm, shape = 'square') {
  const { poly, bbox } = shapePolygon(shape, cfg, null);
  const cov = imageCoverage(bm, cfg, bbox, poly, null, cfg.build.designEdgeMargin);
  let cells = 0;
  if (cov) for (let i = 0; i < cov.mask.length; i++) if (cov.mask[i]) cells++;
  const area = cells * (cov ? cov.cell * cov.cell : 0);
  const { gcode } = generate(
    { shape, colours: { layer1: 'BLACK', layer2: 'BLUE' }, holePos: 'none', design: [], image: pack(bm) }, cfg);

  let inD = false, e = 0, len = 0, px = null, py = null, maxBead = 0;
  for (const l of gcode.split('\n')) {
    if (l.includes('DESIGN (colour 2)')) inD = true;
    if (!l.startsWith('G1 ')) continue;
    const mx = /X(-?[\d.]+)/.exec(l), my = /Y(-?[\d.]+)/.exec(l), me = /E([\d.]+)/.exec(l);
    const x = mx ? +mx[1] : px, y = my ? +my[1] : py;
    // Only moves that lay plastic. A bare E is a retract, and counting those
    // made every one of these numbers meaningless the first time round.
    if (inD && me && (mx || my) && px !== null) {
      const L = Math.hypot(x - px, y - py);
      e += +me[1]; len += L;
      if (L > 0.05) maxBead = Math.max(maxBead, (+me[1]) * XS / (L * cfg.build.layerHeight));
    }
    px = x; py = y;
  }
  const layers = cfg.build.designLayers;
  return {
    area, gcode, maxBead,
    lenPerLayer: len / layers,
    volume: e * XS,
    expected: area * layers * cfg.build.layerHeight,
    onePass: gcode.includes('single bead'),
  };
}

test('a thin line is drawn once down its middle, not up one side and back', () => {
  // The failure: the design outline traces the BOUNDARY of whatever it is
  // given. On a line that boundary runs up one side and back down the other, a
  // fraction of a millimetre apart, each pass laying a full bead — 1.48x the
  // plastic the space can hold, which prints as a raised, blobby line.
  const line = bitmap(N, N, (_x, y) => y === 500);
  const s = designStats(line);
  assert.ok(s.onePass, 'a hairline should be drawn as a single bead');

  // One pass covers the line's length once. Two passes cover it twice, and that
  // is the whole difference — so the path length is the honest test.
  const lineLen = s.area / 0.6;                       // area / its printed width
  assert.ok(s.lenPerLayer < lineLen * 1.35,
    `path is ${s.lenPerLayer.toFixed(0)}mm for a ${lineLen.toFixed(0)}mm line — it is being drawn more than once`);
});

test('a thin line gets the plastic its area holds, no more', () => {
  const line = bitmap(N, N, (_x, y) => y === 500);
  const s = designStats(line);
  const ratio = s.volume / s.expected;
  assert.ok(ratio > 0.8 && ratio < 1.15,
    `extruded ${ratio.toFixed(2)}x what the line has room for`);
});

test('a stroke too wide for one bead is still drawn as two adjacent lines', () => {
  // 0.8mm is two beads side by side and always has been. Sending it down the
  // middle as a single 0.8mm bead is what a 0.4mm nozzle cannot do: laid in one
  // pass it came off a real print lumpy and domed.
  const band = bitmap(N, N, (_x, y) => Math.abs(y - 500) <= (0.8 / 60 * N) / 2);
  const s = designStats(band);
  assert.ok(!s.onePass, 'a 0.8mm stroke should be two lines, not one wide bead');
  const ratio = s.volume / s.expected;
  assert.ok(ratio < 1.25, `extruded ${ratio.toFixed(2)}x into a 0.8mm stroke`);
});

test('no bead is ever wider than the nozzle can lay', () => {
  // The ceiling every line in the file respects, design included. Worth its own
  // test because the width correction is a multiplier, and a multiplier applied
  // after the clamp quietly put 0.82mm beads in a file whose limit is 0.56.
  const cases = [
    bitmap(N, N, (_x, y) => y === 500),
    bitmap(N, N, (_x, y) => Math.abs(y - 500) <= (0.8 / 60 * N) / 2),
    bitmap(N, N, (x, y) => Math.hypot(x - 500, y - 500) < 200),
    bitmap(N, N, (x, y) => { const d = Math.hypot(x - 500, y - 500); return d > 200 && d < 210; }),
  ];
  const cap = cfg.build.lineWidth * 1.25;
  for (const [i, bm] of cases.entries()) {
    const s = designStats(bm);
    assert.ok(s.maxBead <= cap + 1e-6,
      `case ${i}: laid a ${s.maxBead.toFixed(2)}mm bead, over the ${cap.toFixed(2)}mm ceiling`);
  }
});

test('a drawn ring is one continuous run, not a pile of fragments', () => {
  // A one-cell-wide curve that is not axis-aligned is a staircase, and every
  // step of it touches three cells on an 8-connected grid. Read as junctions,
  // a plain circle became 27 separate runs needing 27 retractions — a great
  // deal of stringing to draw one line.
  const ring = bitmap(N, N, (x, y) => { const d = Math.hypot(x - 500, y - 500); return d > 200 && d < 204; });
  const { gcode } = generate(
    { shape: 'square', colours: { layer1: 'BLACK', layer2: 'BLUE' }, holePos: 'none', design: [], image: pack(ring) }, cfg);
  const design = gcode.slice(gcode.indexOf('DESIGN (colour 2)'));
  const retracts = (design.match(/^G1 E-/gm) || []).length;
  assert.ok(retracts <= 8, `${retracts} retractions to draw one ring`);
});

test('walking the skeleton visits every part of it — no stroke is dropped', () => {
  // The walk consumes EDGES, not cells, so a junction is passed through once
  // per arm. Consuming cells instead abandons every branch after the first,
  // which silently loses most of a drawing — the failure mode that matters
  // most here, because the file still looks perfectly valid.
  const { poly, bbox } = shapePolygon('square', cfg, null);
  const y = bitmap(N, N, (x, py) => {
    const stem = Math.abs(x - 500) < 2 && py > 500 && py < 850;
    const a = Math.abs((x - 500) - (py - 500)) < 2 && py > 250 && py <= 500;
    const b = Math.abs((x - 500) + (py - 500)) < 2 && py > 250 && py <= 500;
    return stem || a || b;
  });
  const cov = imageCoverage(y, cfg, bbox, poly, null, cfg.build.designEdgeMargin);
  const spur = Math.max(2, Math.round(cfg.build.lineWidth / cov.cell));
  const skel = pruneSpurs(skeletonize(cov.mask, cov.w, cov.h), cov.w, cov.h, spur);

  let skelCells = 0;
  for (let i = 0; i < skel.length; i++) if (skel[i]) skelCells++;
  const seen = new Set();
  for (const p of skeletonPaths(skel, cov.w, cov.h)) for (const c of p) seen.add(c.y * cov.w + c.x);
  assert.equal(seen.size, skelCells,
    `walked ${seen.size} of ${skelCells} skeleton cells — the rest would never be printed`);
});

test('a closed loop with no endpoint is still walked', () => {
  // Seeding only from loose ends and junctions misses a shape that has
  // neither. A drawn "O" is exactly that, and it would vanish in silence.
  const w = 80, h = 80;
  const ring = new Uint8Array(w * h);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const d = Math.hypot(x - 40, y - 40);
    if (d > 24 && d < 28) ring[y * w + x] = 1;
  }
  const paths = skeletonPaths(skeletonize(ring, w, h), w, h);
  const cells = paths.reduce((a, p) => a + p.length, 0);
  assert.ok(paths.length >= 1, 'the ring produced no path at all');
  assert.ok(cells > 100, `only ${cells} cells walked around a ring — most of it is missing`);
});

test('filled areas are untouched by the thin-line path', () => {
  // The single-bead route must not disturb what already worked: a solid shape
  // is still a perimeter with a fill inside it.
  const block = bitmap(N, N, (x, y) => Math.abs(y - 500) < 250 && Math.abs(x - 500) < 250);
  const s = designStats(block);
  assert.ok(s.gcode.includes('design outline'), 'a solid block still gets a perimeter');
  assert.ok(s.gcode.includes('design fill'), 'a solid block still gets a fill');
  const ratio = s.volume / s.expected;
  assert.ok(ratio > 0.85 && ratio < 1.1, `solid fill extruded ${ratio.toFixed(2)}x its area`);
});
