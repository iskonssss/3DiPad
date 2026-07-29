// Core g-code engine — pure and printer-independent.
//
// generate(design, cfg) -> { gcode, meta }
//   design = {
//     hole: 'left' | 'right' | 'centre',
//     colours: { layer1, layer2 },          // labels only; not in the g-code itself
//     design: [ [ {x,y}, ... ], ... ],       // kid's strokes, plate-local mm, y-up
//     backing: [ ... ]                        // optional strokes if allowBackingDrawing
//   }
//
// The object is a flat two-colour keychain:
//   backing plate (colour 1)  ->  MANUAL COLOUR CHANGE  ->  raised drawing (colour 2)
//
// Coordinates: design arrives in plate-local mm (origin bottom-left, y-up); the
// engine centres the plate on the bed. See geometry.js.

import { outline, spanAtY, yBounds, toBed } from './geometry.js';
import { prepareStrokes, totalLength } from './strokes.js';

const FILAMENT_DENSITY = 0.00124; // g/mm^3 (PLA)
const ACCEL_FUDGE = 1.6;          // naive time * this ~ real wall time (firmware accel/jerk)
const STARTUP_MIN = 2.5;          // heat + home + bed mesh overhead, minutes

export function generate(design, cfg) {
  const b = cfg.build;
  const s = cfg.speed;
  const hole = design.hole || 'centre';
  const crossSection = Math.PI * Math.pow(b.filamentDiameter / 2, 2);

  const em = makeEmitter(cfg, crossSection);

  // ---- header ----
  em.comment(`3DiPad keychain  ${b.plateWidth}x${b.plateHeight}mm  hole:${hole}`);
  em.comment(`layer1(backing): ${design.colours?.layer1 ?? '?'}   layer2(design): ${design.colours?.layer2 ?? '?'}`);
  em.raw(applyTemplate(cfg.template.startResolved, cfg));
  em.raw('G90');  // absolute XYZ
  em.raw('M83');  // relative E — the engine emits incremental E everywhere

  // ---- backing plate (colour 1) ----
  const backingZs = layerZs(b.firstLayerHeight, b.layerHeight, b.backingThickness);
  const nBack = backingZs.length;
  em.comment(`===== BACKING (colour 1) — ${nBack} layers =====`);

  const backingStrokes = b.allowBackingDrawing && Array.isArray(design.backing)
    ? prepareStrokes(design.backing, b, hole)
    : [];

  backingZs.forEach((z, i) => {
    const layerH = i === 0 ? b.firstLayerHeight : b.layerHeight;
    const firstLayer = i === 0;
    const solid = firstLayer || i < b.solidLayers || i >= nBack - b.solidLayers;
    const spacing = solid ? b.lineWidth : b.sparseSpacing;
    const infillFeed = firstLayer ? s.firstLayer : solid ? s.solidInfill : s.infill;
    const perimFeed = firstLayer ? s.firstLayer : s.perimeter;

    em.comment(`; layer ${i + 1}/${nBack}  z=${z.toFixed(2)}  ${solid ? 'solid' : 'sparse'}`);
    em.setZ(z);
    const { plate, hole: holeLoop } = outline(b, hole);
    perimeterLoop(em, cfg, plate, perimFeed, layerH);
    perimeterLoop(em, cfg, holeLoop, perimFeed, layerH);
    infillLayer(em, cfg, hole, spacing, infillFeed, layerH, (i % 2) * (spacing / 2));
    // optional drawing baked into the backing colour
    for (const stroke of backingStrokes) beadStroke(em, cfg, stroke, s.bead, b.beadWidth, layerH);
  });

  // ---- colour change ----
  em.comment('===== COLOUR CHANGE (manual): load layer-2 colour =====');
  for (const line of asLines(cfg.colourChange.gcode)) em.raw(line);

  // ---- design (colour 2), raised beads on top ----
  const strokes = prepareStrokes(design.design || [], b, hole);
  const designZs = layerZs(b.backingThickness + b.layerHeight, b.layerHeight, b.backingThickness + b.designThickness);
  em.comment(`===== DESIGN (colour 2) — ${designZs.length} layers, ${strokes.length} strokes =====`);
  designZs.forEach((z) => {
    em.setZ(z);
    for (const stroke of strokes) beadStroke(em, cfg, stroke, s.bead, b.beadWidth, b.layerHeight);
  });

  // ---- footer ----
  em.raw(applyTemplate(cfg.template.endResolved, cfg));

  const raw = em.meta();
  const estMinutes = raw.timeMin * ACCEL_FUDGE + STARTUP_MIN;
  const grams = raw.filamentMm * crossSection * FILAMENT_DENSITY;

  return {
    gcode: em.lines.join('\n') + '\n',
    meta: {
      hole,
      colours: design.colours,
      backingLayers: nBack,
      designLayers: designZs.length,
      strokeCount: strokes.length,
      drawnLengthMm: Math.round(totalLength(strokes)),
      estMinutes: +estMinutes.toFixed(1),
      estGrams: +grams.toFixed(1),
      overBudget: estMinutes > cfg.limits.maxPrintMinutes,
      nearBudget: estMinutes > cfg.limits.warnPrintMinutes,
    },
  };
}

