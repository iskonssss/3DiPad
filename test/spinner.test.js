import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { spinnerLayerPlan, spinnerSpec, mirrorCoverage } from '../src/gcode/spinner.js';
import { shapePolygon } from '../src/gcode/geometry.js';
import { build3mf, zipMember } from '../src/integrations/bambu3mf.js';

const cfg = loadConfig({ exampleOnly: true });
const sp = spinnerSpec(cfg);
const c = sp.outerR;   // the disc's centre in plate-local mm

// An "F": asymmetric, so a mirror is unmistakable.
const F = [
  { w: 1.6, pts: [{ x: c - 5, y: c - 8 }, { x: c - 5, y: c + 8 }] },
  { w: 1.6, pts: [{ x: c - 5, y: c + 8 }, { x: c + 6, y: c + 8 }] },
  { w: 1.6, pts: [{ x: c - 5, y: c + 1 }, { x: c + 3, y: c + 1 }] },
];
const BLOB = [];
for (let y = -6; y <= 6; y += 1) BLOB.push({ w: 1.6, pts: [{ x: c - 6, y: c + y }, { x: c + 2, y: c + y }] });

const design = (over = {}) => ({
  product: 'spinner', colours: { layer1: 'BLACK', layer2: 'RED' },
  faces: { top: { design: F }, bottom: null }, sameBothSides: true, ...over,
});

const num = (l, k) => { const m = l.match(new RegExp(`${k}(-?[0-9.]+)`)); return m ? parseFloat(m[1]) : null; };

/**
 * Every extrusion segment of the print body, in body-centred mm, tagged with
 * its layer, colour, part (ring/disc/design) and feed.
 */
function segments(gcode) {
  const [bx, by] = cfg.build.bedCenter;
  const bbox = shapePolygon('spinner', cfg).bbox;
  const ox = c - bbox.w / 2 + bx, oy = c - bbox.h / 2 + by;   // where the body's centre lands on the bed
  const out = [];
  let pos = { x: 0, y: 0 }, layer = 0, colour = 0, part = '', inBody = false, feed = 0;
  for (const line of gcode.split('\n')) {
    const lm = line.match(/^; layer (\d+)\/\d+ z=([0-9.]+) (body|design)(?: (top|bottom))? colour (\d)/);
    if (lm) { inBody = true; layer = +lm[1]; colour = +lm[5]; part = lm[3] === 'design' ? 'design' : ''; continue; }
    if (line.startsWith('; ring ')) part = 'ring';
    if (line.startsWith('; disc ')) part = 'disc';
    if (line.includes('A1 mini END') || line.includes('MACHINE_END_GCODE')) inBody = false;
    if (!line.startsWith('G1 ')) continue;
    const x = num(line, 'X'), y = num(line, 'Y'), e = num(line, 'E'), f = num(line, 'F');
    if (f != null) feed = f;
    const to = { x: x ?? pos.x, y: y ?? pos.y };
    if (inBody && e != null && e > 0 && (x != null || y != null)) {
      out.push({ layer, colour, part, feed, a: { x: pos.x - ox, y: pos.y - oy }, b: { x: to.x - ox, y: to.y - oy } });
    }
    pos = to;
  }
  return out;
}
const samples = (s, step = 0.2) => {
  const L = Math.hypot(s.b.x - s.a.x, s.b.y - s.a.y), n = Math.max(1, Math.ceil(L / step)), pts = [];
  for (let i = 0; i <= n; i++) pts.push({ x: s.a.x + ((s.b.x - s.a.x) * i) / n, y: s.a.y + ((s.b.y - s.a.y) * i) / n });
  return pts;
};
const inPinZone = (p) => Math.abs(p.x) < sp.pin.r + 1.5 && Math.abs(p.y) > sp.discR - 1.5;

const { gcode, meta } = generate(design(), cfg);
const segs = segments(gcode);
const plan = spinnerLayerPlan(cfg);

test('layer plan matches the sliced original: 25 layers, cavity 12-14, pause before 15, pins 4-22, foot 1-3, loop to 20', () => {
  assert.equal(plan.layers.length, 25);
  assert.deepEqual(plan.cavityLayers, [12, 14]);
  assert.equal(plan.nfcPauseLayer, 15);
  const pins = plan.layers.filter((L) => L.pin).map((L) => L.i);
  assert.equal(pins[0], 4); assert.equal(pins[pins.length - 1], 22);
  assert.deepEqual(plan.layers.filter((L) => L.foot).map((L) => L.i), [1, 2, 3]);
  assert.deepEqual(plan.layers.filter((L) => L.loop).map((L) => L.i).slice(-1), [20]);
  assert.deepEqual(plan.layers.filter((L) => L.colour === 'bottom').map((L) => L.i), [1, 2]);
  assert.deepEqual(plan.layers.filter((L) => L.colour === 'top').map((L) => L.i), [24, 25]);
  assert.ok(plan.layers[14].bridge, 'layer 15 bridges the cavity');
  for (const i of [9, 10, 11, 16, 17]) assert.ok(plan.layers[i - 1].discSolid, `layer ${i} is solid around the cavity`);
});

