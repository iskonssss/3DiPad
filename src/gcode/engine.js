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
import { prepareStrokes, totalLength, simplify } from './strokes.js';
import { insetPolygon, erode, smooth, decimate } from './outline.js';
import { buildCoverage, maskContours, maskRows, contourToMm } from './fill.js';

const FILAMENT_DENSITY = 0.00124; // g/mm^3 (PLA)
const ACCEL_FUDGE = 1.6;

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
    // The visible top surface gets its own, slower feedrate. Solid fill turns
    // every line width or so, and at 150mm/s the nozzle never reaches the
    // commanded speed before braking for the next turn — so flow varies through
    // every turn, which is what shows as a rough top. Buried layers don't care.
    const topSurface = i === nBack - 1;
    const infillFeed = first ? s.firstLayer : topSurface ? (s.topSurface ?? s.solidInfill) : solid ? s.solidInfill : s.infill;
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
    // The fill boundary sits where the anchor loop's MATERIAL ends, less the
    // overlap — not a whole line width further in. A whole line width assumed
    // the outermost fill line would land exactly on that boundary, but the
    // lines sit at a fixed pitch, so it lands anywhere up to a pitch further
    // in and left a void between the two. Measured on a circle's top surface,
    // 98% of the uncovered area sat in that one 0.4mm band.
    const fillInset = anchorInset + (lw / 2 - overlap) * anchor;

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
  em.comment(`===== COLOUR CHANGE: load ${design.colours?.layer2 ?? 'colour 2'}, then Resume =====`);
  const swap = colourChangeBlock(cfg, backingZs[nBack - 1]);
  // A two-colour keychain whose file never stops is not a keychain — it is a
  // one-colour part that took fifteen minutes and looks like a success until
  // someone picks it up. It happened: a change block built from AMS commands
  // was discarded whole by a printer with no AMS, silently, and the print ran
  // straight through. Nothing downstream could tell, because every other
  // property of the file was correct.
  //
  // So the file is checked rather than trusted. M400 U1 is the only pause this
  // machine has been seen to honour, and refusing to write the file at all is
  // far better than handing a child the wrong keychain.
  if (!swap.some((l) => /^\s*M400\s+U1\b/.test(l))) {
    throw new Error(
      'The colour-change block contains no M400 U1, so the print would never stop ' +
      'to swap filament and the whole keychain would come out in colour 1. ' +
      'Check colourChange in config.json: a "gcode" override replaces the block entirely.',
    );
  }
  for (const line of swap) em.raw(line);

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
  // Painted into one coverage mask before any g-code is emitted. Colouring an
  // area in means dozens of overlapping strokes, and drawn stroke-by-stroke each
  // one lays a full bead over the last — the same spot gets material four or
  // five times and melts into a blob. From a mask, the toolpath is the same
  // whether the kid used one stroke or a hundred.
  const cov = buildCoverage(strokes, cfg, bbox, poly, hole, b.designEdgeMargin);
  em.comment(`===== DESIGN (colour 2) — ${designZs.length} layers, ${strokes.length} strokes =====`);
  designZs.forEach((z, k) => {
    marks.push({ at: em.lines.length, t: em.timeNow() });
    em.setZ(z);
    // alternate the fill direction between the two layers so they cross-bond
    designLayer(em, cfg, bbox, cov, s.bead, b.layerHeight, k % 2 === 1);
  });

  marks.push({ at: em.lines.length, t: em.timeNow(), pct: 100 });
  em.raw(applyTemplate(cfg.template.endResolved, cfg));

  const raw = em.meta();
  const startupMin = startupMinutes(cfg);
  const estMinutes = raw.timeMin * ACCEL_FUDGE + startupMin;
  const grams = raw.filamentMm * crossSection * FILAMENT_DENSITY;

  // Layer marks plus the emitter's time ticks, in file order. The ticks are what
  // keeps the bar moving through a long first layer.
  const all = marks.concat(em.progress).sort((p, q) => p.at - q.at || p.t - q.t);

  // Build one progress report per mark, dropping consecutive duplicates so the
  // printer isn't told the same thing twice.
  const reports = all.map((m) => {
    const done = startupMin + m.t * ACCEL_FUDGE;
    const pct = m.pct ?? Math.max(0, Math.min(100, Math.round((m.t / Math.max(raw.timeMin, 1e-6)) * 100)));
    const remaining = m.pct === 100 ? 0 : Math.max(0, Math.ceil(estMinutes - done));
    return `M73 P${pct} R${remaining}`;
  });
  // splice from the back so earlier indices stay valid
  const lines = em.lines.slice();
  for (let i = all.length - 1; i >= 0; i--) {
    if (i > 0 && reports[i] === reports[i - 1]) continue;
    lines.splice(all[i].at, 0, reports[i]);
  }

  const maxZ = designZs.length ? designZs[designZs.length - 1] : backingZs[nBack - 1];
  return {
    gcode: bambuBlocks(lines, {
      layers: nBack + designZs.length,
      filamentMm: raw.filamentMm,
      grams,
      minutes: estMinutes,
      maxZ,
      // Bambu's header quotes density in g/cm^3 (1.24 for PLA); ours is the
      // g/mm^3 the volume arithmetic wants.
      density: +(FILAMENT_DENSITY * 1000).toFixed(2),
      diameter: b.filamentDiameter,
    }),
    meta: {
      shape, bbox, hole: hole.none ? null : { x: +hole.cx.toFixed(1), y: +hole.cy.toFixed(1) }, colours: design.colours,
      backingLayers: nBack, designLayers: designZs.length, strokeCount: strokes.length,
      drawnLengthMm: Math.round(totalLength(strokes)),
      estMinutes: +estMinutes.toFixed(1), estGrams: +grams.toFixed(1),
      overBudget: estMinutes > cfg.limits.maxPrintMinutes, nearBudget: estMinutes > cfg.limits.warnPrintMinutes,
      // How much of the print is limited by how fast the hotend can melt rather
      // than by the speed settings. Non-zero is normal and healthy: it means the
      // speeds are aspirations and the ceiling is being respected.
      flowClampedMoves: raw.flowClampedMoves, flowClampedMm: raw.flowClampedMm,
    },
  };
}

