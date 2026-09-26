// Dev tool: generate g-code from a design JSON (or a built-in sample) and render
// a top-down toolpath SVG so the engine can be eyeballed without a printer.
//
//   node src/gcode/cli.js                       # sample design, centre hole
//   node src/gcode/cli.js left                  # sample design, left hole
//   node src/gcode/cli.js spinner               # the NFC spinner, two faces
//   node src/gcode/cli.js spinner 1,4,13,15,25  # ...plus one SVG per listed layer
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
} else if (arg === 'spinner') {
  design = sampleSpinner();
} else {
  design = JSON.parse(fs.readFileSync(arg, 'utf8'));
}

const { gcode, meta } = generate(design, cfg);
const outDir = path.join(root, 'output');
fs.mkdirSync(outDir, { recursive: true });
const base = `sample_${design.product === 'spinner' ? 'spinner' : design.shape}`;
fs.writeFileSync(path.join(outDir, base + '.gcode'), gcode);
fs.writeFileSync(path.join(outDir, base + '.svg'), toSvg(gcode));
const layers = (process.argv[3] || '').split(',').map((v) => parseInt(v, 10)).filter((v) => v > 0);
for (const n of layers) fs.writeFileSync(path.join(outDir, `${base}_layer${String(n).padStart(2, '0')}.svg`), toSvg(gcode, n));

console.log(JSON.stringify(meta, null, 2));
console.log(`wrote output/${base}.gcode  and  output/${base}.svg${layers.length ? `  (+${layers.length} layer SVGs)` : ''}`);

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

// The spinner: an "F" on the front (so a mirror is obvious), a filled blob and
// a line on the back. Plate-local mm; the disc's centre is (22.5, 22.5).
function sampleSpinner() {
  const c = 22.5;
  const front = [
    { w: 1.6, pts: [{ x: c - 5, y: c - 8 }, { x: c - 5, y: c + 8 }] },
    { w: 1.6, pts: [{ x: c - 5, y: c + 8 }, { x: c + 6, y: c + 8 }] },
    { w: 1.6, pts: [{ x: c - 5, y: c + 1 }, { x: c + 3, y: c + 1 }] },
  ];
  const back = [];
  for (let y = -6; y <= 6; y += 1) back.push({ w: 1.6, pts: [{ x: c - 6, y: c + y }, { x: c + 2, y: c + y }] });
  back.push({ w: 1.0, pts: [{ x: c + 5, y: c - 9 }, { x: c + 9, y: c + 9 }] });
  return { product: 'spinner', colours: { layer1: 'BLACK', layer2: 'RED' }, faces: { top: { design: front }, bottom: { design: back } }, sameBothSides: false };
}

// Parse g-code, draw extrusion segments (auto-fit); colour backing vs design.
// `onlyLayer` restricts the picture to one layer of the spinner's file, and
// draws its travels faintly too, so a wall printed in the wrong place shows.
function toSvg(gcode, onlyLayer = null) {
  const pad = 6;
  const segs = [];
  let pos = { x: 0, y: 0 };
  let colour = 'back';
  let inBody = false;
  let layer = 0;
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (const line of gcode.split('\n')) {
    if (line.includes('BACKING (colour 1)')) inBody = true;
    if (line.includes('GENERIC END') || line.includes('A1 mini END')) inBody = false;
    if (line.includes('COLOUR CHANGE')) colour = 'design';
    const lm = line.match(/^; layer (\d+)\/\d+ z=.* colour (\d)/);
    if (lm) { inBody = true; layer = +lm[1]; colour = lm[2] === '2' ? 'design' : 'back'; }
    if (!line.startsWith('G1 ')) continue;
    const nx = num(line, 'X'), ny = num(line, 'Y'), e = num(line, 'E');
    const to = { x: nx ?? pos.x, y: ny ?? pos.y };
    const wanted = onlyLayer == null || layer === onlyLayer;
    if (inBody && wanted && (nx != null || ny != null)) {
      const extruding = e != null && e > 0;
      if (extruding || onlyLayer != null) {
        segs.push({ a: pos, b: to, colour: extruding ? colour : 'travel' });
        for (const p of [pos, to]) { minX = Math.min(minX, p.x); minY = Math.min(minY, p.y); maxX = Math.max(maxX, p.x); maxY = Math.max(maxY, p.y); }
      }
    }
    pos = to;
  }
  if (!segs.length) return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"/>';
  const w = (maxX - minX) + pad * 2, h = (maxY - minY) + pad * 2;
  const X = (x) => (x - minX + pad).toFixed(2);
  const Y = (y) => (h - (y - minY + pad)).toFixed(2);
  const stroke = { back: '#38a', design: '#e11', travel: '#bbb' };
  const body = segs
    .map((s) => `<line x1="${X(s.a.x)}" y1="${Y(s.a.y)}" x2="${X(s.b.x)}" y2="${Y(s.b.y)}" stroke="${stroke[s.colour]}" stroke-width="${s.colour === 'travel' ? 0.1 : 0.4}" stroke-linecap="round" opacity="${s.colour === 'travel' ? 0.5 : 0.7}"/>`)
    .join('\n');

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w * 4}" height="${
    h * 4
  }"><rect width="${w}" height="${h}" fill="#fff"/>${body}</svg>`;
}

function num(line, key) {
  const m = line.match(new RegExp(`${key}(-?[0-9.]+)`));
  return m ? parseFloat(m[1]) : null;
}
