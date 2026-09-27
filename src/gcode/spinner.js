// The NFC spinner keychain — a second product on the same engine.
//
// A print-in-place flip spinner: an outer ring with a hanging loop, and a disc
// inside it that flips freely about the axis through the loop. Two pivot pins
// on the disc (a Ø4 peg tapering to a Ø0.6 tip, axis along Y at mid-height)
// ride in matching cone pockets recessed into the ring. An NFC tag drops into
// a floating pocket inside the disc at a pause mid-print. The drawing is
// INLAID flush into the disc's faces, two layers deep, on both sides — the back
// mirrored so it reads correctly when the disc is flipped.
//
// Every number here was measured off the customer's own Tinkercad STL and the
// Bambu Studio g-code that printed it (reference/NFC Spinner Keychain/README.md)
// and lives in config.example.json under "spinner". The body is fixed; only
// the drawings change.
//
//   design = {
//     product: 'spinner',
//     colours: { layer1, layer2 },        // body, drawing
//     faces: {
//       top:    { design: [strokes], image },     // the front, as drawn
//       bottom: { design: [strokes], image } | null,   // the back, as it will
//     },                                             // be SEEN from the back
//     sameBothSides: true,                // bottom = top when no bottom given
//   }
//
// Colour order (external spool, one swap each):
//   body L1 → [c2] design L1..Lc → [c1] body L2 … body L(N-1) → [c2] design
//   top faces → [c1] body LN.   Four swaps for two faces of two layers; the
//   slicer's per-layer interleave needs the same four. Nothing fewer is
//   possible with one nozzle: a 0.4 mm-tall island beside a 0.2 mm layer is
//   where the nozzle cone lands.
//
// Under the pins: the pin's nose begins 0.5 mm above the bed with nothing
// under it. The slicer put a little tree support there. Here the disc grows a
// small foot instead (`pin.foot`): the pin's own first-layer footprint,
// extruded down to the bed, kept clear of the ring. Part of the disc, so
// there is nothing to break off — which, having printed both, is what the
// owner prefers. `pin.support` is the slicer's way, kept as the alternative.

import { toBed } from './geometry.js';
import { buildCoverage, maskRowsAngle, maskContours, contourToMm } from './fill.js';
import { imageCoverage, decodeBitmap } from './image.js';
import { prepareStrokes, totalLength } from './strokes.js';
import { dilate, fillPolygon } from './outline.js';
import {
  makeEmitter, drawSpanRegions, designLayer, unionCoverage, bambuBlocks, colourChangeBlock,
  applyTemplate, startupMinutes, spliceProgress, printConstants, changeStopsItself, levelArea,
} from './engine.js';

/** The resolved numbers for the spinner body. config.example.json documents them. */
export function spinnerSpec(cfg) {
  const s = cfg.spinner || {};
  const pin = s.pin || {};
  const loop = s.loop || {};
  const nfc = s.nfc || {};
  const layerH = s.layerHeight ?? 0.2;
  const first = s.firstLayerHeight ?? layerH;
  const thickness = s.thickness ?? 5;
  const layers = Math.max(3, Math.round((thickness - first) / layerH) + 1);
  return {
    outerR: s.outerRadius ?? 22.5,
    ringInnerR: s.ringInnerRadius ?? 18,
    discR: s.discRadius ?? 16.5,
    thickness, layerH, first, layers,
    edgeRound: s.edgeRoundMm ?? 0.5,
    lineWidth: s.lineWidth ?? 0.42,
    beadModel: s.beadModel ?? 'rounded',
    // Where the body meets the inlaid drawing: how far the body's own wall
    // around the pocket reaches into the drawing's edge. Seen on a print at the
    // old 0.06: a clear groove all round the drawing.
    inlayOverlap: s.inlayOverlapMm ?? 0.15,
    // The seam crossfade: a wall loop's first stretch this long ramps the
    // flow up, and it runs this far over its own start again ramping down.
    seamOverlap: s.seamOverlapMm ?? 2.5,
    // The keychain lays one extra loop between its walls and a solid fill,
    // and welds every fill turn on top of that. On the spinner's narrow ring
    // that put three helpings of plastic along every boundary of a band six
    // lines wide, and the top came out fuzzy; the slicer's file has walls,
    // then fill overlapping the inner wall, nothing between.
    anchorLoop: s.anchorLoop ?? false,
    firstLineWidth: s.firstLayerLineWidth ?? 0.5,
    firstFlow: s.firstLayerFlow ?? 1.0,
    firstZOffset: s.firstLayerZOffsetMm ?? 0,
    bedTemp: s.bedTemp ?? null,
    walls: Math.max(1, s.wallLoops ?? 2),
    overlapFrac: s.infillWallOverlap ?? cfg.build?.infillWallOverlap ?? 0.15,
    bottomSolid: s.bottomSolidLayers ?? 3,
    topSolid: s.topSolidLayers ?? 3,
    sparseSpacing: s.sparseSpacing ?? 2.5,
    colourLayers: Math.max(1, s.colourLayers ?? 2),
    designEdgeMargin: s.designEdgeMargin ?? 1.5,
    // The thinnest pen: an inlaid line is a slot in the body filled with the
    // other colour, and under about 1.5 mm the slot's walls and the line's
    // own bead fight for the same space.
    penRange: Array.isArray(s.penRange) && s.penRange.length === 2 ? s.penRange : [1.5, cfg.build?.penRange?.[1] ?? 2.6],
    pin: {
      r: pin.radius ?? 2.0, neckLen: pin.neckLen ?? 0.8, tipR: pin.tipRadius ?? 0.3, reach: pin.reach ?? 20.3,
      // The pocket as modelled, opened up by extraClearance all round. The
      // first hardware print at the modelled 0.34/0.5 fused: the pin's lower
      // cone droops as it grows and the pocket's roof sags as it closes, and
      // a third of a millimetre was not enough for both.
      pocketR: (pin.pocketRadius ?? 1.95) + (pin.extraClearance ?? 0.2),
      pocketTipR: (pin.pocketTipRadius ?? 0.35) + (pin.extraClearance ?? 0.2),
      pocketReach: (pin.pocketReach ?? 20.8) + (pin.extraClearance ?? 0.2),
      foot: pin.foot ?? true, footClearance: pin.footClearance ?? 0.35,
      support: pin.support ?? false, supportClearance: pin.supportClearance ?? 0.25, supportWidth: pin.supportWidth ?? 7,
      supportGapLayers: Math.max(0, pin.supportGapLayers ?? 1),
    },
    loop: { cy: loop.cy ?? 21, ro: loop.outerRadius ?? 6, ri: loop.innerRadius ?? 4, thickness: loop.thickness ?? 4.0 },
    nfc: {
      enabled: nfc.enabled ?? true, w: nfc.width ?? 22, h: nfc.height ?? 12, t: nfc.thickness ?? 0.6, zBottom: nfc.zBottom ?? 2.2,
      floorSolid: nfc.floorSolidLayers ?? 3, roofSolid: nfc.roofSolidLayers ?? 2, anchorMm: nfc.bridgeAnchorMm ?? 1.0,
    },
    bridgeSpeed: s.bridgeSpeed ?? 1200,
    overhangWallSpeed: s.overhangWallSpeed ?? 600,
    swapMinutes: s.swapMinutes ?? 1.0,
    pauseMinutes: s.nfcPauseMinutes ?? 0.5,
    maxPrintMinutes: s.maxPrintMinutes ?? 45,
    warnPrintMinutes: s.warnPrintMinutes ?? 40,
  };
}

