// Lead capture: every submission is recorded so any print traces back to its
// owner — name, phone, colours, and a visual of the exact design.

import fs from 'node:fs';
import path from 'node:path';

export function saveLead(root, job, design) {
  const dir = path.join(root, 'leads');
  fs.mkdirSync(dir, { recursive: true });

  // 1) append to the CSV master list
  const csv = path.join(dir, 'leads.csv');
  if (!fs.existsSync(csv)) {
    fs.writeFileSync(csv, 'timestamp,seq,name,phone,layer1,layer2,hole,filename,est_minutes\n');
  }
  const c = job.colours;
  const row = [
    new Date().toISOString(),
    job.seq,
    csvCell(job.contact.name),
    csvCell(job.contact.phone),
    c.layer1,
    c.layer2,
    job.hole,
    job.filename,
    job.meta?.estMinutes ?? '',
  ].join(',');
  fs.appendFileSync(csv, row + '\n');

  // 2) save the design as an SVG next to it (the visual record)
  const svg = designSvg(design, job);
  fs.writeFileSync(path.join(dir, `${job.filename.replace(/\.gcode$/, '')}.svg`), svg);
}

function csvCell(v) {
  const s = String(v ?? '');
  return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

// Render the design (plate-local mm, y-up) as a labelled SVG record.
function designSvg(design, job) {
  const W = 100, H = 40, pad = 8;
  const svgW = W + pad * 2, svgH = H + pad * 2 + 14;
  const X = (x) => (x + pad).toFixed(2);
  const Y = (y) => (H - y + pad).toFixed(2);
  const strokes = (design.design || [])
    .map((s) => {
      if (s.length === 1) return `<circle cx="${X(s[0].x)}" cy="${Y(s[0].y)}" r="0.8" fill="#e11"/>`;
      const d = s.map((p, i) => `${i ? 'L' : 'M'}${X(p.x)} ${Y(p.y)}`).join(' ');
      return `<path d="${d}" fill="none" stroke="#e11" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>`;
    })
    .join('');
  const label = `${job.filename} — ${job.contact.name} ${job.contact.phone}`;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${svgW} ${svgH}" width="${svgW * 4}" height="${svgH * 4}">
  <rect width="${svgW}" height="${svgH}" fill="#fff"/>
  <rect x="${pad}" y="${pad}" width="${W}" height="${H}" fill="#f0f2f6" stroke="#ccd"/>
  ${strokes}
  <text x="${pad}" y="${svgH - 4}" font-family="sans-serif" font-size="4" fill="#333">${escapeXml(label)}</text>
</svg>`;
}

function escapeXml(s) {
  return String(s).replace(/[<>&]/g, (c) => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]));
}
