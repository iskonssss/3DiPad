// Hand a stuck printer back to itself.
//
//   npm run clear-printer [-- --printer A1-1]
//
// A Bambu that has failed or finished a print keeps holding it: gcode_state
// stays FAILED, it goes on naming the job that died, and it refuses every new
// print command until told to let go. The refusal is identical whatever you
// send, which is how it looked for weeks like a protocol problem.
//
// The booth now does this by itself before every send. This is for clearing one
// by hand, and for seeing it happen.

import { loadConfig } from '../src/config.js';
import { watchPrinter, isConfigured, clearIfStuck, needsClearing } from '../src/integrations/bambu.js';

const argv = process.argv.slice(2);
const flag = (n) => { const i = argv.indexOf('--' + n); return i >= 0 ? argv[i + 1] : null; };

const cfg = loadConfig();
const printers = (cfg.integrations?.printers || []).filter(isConfigured);
const wanted = flag('printer');
const chosen = wanted ? printers.filter((p) => p.id === wanted) : printers;
if (!chosen.length) {
  console.error(wanted ? `No printer with id ${wanted}.` : 'No printer configured — use the setup page first.');
  process.exit(2);
}

console.log('');
for (const printer of chosen) {
  const state = {};
  const watch = watchPrinter(printer, cfg, (s) => Object.assign(state, s));
  await new Promise((r) => setTimeout(r, 3500));

  if (!state.state) {
    console.log(`  ${printer.name}: not reporting — check it on the setup page`);
  } else if (!needsClearing(state.state)) {
    console.log(`  ${printer.name}: ${state.state} — nothing to clear`);
  } else {
    console.log(`  ${printer.name}: ${state.state}, still holding "${state.file || 'a finished job'}"`);
    const r = await clearIfStuck(printer, cfg, () => state);
    console.log(r.cleared
      ? `  ${printer.name}: cleared — now ${r.state}. It will accept prints again.`
      : `  ${printer.name}: would not clear (still ${r.state}). Dismiss the last print on the printer's own screen.`);
  }
  watch.stop();
}
console.log('');
process.exit(0);
