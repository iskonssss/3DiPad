// Core g-code engine — pure and printer-independent.
//
// generate(design, cfg) -> { gcode, meta }
//   design = {
//     shape: 'rectangle'|'square'|'circle'|'heart'|'custom',
//     customOutline: [ {x,y}, ... ],          // only for shape='custom' (plate-local mm)
//     colours: { layer1, layer2 },            // labels only; not in the g-code
//     hole: { x, y } | null,                   // tapped hole centre (plate-local mm)
//     holePos: 'left'|'right'|'top' | null,    // preset used if hole is null
//     design: [ { w, pts:[{x,y}...] }, ... ],  // strokes with per-stroke pen width
//   }
//
// Object = flat two-colour keychain: backing plate (colour 1) -> M400 U1 colour
// change -> raised bead drawing (colour 2). The backing's top rim and the hole's
// top edge get a 45° chamfer over the top `chamferMm`.

import {
  shapePolygon, scanlineSpans, subtractInterval, boundsY,
  toBed, presetHole, holeIsValid, pointInPolygon,
} from './geometry.js';
import { prepareStrokes, totalLength } from './strokes.js';
import { insetPolygon } from './outline.js';

const FILAMENT_DENSITY = 0.00124; // g/mm^3 (PLA)
const ACCEL_FUDGE = 1.6;
const STARTUP_MIN = 2.5;

