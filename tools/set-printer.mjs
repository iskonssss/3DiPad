// Fill in a printer's LAN details without hand-editing JSON.
//
// Most people should not need this: start the booth and open
//   http://localhost:3000/dashboard/setup.html
// which does the same thing with a Test button beside it and no terminal. This
// is the equivalent for scripting, and it writes through the same code so the
// two cannot drift apart.
//
//   node tools/set-printer.mjs <slot> <ip> <serial> <accessCode> [name]
//
// e.g.  node tools/set-printer.mjs 1 192.168.10.105 0309BA461400280 e94e9beb
//       node tools/set-printer.mjs 2 192.168.10.106 0309BA461400281 a1b2c3d4 "Printer 2"
//
// Creates config.json from config.example.json on first run and turns LAN mode
// on. config.json is git-ignored, so access codes never reach the repository.

import { savePrinter, maskCode } from '../src/printers.js';

const [slotArg, ip, serial, accessCode, nameArg] = process.argv.slice(2);

function usage(msg) {
  if (msg) console.error('Error: ' + msg + '\n');
  console.error('Usage: node tools/set-printer.mjs <slot 1-3> <ip> <serial> <accessCode> [name]');
  console.error('e.g.   node tools/set-printer.mjs 1 192.168.10.105 0309BA461400280 e94e9beb');
  console.error('\nOr skip the terminal: start the booth and open');
  console.error('       http://localhost:3000/dashboard/setup.html');
  process.exit(1);
}

if (!slotArg) usage('slot is required');
if (!ip) usage('ip is required');
if (!serial) usage('serial is required (printer screen: Settings > Device)');
if (!accessCode) usage('accessCode is required (printer screen: Settings > Network, LAN mode)');

let p;
try {
  p = savePrinter({}, { slot: slotArg, ip, serial, accessCode, name: nameArg });
} catch (e) {
  usage(String(e.message || e));
}

console.log(`\nSlot ${slotArg} set: ${p.name} (${p.id})`);
console.log(`  ip          ${p.ip}`);
console.log(`  serial      ${p.serial}`);
console.log(`  accessCode  ${maskCode(p.accessCode)}`);
console.log(`  LAN mode    enabled`);
console.log(`\nNext:  npm run test-printer   (or press Test on the setup page)\n`);