// Resolve the hole to a valid {cx,cy,r}: use the tapped point if valid, else a
// preset, else nudge toward the centroid until a wall fits.
function resolveHole(design, poly, bbox, cfg) {
  const r = cfg.build.holeDiameter / 2;
  // No hole is a choice a child can make, and it has to survive the trip: a
  // null hole used to mean "none given, put one at the top", so asking for a
  // whole tag got you a hole anyway.
  // Expressed as a hole of no size, well off the plate, rather than as null:
  // every path below reads hole.cx/hole.r without asking, and a null would have
  // to be checked in eight places that have nothing to do with the choice.
  if (design.holePos === 'none' && !design.hole) return { cx: -1000, cy: -1000, r: 0, none: true };
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
  if (hole.none) return;
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

  drawSpanRegions(em, cfg, bbox, rows, spacing, feed, layerH, (p) => fromScan(p));
}

/**
 * Chain spans that overlap between consecutive scanlines into regions, then draw
 * each region as one continuous serpentine. Shared by the backing's infill and
 * the design layer's fill; `toPlate` maps a span coordinate to plate-local mm.
 */
function drawSpanRegions(em, cfg, bbox, rows, spacing, feed, layerH, toPlate) {
  const b = cfg.build;
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

  // The turn at the end of each line is EXTRUDED, not hopped over. Every one of
  // those turns lands on the fill boundary, so a dry hop left an un-extruded
  // nick at the edge on every single line — around the whole rim that reads as
  // a dashed line just inside the wall. A slicer lays solid infill as one
  // unbroken zigzag for exactly this reason.
  //
  // Only a real turn is welded: a join no longer than a couple of line spacings.
  // Anything further is the path crossing a concavity, where extruding would
  // draw a line through fresh air.
  const weldLimit = spacing * 2;
  const jumpLimit = spacing * 2.5;
  for (const region of done) {
    let dir = 1, first = true;
    for (const seg of region.segs) {
      const x0 = dir === 1 ? seg.a : seg.b;
      const x1 = dir === 1 ? seg.b : seg.a;
      const p0 = toBed(toPlate({ x: x0, y: seg.y }), bbox, cfg);
      const p1 = toBed(toPlate({ x: x1, y: seg.y }), bbox, cfg);
      const d = em.distanceTo(p0.x, p0.y);
      if (!first && d <= weldLimit) em.extrudeTo(p0.x, p0.y, feed, b.lineWidth, layerH);
      else if (d <= jumpLimit) em.moveTo(p0.x, p0.y);
      else em.travelTo(p0.x, p0.y);
      em.extrudeTo(p1.x, p1.y, feed, b.lineWidth, layerH);
      dir *= -1;
      first = false;
    }
  }
}