/** The plate-local bounding box of the whole body (ring + loop), like shapePolygon's. */
export function spinnerBBox(cfg) {
  const sp = spinnerSpec(cfg);
  return { w: 2 * sp.outerR, h: sp.outerR + sp.loop.cy + sp.loop.ro };
}

/**
 * What each layer is, top to bottom, before any g-code is written. Exported so
 * the tests can check the plan against the measured original and the kiosk
 * can say when the pause comes.
 */
export function spinnerLayerPlan(cfg) {
  const sp = spinnerSpec(cfg);
  const N = sp.layers;
  const axisZ = sp.thickness / 2;
  const nfc = sp.nfc;
  const out = [];
  let cavityFirst = -1, cavityLast = -1;
  for (let i = 1; i <= N; i++) {
    const zTop = +(sp.first + (i - 1) * sp.layerH).toFixed(3);
    const h = i === 1 ? sp.first : sp.layerH;
    const zMid = zTop - h / 2;
    const cavity = nfc.enabled && zTop > nfc.zBottom + 1e-6 && zTop <= nfc.zBottom + nfc.t + 1e-6;
    if (cavity) { if (cavityFirst < 0) cavityFirst = i; cavityLast = i; }
    out.push({ i, zTop, zMid, h, dz: Math.abs(zMid - axisZ), cavity });
  }
  const bridge = cavityLast > 0 ? cavityLast + 1 : -1;
  for (const L of out) {
    const i = L.i;
    L.colour = i <= sp.colourLayers ? 'bottom' : i > N - sp.colourLayers ? 'top' : null;
    L.loop = L.zTop <= sp.loop.thickness + 1e-6;
    L.bridge = i === bridge;
    const faceSolid = i <= sp.bottomSolid || i > N - sp.topSolid;
    const floor = cavityFirst > 0 && i < cavityFirst && i >= cavityFirst - nfc.floorSolid;
    const roof = bridge > 0 && i > bridge && i <= bridge + nfc.roofSolid;
    L.discSolid = faceSolid || floor || roof || L.bridge || L.cavity;
    // the loop's own top surface: solid where the ring proper would be sparse
    const loopTop = L.loop && L.zTop > sp.loop.thickness - sp.topSolid * sp.layerH + 1e-6;
    L.ringSolid = faceSolid || loopTop;
    // the pin exists where its revolution profile is wider than the layer's
    // distance from the axis
    L.pin = sp.pin.r > L.dz + 1e-9;
    L.pocket = sp.pin.pocketR > L.dz + 1e-9;
    L.pinGrowing = L.pin && L.zMid < axisZ;   // lower cone: each layer overhangs the last
    L.pocketShrinking = L.pocket && L.zMid > axisZ;
  }
  const firstPin = out.find((L) => L.pin);
  for (const L of out) {
    L.foot = !!(sp.pin.foot && firstPin && !L.pin && L.i < firstPin.i);
    // support pads under the pin noses, stopping a gap layer short of the pin
    L.support = !!(sp.pin.support && !L.foot && firstPin && L.i < firstPin.i - sp.pin.supportGapLayers);
  }
  return { spec: sp, layers: out, nfcPauseLayer: bridge, cavityLayers: cavityLast > 0 ? [cavityFirst, cavityLast] : null, footDz: firstPin ? firstPin.dz : null };
}

// ---------------------------------------------------------------------------
// Geometry, in body-centred mm: the ring's centre is (0,0), the loop is at +Y,
// the pivot axis is the Y axis at z = thickness/2.

const TAU = Math.PI * 2;

/** Radius of the pin's profile of revolution at distance y from the centre. */
function pinRadiusAt(sp, y) {
  const p = sp.pin;
  const neckEnd = sp.discR + p.neckLen;
  if (y <= neckEnd) return p.r;
  if (y >= p.reach) return 0;
  return p.tipR + (p.r - p.tipR) * (p.reach - y) / (p.reach - neckEnd);
}
/** Radius of the pocket's profile at distance y from the centre. */
function pocketRadiusAt(sp, y) {
  const p = sp.pin;
  if (y <= sp.ringInnerR) return p.pocketR;
  if (y >= p.pocketReach) return 0;
  return p.pocketTipR + (p.pocketR - p.pocketTipR) * (p.pocketReach - y) / (p.pocketReach - sp.ringInnerR);
}

/**
 * One pin lobe or pocket notch as a polyline, for the +Y side, running from
 * the right edge out to the tip and back down the left edge (CCW order for a
 * bump on a CCW outline). `radiusAt` is the profile; `dz` the layer's height
 * off the axis; `grow` widens the shape (a pocket's wall offset) and a
 * negative `grow` narrows it (a pin's wall inset). `yBase` is the circle the
 * bump sits on, `yCap` an optional hard limit on how far out it reaches.
 */