export function generate(design, cfg) {
  const b = cfg.build;
  const s = cfg.speed;
  const shape = design.shape || 'rectangle';
  const crossSection = Math.PI * Math.pow(b.filamentDiameter / 2, 2);

  const { poly, bbox } = shapePolygon(shape, cfg, design.customOutline);
  const hole = resolveHole(design, poly, bbox, cfg);
  const em = makeEmitter(cfg, crossSection);

  em.comment(`3DiPad keychain  shape:${shape}  ${bbox.w.toFixed(0)}x${bbox.h.toFixed(0)}mm`);
  em.comment(`layer1(backing): ${design.colours?.layer1 ?? '?'}   layer2(design): ${design.colours?.layer2 ?? '?'}`);
  em.raw(applyTemplate(cfg.template.startResolved, cfg));
  em.raw('G90'); em.raw('M83');
  // Bambu's on-screen progress and time-remaining come from M73. Without it the
  // printer shows 0:00 for the whole print. Marks are collected as we go and
  // filled in at the end, once the total is known.
  const marks = [{ at: em.lines.length, t: 0, pct: 0 }];

  // ---- backing plate (colour 1) ----
  const backingZs = layerZs(b.firstLayerHeight, b.layerHeight, b.backingThickness);
  const nBack = backingZs.length;
  em.comment(`===== BACKING (colour 1) — ${shape}, ${nBack} layers =====`);

  // Inset outlines are rasterised, so cache them by distance — several layers
  // share the same inset and each computation is not free.
  const insetCache = new Map();
  const insetAt = (d) => {
    const key = d.toFixed(3);
    if (!insetCache.has(key)) insetCache.set(key, insetPolygon(poly, d, { cell: 0.25 }));
    return insetCache.get(key);
  };

  backingZs.forEach((z, i) => {
    const layerH = i === 0 ? b.firstLayerHeight : b.layerHeight;
    const first = i === 0;
    const solid = first || i < b.solidLayers || i >= nBack - b.solidLayers;
    const spacing = solid ? b.lineWidth : b.sparseSpacing;
    const infillFeed = first ? s.firstLayer : solid ? s.solidInfill : s.infill;
    const perimFeed = first ? s.firstLayer : s.perimeter;

    // Chamfer: over the top `chamferMm` the layer is inset so the rim bevels.
    // Every layer still gets a real perimeter — without one the top layers are
    // just ragged infill ends, which is what a missing wall looks like in PLA.
    const cham = Math.max(0, b.chamferMm - (b.backingThickness - z));
    const holeR = hole.r + cham;

    // Walls: two loops, like a real slicer. The outer centreline sits half a
    // line width inside the nominal edge so the part measures what was drawn.
    const lw = b.lineWidth;
    const walls = Math.max(1, b.wallLoops ?? 2);
    const overlap = lw * (b.infillWallOverlap ?? 0.15);
    // Solid surfaces get one more loop hugging the fill boundary before the
    // scanline fill. Diagonal fill lines END on that boundary, and consecutive
    // ends sit spacing/sin(45) apart while each only covers a line width — so
    // without the loop the rim carries a scalloped groove between the fill and
    // the wall. Sparse layers are internal and don't need the extra pass.
    const anchor = solid ? 1 : 0;
    // infill starts just inside the innermost loop and overlaps into it, which
    // is what stops a visible groove appearing between the wall and the fill
    const anchorInset = cham + lw * (walls + 0.5) - overlap;
    const fillInset = anchorInset + lw * anchor - overlap * anchor;

    em.comment(`layer ${i + 1}/${nBack} z=${z.toFixed(2)} ${solid ? 'solid' : 'sparse'}${cham > 0 ? ` chamfer ${cham.toFixed(2)}mm` : ''}`);
    marks.push({ at: em.lines.length, t: em.timeNow() });
    em.setZ(z);
    // Part cooling: off for the first layer so it sticks, then on for the rest.
    // Printing the whole part with the fan off is what causes drooping and the
    // fine strings between travel moves.
    if (i === 1) em.raw(`M106 S${Math.round(cfg.fan?.other ?? 255)} ; part cooling on`);

    // inner walls first, outer wall last — the order Bambu Studio uses
    for (let wIdx = walls - 1; wIdx >= 0; wIdx--) {
      const loop = insetAt(cham + lw * (wIdx + 0.5));
      if (loop.length >= 3) {
        em.comment(wIdx === 0 ? 'outer wall' : 'inner wall');
        perimeterLoop(em, cfg, bbox, loop, perimFeed, layerH);
      }
    }
    // hole wall centreline sits a half width OUTSIDE the void, so the finished
    // hole is the full 5mm rather than 5mm minus a wall
    holePerimeter(em, cfg, bbox, hole, holeR + lw / 2, perimFeed, layerH);

    if (anchor) {
      const edgeLoop = insetAt(anchorInset);
      if (edgeLoop.length >= 3) {
        em.comment('solid infill boundary');
        perimeterLoop(em, cfg, bbox, edgeLoop, infillFeed, layerH);
      }
      // and the same closing loop around the hole, for the same reason
      holePerimeter(em, cfg, bbox, hole, holeR + lw * 1.5 - overlap, infillFeed, layerH);
    }

    const fillPoly = insetAt(fillInset);
    if (fillPoly.length >= 3) {
      em.comment(solid ? 'solid infill' : 'sparse infill');
      // 45 degrees, alternating per layer — diagonal to the walls, so lines
      // bond better and the surface doesn't read as one direction of banding
      infillLayer(em, cfg, bbox, fillPoly, hole, holeR + lw * (1 + anchor) - overlap * (1 + anchor), spacing, infillFeed, layerH,
        (i % 2) * (spacing / 2), i % 2 === 0 ? 45 : 135);
    }
  });

  // ---- colour change ----
  em.comment('===== COLOUR CHANGE (M400 U1): load layer-2 colour, then Resume =====');
  for (const line of asLines(cfg.colourChange.gcode)) em.raw(line);

  // ---- design (colour 2), raised beads ----
  const strokes = prepareStrokes(design.design || [], poly, cfg, hole, b.designEdgeMargin);
  // Design height is counted in layers, not mm — 2 layers reads as a raised
  // line you can feel without looking like a slab on top of the plate.
  const nDesign = Math.max(1, b.designLayers ?? Math.round((b.designThickness ?? 0.56) / b.layerHeight));
  // Stack on the LAST BACKING LAYER, not on the nominal backingThickness: a 2mm
  // backing at 0.28mm layers really tops out at 1.96mm, so measuring from 2.0
  // left the first design layer floating 0.32mm above the surface while being
  // extruded for 0.28 — a thin, badly-stuck bead.
  const backingTop = backingZs[nBack - 1];
  const designZs = [];
  for (let k = 1; k <= nDesign; k++) designZs.push(+(backingTop + k * b.layerHeight).toFixed(3));
  em.comment(`===== DESIGN (colour 2) — ${designZs.length} layers, ${strokes.length} strokes =====`);
  designZs.forEach((z) => {
    marks.push({ at: em.lines.length, t: em.timeNow() });
    em.setZ(z);
    for (const st of strokes) beadStroke(em, cfg, bbox, st, s.bead, b.layerHeight);
  });

  marks.push({ at: em.lines.length, t: em.timeNow(), pct: 100 });
  em.raw(applyTemplate(cfg.template.endResolved, cfg));

  const raw = em.meta();
  const estMinutes = raw.timeMin * ACCEL_FUDGE + STARTUP_MIN;
  const grams = raw.filamentMm * crossSection * FILAMENT_DENSITY;

  // Build one progress report per mark, dropping consecutive duplicates so the
  // printer isn't told the same thing twice.
  const reports = marks.map((m) => {
    const done = STARTUP_MIN + m.t * ACCEL_FUDGE;
    const pct = m.pct ?? Math.max(0, Math.min(100, Math.round((m.t / Math.max(raw.timeMin, 1e-6)) * 100)));
    const remaining = m.pct === 100 ? 0 : Math.max(0, Math.ceil(estMinutes - done));
    return `M73 P${pct} R${remaining}`;
  });
  // splice from the back so earlier indices stay valid
  const lines = em.lines.slice();
  for (let i = marks.length - 1; i >= 0; i--) {
    if (i > 0 && reports[i] === reports[i - 1]) continue;
    lines.splice(marks[i].at, 0, reports[i]);
  }

  return {
    gcode: lines.join('\n') + '\n',
    meta: {
      shape, bbox, hole: { x: +hole.cx.toFixed(1), y: +hole.cy.toFixed(1) }, colours: design.colours,
      backingLayers: nBack, designLayers: designZs.length, strokeCount: strokes.length,
      drawnLengthMm: Math.round(totalLength(strokes)),
      estMinutes: +estMinutes.toFixed(1), estGrams: +grams.toFixed(1),
      overBudget: estMinutes > cfg.limits.maxPrintMinutes, nearBudget: estMinutes > cfg.limits.warnPrintMinutes,
    },
  };
}