/**
 * Draw the design layer from its coverage mask: a perimeter around every
 * contour, then a solid fill inside.
 *
 * Contours include the inside of enclosed holes, so a drawn "O" prints as a
 * ring rather than a filled disc. Thin strokes survive as a degenerate loop —
 * up one side of the ribbon and back the other — which is the right two passes
 * for a pen line and costs nothing extra to fall out of the same code.
 */
function designLayer(em, cfg, bbox, cov, feed, layerH, vertical) {
  if (!cov) return;
  const b = cfg.build;
  const lw = b.lineWidth;
  const overlap = lw * (b.infillWallOverlap ?? 0.15);

  const perim = erode(cov.mask, cov.w, cov.h, lw / 2 / cov.cell);
  em.comment('design outline');
  for (const loop of maskContours(perim, cov.w, cov.h)) {
    const pts = smoothContour(contourToMm(loop, cov), cov.cell);
    if (pts.length >= 3) perimeterLoop(em, cfg, bbox, pts, feed, layerH);
  }

  // fill starts a line width in from the perimeter's centreline, overlapping it
  // by the same fraction the backing uses
  const inner = erode(cov.mask, cov.w, cov.h, (lw * 1.5 - overlap) / cov.cell);
  const step = Math.max(1, Math.round(lw / cov.cell));
  const rows = maskRows(inner, cov.w, cov.h, step, vertical ? step / 2 : 0, vertical);
  if (rows.length) {
    em.comment('design fill');
    // Scanning vertically, a row's line index is a column and its spans are row
    // indices — so the pair arrives at toPlate the other way round.
    const toPlate = vertical ? (p) => cov.toMm({ x: p.y, y: p.x }) : (p) => cov.toMm(p);
    drawSpanRegions(em, cfg, bbox, rows, lw, feed, layerH, toPlate);
  }
}

/**
 * Take the staircase out of a traced contour.
 *
 * The drawing is stamped into a grid and its printed edge is a marching-squares
 * trace of that grid, so the edge only ever runs along a cell side or across a
 * cell corner. On a line a child drew at some angle that is a saw: measured on
 * one straight diagonal stroke, the traced edge changed direction 87 times in
 * 309 points. That is what "rough, like it jumps point to point" was — not the
 * drawn points, which are smoothed well before this, and not the bead width.
 *
 * Chaikin over points a cell apart averages the steps away; the simplify pass
 * afterwards drops what is then redundant, which matters because a contour has
 * a point per cell and the file would otherwise carry all of them. Smoothing
 * pulls the loop in by well under a cell — invisible against a bead more than
 * ten cells wide.
 */
function smoothContour(pts, cell) {
  if (pts.length < 8) return pts;
  return simplify(smooth(decimate(pts, cell * 0.9, true), 2, false), cell / 3);
}