function bumpPolyline(radiusAt, dz, grow, baseR, yCap = Infinity) {
  // the profile's half-width in this layer, before any offset
  const raw = (y) => { const r = radiusAt(y); return r > dz ? Math.sqrt(r * r - dz * dz) : 0; };
  const hw0 = raw(baseR) + grow;
  if (hw0 <= 0.05) return null;
  // the bump starts where its straight edges meet the circle
  const y0 = Math.sqrt(Math.max(0, baseR * baseR - hw0 * hw0));
  // Where the raw profile ends. The offset moves that end too: a wall inset
  // by d stops d short of the tip (or the bead would reach d past it), and a
  // pocket's wall reaches d beyond. Narrowing the sides alone was measured to
  // leave the pin's material a quarter of a millimetre proud of the profile,
  // which is most of its clearance.
  let yEnd0 = baseR;
  for (let y = baseR; y < baseR + 40; y += 0.02) { if (raw(y) <= 0) break; yEnd0 = y; }
  const yLim = Math.min(yEnd0 + grow, yCap);
  if (yLim <= y0 + 0.02) return null;
  // The sides are offset along their normal, not sideways: a side sloping at
  // angle a to the axis moves by grow/cos(a) in x. Capped near a point, where
  // the slope runs away.
  const off = (y) => {
    const slope = (raw(y + 0.05) - raw(y - 0.05)) / 0.1;
    return grow * Math.min(3, Math.sqrt(1 + slope * slope));
  };
  const right = [];
  const step = 0.15;
  for (let y = y0; y < yLim; y += step) right.push({ x: Math.max(0.02, raw(y) + off(y)), y });
  right.push({ x: Math.max(0.02, raw(yLim) + off(yLim)), y: yLim });
  // A truncated tip, a pocket's offset end or a capped foot ends square; a
  // real point closes to one.
  const tip = right[right.length - 1];
  const pts = right.slice();
  if (tip.x <= 0.2) { pts.pop(); pts.push({ x: 0, y: tip.y }); right.pop(); }
  for (let k = right.length - 1; k >= 0; k--) pts.push({ x: -right[k].x, y: right[k].y });
  return { pts, hw0 };
}

/**
 * A circle of radius r with a bump inserted at +Y and −Y (the −Y one is the
 * +Y one rotated by 180°, which keeps the winding). No bump → plain circle.
 */
function circleWithBumps(r, bump, n = 180) {
  const out = [];
  let insertedTop = false, insertedBottom = false;
  for (let k = 0; k < n; k++) {
    const a = (TAU * k) / n;
    const p = { x: r * Math.cos(a), y: r * Math.sin(a) };
    if (bump && Math.abs(p.x) < bump.hw0) {
      if (p.y > 0) { if (!insertedTop) { insertedTop = true; out.push(...bump.pts); } continue; }
      if (p.y < 0) { if (!insertedBottom) { insertedBottom = true; out.push(...bump.pts.map((q) => ({ x: -q.x, y: -q.y }))); } continue; }
    }
    out.push(p);
  }
  return out;
}

/** The disc outline at a layer, inset by `d` (walls, fill boundary). */
function discOutline(sp, L, d, footDz) {
  let bump = null;
  if (L.pin) bump = bumpPolyline((y) => pinRadiusAt(sp, y), L.dz, -d, sp.discR - d);
  else if (L.foot && footDz != null) bump = bumpPolyline((y) => pinRadiusAt(sp, y), footDz, -d, sp.discR - d, sp.ringInnerR - sp.pin.footClearance - d);
  return circleWithBumps(sp.discR - d, bump);
}

/** The ring's inner boundary at a layer, pushed OUT into the ring by `d`. */
function ringInnerOutline(sp, L, d) {
  const bump = L.pocket ? bumpPolyline((y) => pocketRadiusAt(sp, y), L.dz, d, sp.ringInnerR + d) : null;
  return circleWithBumps(sp.ringInnerR + d, bump);
}

/** The ring's outer radius at a layer: the 0.5 mm edge round takes it in near each face. */
function ringOuterRadius(sp, L) {
  const dFace = Math.min(L.zMid, sp.thickness - L.zMid);
  const R = sp.edgeRound;
  if (!(R > 0) || dFace >= R) return sp.outerR;
  return sp.outerR - R + Math.sqrt(Math.max(0, R * R - (R - dFace) * (R - dFace)));
}

function arc(cx, cy, r, a0, a1, n) {
  const pts = [];
  for (let k = 0; k <= n; k++) { const a = a0 + ((a1 - a0) * k) / n; pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) }); }
  return pts;
}

/**
 * The ring's outer outline inset by `d`: the main circle, with the hanging
 * loop's outer arc replacing the top of it on the layers the loop exists.
 */
function ringOuterOutline(sp, L, d) {
  const rc = ringOuterRadius(sp, L) - d;
  if (!L.loop) return arc(0, 0, rc, 0, TAU, 180).slice(0, -1);
  const { cy } = sp.loop;
  const Rl = sp.loop.ro - d;
  const yi = (rc * rc - Rl * Rl + cy * cy) / (2 * cy);
  const xi2 = rc * rc - yi * yi;
  if (xi2 <= 0) return arc(0, 0, rc, 0, TAU, 180).slice(0, -1);
  const xi = Math.sqrt(xi2);
  const thL = Math.atan2(yi, -xi), thR = Math.atan2(yi, xi);
  const main = arc(0, 0, rc, thL, thR + TAU, 160);
  // The loop's arc runs from the right intersection OVER THE TOP to the left.
  // Where the intersection sits below the loop's centre (a thin first layer
  // with the edge round, a deep wall inset) atan2 hands back a negative left
  // angle, and the arc would run under the loop instead — through the bore.
  const phR = Math.atan2(yi - cy, xi);
  let phL = Math.atan2(yi - cy, -xi);
  if (phL < phR) phL += TAU;
  const loop = arc(0, cy, Rl, phR, phL, 48);
  return main.concat(loop.slice(1, -1));
}

/**
 * The loop's hole, grown by `d`: inside the loop's inner circle and outside
 * the main ring. A lune. Null on layers without the loop or when it closes.
 */
