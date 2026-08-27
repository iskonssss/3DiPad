import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { imageCoverage, decodeBitmap } from '../src/gcode/image.js';

const cfg = loadConfig({ exampleOnly: true });

/** A binary bitmap {w,h,ink}, ink=1 from fn(x,y). Origin top-left, y DOWN. */
function bitmap(w, h, fn) {
  const ink = new Uint8Array(w * h);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) if (fn(x, y)) ink[y * w + x] = 1;
  return { w, h, ink };
}

/** Bit-pack a bitmap into the { w, h, data } wire form (MSB first). */
function pack(bm) {
  const n = bm.w * bm.h;
  const bytes = new Uint8Array(Math.ceil(n / 8));
  for (let i = 0; i < n; i++) if (bm.ink[i]) bytes[i >> 3] |= 1 << (7 - (i & 7));
  return { w: bm.w, h: bm.h, data: Buffer.from(bytes).toString('base64') };
}

/** Printed width in mm of a horizontal feature: ink cells in a central column. */
function inkThicknessMm(cov, bbox) {
  const ci = Math.round(bbox.w / 2 / cov.cell + cov.pad);
  let n = 0;
  for (let j = 0; j < cov.h; j++) if (cov.mask[j * cov.w + ci]) n++;
  return n * cov.cell;
}

test('decodeBitmap round-trips the packed wire form', () => {
  const bm = bitmap(13, 7, (x, y) => (x + y) % 3 === 0);
  const got = decodeBitmap(pack(bm));
  assert.equal(got.w, 13);
  assert.equal(got.h, 7);
  assert.deepEqual([...got.ink], [...bm.ink]);
});

const MIN_FEATURE = cfg.build.imageMinFeatureMm ?? 0.5;

test('a hairline stroke is thickened to a printable bead, not printed thin', () => {
  // 0.06mm/px: a 1px line is 0.3mm, under the 0.5mm the printer will hold as a
  // ridge. Traced literally it prints as a whisker that snaps off.
  const bbox = { w: 60, h: 60 };
  const H = 1000;
  const line = bitmap(1000, H, (_x, y) => Math.abs(y - H / 2) < 0.5); // one row
  const cov = imageCoverage(line, cfg, bbox, null, null, 0);
  assert.ok(cov, 'the line survived');
  const t = inkThicknessMm(cov, bbox);
  assert.ok(t >= MIN_FEATURE - cov.cell,
    `hairline came out ${t.toFixed(2)}mm wide, under the ${MIN_FEATURE}mm minimum`);
});

test('a line already thick enough is left alone, not bolded to the minimum', () => {
  // The reason thickening is conditional rather than a blanket dilation: a
  // drawing is mostly lines that are already fine, and growing every one of
  // them merges the features a child meant to keep apart. A 2mm band must come
  // off the plate 2mm, not 2mm plus the minimum.
  const bbox = { w: 60, h: 60 };
  const H = 1000, halfPx = (2 / 60) * 1000 / 2;   // a 2mm-wide band
  const band = bitmap(1000, H, (_x, y) => Math.abs(y - H / 2) <= halfPx);
  const cov = imageCoverage(band, cfg, bbox, null, null, 0);
  assert.ok(cov);
  const t = inkThicknessMm(cov, bbox);
  assert.ok(Math.abs(t - 2) < 0.25, `a 2mm band came out ${t.toFixed(2)}mm — it was bolded`);
});

test('the printable floor holds when config.json carries no image settings', () => {
  // The booth's config.json is NOT in git and is hand-edited, so it will not
  // have the image keys until someone adds them. The floor has to come from the
  // code, not from the config file — otherwise every booth silently runs with
  // whatever the fallback happens to be.
  const bare = { ...cfg, build: { ...cfg.build } };
  delete bare.build.imageMinFeatureMm;
  delete bare.build.imageSpeckMm;
  delete bare.build.imageCloseMm;

  const bbox = { w: 60, h: 60 };
  const H = 1000;
  const line = bitmap(1000, H, (_x, y) => Math.abs(y - H / 2) < 0.5);
  const cov = imageCoverage(line, bare, bbox, null, null, 0);
  assert.ok(cov, 'the line survived with no image config at all');
  const t = inkThicknessMm(cov, bbox);
  assert.ok(t >= 0.5 - cov.cell, `defaulted to ${t.toFixed(2)}mm, under the 0.5mm the printer holds`);
  // and it must not have quietly fallen back to the 0.8 pen minimum
  assert.ok(t < 0.8, `defaulted to ${t.toFixed(2)}mm — that is the penRange floor, not the printable one`);
});

