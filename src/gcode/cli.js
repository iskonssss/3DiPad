// Dev tool: generate g-code from a design JSON (or a built-in sample) and render
// a top-down toolpath SVG so the engine can be eyeballed without a printer.
//
//   node src/gcode/cli.js                       # sample design, centre hole
//   node src/gcode/cli.js left                  # sample design, left hole
//   node src/gcode/cli.js path/to/design.json   # your own design

import fs from 'node:fs';
import path from 'node:path';
import { loadConfig, root } from '../config.js';
import { generate } from './engine.js';

const cfg = loadConfig();
const arg = process.argv[2] || 'rectangle';
const SHAPES = ['rectangle', 'square', 'circle', 'heart', 'custom'];

let design;
if (SHAPES.includes(arg)) {
  design = sampleDesign(arg);
} else {
  design = JSON.parse(fs.readFileSync(arg, 'utf8'));
}

const { gcode, meta } = generate(design, cfg);
const outDir = path.join(root, 'output');
fs.mkdirSync(outDir, { recursive: true });
const base = `sample_${design.shape}`;
fs.writeFileSync(path.join(outDir, base + '.gcode'), gcode);
fs.writeFileSync(path.join(outDir, base + '.svg'), toSvg(gcode));

console.log(JSON.stringify(meta, null, 2));
console.log(`wrote output/${base}.gcode  and  output/${base}.svg`);

// A crude "HI" in plate-local mm (y-up), two pen widths, for the chosen shape.
function sampleDesign(shape) {
  const design = [
    { w: 1.4, pts: [{ x: 20, y: 12 }, { x: 20, y: 30 }] },
    { w: 1.4, pts: [{ x: 20, y: 21 }, { x: 30, y: 21 }] },
    { w: 1.4, pts: [{ x: 30, y: 12 }, { x: 30, y: 30 }] },
    { w: 2.2, pts: [{ x: 40, y: 12 }, { x: 40, y: 30 }] },
  ];
  const customOutline = [
    { x: 5, y: 20 }, { x: 20, y: 55 }, { x: 45, y: 60 }, { x: 70, y: 45 }, { x: 60, y: 10 }, { x: 25, y: 5 },
  ];
  return { shape, colours: { layer1: 'BLACK', layer2: 'WHITE' }, holePos: 'top', customOutline, design };
}

// Parse g-code, draw extrusion segments (auto-fit); colour backing vs design.
function toSvg(gcode) {
  const pad = 6;
  const segs = [];
  let pos = { x: 0, y: 0 };
  let colour = 'back';
  let inBody = false;
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (const line of gcode.split('\n')) {
    if (line.includes('BACKING (colour 1)')) inBody = true;
    if (line.includes('GENERIC END') || line.includes('A1 mini END')) inBody = false;
    if (line.includes('COLOUR CHANGE')) colour = 'design';
    if (!line.startsWith('G1 ')) continue;
    const nx = num(line, 'X'), ny = num(line, 'Y'), e = num(line, 'E');
    const to = { x: nx ?? pos.x, y: ny ?? pos.y };
    if (inBody && e != null && e > 0 && (nx != null || ny != null)) {
      segs.push({ a: pos, b: to, colour });
      for (const p of [pos, to]) { minX = Math.min(minX, p.x); minY = Math.min(minY, p.y); maxX = Math.max(maxX, p.x); maxY = Math.max(maxY, p.y); }
    }
    pos = to;
  }
  const w = (maxX - minX) + pad * 2, h = (maxY - minY) + pad * 2;
  const X = (x) => (x - minX + pad).toFixed(2);
  const Y = (y) => (h - (y - minY + pad)).toFixed(2);

  const body = segs
    .map(
      (s) =>
        `<line x1="${X(s.a.x)}" y1="${Y(s.a.y)}" x2="${X(s.b.x)}" y2="${Y(s.b.y)}" stroke="${
          s.colour === 'design' ? '#e11' : '#38a'
        }" stroke-width="0.4" stroke-linecap="round" opacity="0.7"/>`,
    )
    .join('\n');

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w * 4}" height="${
    h * 4
  }"><rect width="${w}" height="${h}" fill="#fff"/>${body}</svg>`;
}

function num(line, key) {
  const m = line.match(new RegExp(`${key}(-?[0-9.]+)`));
  return m ? parseFloat(m[1]) : null;
}