function loopHole(sp, L, d) {
  if (!L.loop) return null;
  const rc = ringOuterRadius(sp, L) - d;
  const { cy } = sp.loop;
  const Rl = sp.loop.ri + d;
  const yi = (rc * rc - Rl * Rl + cy * cy) / (2 * cy);
  const xi2 = rc * rc - yi * yi;
  if (xi2 <= 0 || yi >= cy + Rl) return null;
  const xi = Math.sqrt(xi2);
  const phR = Math.atan2(yi - cy, xi);
  let phL = Math.atan2(yi - cy, -xi);
  if (phL < phR) phL += TAU;                 // same as above: over the top, never under
  const inner = arc(0, cy, Rl, phR, phL, 40);
  const thL = Math.atan2(yi, -xi), thR = Math.atan2(yi, xi);
  const main = arc(0, 0, rc, thL, thR, 24);
  const pts = inner.concat(main.slice(1, -1));
  return pts.length >= 3 ? pts : null;
}

/** An axis-aligned rectangle centred on the origin, grown by `g` on every side. */
function rectPoly(w, h, g) {
  const x = w / 2 + g, y = h / 2 + g;
  return [{ x: -x, y: -y }, { x, y: -y }, { x, y }, { x: -x, y }];
}

// ---------------------------------------------------------------------------
// Fills. Regions are sets of polygons under the even-odd rule, so a boundary
// and its holes are simply listed together.

/**
 * Scanline spans of a multi-polygon region at `angleDeg`, `spacing` apart.
 * Returns rows in the scan frame plus the map back to body-centred mm.
 */
function regionRows(polys, spacing, phase, angleDeg, minLen) {
  const a = (angleDeg * Math.PI) / 180;
  const ca = Math.cos(a), sa = Math.sin(a);
  const toScan = (p) => ({ x: p.x * ca + p.y * sa, y: -p.x * sa + p.y * ca });
  const fromScan = (p) => ({ x: p.x * ca - p.y * sa, y: p.x * sa + p.y * ca });
  const work = polys.filter((p) => p && p.length >= 3).map((p) => p.map(toScan));
  if (!work.length) return { rows: [], fromScan };
  let yMin = Infinity, yMax = -Infinity;
  for (const poly of work) for (const p of poly) { if (p.y < yMin) yMin = p.y; if (p.y > yMax) yMax = p.y; }
  const rows = [];
  for (let y = yMin + spacing * 0.5 + phase; y <= yMax - 0.001; y += spacing) {
    const xs = [];
    for (const poly of work) {
      for (let i = 0; i < poly.length; i++) {
        const p = poly[i], q = poly[(i + 1) % poly.length];
        if ((p.y <= y && q.y > y) || (q.y <= y && p.y > y)) xs.push(p.x + ((y - p.y) / (q.y - p.y)) * (q.x - p.x));
      }
    }
    xs.sort((p, q) => p - q);
    const spans = [];
    for (let k = 0; k + 1 < xs.length; k += 2) if (xs[k + 1] - xs[k] > minLen) spans.push([xs[k], xs[k + 1]]);
    if (spans.length) rows.push({ y, spans });
  }
  return { rows, fromScan };
}

/** The design coverage grid, laid out exactly as fill.js and image.js lay theirs. */
function gridSpec(cfgD, bbox) {
  const cell = cfgD.build.designCell ?? 0.12;
  const pad = Math.ceil(3 / cell);
  const w = Math.ceil(bbox.w / cell) + pad * 2;
  const h = Math.ceil(bbox.h / cell) + pad * 2;
  return { w, h, cell, pad, toCell: (p) => ({ x: p.x / cell + pad, y: p.y / cell + pad }), toMm: (c) => ({ x: (c.x - pad) * cell, y: (c.y - pad) * cell }) };
}

/** The same drawing seen from the other side: flipped left-to-right. */
export function mirrorCoverage(cov, bboxW) {
  if (!cov) return null;
  const mask = new Uint8Array(cov.w * cov.h);
  const shift = Math.round(bboxW / cov.cell) + 2 * cov.pad;
  for (let j = 0; j < cov.h; j++) {
    for (let i = 0; i < cov.w; i++) {
      const i2 = shift - i;
      if (i2 >= 0 && i2 < cov.w && cov.mask[j * cov.w + i]) mask[j * cov.w + i2] = 1;
    }
  }
  return { ...cov, mask };
}

// ---------------------------------------------------------------------------