test('the file: header, four swaps, the NFC pause before layer 15, both faces in colour 2', () => {
  assert.equal(meta.layers, 25);
  assert.equal(meta.swaps, 4);
  assert.equal(meta.nfcPauseLayer, 15);
  assert.ok(meta.hasDesign);
  assert.deepEqual(meta.faces, { top: true, bottom: true });
  assert.ok(/^; filament: 1,2$/m.test(gcode), 'two filaments declared');
  assert.ok(/^; total layer number: 25$/m.test(gcode));
  assert.equal((gcode.match(/^M400 U1\b/gm) || []).length, 5, 'four filament stops plus the NFC stop');
  const pauseAt = gcode.indexOf('NFC PAUSE before layer 15');
  const layer14 = gcode.indexOf('; layer 14/25');
  const layer15 = gcode.indexOf('; layer 15/25');
  assert.ok(pauseAt > layer14 && pauseAt < layer15, 'the pause sits between layer 14 and layer 15');
  // colour 2 appears on exactly the face layers, and each face layer has body too
  const byLayer = new Map();
  for (const s of segs) { if (!byLayer.has(s.layer)) byLayer.set(s.layer, new Set()); byLayer.get(s.layer).add(s.colour); }
  for (let i = 1; i <= 25; i++) {
    const cols = [...byLayer.get(i)].sort().join('');
    assert.equal(cols, [1, 2, 24, 25].includes(i) ? '12' : '1', `layer ${i} colours`);
  }
  // the order the swaps come in: body1, design(1,2), body2..24, design(24,25), body25
  const order = [...gcode.matchAll(/^; layer (\d+)\/25 z=[0-9.]+ (body|design)/gm)].map((m) => `${m[2][0]}${m[1]}`);
  assert.deepEqual(order.slice(0, 4), ['b1', 'd1', 'd2', 'b2']);
  assert.deepEqual(order.slice(-4), ['b24', 'd24', 'd25', 'b25']);
});

test('the back is the front mirrored left-to-right', () => {
  const centroid = (layer) => {
    let sx = 0, n = 0;
    for (const s of segs) if (s.layer === layer && s.colour === 2) for (const p of samples(s)) { sx += p.x; n++; }
    return sx / n;
  };
  // Layer for layer with the same fill direction: 24 with 1, 25 with 2. Most
  // of an F's ink is its upright, which sits left of centre.
  for (const [top, bottom] of [[24, 1], [25, 2]]) {
    const front = centroid(top), back = centroid(bottom);
    assert.ok(front < -0.5, `the F leans left on the front (layer ${top}: ${front.toFixed(2)})`);
    assert.ok(Math.abs(front + back) < 0.15, `the back leans the other way by the same amount (layer ${bottom}: ${back.toFixed(2)} vs ${front.toFixed(2)})`);
  }
});

test('the disc never touches the ring: a clear gap on every layer, pins inside their pockets', () => {
  for (let i = 1; i <= 25; i++) {
    const ring = segs.filter((s) => s.layer === i && s.part === 'ring').flatMap((s) => samples(s));
    const disc = segs.filter((s) => s.layer === i && s.part === 'disc').flatMap((s) => samples(s));
    assert.ok(ring.length && disc.length, `layer ${i} has both parts`);
    // Radial: nothing of either part in the clearance gap, outside the pin zone.
    for (const p of disc) {
      const r = Math.hypot(p.x, p.y);
      if (inPinZone(p)) continue;
      assert.ok(r < sp.discR - sp.lineWidth / 2 + 0.05, `layer ${i}: disc line at r=${r.toFixed(2)} past the disc edge`);
    }
    for (const p of ring) {
      const r = Math.hypot(p.x, p.y);
      if (inPinZone(p)) continue;
      assert.ok(r > sp.ringInnerR + sp.lineWidth / 2 - 0.05, `layer ${i}: ring line at r=${r.toFixed(2)} inside the ring's bore`);
    }
    // Closest approach anywhere, pin to pocket included: two line centres must
    // stay a line width plus real clearance apart or the parts fuse.
    let min = Infinity;
    const near = ring.filter(inPinZone), nearD = disc.filter(inPinZone);
    for (const p of nearD) for (const q of near) { const d = Math.hypot(p.x - q.x, p.y - q.y); if (d < min) min = d; }
    if (near.length && nearD.length) assert.ok(min >= sp.lineWidth + 0.25, `layer ${i}: pin and pocket walls ${min.toFixed(2)} mm apart`);
  }
});

