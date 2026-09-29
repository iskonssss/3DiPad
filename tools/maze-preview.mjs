// Draw a name-maze layout as an SVG and print its numbers, without a printer.
//
//   node tools/maze-preview.mjs                    # config defaults, seed 1, letter M
//   node tools/maze-preview.mjs --letter K --seed 7
//   node tools/maze-preview.mjs --name Kiara       # seed from the name
//   node tools/maze-preview.mjs --size 100 --cells 9 --chamber 3
//   node tools/maze-preview.mjs --sizes 80,100,120 # a table of rough times, no SVG
//   node tools/maze-preview.mjs --html --seeds 1,2,3,4,5,6   # a 3D preview page too
//
// Writes output/maze_<letter>_<seed>.svg, and with --html a page
// output/maze_<letter>_<seed>.html (from tools/maze-preview.html) that draws
// the tray in 3D with the letter in a chosen font, one maze per listed seed.

import fs from 'node:fs';
import path from 'node:path';
import { loadConfig, root } from '../src/config.js';
import { mazeLayout, mazeSvg, mazeRoughMinutes, mazeLayoutJson, seedFrom } from '../src/gcode/maze.js';

const args = process.argv.slice(2);
const opt = (name, dflt) => { const i = args.indexOf(`--${name}`); return i >= 0 && args[i + 1] != null ? args[i + 1] : dflt; };

const cfg = loadConfig();
cfg.maze = { ...(cfg.maze || {}) };
for (const [flag, k] of [['size', 'outerSize'], ['cells', 'cells'], ['chamber', 'chamberCells'], ['wall', 'wallThickness'], ['rim', 'rimThickness'], ['height', 'wallHeight'], ['floor', 'floorThickness'], ['layer', 'layerHeight'], ['flow', 'maxVolumetricMmps'], ['ball', 'ballDiameter'], ['boss', 'lid.bossRadius'], ['inset', 'lid.holeInset']]) {
  const v = opt(flag, null);
  if (v == null) continue;
  if (k.startsWith('lid.')) { cfg.maze.lid = { ...(cfg.maze.lid || {}), [k.slice(4)]: parseFloat(v) }; } else cfg.maze[k] = parseFloat(v);
}

const name = opt('name', null);
const letter = opt('letter', name ? name[0].toUpperCase() : 'M');
const seed = name ? seedFrom(name) : parseInt(opt('seed', '1'), 10);

const sizes = opt('sizes', null);
if (sizes) {
  console.log('size   cells corridor  walls(mm)  floor  walls  total   grams');
  for (const s of sizes.split(',').map(Number)) {
    cfg.maze.outerSize = s;
    let lay;
    try { lay = mazeLayout(cfg, { seed, letter }); } catch (e) { console.log(`${String(s).padEnd(6)} ${e.message}`); continue; }
    const t = mazeRoughMinutes(lay, cfg);
    console.log(`${String(s).padEnd(6)} ${String(lay.cells).padEnd(5)} ${lay.corridor.toFixed(2).padStart(8)} ${lay.innerWallLength.toFixed(0).padStart(10)} ${t.floorMinutes.toFixed(1).padStart(6)} ${t.wallMinutes.toFixed(1).padStart(6)} ${t.minutes.toFixed(1).padStart(6)} ${t.grams.toFixed(0).padStart(7)}`);
  }
  process.exit(0);
}

const lay = mazeLayout(cfg, { seed, letter });
const t = mazeRoughMinutes(lay, cfg);
const outDir = path.join(root, 'output');
fs.mkdirSync(outDir, { recursive: true });
const file = path.join(outDir, `maze_${letter}_${seed}.svg`);
fs.writeFileSync(file, mazeSvg(lay));

console.log(JSON.stringify({
  letter, seed, tray: lay.outer, cells: lay.cells, chamber: lay.chamber,
  corridor: +lay.corridor.toFixed(2), wall: lay.wallT, rim: lay.rimT, pitch: +lay.pitch.toFixed(2),
  layers: { floor: lay.spec.floorLayers, wall: lay.spec.wallLayers, height: lay.spec.layerH },
  innerWallMm: Math.round(lay.innerWallLength), solutionCells: lay.solution.length, finishSide: lay.finish.side,
  rough: { minutes: +t.minutes.toFixed(1), floorMinutes: +t.floorMinutes.toFixed(1), wallMinutes: +t.wallMinutes.toFixed(1), grams: +t.grams.toFixed(1) },
}, null, 2));
console.log(`wrote ${path.relative(root, file)}`);

if (args.includes('--html')) {
  const seeds = opt('seeds', String(seed)).split(',').map((v) => parseInt(v, 10)).filter((v) => Number.isFinite(v));
  const layouts = seeds.map((sd) => mazeLayoutJson(mazeLayout(cfg, { seed: sd, letter }), cfg));
  const tpl = fs.readFileSync(path.join(root, 'tools', 'maze-preview.html'), 'utf8');
  const page = tpl.replace('/*__LAYOUTS__*/null', JSON.stringify(layouts));
  const html = path.join(outDir, `maze_${letter}_${seed}.html`);
  fs.writeFileSync(html, page);
  console.log(`wrote ${path.relative(root, html)}  (${layouts.length} maze${layouts.length === 1 ? '' : 's'})`);
}
