// Turn an M1006 tune into a standalone file you run from the printer's SCREEN.
//
//   node tools/make-music.mjs               # builds every tune in TUNES below
//
// Completely separate from the booth. It writes a .gcode and a .3mf per tune to
// output/music/. Copy the .3mf onto the printer's SD card with a card reader,
// then on the printer: Print -> SD card -> pick it -> go. It plays the tune on
// the buzzer/motors and does NOTHING else: no homing, no heating, no extrusion,
// no bed levelling. Nothing to load, no network. A ~20-second "print" that is
// only a song.
//
// The .3mf is the safe one — it is Bambu's own format and always lists on the
// screen. The .gcode is written too in case a firmware prefers it.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadConfig } from '../src/config.js';
import { bambuBlocks } from '../src/gcode/engine.js';
import { build3mf } from '../src/integrations/bambu3mf.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const cfg = loadConfig();
const outDir = path.join(root, 'output', 'music');
fs.mkdirSync(outDir, { recursive: true });

// A tune is a list of [pitch, dur] — pitch is a MIDI note (0 = rest), dur is the
// M1006 duration unit. Same numbers Booth Buzzer Studio plays.
const TUNES = {
  'CRAZY-FROG': {
    title: 'Crazy Frog — Axel F',
    // Transcribed note-for-note from 'Crazy Frog - Axel F.mid' (140 BPM): exact
    // pitches (45-62, already in range), each note's real length, and the real
    // gaps between notes, sped up 10% from the file. Plays right at 8ms/unit.
    notes: [
      [50,12],[0,36],[53,12],[0,24],[50,12],[0,12],[50,12],[55,12],[0,12],[50,12],[0,12],[48,12],[0,12],[50,12],[0,36],[57,12],[0,24],[50,12],[0,12],[50,12],[58,12],[0,12],[57,12],[0,12],[53,12],[0,12],[50,12],[0,12],[57,12],[0,12],[62,12],[0,12],[50,12],[48,12],[0,12],[48,12],[45,12],[0,12],[52,12],[0,12],[50,12],[0,217],[50,12],[0,36],[53,12],[0,24],[50,12],[0,12],[50,12],[55,12],[0,12],[50,12],[0,12],[48,12],[0,12],[50,12],[0,36],[57,12],[0,24],[50,12],[0,12],[50,12],[58,12],[0,12],[57,12],[0,12],[53,12],[0,12],[50,12],[0,12],[57,12],[0,12],[62,12],[0,12],[50,12],[48,12],[0,12],[48,12],[45,12],[0,12],[52,12],[0,12],[50,12],[0,217],[50,12],[0,36],[53,12],[0,24],[50,12],[0,12],[50,12],[55,12],[0,12],[50,12],[0,12],[48,12],[0,12],[50,12],[0,36],[57,12],[0,24],[50,12],[0,12],[50,12],[58,12],[0,12],[57,12],[0,12],[53,12],[0,12],[50,12],[0,12],[57,12],[0,12],[62,12],[0,12],[50,12],[48,12],[0,12],[48,12],[45,12],[0,12],[52,12],[0,12],[50,12],
    ],
  },
};

function tuneLines(notes) {
  const out = [
    '; ===== MUSIC ONLY — plays a tune on the buzzer, prints nothing =====',
    'M104 S0 ; hotend off — this file never heats',
    'M140 S0 ; bed off',
    'M106 S0 ; fan off',
    'M17    ; motors on (the tune is played on them)',
    'M400 S1',
    'M1006 S1',
  ];
  for (const [p, d] of notes) {
    out.push(`M1006 A${p} B${d} L100 C${p} D${d} M100 E${p} F${d} N100`);
  }
  out.push('M1006 W', 'M18 ; motors off', '; ===== end of tune =====');
  return out;
}

const info = { minutes: 0.5, layers: 1, filamentMm: 0, grams: 0, maxZ: 1, density: 1.24, diameter: 1.75 };
const meta = { bbox: { w: 100, h: 40 }, colours: { layer1: 'BLACK', layer2: 'BLACK' }, estMinutes: 1, estGrams: 0 };

for (const [name, tune] of Object.entries(TUNES)) {
  const gcode = bambuBlocks(tuneLines(tune.notes), info).replace('3DiPad booth generator', `3DiPad — ${tune.title}`);
  const gpath = path.join(outDir, `${name}.gcode`);
  fs.writeFileSync(gpath, gcode);
  const threemf = build3mf({ gcode, meta, cfg, name });
  fs.writeFileSync(path.join(outDir, `${name}.3mf`), threemf);
  const secs = (tune.notes.reduce((s, [, d]) => s + d, 0) * 0.008).toFixed(1);
  console.log(`  ${tune.title}`);
  console.log(`    ${path.relative(root, gpath)}   (${tune.notes.filter(n => n[0] > 0).length} notes, ~${secs}s at 8ms/unit)`);
  console.log(`    ${path.relative(root, gpath).replace('.gcode', '.3mf')}   <- copy THIS to the SD card`);
}
console.log('');
console.log('  On the printer: Print -> SD card (Local) -> pick the file -> start. It just plays.');
console.log('');