// Resolve the hole to a valid {cx,cy,r}: use the tapped point if valid, else a
// preset, else nudge toward the centroid until a wall fits.
function resolveHole(design, poly, bbox, cfg) {
  const r = cfg.build.holeDiameter / 2;
  let pt = design.hole && Number.isFinite(+design.hole.x) ? { x: +design.hole.x, y: +design.hole.y }
    : presetHole(design.holePos || 'top', bbox, cfg);
  if (!holeIsValid(pt, poly, cfg)) pt = nudgeInside(pt, poly, cfg);
  return { cx: pt.x, cy: pt.y, r };
}
function centroid(poly) {
  let x = 0, y = 0;
  for (const p of poly) { x += p.x; y += p.y; }
  return { x: x / poly.length, y: y / poly.length };
}
function nudgeInside(pt, poly, cfg) {
  const c = centroid(poly);
  for (let t = 0; t <= 1.001; t += 0.05) {
    const q = { x: pt.x + (c.x - pt.x) * t, y: pt.y + (c.y - pt.y) * t };
    if (holeIsValid(q, poly, cfg)) return q;
  }
  return pointInPolygon(c, poly) ? c : pt;
}

// ---------------------------------------------------------------------------

function layerZs(first, step, top) {
  const zs = []; let z = first;
  while (z <= top + 1e-6) { zs.push(+z.toFixed(3)); z += step; }
  if (!zs.length) zs.push(+first.toFixed(3));
  return zs;
}

function perimeterLoop(em, cfg, bbox, poly, feed, layerH) {
  if (poly.length < 3) return;
  const p0 = toBed(poly[0], bbox, cfg);
  em.travelTo(p0.x, p0.y);
  for (let i = 1; i <= poly.length; i++) {
    const p = toBed(poly[i % poly.length], bbox, cfg);
    em.extrudeTo(p.x, p.y, feed, cfg.build.lineWidth, layerH);
  }
}

function holePerimeter(em, cfg, bbox, hole, r, feed, layerH) {
  if (r <= 0.2) return;
  const seg = 32;
  const p0 = toBed({ x: hole.cx + r, y: hole.cy }, bbox, cfg);
  em.travelTo(p0.x, p0.y);
  for (let i = 1; i <= seg; i++) {
    const a = (2 * Math.PI * i) / seg;
    const p = toBed({ x: hole.cx + r * Math.cos(a), y: hole.cy + r * Math.sin(a) }, bbox, cfg);
    em.extrudeTo(p.x, p.y, feed, cfg.build.lineWidth, layerH);
  }
}

/**
 * Scanline fill of `poly` (already inset), with the hole carved out.
 *
 * `vertical` rotates the fill 90 degrees for this layer. Adjacent lines are
 * joined with a plain move instead of retract + Z-hop + travel: on a part this
 * small that removes hundreds of retractions per layer, which is most of the
 * stringing and a good chunk of the print time.
 */