test('a hairline is never lost between samples when the image outresolves the plate', () => {
  // The failure this pins: sampling ONE source pixel per plate cell steps over
  // whole rows of a drawing posted at higher resolution than the plate grid. A
  // 1px line landing on a skipped row vanished completely — not thin, ABSENT —
  // and nothing downstream could tell. Measured at two hairlines 0.6mm apart:
  // both disappeared, and the keychain came out blank where the drawing was.
  //
  // Swept across offsets because whether it survived was pure alignment luck:
  // the same line one pixel further down would print.
  const bbox = { w: 60, h: 60 };
  const H = 1000;
  for (let off = 0; off < 8; off++) {
    const row = Math.round(H / 2) + off;
    const line = bitmap(1000, H, (_x, y) => y === row);   // exactly one pixel tall
    const cov = imageCoverage(line, cfg, bbox, null, null, 0);
    assert.ok(cov, `a 1px line at row ${row} disappeared entirely`);
    const t = inkThicknessMm(cov, bbox);
    assert.ok(t >= MIN_FEATURE - cov.cell,
      `a 1px line at row ${row} came out ${t.toFixed(2)}mm, under the ${MIN_FEATURE}mm minimum`);
  }
});

test('two close hairlines both survive and stay separate', () => {
  // 0.8mm apart is the case the 0.5mm floor exists to serve: at a 0.8mm floor
  // these merge into one blob, which is a face losing its eyes.
  const bbox = { w: 60, h: 60 };
  const H = 1000, pxPerMm = H / bbox.h, gap = 0.8 * pxPerMm;
  const two = bitmap(1000, H, (_x, y) => y === Math.round(H / 2 - gap / 2) || y === Math.round(H / 2 + gap / 2));
  const cov = imageCoverage(two, cfg, bbox, null, null, 0);
  assert.ok(cov, 'both hairlines disappeared');
  const ci = Math.round(bbox.w / 2 / cov.cell + cov.pad);
  let runs = 0, prev = 0;
  for (let j = 0; j < cov.h; j++) { const on = cov.mask[j * cov.w + ci]; if (on && !prev) runs++; prev = on; }
  assert.equal(runs, 2, `${runs} line(s) printed — 0.8mm apart they should stay separate`);
});

test('a speck too small to survive is dropped', () => {
  // A single stray pixel — a dust speck on a phone photo. It must not become a
  // bead sitting on its own on the plate.
  const bbox = { w: 60, h: 60 };
  const spec = bitmap(1000, 1000, (x, y) => x === 500 && y === 500);
  const cov = imageCoverage(spec, cfg, bbox, null, null, 0);
  assert.equal(cov, null, 'a lone speck produced coverage it should have dropped');
});

test('a solid region survives and fills', () => {
  const bbox = { w: 60, h: 60 };
  const disc = bitmap(400, 400, (x, y) => Math.hypot(x - 200, y - 200) < 120);
  const cov = imageCoverage(disc, cfg, bbox, null, null, 0);
  assert.ok(cov, 'the disc produced coverage');
  let n = 0;
  for (let i = 0; i < cov.mask.length; i++) if (cov.mask[i]) n++;
  const discMm2 = Math.PI * (120 / 400 * 60 / 2) ** 2; // ~ the disc area in mm^2
  const cells = n * cov.cell * cov.cell;
  assert.ok(cells > discMm2 * 0.7, `filled ${cells.toFixed(0)}mm^2 of a ~${discMm2.toFixed(0)}mm^2 disc`);
});

test('the drawing keeps the same way up — image y-down maps to plate y-up', () => {
  // Ink only in the top third of the file must end up in the top of the plate.
  const bbox = { w: 60, h: 60 };
  const topBand = bitmap(400, 400, (_x, y) => y < 130); // top third, y-down
  const cov = imageCoverage(topBand, cfg, bbox, null, null, 0);
  assert.ok(cov);
  let minY = Infinity;
  for (let j = 0; j < cov.h; j++) for (let i = 0; i < cov.w; i++) {
    if (cov.mask[j * cov.w + i]) minY = Math.min(minY, cov.toMm({ x: i, y: j }).y);
  }
  assert.ok(minY > bbox.h / 2, `top-of-image ink landed at y>=${minY.toFixed(1)}mm; it should be in the plate's upper half`);
});

test('a wide image is letterboxed, not stretched', () => {
  // 2:1 image into a square plate: ink fills the width but only the middle band
  // of the height. If it were stretched it would fill top to bottom.
  const bbox = { w: 60, h: 60 };
  const full = bitmap(400, 200, () => 1);
  const cov = imageCoverage(full, cfg, bbox, null, null, 0);
  assert.ok(cov);
  let maxY = -Infinity, minY = Infinity;
  for (let j = 0; j < cov.h; j++) for (let i = 0; i < cov.w; i++) {
    if (cov.mask[j * cov.w + i]) { const y = cov.toMm({ x: i, y: j }).y; maxY = Math.max(maxY, y); minY = Math.min(minY, y); }
  }
  assert.ok(maxY - minY < bbox.h * 0.7, `2:1 image covered ${(maxY - minY).toFixed(0)}mm of height — it was stretched`);
  assert.ok(minY > 5 && maxY < bbox.h - 5, 'the letterbox margins are blank paper');
});

