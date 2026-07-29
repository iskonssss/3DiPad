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

  // ---- backing plate (colour 1) ----
  const backingZs = layerZs(b.firstLayerHeight, b.layerHeight, b.backingThickness);
  const nBack = backingZs.length;
  em.comment(`===== BACKING (colour 1) — ${shape}, ${nBack} layers =====`);

  backingZs.forEach((z, i) => {
    const layerH = i === 0 ? b.firstLayerHeight : b.layerHeight;
    const first = i === 0;
    const solid = first || i < b.solidLayers || i >= nBack - b.solidLayers;
    const spacing = solid ? b.lineWidth : b.sparseSpacing;
    const infillFeed = first ? s.firstLayer : solid ? s.solidInfill : s.infill;
    const perimFeed = first ? s.firstLayer : s.perimeter;

    // chamfer: over the top `chamferMm`, inset the solid region (and widen the
    // hole) to bevel the top rim. Done by inset-of-spans (robust on concave shapes).
    const cham = Math.max(0, b.chamferMm - (b.backingThickness - z));
    const perimOn = cham < 1e-6;
    const inset = perimOn ? b.lineWidth : cham;
    const holeR = hole.r + cham;

    em.comment(`; layer ${i + 1}/${nBack} z=${z.toFixed(2)} ${solid ? 'solid' : 'sparse'}${cham > 0 ? ' chamfer' : ''}`);
    em.setZ(z);
    if (perimOn) perimeterLoop(em, cfg, bbox, poly, perimFeed, layerH); // raw outline
    holePerimeter(em, cfg, bbox, hole, holeR, perimFeed, layerH);
    infillLayer(em, cfg, bbox, poly, hole, holeR, spacing, infillFeed, layerH, (i % 2) * (spacing / 2), inset);
  });

  // ---- colour change ----
  em.comment('===== COLOUR CHANGE (M400 U1): load layer-2 colour, then Resume =====');
  for (const line of asLines(cfg.colourChange.gcode)) em.raw(line);

  // ---- design (colour 2), raised beads ----
  const strokes = prepareStrokes(design.design || [], poly, cfg, hole, b.designEdgeMargin);
  const designZs = layerZs(b.backingThickness + b.layerHeight, b.layerHeight, b.backingThickness + b.designThickness);
  em.comment(`===== DESIGN (colour 2) — ${designZs.length} layers, ${strokes.length} strokes =====`);
  designZs.forEach((z) => {
    em.setZ(z);
    for (const st of strokes) beadStroke(em, cfg, bbox, st, s.bead, b.layerHeight);
  });

  em.raw(applyTemplate(cfg.template.endResolved, cfg));

  const raw = em.meta();
  const estMinutes = raw.timeMin * ACCEL_FUDGE + STARTUP_MIN;
  const grams = raw.filamentMm * crossSection * FILAMENT_DENSITY;
  return {
    gcode: em.lines.join('\n') + '\n',
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

function infillLayer(em, cfg, bbox, poly, hole, holeR, spacing, feed, layerH, phase, inset) {
  const b = cfg.build;
  const { yMin, yMax } = boundsY(poly);
  let dir = 1;
  for (let y = yMin + spacing * 0.5 + phase; y <= yMax - 0.001; y += spacing) {
    if (y < yMin + inset || y > yMax - inset) continue; // vertical inset (wall/chamfer)
    let spans = scanlineSpans(poly, y)
      .map(([a, c]) => [a + inset, c - inset])
      .filter(([a, c]) => c - a > 0.2);
    if (!spans.length) continue;
    // carve the hole out of this scanline
    if (Math.abs(y - hole.cy) < holeR) {
      const dx = Math.sqrt(holeR * holeR - (y - hole.cy) * (y - hole.cy));
      let cut = [];
      for (const sp of spans) cut = cut.concat(subtractInterval([sp], hole.cx - dx, hole.cx + dx));
      spans = cut;
    }
    if (dir === -1) spans = spans.slice().reverse();
    for (let [a, c] of spans) {
      if (dir === -1) { const t = a; a = c; c = t; }
      const p0 = toBed({ x: a, y }, bbox, cfg);
      const p1 = toBed({ x: c, y }, bbox, cfg);
      em.travelTo(p0.x, p0.y);
      em.extrudeTo(p1.x, p1.y, feed, b.lineWidth, layerH);
    }
    dir *= -1;
  }
}

function beadStroke(em, cfg, bbox, stroke, feed, layerH) {
  const pts = stroke.pts;
  if (!pts.length) return;
  const width = stroke.w;
  const p0 = toBed(pts[0], bbox, cfg);
  em.travelTo(p0.x, p0.y);
  if (pts.length === 1) { em.extrudeTo(p0.x + width * 0.5, p0.y, feed, width, layerH); return; }
  for (let i = 1; i < pts.length; i++) {
    const p = toBed(pts[i], bbox, cfg);
    em.extrudeTo(p.x, p.y, feed, width, layerH);
  }
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