// ---------------------------------------------------------------------------

function layerZs(first, step, top) {
  const zs = [];
  let z = first;
  while (z <= top + 1e-6) {
    zs.push(+z.toFixed(3));
    z += step;
  }
  if (!zs.length) zs.push(+first.toFixed(3));
  return zs;
}

function perimeterLoop(em, cfg, poly, feed, layerH) {
  if (poly.length < 2) return;
  const p0 = toBed(poly[0], cfg.build);
  em.travelTo(p0.x, p0.y);
  for (let i = 1; i < poly.length; i++) {
    const p = toBed(poly[i], cfg.build);
    em.extrudeTo(p.x, p.y, feed, cfg.build.lineWidth, layerH);
  }
}

function infillLayer(em, cfg, hole, spacing, feed, layerH, phase) {
  const b = cfg.build;
  const { yMin, yMax } = yBounds(b, hole);
  const inset = b.lineWidth; // keep infill just inside the perimeter
  let dir = 1;
  for (let y = yMin + spacing * 0.5 + phase; y <= yMax - 0.001; y += spacing) {
    let spans = spanAtY(y, b, hole, inset);
    if (!spans.length) continue;
    if (dir === -1) spans = spans.slice().reverse();
    for (let [a, c] of spans) {
      if (dir === -1) [a, c] = [c, a];
      const p0 = toBed({ x: a, y }, b);
      const p1 = toBed({ x: c, y }, b);
      em.travelTo(p0.x, p0.y);
      em.extrudeTo(p1.x, p1.y, feed, b.lineWidth, layerH);
    }
    dir *= -1;
  }
}

function beadStroke(em, cfg, stroke, feed, width, layerH) {
  if (!stroke.length) return;
  const p0 = toBed(stroke[0], cfg.build);
  em.travelTo(p0.x, p0.y);
  if (stroke.length === 1) {
    // a dot: nudge a bead-width so it lays a blob
    em.extrudeTo(p0.x + width * 0.5, p0.y, feed, width, layerH);
    return;
  }
  for (let i = 1; i < stroke.length; i++) {
    const p = toBed(stroke[i], cfg.build);
    em.extrudeTo(p.x, p.y, feed, width, layerH);
  }
}

function makeEmitter(cfg, crossSection) {
  const s = cfg.speed;
  const lines = [];
  const pos = { x: 0, y: 0, z: 0 };
  let timeMin = 0;
  let filamentMm = 0;

  const eFor = (len, width, h) => (width * h * len) / crossSection;

  return {
    lines,
    meta: () => ({ timeMin, filamentMm }),
    comment: (t) => lines.push('; ' + t),
    raw: (t) => { if (t && t.length) lines.push(t); },
    setZ(z) {
      lines.push(`G1 Z${z.toFixed(3)} F${Math.round(s.travel)}`);
      timeMin += Math.abs(z - pos.z) / s.travel;
      pos.z = z;
    },
    retract() { if (s.retractMm > 0) lines.push(`G1 E-${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    unretract() { if (s.retractMm > 0) lines.push(`G1 E${s.retractMm.toFixed(3)} F${Math.round(s.retractSpeed)}`); },
    travelTo(x, y) {
      this.retract();
      if (s.zHopMm > 0) lines.push(`G1 Z${(pos.z + s.zHopMm).toFixed(3)} F${Math.round(s.travel)}`);
      const L = Math.hypot(x - pos.x, y - pos.y);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} F${Math.round(s.travel)}`);
      timeMin += L / s.travel;
      if (s.zHopMm > 0) lines.push(`G1 Z${pos.z.toFixed(3)} F${Math.round(s.travel)}`);
      pos.x = x; pos.y = y;
      this.unretract();
    },
    extrudeTo(x, y, feed, width, h) {
      const L = Math.hypot(x - pos.x, y - pos.y);
      if (L < 1e-4) return;
      const e = eFor(L, width, h);
      lines.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} E${e.toFixed(5)} F${Math.round(feed)}`);
      timeMin += L / feed;
      filamentMm += e;
      pos.x = x; pos.y = y;
    },
  };
}

function asLines(v) {
  if (Array.isArray(v)) return v;
  return String(v).split('\n');
}

function applyTemplate(text, cfg) {
  if (!text) return '';
  return text
    .replaceAll('{nozzle}', cfg.temp.nozzle)
    .replaceAll('{bed}', cfg.temp.bed)
    .replaceAll('{nozzleFirst}', cfg.temp.nozzleFirst)
    .replaceAll('{bedFirst}', cfg.temp.bedFirst);
}