test('coverage is clipped to the plate and carved around the hole', () => {
  const bbox = { w: 60, h: 60 };
  const poly = [{ x: 0, y: 0 }, { x: 60, y: 0 }, { x: 60, y: 60 }, { x: 0, y: 60 }];
  const hole = { cx: 30, cy: 50, r: cfg.build.holeDiameter / 2 };
  const full = bitmap(400, 400, () => 1);
  const cov = imageCoverage(full, cfg, bbox, poly, hole, cfg.build.designEdgeMargin);
  assert.ok(cov);
  for (let j = 0; j < cov.h; j++) for (let i = 0; i < cov.w; i++) {
    if (!cov.mask[j * cov.w + i]) continue;
    const p = cov.toMm({ x: i, y: j });
    assert.ok(Math.hypot(p.x - hole.cx, p.y - hole.cy) > hole.r, `ink at ${p.x.toFixed(1)},${p.y.toFixed(1)} sits in the hole`);
    assert.ok(p.x > -0.5 && p.x < bbox.w + 0.5 && p.y > -0.5 && p.y < bbox.h + 0.5, 'ink stayed on the plate');
  }
});

test('a blank scan produces no coverage at all', () => {
  const bbox = { w: 60, h: 60 };
  assert.equal(imageCoverage(bitmap(100, 100, () => 0), cfg, bbox, null, null, 0), null);
  assert.equal(imageCoverage(null, cfg, bbox, null, null, 0), null);
});

test('an imported image drives the whole generate() pipeline', () => {
  const disc = bitmap(400, 400, (x, y) => Math.hypot(x - 200, y - 200) < 130);
  const design = {
    shape: 'circle', colours: { layer1: 'BLACK', layer2: 'BLUE' }, holePos: 'left',
    design: [], image: pack(disc),
  };
  const { gcode, meta } = generate(design, cfg);
  assert.equal(meta.fromImage, true);
  assert.equal(meta.hasDesign, true);
  assert.equal(meta.strokeCount, 0);
  assert.ok(gcode.includes('imported image'), 'the design section names the image source');
  assert.ok(gcode.includes('design fill'), 'the imported image was actually filled');
});

test('an image that thresholds to blank is refused, not printed as one colour', () => {
  const design = {
    shape: 'circle', colours: { layer1: 'BLACK', layer2: 'BLUE' }, holePos: 'left',
    design: [], image: pack(bitmap(100, 100, () => 0)),
  };
  const { meta } = generate(design, cfg);
  assert.equal(meta.hasDesign, false, 'a blank upload must not look printable');
});

test('the size slider shrinks the drawing about the centre of the plate', () => {
  const bbox = { w: 60, h: 60 };
  const full = bitmap(200, 200, () => 1);
  const extent = (cov) => {
    let lo = Infinity, hi = -Infinity;
    for (let j = 0; j < cov.h; j++) for (let i = 0; i < cov.w; i++) {
      if (cov.mask[j * cov.w + i]) { const x = cov.toMm({ x: i, y: j }).x; lo = Math.min(lo, x); hi = Math.max(hi, x); }
    }
    return { lo, hi, w: hi - lo };
  };
  const whole = extent(imageCoverage(full, cfg, bbox, null, null, 0));
  const half = extent(imageCoverage({ ...full, scale: 0.5 }, cfg, bbox, null, null, 0));
  assert.ok(Math.abs(half.w - whole.w / 2) < 1.5, `half size should be half as wide: ${half.w.toFixed(1)} vs ${whole.w.toFixed(1)}`);
  assert.ok(Math.abs((half.lo + half.hi) / 2 - (whole.lo + whole.hi) / 2) < 1, 'and stay centred');
  // the wire form carries it
  assert.equal(decodeBitmap({ ...pack(full), scale: 0.5 }).scale, 0.5);
});

test('strokes drawn over an imported image print too', async () => {
  // A studio uploads a drawing; the child writes their name on it. Both must
  // reach the plate. The image sits in the left half; the stroke is on the right.
  const { generate } = await import('../src/gcode/engine.js');
  const left = bitmap(200, 200, (x) => x < 60);
  const base = { shape: 'rectangle', colours: { layer1: 'BLACK', layer2: 'PINK' }, hole: 'none', holePos: 'none' };
  const stroke = [{ pts: [{ x: 80, y: 20 }, { x: 95, y: 20 }], w: 2.2 }];
  const imgOnly = generate({ ...base, image: pack(left), design: [] }, cfg);
  const both = generate({ ...base, image: pack(left), design: stroke }, cfg);
  const strokeOnly = generate({ ...base, design: stroke }, cfg);
  assert.ok(imgOnly.meta.hasDesign && strokeOnly.meta.hasDesign && both.meta.hasDesign);
  // the combined print lays more filament than either alone
  assert.ok(both.meta.estGrams > imgOnly.meta.estGrams, 'the stroke adds to the image');
  assert.ok(both.meta.estGrams > strokeOnly.meta.estGrams, 'the image adds to the stroke');
  assert.match(both.gcode, /imported image \+ 1 strokes/);
});