/**
 * Scanline fill of `poly` (already inset), with the hole carved out.
 *
 * Two things matter here beyond just covering the area:
 *
 *  - `angleDeg` rotates the fill so it runs diagonally to the walls. The
 *    geometry is rotated into the scan frame and the emitted points rotated
 *    back, so the rest of the code needn't care.
 *
 *  - Spans are chained into connected regions before being drawn. A concave
 *    shape (a bat, a star) produces several separate spans on one scanline —
 *    filling row by row makes the head dash from one side of the part to the
 *    other and back for every line. Chaining fills one region completely,
 *    then moves on, which is how a slicer behaves.
 */
function infillLayer(em, cfg, bbox, poly, hole, holeR, spacing, feed, layerH, phase, angleDeg = 45) {
  const b = cfg.build;
  const a = (angleDeg * Math.PI) / 180;
  const ca = Math.cos(a), sa = Math.sin(a);
  const toScan = (p) => ({ x: p.x * ca + p.y * sa, y: -p.x * sa + p.y * ca });
  const fromScan = (p) => ({ x: p.x * ca - p.y * sa, y: p.x * sa + p.y * ca });

  const work = poly.map(toScan);
  const holeC = toScan({ x: hole.cx, y: hole.cy });
  const { yMin, yMax } = boundsY(work);

  // 1. gather the spans of every scanline
  const rows = [];
  for (let y = yMin + spacing * 0.5 + phase; y <= yMax - 0.001; y += spacing) {
    let spans = scanlineSpans(work, y).filter(([p, q]) => q - p > 0.2);
    if (spans.length && Math.abs(y - holeC.y) < holeR) {
      const dx = Math.sqrt(holeR * holeR - (y - holeC.y) * (y - holeC.y));
      let cut = [];
      for (const sp of spans) cut = cut.concat(subtractInterval([sp], holeC.x - dx, holeC.x + dx));
      spans = cut.filter(([p, q]) => q - p > 0.2);
    }
    if (spans.length) rows.push({ y, spans });
  }

  // 2. chain spans that overlap between consecutive scanlines into regions
  const done = [];
  let open = [];
  for (const row of rows) {
    const claimed = new Array(open.length).fill(false);
    const next = [];
    for (const [sa2, sb2] of row.spans) {
      let hit = -1;
      for (let k = 0; k < open.length; k++) {
        if (claimed[k]) continue;
        const last = open[k].segs[open[k].segs.length - 1];
        if (Math.min(sb2, last.b) - Math.max(sa2, last.a) > 0) { hit = k; break; }
      }
      if (hit >= 0) { claimed[hit] = true; open[hit].segs.push({ y: row.y, a: sa2, b: sb2 }); next.push(open[hit]); }
      else next.push({ segs: [{ y: row.y, a: sa2, b: sb2 }] });
    }
    for (let k = 0; k < open.length; k++) if (!claimed[k]) done.push(open[k]);
    open = next;
  }
  done.push(...open);

  // 3. draw each region as one continuous serpentine
  const jumpLimit = spacing * 2.5;
  for (const region of done) {
    let dir = 1;
    for (const seg of region.segs) {
      const x0 = dir === 1 ? seg.a : seg.b;
      const x1 = dir === 1 ? seg.b : seg.a;
      const p0 = toBed(fromScan({ x: x0, y: seg.y }), bbox, cfg);
      const p1 = toBed(fromScan({ x: x1, y: seg.y }), bbox, cfg);
      if (em.distanceTo(p0.x, p0.y) <= jumpLimit) em.moveTo(p0.x, p0.y);
      else em.travelTo(p0.x, p0.y);
      em.extrudeTo(p1.x, p1.y, feed, b.lineWidth, layerH);
      dir *= -1;
    }
  }
}

/**
 * Draw one pen stroke as a raised bead.
 *
 * A 0.4mm nozzle can only lay about 0.8mm of plastic in a single pass. Asking
 * it for the full pen width in one go over-extrudes badly — the line comes out
 * lumpy and domed instead of a flat raised bead. So a wide pen is drawn as
 * several parallel passes at normal line width, side by side, walked in a
 * serpentine so the passes join without retracting.
 */
