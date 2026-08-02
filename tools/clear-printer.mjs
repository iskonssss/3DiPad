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
import { watchPrinter, isConfigured, clearIfStuck, needsClearing, readCommandReply } from '../src/integrations/bambu.js';
import { refuseIfBoothRunning } from './booth-running.mjs';

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

await refuseIfBoothRunning(process.argv, 'clear-printer');

console.log('');
for (const printer of chosen) {
  const state = {};
  let stopReply = null;
  const watch = watchPrinter(printer, cfg, (s) => Object.assign(state, s), (msg) => {
    const r = readCommandReply(msg);
    if (r && r.command === 'stop') stopReply = r;
  });
  await new Promise((r) => setTimeout(r, 3500));

  if (!state.state) {
    console.log(`  ${printer.name}: not reporting — check it on the setup page`);
  } else if (!needsClearing(state.state)) {
    console.log(`  ${printer.name}: ${state.state} — nothing to clear`);
  } else {
    console.log(`  ${printer.name}: ${state.state}, still holding "${state.file || 'a finished job'}"`);
    const r = await clearIfStuck(printer, cfg, () => state, { onReply: () => stopReply });
    if (r.cleared) {
      console.log(`  ${printer.name}: cleared — now ${r.state}. It will accept prints again.`);
    } else if (r.accepted && r.accepted.result === 'success') {
      // The command landed. Whether the state followed is a separate question,
      // and saying "refused" here was simply wrong.
      console.log(`  ${printer.name}: it accepted the stop, but still reports ${r.state}.`);
      console.log('');
      console.log('    The command was not refused — the printer answered "success". Either it');
      console.log('    has not finished letting go yet, or the last print left something that');
      console.log('    needs acknowledging on the printer\'s own screen.');
      console.log('');
      console.log('    Look at the screen: dismiss whatever the failed print left there, then');
      console.log('    run this again. If it clears, that was it.');
    } else if (r.accepted) {
      console.log(`  ${printer.name}: the stop was REFUSED — ${r.accepted.reason || r.accepted.result}`);
      console.log('');
      console.log('    Every print command being refused means third-party print control is off.');
      console.log('    Turn DEVELOPER MODE on in the printer\'s network settings and restart it.');
      console.log('    Run  npm run probe-commands  to see the whole picture.');
    } else {
      console.log(`  ${printer.name}: no answer to the stop, and still ${r.state}.`);
      console.log('    Run  npm run probe-commands  to see what it is accepting.');
    }
  }
  watch.stop();
}
console.log('');
process.exit(0);
