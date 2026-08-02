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
    if (r.cleared) {
      console.log(`  ${printer.name}: cleared — now ${r.state}. It will accept prints again.`);
    } else {
      console.log(`  ${printer.name}: would not clear (still ${r.state}).`);
      console.log('');
      console.log('    The printer refused `stop` as well, with the same code it refuses');
      console.log('    project_file with — and `stop` is valid in every state there is. So this');
      console.log('    is not the failed job blocking things: every print command is being');
      console.log('    refused, while the light and the status feed work fine.');
      console.log('');
      console.log('    Dismiss the failed print on the printer\'s own screen, and look for');
      console.log('    DEVELOPER MODE in its network settings — third-party print control is off.');
      console.log('    Run  npm run probe-commands  to see the whole picture.');
    }
  }
  watch.stop();
}
console.log('');
process.exit(0);