export function generateSpinner(design, cfg) {
  // NFC off for this job: no pocket, no bridge, no pause — a solid spinner.
  // The design says so; the config's nfc.enabled is only the default.
  if (design.nfc === false && cfg.spinner?.nfc?.enabled !== false) {
    cfg = { ...cfg, spinner: { ...cfg.spinner, nfc: { ...cfg.spinner.nfc, enabled: false } } };
  }
  const plan = spinnerLayerPlan(cfg);
  const sp = plan.spec;
  const N = sp.layers;
  const { filamentDensity, accelFudge } = printConstants();
  const filamentDiameter = cfg.build.filamentDiameter ?? 1.75;
  const crossSection = Math.PI * Math.pow(filamentDiameter / 2, 2);
  const bbox = spinnerBBox(cfg);
  // Everything the shared drawing code reads from cfg.build, with the
  // spinner's own numbers over the keychain's.
  const cfgD = { ...cfg, build: { ...cfg.build, lineWidth: sp.lineWidth, layerHeight: sp.layerH, firstLayerHeight: sp.first, wallLoops: sp.walls, infillWallOverlap: sp.overlapFrac, designEdgeMargin: sp.designEdgeMargin, penRange: sp.penRange, beadModel: sp.beadModel }, speed: { ...cfg.speed, ...(cfg.spinner?.speed || {}) } };
  const s = cfgD.speed;
  const lw = sp.lineWidth;
  // body-centred mm -> bed. The body's centre sits at (outerR, outerR) of the
  // plate-local box shapePolygon('spinner') describes; the loop takes the rest.
  const R0 = sp.outerR;
  const toBedC = (p) => toBed({ x: p.x + R0, y: p.y + R0 }, bbox, cfgD);

  // ---- the drawings ----
  const discPoly = [];
  for (let k = 0; k < 120; k++) { const a = (TAU * k) / 120; discPoly.push({ x: R0 + sp.discR * Math.cos(a), y: R0 + sp.discR * Math.sin(a) }); }
  const coverageOf = (face) => {
    if (!face) return { cov: null, strokes: [], bitmap: null };
    const bitmap = face.image ? decodeBitmap(face.image) : null;
    const strokes = prepareStrokes(face.design || [], discPoly, cfgD, null, sp.designEdgeMargin);
    const cov = unionCoverage(
      bitmap ? imageCoverage(bitmap, cfgD, bbox, discPoly, null, sp.designEdgeMargin) : null,
      strokes.length ? buildCoverage(strokes, cfgD, bbox, discPoly, null, sp.designEdgeMargin) : null,
    );
    return { cov, strokes, bitmap };
  };
  const faces = design.faces || {};
  const top = coverageOf(faces.top);
  const sameBoth = design.sameBothSides !== false && !faces.bottom;
  const bottomSrc = sameBoth ? top : coverageOf(faces.bottom);
  // The back is drawn as it will be seen from the back. Seen from the bed's
  // side, that is left-to-right reversed.
  const bottomCov = mirrorCoverage(bottomSrc.cov, bbox.w);
  const topCov = top.cov;
  const grid = gridSpec(cfgD, bbox);

  // ---- temperatures per colour, as the keychain does ----
  const _ov = cfg.temp?.colourOverrides || {};
  const _eff = (col, base) => Math.max(base ?? 0, _ov[col] ?? 0);
  const tempFor = (colour) => _eff(colour === 1 ? design.colours?.layer1 : design.colours?.layer2, cfg.temp?.nozzle);
  const bedT = sp.bedTemp ?? cfg.temp?.bed, bedT1 = sp.bedTemp ?? cfg.temp?.bedFirst;
  const cfgStart = { ...cfgD, temp: { ...cfg.temp, bed: bedT, bedFirst: bedT1, nozzle: tempFor(1), nozzleFirst: _eff(design.colours?.layer1, cfg.temp?.nozzleFirst) }, calibration: { ...cfg.calibration, area: levelArea(bbox, cfgD) } };
  // The change block takes the colour it changes INTO: its temperature, and
  // the filament index (0 = body, 1 = drawing) for the printer's own sequence.
  const cfgFor = (colour) => ({ ...cfgD, temp: { ...cfg.temp, nozzle: tempFor(colour) }, colourChange: { ...(cfg.colourChange || {}), tool: colour - 1 } });

  const em = makeEmitter(cfgD, crossSection);
  em.comment(`3DiPad NFC spinner  Ø${(2 * sp.outerR).toFixed(0)}mm x ${sp.thickness}mm  ${N} layers`);
  em.comment(`colour1(body): ${design.colours?.layer1 ?? '?'}   colour2(drawing): ${design.colours?.layer2 ?? '?'}`);
  em.raw(applyTemplate(cfgStart.template.startResolved, cfgStart));
  em.raw('G90'); em.raw('M83');
  // Bambu's own start for the textured plate lowers the nozzle a touch
  // (G29.1 Z-0.02): a 0.2 mm first layer needs the squish a 0.28 one forgives.
  // Reset at the end so a keychain printed next inherits nothing.
  if (sp.firstZOffset) em.raw(`G29.1 Z${sp.firstZOffset} ; first-layer squish for the textured plate`);
  const marks = [{ at: em.lines.length, t: 0, pct: 0 }];

  // ---- the program: which layer, which part, which colour, in order ----
  const cL = sp.colourLayers;
  const seq = [];
  const body = (i) => ({ i, part: 'body', colour: 1 });
  const dsgn = (i, face) => ({ i, part: 'design', colour: 2, face });
  seq.push(body(1));
  if (bottomCov) for (let i = 1; i <= cL; i++) seq.push(dsgn(i, 'bottom'));
  const topStart = N - cL + 1;
  if (topCov && cL > 1) {
    for (let i = 2; i <= N - 1; i++) seq.push(body(i));
    for (let i = topStart; i <= N; i++) seq.push(dsgn(i, 'top'));
    seq.push(body(N));
  } else {
    for (let i = 2; i <= N; i++) seq.push(body(i));
    if (topCov) seq.push(dsgn(N, 'top'));
  }

  let current = 1;
  let swaps = 0;
  let fanOn = false;
  let zNow = 0;
  const filamentBy = [0, 0];
  let filamentMark = 0;
  const tally = () => { const now = em.meta().filamentMm; filamentBy[current - 1] += now - filamentMark; filamentMark = now; };
  const feedFor = (L, kind) => {
    if (L.i === 1) return s.firstLayer;
    if (kind === 'perim') return s.perimeter;
    if (kind === 'top') return s.topSurface ?? s.solidInfill;
    if (kind === 'solid') return s.solidInfill;
    return s.infill;
  };

  const L = (i) => plan.layers[i - 1];
  const insetCache = new Map();
  const cachedDisc = (i, d) => {
    const key = `${i}:${d.toFixed(3)}`;
    if (!insetCache.has(key)) insetCache.set(key, discOutline(sp, L(i), d, plan.footDz));
    return insetCache.get(key);
  };

  /** A closed wall loop, with a slower feed where `zone` says the wall hangs over air. */
  // The first layer is laid wider (the slicer's initial_layer_line_width) and
  // can be told to run richer; every width and inset below follows `lay`.
  let lay = null;
  const layFor = (Li) => {
    const w = Li.i === 1 ? sp.firstLineWidth : lw;
    const eW = w * (Li.i === 1 ? sp.firstFlow : 1);
    // The pitch lines sit on. A rounded bead of width w only covers w minus
    // the two rounded shoulders, so the slicer lays them closer than w —
    // 0.377 for a 0.42 line at 0.2 — and that is what fills a top surface
    // flat. Laid a full width apart, the same beads leave a ridge between
    // every pair.
    const h = Li.h;
    const pitch = sp.beadModel === 'rounded' && w > h ? w - h * (1 - Math.PI / 4) : w;
    const ov = pitch * sp.overlapFrac;
    // the outer wall sits half a bead inside the edge; every line after it is a pitch further in
    const wallD = (k) => w / 2 + k * pitch;
    const anchorInset = wallD(sp.walls) - ov;
    // Solid fill ends: half a pitch past the last loop it meets, less the
    // overlap — the anchor loop when there is one, the innermost wall when not.
    const fillInset = sp.anchorLoop ? anchorInset + (pitch / 2 - ov) : wallD(sp.walls - 1) + pitch / 2 - ov;
    return { lw: w, eW, pitch, wallD, cfg: { ...cfgD, build: { ...cfgD.build, lineWidth: eW, lineSpacing: pitch } }, anchorInset, fillInset };
  };
  /**
   * A closed wall loop with a crossfaded seam. The first `seamOverlap` mm
   * ramp the flow up from nothing, and after closing the loop runs that far
   * again over its own start with the flow ramping down — the two add up to
   * one full bead everywhere, and there is no start to starve and no end to
   * blob. A plain overlap was tried first (0.4 mm past the start, full flow)
   * and the nick simply moved with the seam: the starved stretch after a
   * travel is longer than that. This is what the slicer's scarf seam does,
   * minus the Z ramp; its file has "scarf seam on circles" on for this part.
   */
  const wallLoop = (poly, feed, layerH, zone) => {
    if (!poly || poly.length < 3) return;
    let total = 0;
    for (let k = 0; k < poly.length; k++) { const a = poly[k], b = poly[(k + 1) % poly.length]; total += Math.hypot(b.x - a.x, b.y - a.y); }
    const S = Math.min(sp.seamOverlap, total * 0.25);
    const p0 = toBedC(poly[0]);
    em.travelTo(p0.x, p0.y);
    // walk the loop, subdividing inside the two ramps so they are smooth
    const step = 0.3;
    const walk = (from, to, dist, flowAt) => {
      const L = Math.hypot(to.x - from.x, to.y - from.y);
      if (L < 1e-6) return dist;
      const n = flowAt ? Math.max(1, Math.ceil(L / step)) : 1;
      for (let j = 1; j <= n; j++) {
        const t = j / n;
        const q = { x: from.x + (to.x - from.x) * t, y: from.y + (to.y - from.y) * t };
        const p = toBedC(q);
        const f = flowAt ? flowAt(dist + L * (t - 0.5 / n)) : 1;
        em.extrudeTo(p.x, p.y, zone && zone(q) ? sp.overhangWallSpeed : feed, lay.eW, layerH, f);
      }
      return dist + L;
    };
    let d = 0;
    for (let k = 0; k < poly.length; k++) {
      const a = poly[k], b = poly[(k + 1) % poly.length];
      d = walk(a, b, d, d < S ? (x) => Math.min(1, x / S) : null);
    }
    // ...and over the start again, fading out
    let over = 0;
    for (let k = 0; k < poly.length && over < S; k++) {
      const a = poly[k], b = poly[(k + 1) % poly.length];
      const L = Math.hypot(b.x - a.x, b.y - a.y);
      const t = Math.min(1, (S - over) / Math.max(L, 1e-6));
      const end = { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t };
      over = walk(a, end, over, (x) => Math.max(0, 1 - x / S));
    }
  };
  // The ring's loops start at the bottom, where a seam hides under the part in
  // the hand. Built as they are, the outline starts where the loop's arc
  // meets the ring — top left, the most looked-at spot on the thing.
  const fromBottom = (poly) => {
    if (!poly || poly.length < 3) return poly;
    let best = 0, bestD = Infinity;
    for (let k = 0; k < poly.length; k++) { const d = Math.hypot(poly[k].x, poly[k].y + 100); if (d < bestD) { bestD = d; best = k; } }
    return poly.slice(best).concat(poly.slice(0, best));
  };
  const fillRegion = (polys, spacing, feed, layerH, angle, phase) => {
    const { rows, fromScan } = regionRows(polys, spacing, phase, angle, 0.2);
    if (rows.length) drawSpanRegions(em, lay.cfg, bbox, rows, spacing, feed, layerH, (p) => { const q = fromScan(p); return { x: q.x + R0, y: q.y + R0 }; });
  };

  const pinZone = (q) => Math.abs(q.x) < sp.pin.r + 1 && Math.abs(q.y) > sp.discR - 1;

  function emitRing(Li, layerH) {
    const solid = Li.ringSolid;
    const perimFeed = feedFor(Li, 'perim');
    const isFace = Li.i === 1 || Li.i === N;
    const infillFeed = feedFor(Li, isFace ? 'top' : solid ? 'solid' : 'sparse');
    em.comment(`ring ${solid ? 'solid' : 'sparse'}${Li.loop ? ' +loop' : ''}${Li.pocket ? ' pocket' : ''}`);
    // walls: inner loops first, outer last, the order Bambu Studio uses
    const { lw: lwL, pitch, anchorInset, fillInset } = lay;
    for (let w = sp.walls - 1; w >= 0; w--) {
      const d = lay.wallD(w);
      em.comment(w === 0 ? 'outer wall' : 'inner wall');
      wallLoop(fromBottom(ringOuterOutline(sp, Li, d)), perimFeed, layerH);
      wallLoop(loopHole(sp, Li, d), perimFeed, layerH);
      wallLoop(fromBottom(ringInnerOutline(sp, Li, d)), perimFeed, layerH, Li.pocketShrinking ? pinZone : null);
    }
    const dFill = solid ? fillInset : anchorInset;
    if (solid && sp.anchorLoop) {
      em.comment('solid infill boundary');
      wallLoop(fromBottom(ringOuterOutline(sp, Li, anchorInset)), infillFeed, layerH);
      wallLoop(loopHole(sp, Li, anchorInset), infillFeed, layerH);
      wallLoop(fromBottom(ringInnerOutline(sp, Li, anchorInset)), infillFeed, layerH, Li.pocketShrinking ? pinZone : null);
    }
    em.comment(solid ? 'solid infill' : 'sparse infill');
    const spacing = solid ? pitch : sp.sparseSpacing;
    fillRegion([ringOuterOutline(sp, Li, dFill), loopHole(sp, Li, dFill), ringInnerOutline(sp, Li, dFill)],
      spacing, infillFeed, layerH, Li.i % 2 ? 45 : 135, (Li.i % 2) * (spacing / 2));
  }

  function emitDisc(Li, layerH) {
    const solid = Li.discSolid;
    const perimFeed = feedFor(Li, 'perim');
    const isFace = Li.i === 1 || Li.i === N;
    const infillFeed = feedFor(Li, isFace ? 'top' : solid ? 'solid' : 'sparse');
    const cav = Li.cavity ? { w: sp.nfc.w, h: sp.nfc.h } : null;
    em.comment(`disc ${solid ? 'solid' : 'sparse'}${Li.pin ? ' pin' : Li.foot ? ' pin-foot' : ''}${cav ? ' NFC-cavity' : ''}${Li.bridge ? ' bridge' : ''}${Li.colour ? ` ${Li.colour}-face` : ''}`);
    const { lw: lwL, pitch, anchorInset, fillInset } = lay;
    for (let w = sp.walls - 1; w >= 0; w--) {
      const d = lay.wallD(w);
      em.comment(w === 0 ? 'outer wall' : 'inner wall');
      wallLoop(cachedDisc(Li.i, d), perimFeed, layerH, Li.pinGrowing ? pinZone : null);
      if (cav) wallLoop(rectPoly(cav.w, cav.h, d), perimFeed, layerH);
    }
    if (solid && sp.anchorLoop) {
      em.comment('solid infill boundary');
      wallLoop(cachedDisc(Li.i, anchorInset), infillFeed, layerH);
      if (cav) wallLoop(rectPoly(cav.w, cav.h, anchorInset), infillFeed, layerH);
    }
    const dFill = solid ? fillInset : anchorInset;
    const outline = cachedDisc(Li.i, dFill);
    const angle = Li.i % 2 ? 45 : 135;

    if (Li.colour) {
      // The face: everything the drawing does not claim, filled in the body
      // colour. The drawing's own outline lands lw/2 inside its mask and the
      // body reaches `overlap` into it, so the two meet without a groove.
      const cov = Li.colour === 'top' ? topCov : bottomCov;
      const cells = outline.map((p) => grid.toCell({ x: p.x + R0, y: p.y + R0 }));
      const mask = fillPolygon(cells, grid.w, grid.h);
      if (cov) {
        // The pocket gets a wall of its own in the body colour, the way a
        // slicer walls any hole, and the fill ends against that wall instead
        // of against thin air. Fill lines ending on the drawing's edge left a
        // groove all the way round it on the first print with a drawing.
        const wallR = Math.max(0, lwL / 2 - sp.inlayOverlap);          // centreline, outside the drawing's edge
        const wallMask = dilate(cov.mask, cov.w, cov.h, wallR / cov.cell);
        em.comment('pocket walls around the drawing');
        for (const loop of maskContours(wallMask, cov.w, cov.h)) {
          const pts = contourToMm(loop, cov).map((p) => ({ x: p.x - R0, y: p.y - R0 }));
          if (pts.length >= 6) wallLoop(pts, perimFeed, layerH);
        }
        const keep = dilate(cov.mask, cov.w, cov.h, (wallR + pitch / 2 - pitch * sp.overlapFrac) / cov.cell);
        for (let k = 0; k < mask.length; k++) if (keep[k]) mask[k] = 0;
      }
      em.comment('solid infill (around the drawing)');
      const { rows, fromScan } = maskRowsAngle(mask, grid, angle, pitch, 0, lwL * 0.5);
      if (rows.length) drawSpanRegions(em, lay.cfg, bbox, rows, pitch, infillFeed, layerH, fromScan);
      return;
    }
    if (Li.bridge) {
      // The cavity roof: lines across the SHORT axis, slow, fan full, anchored a
      // millimetre onto the walls either side. The rest of the layer is normal.
      const a = sp.nfc.anchorMm;
      em.comment('solid infill');
      fillRegion([outline, rectPoly(sp.nfc.w, sp.nfc.h, a)], pitch, infillFeed, layerH, angle, 0);
      em.comment(`bridge over the NFC cavity @ ${Math.round(sp.bridgeSpeed / 60)} mm/s`);
      em.raw('M106 S255 ; full fan for the bridge');
      const along = sp.nfc.w >= sp.nfc.h ? 90 : 0;   // lines cross the shorter span
      fillRegion([rectPoly(sp.nfc.w, sp.nfc.h, a)], pitch, sp.bridgeSpeed, layerH, along, 0);
      em.raw(`M106 S${Math.round(cfg.fan?.other ?? 255)}`);
      return;
    }
    em.comment(solid ? 'solid infill' : 'sparse infill');
    const spacing = solid ? pitch : sp.sparseSpacing;
    fillRegion([outline, cav ? rectPoly(cav.w, cav.h, dFill) : null], spacing, infillFeed, layerH, angle, (Li.i % 2) * (spacing / 2));
  }

  /**
   * The support under each pin's nose: an arc of lines in the clearance gap,
   * `supportClearance` from both the disc and the ring so it fuses to
   * neither, `supportWidth` long along the gap. Loose by design.
   */
  function emitPinSupport(Li, layerH) {
    const c = sp.pin.supportClearance;
    const lwL = lay.lw, pitch = lay.pitch;
    const r0 = sp.discR + c + lwL / 2, r1 = sp.ringInnerR - c - lwL / 2;
    if (r1 < r0) return;
    const half = sp.pin.supportWidth / 2;
    em.comment('support under the pins');
    for (const dir of [1, -1]) {
      let k = 0;
      for (let r = r0; r <= r1 + 1e-6; r += pitch, k++) {
        const a0 = Math.PI / 2 * dir - half / r, a1 = Math.PI / 2 * dir + half / r;
        const n = 16;
        const pts = [];
        for (let j = 0; j <= n; j++) { const a = a0 + ((a1 - a0) * j) / n; pts.push({ x: r * Math.cos(a), y: r * Math.sin(a) }); }
        if (k % 2) pts.reverse();
        const p0 = toBedC(pts[0]);
        if (k === 0) em.travelTo(p0.x, p0.y); else em.moveTo(p0.x, p0.y);
        for (let j = 1; j < pts.length; j++) { const p = toBedC(pts[j]); em.extrudeTo(p.x, p.y, feedFor(Li, 'perim'), lay.eW, layerH); }
      }
    }
  }

  function nfcPause(Li) {
    const c = cfg.colourChange || {};
    const t = tempFor(current);
    const up = +(zNow + (c.liftMm ?? 4)).toFixed(2);
    em.comment(`===== NFC PAUSE before layer ${Li.i}: drop the tag into the pocket, then press Resume =====`);
    em.raw('M400');
    em.raw(`G1 E-${(s.retractMm ?? 0.8).toFixed(3)} F${Math.round(s.retractSpeed ?? 2400)}`);
    em.raw(`G1 Z${up} F1200`);
    em.raw(`G1 X${c.parkX ?? 180} Y${c.parkY ?? 90} F18000 ; park clear of the part`);
    em.raw('M400 U1 ; ===== PUT THE NFC TAG IN NOW, then press Resume on the printer =====');
    em.raw(`M109 S${t} ; back to temperature after the pause`);
    em.raw('G92 E0');
    em.raw(`G1 E${((s.retractMm ?? 0.8) + 4).toFixed(2)} F300 ; re-prime after the pause`);
    for (const l of ['G1 E-1.5 F1800', 'G1 E1.5 F300', 'M400', 'M106 P1 S178', 'M400 S2']) em.raw(l);
    for (let k = 0; k < 3; k++) { em.raw('G1 X-3.5 F18000'); em.raw('G1 X-13.5 F3000'); }
    for (const l of ['M400', `M106 S${Math.round(cfg.fan?.other ?? 255)}`, 'G92 E0', `G1 Z${up} F3000`]) em.raw(l);
  }

  // ---- run the program ----
  for (const seg of seq) {
    const Li = L(seg.i);
    const layerH = Li.h;
    lay = layFor(Li);
    if (seg.colour !== current) {
      tally();
      const target = seg.colour;
      em.comment(`===== COLOUR CHANGE ${swaps + 1}: load ${target === 2 ? (design.colours?.layer2 ?? 'colour 2') : (design.colours?.layer1 ?? 'colour 1')}, then Resume =====`);
      const swap = colourChangeBlock(cfgFor(target), zNow);
      // The same guard the keychain has: a change block with no stop in it is a
      // print that never pauses and comes out in one colour.
      if (!swap.some((l) => /^\s*M400\s+U1\b/.test(l)) && !changeStopsItself(cfg)) {
        throw new Error('The colour-change block contains no M400 U1, so the print would never stop to swap filament. Check colourChange in config.json.');
      }
      for (const line of swap) em.raw(line);
      if (fanOn) em.raw(`M106 S${Math.round(cfg.fan?.other ?? 255)} ; part cooling back on after the change`);
      current = target;
      swaps++;
      filamentMark = em.meta().filamentMm;
    }
    if (seg.part === 'body' && Li.bridge && plan.nfcPauseLayer === Li.i) nfcPause(Li);
    marks.push({ at: em.lines.length, t: em.timeNow() });
    em.comment(`layer ${Li.i}/${N} z=${Li.zTop.toFixed(2)} ${seg.part}${seg.face ? ' ' + seg.face : ''} colour ${seg.colour}`);
    if (Li.zTop !== zNow) { em.setZ(Li.zTop); zNow = Li.zTop; }
    if (!fanOn && Li.i >= 2) { em.raw(`M106 S${Math.round(cfg.fan?.other ?? 255)} ; part cooling on`); fanOn = true; }
    if (seg.part === 'body') {
      emitRing(Li, layerH);
      emitDisc(Li, layerH);
      if (Li.support) emitPinSupport(Li, layerH);
    } else {
      const cov = seg.face === 'top' ? topCov : bottomCov;
      const k = seg.face === 'top' ? Li.i - topStart : Li.i - 1;
      em.comment(`drawing (${seg.face} face) layer ${k + 1}/${cL}`);
      // the same 45/135 the body runs at on this layer, so face and drawing read as one surface
      designLayer(em, lay.cfg, bbox, cov, s.bead, layerH, k % 2 === 1, Li.i % 2 ? 45 : 135);
    }
  }
  tally();

  marks.push({ at: em.lines.length, t: em.timeNow(), pct: 100 });
  if (sp.firstZOffset) em.raw('G29.1 Z0 ; back to no offset for whatever prints next');
  em.raw(applyTemplate(cfg.template.endResolved, cfgStart));

  const raw = em.meta();
  const startupMin = startupMinutes(cfg);
  const pauseMin = swaps * sp.swapMinutes + (plan.nfcPauseLayer > 0 ? sp.pauseMinutes : 0);
  const estMinutes = raw.timeMin * accelFudge + startupMin + pauseMin;
  const grams = raw.filamentMm * crossSection * filamentDensity;
  const lines = spliceProgress(em, marks, { startupMin, estMinutes, rawTimeMin: raw.timeMin });

  // Which layers carry which filament, 0-indexed, the way Bambu's slice_info
  // declares it — so the printer knows where the second colour appears.
  const filamentLayerLists = [];
  const both = [];
  if (bottomCov) both.push(`0 ${cL - 1}`);
  if (topCov) both.push(`${N - cL} ${N - 1}`);
  if (both.length) filamentLayerLists.push({ list: '0 1', ranges: both.join(',') });
  const midFrom = bottomCov ? cL : 0, midTo = topCov ? N - cL - 1 : N - 1;
  if (midTo >= midFrom) filamentLayerLists.push({ list: '0', ranges: `${midFrom} ${midTo}` });

  const strokeCount = top.strokes.length + (sameBoth ? 0 : bottomSrc.strokes.length);
  return {
    gcode: bambuBlocks(lines, {
      layers: N, filamentMm: raw.filamentMm, filamentMmByColour: filamentBy, grams, minutes: estMinutes,
      maxZ: sp.thickness, density: +(filamentDensity * 1000).toFixed(2), diameter: filamentDiameter,
    }),
    meta: {
      product: 'spinner', shape: 'spinner', bbox, hole: null, colours: design.colours,
      layers: N, backingLayers: N - cL, designLayers: cL,
      faces: { top: !!topCov, bottom: !!bottomCov }, sameBothSides: sameBoth,
      hasDesign: !!(topCov || bottomCov), fromImage: !!(top.bitmap || (!sameBoth && bottomSrc.bitmap)),
      strokeCount, drawnLengthMm: Math.round(totalLength(top.strokes) + (sameBoth ? 0 : totalLength(bottomSrc.strokes))),
      swaps, nfc: !!plan.cavityLayers, nfcPauseLayer: plan.nfcPauseLayer, cavityLayers: plan.cavityLayers,
      pauses: plan.nfcPauseLayer > 0 ? [{ layer: plan.nfcPauseLayer }] : [],
      pinSupport: plan.layers.filter((L) => L.support).map((L) => L.i),
      filamentLayerLists,
      estMinutes: +estMinutes.toFixed(1), estGrams: +grams.toFixed(1),
      overBudget: estMinutes > sp.maxPrintMinutes, nearBudget: estMinutes > sp.warnPrintMinutes,
      flowClampedMoves: raw.flowClampedMoves, flowClampedMm: raw.flowClampedMm,
    },
  };
}