function makeEmitter(cfg, crossSection) {
  const s = cfg.speed;
  const lines = [];
  const pos = { x: 0, y: 0, z: 0 };
  let timeMin = 0, filamentMm = 0;

  // Progress reports were only emitted at layer boundaries, and the first layer
  // is slow enough to be ~40% of a keychain — so the printer's bar sat at 0%
  // for minutes before jumping. Marks are taken on a time tick instead, so the
  // bar moves whatever a layer is doing.
  const progress = [];
  let nextTick = 0;
  const TICK_MIN = 0.08;
  const tick = () => {
    if (timeMin >= nextTick) { progress.push({ at: lines.length, t: timeMin }); nextTick = timeMin + TICK_MIN; }
  };

  const eFor = (len, width, h) => (width * h * len) / crossSection;

  /**
   * The hotend's melt rate, not the motion system's speed, is what actually
   * limits a print. An A1 mini can move at 250 mm/s all day; it can only melt
   * about 12 mm³ of PLA per second. Asking for more does not print faster — the
   * extruder grinds, what comes out is half-melted and lumpy, the nozzle then
   * ploughs through its own blobs, and on a 100 x 40 plate the sideways force
   * eventually knocks the part off the bed.
   *
   * We were asking for 25.2 mm³/s on sparse infill and 18.9 on solid, against
   * a ceiling of 12 — this is why ORANGE-BLACK_0010 tore itself apart three
   * times with three different filaments. Bambu Studio caps every extruding
   * move the same way (filament_max_volumetric_speed = 12 in the profile on
   * this very printer); its 270 mm/s infill setting is a ceiling that is never
   * reached at this layer height.
   *
   * Capping here, at the one place every extruding move passes through, means
   * the speed settings can stay as aspirations and the geometry decides what is
   * actually achievable.
   */
  const maxVol = s.maxVolumetricMmps ?? 12;
  let clamped = 0, clampedMm = 0;
  function capFeed(feed, width, h, len) {
    if (!(maxVol > 0)) return feed;
    const limit = (maxVol * 60) / (width * h);   // mm/min at this cross-section
    if (feed <= limit) return feed;
    clamped++; clampedMm += len;
    return limit;
  }

  return {
    lines, progress,
    meta: () => ({ timeMin, filamentMm, flowClampedMoves: clamped, flowClampedMm: +clampedMm.toFixed(1) }),
    comment: (t) => lines.push('; ' + t),
    raw: (t) => { if (t && t.length) lines.push(t); },
    setZ(z) { lines.push(`G1 Z${z.toFixed(3)} F${Math.round(s.travel)}`); timeMin += Math.abs(z - pos.z) / s.travel; pos.z = z; tick(); },
    timeNow() { return timeMin; },
    distanceTo(x, y) { return Math.hypot(x - pos.x, y - pos.y); },
    /** Short hop with no retract or Z-hop — for joining adjacent infill lines. */
    moveTo(x, y) {
      const L = Math.hypot(x - pos.x, y - pos.y);
      if (L < 1e-4) return;
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} F${Math.round(s.travel)}`);
      timeMin += L / s.travel;
      pos.x = x; pos.y = y; tick();
    },
    retract() { if (s.retractMm > 0) lines.push(`G1 E-${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    unretract() { if (s.retractMm > 0) lines.push(`G1 E${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    travelTo(x, y) {
      this.retract();
      if (s.zHopMm > 0) lines.push(`G1 Z${(pos.z + s.zHopMm).toFixed(3)} F${Math.round(s.travel)}`);
      const L = Math.hypot(x - pos.x, y - pos.y);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} F${Math.round(s.travel)}`); timeMin += L / s.travel;
      if (s.zHopMm > 0) lines.push(`G1 Z${pos.z.toFixed(3)} F${Math.round(s.travel)}`);
      pos.x = x; pos.y = y; this.unretract(); tick();
    },
    extrudeTo(x, y, feed, width, h) {
      const L = Math.hypot(x - pos.x, y - pos.y);
      if (L < 1e-4) return;
      const e = eFor(L, width, h);
      const f = capFeed(feed, width, h, L);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} E${e.toFixed(5)} F${Math.round(f)}`);
      timeMin += L / f; filamentMm += e; pos.x = x; pos.y = y; tick();
    },
  };
}

/**
 * Bambu firmware does not read a .gcode as a flat stream of commands. Its own
 * files — including the one that printed successfully on this booth's A1 mini —
 * are divided into three labelled blocks, and the printer reads the first two
 * before it will run the third:
 *
 *   HEADER_BLOCK      layer count, filament used, print time, max Z. This is
 *                     what the printer's screen shows, and what it uses to
 *                     decide the job is describable at all.
 *   CONFIG_BLOCK      the slicer's settings, as comments.
 *   EXECUTABLE_BLOCK  the moves.
 *
 * We were emitting the moves alone, with no blocks around them. A file like
 * that loads and sits there: the printer has nothing to show and nothing to
 * validate, and a start command against it does nothing at all — which is
 * exactly the symptom, a file present on the SD card that will not start.
 *
 * These are comments, so they cost nothing if a firmware ignores them.
 */
export function bambuBlocks(lines, info) {
  const mins = Math.floor(info.minutes);
  const secs = Math.round((info.minutes - mins) * 60);
  const time = `${mins}m ${secs}s`;
  const volumeCm3 = (info.filamentMm * Math.PI * (info.diameter / 2) ** 2) / 1000;

  const header = [
    '; HEADER_BLOCK_START',
    '; 3DiPad booth generator',
    `; model printing time: ${time}; total estimated time: ${time}`,
    `; total layer number: ${info.layers}`,
    `; total filament length [mm] : ${info.filamentMm.toFixed(2)}`,
    `; total filament volume [cm^3] : ${volumeCm3.toFixed(2)}`,
    `; total filament weight [g] : ${info.grams.toFixed(2)}`,
    `; filament_density: ${info.density}`,
    `; filament_diameter: ${info.diameter}`,
    `; max_z_height: ${info.maxZ.toFixed(2)}`,
    '; filament: 1',
    '; HEADER_BLOCK_END',
    '',
  ];

  // The moves already carry the settings that produced them in their own
  // comments; this block exists so the structure matches, and carries the few
  // values the printer is known to read back.
  const config = [
    '; CONFIG_BLOCK_START',
    `; filament_diameter = ${info.diameter}`,
    `; filament_density = ${info.density}`,
    '; filament_type = PLA',
    '; nozzle_diameter = 0.4',
    '; printer_model = Bambu Lab A1 mini',
    '; CONFIG_BLOCK_END',
    '',
  ];

  return [
    ...header,
    ...config,
    '; EXECUTABLE_BLOCK_START',
    ...lines,
    '; EXECUTABLE_BLOCK_END',
    '',
  ].join('\n');
}

const asLines = (v) => Array.isArray(v) ? v : String(v).split('\n');

/**
 * The filament swap, in the shape Bambu Studio's own "multi-colour with
 * external spool" uses — read off a real A1 mini file rather than invented:
 * park clear of the part, back the old colour out of the melt zone, pause,
 * then purge and wipe the new colour before printing with it.
 *
 * The plain pause left that last part to the operator via the printer's
 * filament menu, and whatever colour was still in the nozzle went into the
 * first few millimetres of the drawing.
 *
 * Bambu's own version is driven by `manual_color_change` in the print task,
 * which only the project_file command carries — we send a bare .gcode, so the
 * moves are emitted here instead. Set colourChange.mode to "pause" for the old
 * behaviour, or colourChange.gcode to replace the block outright.
 */
/**
 * The stop itself. M400 U1 is the only pause this printer has been observed to
 * honour, so every mode goes through here rather than spelling it out — a mode
 * that forgets it produces a two-colour file that prints in one colour.
 */
function pauseLines(c) {
  return asLines(c.pauseGcode ?? 'M400 U1 ; pause for the filament swap');
}

export function colourChangeBlock(cfg, atZ = 0) {
  const c = cfg.colourChange || {};
  if (c.gcode) return asLines(c.gcode);           // explicit override wins
  const pause = pauseLines(c);
  if (c.mode === 'pause') return pause;
  if (c.mode === 'bambu') return bambuChangeBlock(cfg, atZ);
  if (c.mode === 'cut') return bambuChangeBlock(cfg, atZ, { load: false });

  const t = cfg.temp?.nozzle ?? 220;
  const lift = +(atZ + (c.liftMm ?? 4)).toFixed(2);
  const purgeFeed = Math.round(c.purgeFeed ?? 300);
  const out = [
    'M400 ; finish everything queued',
    'M106 P1 S0 ; part fan off — no draught over an open nozzle',
    `G1 Z${lift} F1200 ; lift clear of the print`,
    `G1 X${c.parkX ?? 180} Y${c.parkY ?? 90} F18000 ; park clear of the part`,
    'G92 E0',
    `G1 E-${(c.retractMm ?? 8).toFixed(1)} F1200 ; back the old colour out of the melt zone`,
    'M400',
    ...pause,
    `M109 S${t} ; back to temperature after the swap`,
    'G92 E0',
    'M106 P1 S60 ; gentle fan so the purge does not weld to the nozzle',
  ];

  // Purged in bites, like the slicer does: a long slow push packs the melt zone
  // and the short fast ones break the strand so it drops instead of trailing.
  const purge = Math.max(0, c.purgeMm ?? 60);
  // The filament slot to change into. 1, read out of a real Bambu Studio export
  // for a manual external-spool change on this printer — NOT 255. 255 means "no
  // next tool" and appears only in the end-of-print unload; asking for it takes
  // the branch of Bambu's own template that does nothing, which is how a
  // two-colour keychain came out in one colour.
  // 254 is the EXTERNAL SPOOL. Not 1, which is AMS slot 1 — asking for that on
  // a printer with no AMS attached produced "AMS Lite communication is
  // abnormal" and a deadlock, which is the printer being clear that it went
  // looking for hardware that is not there. And not 255, which means no tool at
  // all and does nothing. The `A` suffix is AMS addressing too: Bambu's own
  // end-of-print unload, on a machine with no AMS, is "M620 S255" with no A.
  const tool = c.tool ?? 254;
  const ams = tool < 254 ? 'A' : '';
  if (purge > 0) {
    const bites = Math.max(1, Math.round(c.purgeBites ?? 4));
    const each = purge / bites;
    out.push('; --- purge the new colour ---');
    for (let i = 0; i < bites; i++) {
      out.push(`G1 E${each.toFixed(2)} F${purgeFeed}`);
      out.push('G1 E1.5 F50');
    }
    out.push('G1 E-1.5 F1800', 'G1 E1.5 F300');
  }

  // Wipe on the brush at the left of the bed, the same moves the slicer uses.
  const wipes = Math.max(0, Math.round(c.wipes ?? 4));
  if (wipes > 0) {
    out.push('M400', 'M106 P1 S178 ; full fan to set the strand', 'M400 S3');
    for (let i = 0; i < wipes; i++) out.push('G1 X-3.5 F18000', 'G1 X-13.5 F3000');
    out.push('M400', 'M106 P1 S0');
  }

  out.push('G92 E0', `G1 Z${lift} F3000`);
  return out;
}

/**
 * The A1 mini's own filament change — cut, unload, prompt, reload — rather than
 * our approximation of it.
 *
 * The hand-rolled block above parks and retracts 8 mm and pauses, which clears
 * the melt zone but leaves the operator to work the printer's filament menu at
 * every single swap. What everyone actually wants is what Bambu Studio does:
 * the head goes to the cutter, snips, the printer pulls the old colour out and
 * asks for the new one, and feeds it in until the extruder gear catches.
 *
 * None of that can be arrived at by reasoning — the commands are undocumented
 * Bambu internals and the cutter is at a machine-specific coordinate. These
 * lines are transcribed from Bambu Studio's own A1 mini profile
 * (resources/profiles/BBL/machine, "A1 mini 0.4 nozzle template
 * change_filament_gcode"), with the slicer's template expressions resolved for
 * a single-extruder external-spool change:
 *
 *   next_extruder = 255      WRONG, and it cost a print — see below
 *   G1 X180                  the cutter, at the right-hand edge of a 180 bed
 *   M620.11 S1 I254 E-18     the long retraction that performs the cut
 *   T255                     unload, then ask for the new filament
 *   feedrate                 flush_volumetric_speed / 2.4053 * 60, i.e. mm/min
 *                            of 1.75 mm filament for a given mm^3/s
 *
 * WHAT WENT WRONG THE FIRST TIME, so nobody repeats it. 255 was read as "the
 * external spool". It is not — it means NO NEXT TOOL, the end-of-print unload.
 * The slicer template wraps its whole body in `{if next_extruder < 255}` and
 * the `{else}` branch is a single travel move, so asking for 255 selects the
 * branch that does nothing. The printer did not refuse it and nothing appeared
 * in any log; the keychain simply came out in one colour. The right index is a
 * real filament slot, and what the slicer resolves it to for a manual
 * external-spool change is a question only an exported two-colour file from
 * Bambu Studio can answer. Nobody should guess at it a third time.
 *
 * Because of that, the pause below is unconditional: if every AMS command here
 * is discarded, this still behaves exactly like the "purge" mode and the print
 * still stops. The cut is a bonus, never the thing being relied on.
 */
export function bambuChangeBlock(cfg, atZ = 0, opts = {}) {
  const c = cfg.colourChange || {};
  const t = cfg.temp?.nozzle ?? 220;
  const up = +(atZ + (c.liftMm ?? 3)).toFixed(2);
  const cutX = c.cutX ?? 180;                       // A1 mini: the 180 mm edge
  const cutRetract = c.cutRetractMm ?? 18;          // retraction_distances_when_cut
  // mm/min of 1.75 mm filament for a given volumetric rate — the slicer's own
  // conversion, and the reason its purge feedrates look like arbitrary numbers.
  const feed = Math.round(((c.flushMmps ?? cfg.speed?.maxVolumetricMmps ?? 12) / 2.4053) * 60);
  const purge = Math.max(0, c.purgeMm ?? 60);
  // The filament slot to change into. 1, read out of a real Bambu Studio export
  // for a manual external-spool change on this printer — NOT 255. 255 means "no
  // next tool" and appears only in the end-of-print unload; asking for it takes
  // the branch of Bambu's own template that does nothing, which is how a
  // two-colour keychain came out in one colour.
  // 254 is the EXTERNAL SPOOL. Not 1, which is AMS slot 1 — asking for that on
  // a printer with no AMS attached produced "AMS Lite communication is
  // abnormal" and a deadlock, which is the printer being clear that it went
  // looking for hardware that is not there. And not 255, which means no tool at
  // all and does nothing. The `A` suffix is AMS addressing too: Bambu's own
  // end-of-print unload, on a machine with no AMS, is "M620 S255" with no A.
  const tool = c.tool ?? 254;
  const ams = tool < 254 ? 'A' : '';

  const out = [
    '; ===== A1 mini filament change: cut, unload, reload =====',
    'G392 S0',
    'M1007 S0',
    `M620 S${tool}${ams}`,
    'M204 S9000',
    `G1 Z${up} F1200`,
    'M400',
    'M106 P1 S0',
    'M106 P2 S0',
    `M104 S${t} ; keep the old colour molten for the cut`,
    `G1 X${cutX} F18000 ; to the cutter`,
    `M620.11 S1 I${tool} E-${cutRetract} F1200 ; the long retraction that cuts it`,
    'M400',
    `M620.1 E F${feed} T${t}`,
    `M620.10 A0 F${feed}`,
    // The toolchange, and the one part of this that has not worked yet.
    //
    // On a real machine the cut and the pull-back both happened; T1 then left
    // the printer sitting on "the filament is not inserted" with no way to feed
    // the new colour in. The likely reason is that our 3mf declares one
    // filament, so slot 1 is a slot the printer has no configuration for: it
    // knows to ask, and does not know what it is being handed.
    //
    // mode "cut" leaves this line out. The cut and the unload are the fiddly
    // half and they work; loading from the printer's own filament menu is
    // twenty seconds an operator already knows how to do.
    ...(opts.load === false
      ? ['; no toolchange — load from the printer\'s filament menu at the pause below']
      : [`T${tool} ; the printer stops and asks, because the print task was sent`,
         '        ; with manual_color_change set']),
    `M620.1 E F${feed} T${t}`,
    'G1 Y90 F9000',
    'M400',
    'G92 E0',
    'M628 S0',
    // The pause goes in whatever the commands above did.
    //
    // Everything before this line is an AMS instruction, and a printer with no
    // AMS attached does not refuse them — it discards them and carries straight
    // on. A file relying on T255 alone therefore printed a two-colour keychain
    // in one colour, with no pause, no error and nothing in the log: the worst
    // possible failure, because it looks like a success until you pick the part
    // up. M400 U1 is the one stop this machine is known to honour, so it is not
    // optional and not conditional.
    //
    // If the cut did work, the old colour is already out and the operator just
    // loads the new one. If it did not, this is the swap they were doing
    // before. Either way the print stops.
    ...pauseLines(c),
  ];

  if (purge > 0) {
    // The slicer's shape: one long push to pack the melt zone, then short slow
    // ones that break the strand so it drops instead of trailing across the part.
    out.push('; --- purge the new colour ---', 'M400', `M109 S${t}`, 'M106 P1 S60');
    const head = Math.min(23.7, purge);
    out.push(`G1 E${head.toFixed(2)} F${feed}`);
    const rest = purge - head;
    if (rest > 0) {
      for (let i = 0; i < 4; i++) {
        out.push(`G1 E${(rest * 0.02).toFixed(2)} F50`);
        out.push(`G1 E${(rest * 0.23).toFixed(2)} F${feed}`);
      }
    }
    out.push('G1 E-1.5 F1800', 'G1 E1.5 F300');
  }

  const wipes = Math.max(0, Math.round(c.wipes ?? 4));
  if (wipes > 0) {
    out.push('; --- wipe on the brush ---', 'M400', 'M106 P1 S178', 'M400 S3');
    for (let i = 0; i < wipes; i++) out.push('G1 X-3.5 F18000', 'G1 X-13.5 F3000');
    out.push('M400', 'M106 P1 S0');
  }

  out.push('M629', `M621 S${tool}${ams}`, 'G392 S0', 'M400', 'G92 E0', `G1 Z${up} F3000`, 'M1007 S1');
  return out;
}

/**
 * The calibration block for the start template.
 *
 * A full G29 mesh probe costs well over a minute — on a 13-minute keychain that
 * is a tenth of the booth's throughput, repeated for every single kid. With it
 * off the printer uses the mesh it stored the last time it levelled, which is
 * what Bambu Studio's "no calibration" option does too. Level once on arrival
 * (printer screen, or flip bedLevel on for the day's first print) and every
 * print after that starts straight into the prime line.
 */
function calibrationBlock(cfg) {
  const c = cfg.calibration || {};
  const out = [];
  if (c.bedLevel) out.push('G29 ; auto bed levelling (probes at reduced nozzle temp)');
  else out.push('; bed levelling skipped — using the mesh stored on the printer');
  if (c.flow) out.push('M900 ; flow dynamics calibration');
  for (const line of asLines(c.extra || [])) if (line && line.trim()) out.push(line);
  return out.join('\n');
}

/** Minutes before the first extrusion: heat soak, homing, and any calibration. */
function startupMinutes(cfg) {
  const c = cfg.calibration || {};
  return (c.startupMinutes ?? 1.2) + (c.bedLevel ? (c.bedLevelMinutes ?? 1.3) : 0);
}

function applyTemplate(text, cfg) {
  if (!text) return '';
  return text.replaceAll('{nozzle}', cfg.temp.nozzle).replaceAll('{bed}', cfg.temp.bed)
    .replaceAll('{nozzleFirst}', cfg.temp.nozzleFirst).replaceAll('{bedFirst}', cfg.temp.bedFirst)
    .replaceAll('{calibration}', calibrationBlock(cfg));
}