test('the NFC cavity is empty, walled, and roofed by a slow bridge across its short side', () => {
  const half = { x: sp.nfc.w / 2, y: sp.nfc.h / 2 };
  for (const i of [12, 13, 14]) {
    const inside = segs.filter((s) => s.layer === i).flatMap((s) => samples(s))
      .filter((p) => Math.abs(p.x) < half.x - sp.lineWidth / 2 - 0.05 && Math.abs(p.y) < half.y - sp.lineWidth / 2 - 0.05);
    assert.equal(inside.length, 0, `layer ${i}: ${inside.length} points inside the cavity`);
    const wall = segs.filter((s) => s.layer === i && s.part === 'disc').flatMap((s) => samples(s))
      .filter((p) => Math.abs(Math.abs(p.x) - (half.x + sp.lineWidth / 2)) < 0.1 && Math.abs(p.y) < half.y);
    assert.ok(wall.length > 20, `layer ${i}: a wall hugs the cavity`);
  }
  const bridge = segs.filter((s) => s.layer === 15 && s.part === 'disc' && Math.abs((s.a.x + s.b.x) / 2) < half.x - 1 && Math.abs((s.a.y + s.b.y) / 2) < half.y - 1);
  assert.ok(bridge.length > 30, 'lines cross the cavity on layer 15');
  for (const s of bridge) {
    assert.ok(Math.abs(s.b.x - s.a.x) < 0.05, 'bridge lines run along Y, the short span');
    assert.ok(s.feed <= sp.bridgeSpeed, `bridge line at F${s.feed}`);
  }
  // and the layer below the cavity is solid: no gaps wider than a line pitch
  const floor = segs.filter((s) => s.layer === 11 && s.part === 'disc').flatMap((s) => samples(s, 0.1)).filter((p) => Math.abs(p.x) < 8 && Math.abs(p.y) < 4);
  assert.ok(floor.length > 400, 'the cavity floor is solid');
});

test('one face, one layer deep, no design: swap counts and refusals', () => {
  const top = generate(design({ faces: { top: { design: F }, bottom: { design: [] } }, sameBothSides: false }), cfg).meta;
  assert.equal(top.swaps, 2); assert.deepEqual(top.faces, { top: true, bottom: false });
  const one = generate(design(), { ...cfg, spinner: { ...cfg.spinner, colourLayers: 1 } }).meta;
  assert.equal(one.swaps, 3); assert.equal(one.designLayers, 1);
  const none = generate(design({ faces: { top: { design: [] }, bottom: null } }), cfg).meta;
  assert.equal(none.hasDesign, false); assert.equal(none.swaps, 0);
  const diff = generate(design({ faces: { top: { design: F }, bottom: { design: BLOB } }, sameBothSides: false }), cfg).meta;
  assert.equal(diff.sameBothSides, false); assert.equal(diff.strokeCount, F.length + BLOB.length);
});

test('estimate is in the range the original prints in, under the spinner budget', () => {
  assert.ok(meta.estMinutes > 12 && meta.estMinutes < 45, `estimated ${meta.estMinutes} min`);
  assert.ok(meta.estGrams > 4 && meta.estGrams < 14, `estimated ${meta.estGrams} g`);
  assert.equal(meta.overBudget, false);
  assert.equal(meta.shape, 'spinner');
  assert.equal(meta.bbox.w, 45);
});

test('the 3mf declares both colours on the face layers and the pause', () => {
  const zip = build3mf({ gcode, meta, cfg, name: 'spinner' });
  const info = zipMember(zip, 'Metadata/slice_info.config').toString('utf8');
  assert.ok(info.includes('layer_ranges="0 1,23 24"'), 'both filaments on layers 1-2 and 24-25');
  assert.ok(info.includes('filament_list="0" layer_ranges="2 22"'));
  assert.ok(info.includes('<pause index="1" layer="15"'));
  assert.ok(info.includes('<metadata key="pause_count" value="1"/>'));
});

test('mirrorCoverage flips a mask about the plate centre', () => {
  const cell = 0.12, pad = 25, w = Math.ceil(45 / cell) + 2 * pad;
  const cov = { w, h: 4, cell, pad, mask: new Uint8Array(w * 4), toMm: (p) => ({ x: (p.x - pad) * cell, y: 0 }) };
  const i = Math.round(10 / cell) + pad;   // x = 10 mm
  cov.mask[i] = 1;
  const m = mirrorCoverage(cov, 45);
  const j = Math.round(35 / cell) + pad;   // x = 35 mm
  assert.equal(m.mask[j], 1);
  assert.equal(m.mask[i], 0);
});
