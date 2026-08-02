// Send one file to a printer and print exactly what it answers.
//
//   npm run send-file -- <file> [--printer A1-1] [--command project_file]
//                              [--param Metadata/plate_1.gcode] [--dir cache]
//                              [--no-start]
//
// This exists to settle one question that guessing cannot: is the printer
// refusing our *file*, or our *request*?
//
// The booth uploads a 3mf and the A1 mini answers project_file with
// err_code 0x05024007 and does nothing. Two very different faults look
// identical from outside — a 3mf the firmware will not open, or a command it
// will not accept. Sending a 3mf that is known to have printed on this exact
// machine separates them in one attempt:
//
//   it starts      -> our 3mf is wrong; the command is fine
//   same err_code  -> the command is wrong; the 3mf is fine
//
// Everything is printed: the file, its md5, where it landed, the command, and
// every message the printer sends for the next few seconds.

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { loadConfig } from '../src/config.js';
import { uploadFile, buildPrintCommand, publishCommand, watchPrinter, isConfigured } from '../src/integrations/bambu.js';
import { refuseIfBoothRunning } from './booth-running.mjs';

const argv = process.argv.slice(2);
const flag = (name, fallback = null) => {
  const i = argv.indexOf('--' + name);
  return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : fallback;
};
const has = (name) => argv.includes('--' + name);
const file = argv.find((a) => !a.startsWith('--') && argv[argv.indexOf(a) - 1]?.startsWith('--') !== true);

if (!file) {
  console.error('Usage: npm run send-file -- <file.3mf|file.gcode> [--printer A1-1] [--command project_file]');
  console.error('                          [--param Metadata/plate_1.gcode] [--dir cache] [--no-start]');
  process.exit(2);
}

await refuseIfBoothRunning(process.argv, 'send-file');
if (!fs.existsSync(file)) {
  console.error(`No such file: ${path.resolve(file)}`);
  process.exit(2);
}

const cfg = loadConfig();
const printers = cfg.integrations?.printers || [];
const wanted = flag('printer');
const printer = wanted ? printers.find((p) => p.id === wanted) : printers.find(isConfigured);
if (!printer) {
  console.error(wanted ? `No printer with id ${wanted}` : 'No printer is configured — use the setup page first.');
  process.exit(2);
}

// upload into whichever directory is being tested, without touching config.json
const dir = flag('dir', cfg.integrations?.lan?.uploadDir ?? '');
const sendCfg = { ...cfg, integrations: { ...cfg.integrations, lan: { ...cfg.integrations.lan, uploadDir: dir, debug: false } } };

const bytes = fs.readFileSync(file);
console.log('');
console.log(`  file      ${path.resolve(file)}`);
console.log(`  size      ${bytes.length} bytes`);
console.log(`  md5       ${crypto.createHash('md5').update(bytes).digest('hex').toUpperCase()}`);
console.log(`  printer   ${printer.name} (${printer.id}) at ${printer.ip}`);
console.log('');

// Listen before sending, so the refusal cannot arrive before we are watching.
const seen = [];
const watch = watchPrinter(printer, sendCfg, () => {});
const origLog = console.log;
await new Promise((r) => setTimeout(r, 2500));

console.log('  uploading...');
let up;
try {
  up = await uploadFile(printer, file, sendCfg);
} catch (e) {
  console.error(`  UPLOAD FAILED: ${e.message || e}`);
  watch.stop();
  process.exit(1);
}
console.log(`  uploaded  ${up.remotePath}`);

if (has('no-start')) {
  console.log('  --no-start: not asking it to print. Check the printer screen for the file.');
  watch.stop();
  process.exit(0);
}

const variant = flag('command', 'project_file');
const param = flag('param', variant === 'project_file' ? 'Metadata/plate_1.gcode' : undefined);
const payload = buildPrintCommand(up.remotePath, { sequenceId: Date.now() % 100000, variant, gcodePath: param });
console.log('');
console.log('  sending:');
console.log('    ' + JSON.stringify(payload));
const pub = await publishCommand(printer, payload, sendCfg);
console.log(`  publish   ${pub.ok ? 'went out' : 'FAILED: ' + pub.error}`);

console.log('');
console.log('  listening for 20 seconds...');
const until = Date.now() + 20000;
let lastState = null;
const timer = setInterval(() => {
  const h = watch.health();
  if (h.lastCommand && h.lastCommand !== lastState) {
    lastState = h.lastCommand;
    const c = h.lastCommand;
    console.log(`  ANSWER    ${c.command}: ${c.result}${c.reason ? ' — ' + c.reason : ''}`);
  }
  if (Date.now() >= until) {
    clearInterval(timer);
    const h2 = watch.health();
    console.log('');
    if (!h2.lastCommand) console.log('  The printer never answered the command at all.');
    console.log(`  messages received: ${h2.messages}`);
    for (const r of (h2.recent || []).slice(-4)) console.log('    ' + r.text);
    console.log('');
    console.log('  Look at the printer now. Did it start?');
    watch.stop();
    process.exit(0);
  }
}, 500);
