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
const arg = process.argv[2] || 'centre';

let design;
if (['left', 'right', 'centre'].includes(arg)) {
  design = sampleDesign(arg, cfg.build);
} else {
  design = JSON.parse(fs.readFileSync(arg, 'utf8'));
}

const { gcode, meta } = generate(design, cfg);
const outDir = path.join(root, 'output');
fs.mkdirSync(outDir, { recursive: true });
const base = `sample_${design.hole}`;
fs.writeFileSync(path.join(outDir, base + '.gcode'), gcode);
fs.writeFileSync(path.join(outDir, base + '.svg'), toSvg(gcode, cfg.build));

console.log(JSON.stringify(meta, null, 2));
console.log(`wrote output/${base}.gcode  and  output/${base}.svg`);

// A crude "HI" plus an underline, in plate-local mm (y-up).
function sampleDesign(hole, b) {
  const strokes = [
    [{ x: 25, y: 10 }, { x: 25, y: 30 }],                 // H left
    [{ x: 25, y: 20 }, { x: 38, y: 20 }],                 // H bar
    [{ x: 38, y: 10 }, { x: 38, y: 30 }],                 // H right
    [{ x: 55, y: 10 }, { x: 55, y: 30 }],                 // I stem
    [{ x: 48, y: 30 }, { x: 62, y: 30 }],                 // I top
    [{ x: 48, y: 10 }, { x: 62, y: 10 }],                 // I bottom
    [{ x: 20, y: 6 }, { x: 80, y: 6 }],                   // underline
  ];
  return { hole, colours: { layer1: 'BLACK', layer2: 'WHITE' }, design: strokes };
}

// Parse g-code, draw extrusion segments; colour backing vs design by the marker.
function toSvg(gcode, b) {
  const pad = 6;
  const bulge = b.bulgeRadius;
  const w = b.plateWidth + pad * 2;
  const h = b.plateHeight + bulge + pad * 2;
  const cx = b.bedCenter[0];
  const cy = b.bedCenter[1];

  const segs = [];
  let pos = { x: 0, y: 0 };
  let colour = 'back';
  for (const line of gcode.split('\n')) {
    if (line.includes('COLOUR CHANGE')) colour = 'design';
    const m = line.match(/^G1 /);
    if (!m) continue;
    const nx = num(line, 'X');
    const ny = num(line, 'Y');
    const e = num(line, 'E');
    const to = { x: nx ?? pos.x, y: ny ?? pos.y };
    if (e != null && e > 0 && (nx != null || ny != null)) segs.push({ a: pos, b: to, colour });
    pos = to;
  }

  // bed -> plate-local -> svg (flip y for screen)
  const X = (x) => (x - cx + b.plateWidth / 2 + pad).toFixed(2);
  const Y = (y) => (h - (y - cy + b.plateHeight / 2 + pad)).toFixed(2);

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
