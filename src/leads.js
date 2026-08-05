// Lead capture: every submission is recorded so any print traces back to its
// owner — name, phone, colours, and a visual of the exact design.

import fs from 'node:fs';
import path from 'node:path';
import { shapePolygon } from './gcode/geometry.js';
import { imageCoverage, decodeBitmap } from './gcode/image.js';
import { maskContours, contourToMm } from './gcode/fill.js';

/** `dir` is where lead records go — see output.leadsDir. */
export function saveLead(dir, job, design, cfg) {
  fs.mkdirSync(dir, { recursive: true });

  // 1) append to the CSV master list
  const csv = path.join(dir, 'leads.csv');
  if (!fs.existsSync(csv)) {
    fs.writeFileSync(csv, 'timestamp,seq,name,phone,layer1,layer2,shape,hole_x,hole_y,filename,est_minutes\n');
  }
  const c = job.colours;
  const row = [
    new Date().toISOString(),
    job.seq,
    csvCell(job.contact.name),
    csvCell(job.contact.phone),
    c.layer1,
    c.layer2,
    job.shape ?? '',
    job.hole?.x ?? '',
    job.hole?.y ?? '',
    job.filename,
    job.meta?.estMinutes ?? '',
  ].join(',');
  fs.appendFileSync(csv, row + '\n');

  // 2) save the design as an SVG next to it (the visual record)
  const svg = designSvg(design, job, cfg);
  fs.writeFileSync(path.join(dir, `${job.filename.replace(/\.gcode$/, '')}.svg`), svg);
}

function csvCell(v) {
  const s = String(v ?? '');
  return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

// Render the design (plate-local mm, y-up) as a labelled SVG record: the actual
// backing shape, the keyring hole, and each stroke at its own pen width.
function designSvg(design, job, cfg) {
  const pad = 8;
  const { poly, bbox } = shapePolygon(design.shape || 'rectangle', cfg, design.customOutline);
  const W = bbox.w, H = bbox.h;
  const svgW = W + pad * 2, svgH = H + pad * 2 + 14;
  const X = (x) => (x + pad).toFixed(2);
  const Y = (y) => (H - y + pad).toFixed(2);

  const outline = poly.map((p, i) => `${i ? 'L' : 'M'}${X(p.x)} ${Y(p.y)}`).join(' ') + ' Z';
  const hole = job.hole
    ? `<circle cx="${X(job.hole.x)}" cy="${Y(job.hole.y)}" r="${cfg.build.holeDiameter / 2}" fill="#fff" stroke="#aab"/>`
    : '';
  // An uploaded drawing has no strokes; its visual record is the printed
  // silhouette itself — the same coverage the g-code was built from, traced to
  // filled contours so the record shows exactly what came off the plate.
  const design2 = design.image ? imageContours(design, poly, cfg) : strokePaths(design.design, X, Y, cfg);

  const label = `${job.filename} — ${job.contact.name} ${job.contact.phone}${design.image ? ' (imported image)' : ''}`;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${svgW} ${svgH}" width="${svgW * 4}" height="${svgH * 4}">
  <rect width="${svgW}" height="${svgH}" fill="#fff"/>
  <path d="${outline}" fill="#f0f2f6" stroke="#ccd"/>
  ${hole}
  ${design2}
  <text x="${pad}" y="${svgH - 4}" font-family="sans-serif" font-size="4" fill="#333">${escapeXml(label)}</text>
</svg>`;
}

function strokePaths(strokes, X, Y, cfg) {
  return (strokes || [])
    .map((s) => {
      const pts = Array.isArray(s?.pts) ? s.pts : Array.isArray(s) ? s : [];
      const w = Number.isFinite(+s?.w) ? +s.w : cfg.build.beadWidth;
      if (!pts.length) return '';
      if (pts.length === 1) return `<circle cx="${X(pts[0].x)}" cy="${Y(pts[0].y)}" r="${(w / 2).toFixed(2)}" fill="#e11"/>`;
      const d = pts.map((p, i) => `${i ? 'L' : 'M'}${X(p.x)} ${Y(p.y)}`).join(' ');
      return `<path d="${d}" fill="none" stroke="#e11" stroke-width="${w.toFixed(2)}" stroke-linecap="round" stroke-linejoin="round"/>`;
    })
    .join('');
}

/** The imported drawing as filled contours of the exact printed coverage. */
function imageContours(design, poly, cfg) {
  try {
    const bitmap = decodeBitmap(design.image);
    if (!bitmap) return '';
    const { poly: pp, bbox } = shapePolygon(design.shape || 'rectangle', cfg, design.customOutline);
    const cov = imageCoverage(bitmap, cfg, bbox, pp, null, cfg.build.designEdgeMargin);
    if (!cov) return '';
    const H = bbox.h, pad = 8;
    const X = (x) => (x + pad).toFixed(2);
    const Y = (y) => (H - y + pad).toFixed(2);
    // fill-rule even-odd so an enclosed hole (a drawn "O") reads as a ring.
    const d = maskContours(cov.mask, cov.w, cov.h)
      .map((loop) => contourToMm(loop, cov))
      .filter((l) => l.length >= 3)
      .map((l) => l.map((p, i) => `${i ? 'L' : 'M'}${X(p.x)} ${Y(p.y)}`).join(' ') + ' Z')
      .join(' ');
    return d ? `<path d="${d}" fill="#e11" fill-rule="evenodd" stroke="none"/>` : '';
  } catch {
    return '';
  }
}

function escapeXml(s) {
  return String(s).replace(/[<>&]/g, (c) => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]));
}