function beadStroke(em, cfg, bbox, stroke, feed, layerH) {
  const pts = stroke.pts;
  if (!pts.length) return;
  const lw = cfg.build.lineWidth;
  const width = Math.max(lw, stroke.w);
  const passes = Math.max(1, Math.round(width / lw));

  if (pts.length === 1) {
    // a dot: a few short side-by-side dabs of the right overall width
    const c = pts[0];
    for (let k = 0; k < passes; k++) {
      const off = passes === 1 ? 0 : -(width - lw) / 2 + (k * (width - lw)) / (passes - 1);
      const a = toBed({ x: c.x - lw * 0.5, y: c.y + off }, bbox, cfg);
      const b = toBed({ x: c.x + lw * 0.5, y: c.y + off }, bbox, cfg);
      if (em.distanceTo(a.x, a.y) <= lw * 2.5) em.moveTo(a.x, a.y); else em.travelTo(a.x, a.y);
      em.extrudeTo(b.x, b.y, feed, lw, layerH);
    }
    return;
  }

  const normals = strokeNormals(pts);
  for (let k = 0; k < passes; k++) {
    const off = passes === 1 ? 0 : -(width - lw) / 2 + (k * (width - lw)) / (passes - 1);
    // serpentine: reverse every other pass so the end of one is beside the
    // start of the next, letting them join with a plain move
    const order = k % 2 === 0 ? [...pts.keys()] : [...pts.keys()].reverse();
    let started = false;
    for (const idx of order) {
      const p = pts[idx], n = normals[idx];
      const q = toBed({ x: p.x + n.x * off, y: p.y + n.y * off }, bbox, cfg);
      if (!started) {
        if (em.distanceTo(q.x, q.y) <= Math.max(lw * 2.5, 1.0)) em.moveTo(q.x, q.y);
        else em.travelTo(q.x, q.y);
        started = true;
      } else {
        em.extrudeTo(q.x, q.y, feed, lw, layerH);
      }
    }
  }
}

/** Unit normal at each point of an open polyline (average of adjacent segments). */
function strokeNormals(pts) {
  const out = [];
  for (let i = 0; i < pts.length; i++) {
    const a = pts[Math.max(0, i - 1)], b = pts[Math.min(pts.length - 1, i + 1)];
    let tx = b.x - a.x, ty = b.y - a.y;
    const len = Math.hypot(tx, ty) || 1;
    tx /= len; ty /= len;
    out.push({ x: -ty, y: tx });
  }
  return out;
}

function makeEmitter(cfg, crossSection) {
  const s = cfg.speed;
  const lines = [];
  const pos = { x: 0, y: 0, z: 0 };
  let timeMin = 0, filamentMm = 0;
  const eFor = (len, width, h) => (width * h * len) / crossSection;
  return {
    lines, meta: () => ({ timeMin, filamentMm }),
    comment: (t) => lines.push('; ' + t),
    raw: (t) => { if (t && t.length) lines.push(t); },
    setZ(z) { lines.push(`G1 Z${z.toFixed(3)} F${Math.round(s.travel)}`); timeMin += Math.abs(z - pos.z) / s.travel; pos.z = z; },
    timeNow() { return timeMin; },
    distanceTo(x, y) { return Math.hypot(x - pos.x, y - pos.y); },
    /** Short hop with no retract or Z-hop — for joining adjacent infill lines. */
    moveTo(x, y) {
      const L = Math.hypot(x - pos.x, y - pos.y);
      if (L < 1e-4) return;
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} F${Math.round(s.travel)}`);
      timeMin += L / s.travel;
      pos.x = x; pos.y = y;
    },
    retract() { if (s.retractMm > 0) lines.push(`G1 E-${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    unretract() { if (s.retractMm > 0) lines.push(`G1 E${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    travelTo(x, y) {
      this.retract();
      if (s.zHopMm > 0) lines.push(`G1 Z${(pos.z + s.zHopMm).toFixed(3)} F${Math.round(s.travel)}`);
      const L = Math.hypot(x - pos.x, y - pos.y);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} F${Math.round(s.travel)}`); timeMin += L / s.travel;
      if (s.zHopMm > 0) lines.push(`G1 Z${pos.z.toFixed(3)} F${Math.round(s.travel)}`);
      pos.x = x; pos.y = y; this.unretract();
    },
    extrudeTo(x, y, feed, width, h) {
      const L = Math.hypot(x - pos.x, y - pos.y);
      if (L < 1e-4) return;
      const e = eFor(L, width, h);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} E${e.toFixed(5)} F${Math.round(feed)}`);
      timeMin += L / feed; filamentMm += e; pos.x = x; pos.y = y;
    },
  };
}

const asLines = (v) => Array.isArray(v) ? v : String(v).split('\n');
function applyTemplate(text, cfg) {
  if (!text) return '';
  return text.replaceAll('{nozzle}', cfg.temp.nozzle).replaceAll('{bed}', cfg.temp.bed)
    .replaceAll('{nozzleFirst}', cfg.temp.nozzleFirst).replaceAll('{bedFirst}', cfg.temp.bedFirst);
}
