// Does this printer accept anything at all from us, or only refuse to print?
//
//   npm run probe-commands
//
// Seven different print requests were refused with one unchanging code, which
// said the fault was not in what we sent. LAN Only Mode was already on, so the
// obvious permission explanation is gone too. What is left is a narrower
// question that has not been asked yet:
//
//   is it that this printer will not take a PRINT command from us,
//   or that it will not take ANY command from us?
//
// The chamber light answers that, and answers it visibly. If the light obeys,
// our MQTT session is trusted and the refusal is specific to printing — so the
// next place to look is the printer's own condition. If the light ignores us
// too, nothing we send is being acted on, and the session is the thing to fix.
//
// It also dumps the printer's full reported state, because a machine with an
// unresolved error can sit at IDLE and refuse new jobs, and we have never
// actually looked at everything it tells us.

import { loadConfig } from '../src/config.js';
import { publishCommand, watchPrinter, isConfigured, readCommandReply, errorCodeText } from '../src/integrations/bambu.js';

const argv = process.argv.slice(2);
const flag = (n, d = null) => { const i = argv.indexOf('--' + n); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };

const cfg = loadConfig();
const printers = cfg.integrations?.printers || [];
const wanted = flag('printer');
const printer = wanted ? printers.find((p) => p.id === wanted) : printers.find(isConfigured);
if (!printer) {
  console.error(wanted ? `No printer with id ${wanted}.` : 'No printer configured — use the setup page first.');
  process.exit(2);
}

let full = null;
const watch = watchPrinter(printer, cfg, () => {});
const raw = [];

console.log('');
console.log(`  Talking to ${printer.name} (${printer.id}) at ${printer.ip}`);
console.log('');
await sleep(4000);

/* ---- 1. everything the printer says about itself ---------------------- */

const h = watch.health();
console.log('  ---- what the printer reports about itself');
if (!h.messages) {
  console.log('        nothing at all — it is not talking to us on this topic');
} else {
  console.log(`        ${h.messages} messages received`);
}
// pushall asks for the complete state rather than the deltas it sends by habit
await publishCommand(printer, { pushing: { sequence_id: '1', command: 'pushall' } }, cfg);
await sleep(3500);
reportState();

/* ---- 2. will it obey anything at all? --------------------------------- */

console.log('');
console.log('  ---- can it be commanded at all?');
console.log('        WATCH THE PRINTER: its light should go off, then on again.');
console.log('');

const light = (mode, node) => ({
  system: {
    sequence_id: String(Math.floor(Math.random() * 1000) + 100),
    command: 'ledctrl', led_node: node, led_mode: mode,
    led_on_time: 500, led_off_time: 500, loop_times: 0, interval_time: 0,
  },
});

// A1 mini calls it a chamber light in the protocol even though it has no
// chamber; older firmware used work_light. Try both, off then on.
for (const node of ['chamber_light', 'work_light']) {
  for (const mode of ['off', 'on']) {
    const r = await publishCommand(printer, light(mode, node), cfg);
    console.log(`        ${node} ${mode}: ${r.ok ? 'sent' : 'FAILED ' + r.error}`);
    await sleep(2500);
  }
}

await sleep(2000);
const after = watch.health();
const replies = after.recent.map((m) => readCommandReply(m.msg)).filter(Boolean);
const ledReplies = replies.filter((r) => r.command === 'ledctrl');

console.log('');
if (ledReplies.length) {
  for (const r of ledReplies) console.log(`        answered ledctrl: ${r.result}${r.reason ? ' — ' + r.reason : ''}`);
} else {
  console.log('        it did not answer the light commands either way.');
}

/* ---- what that tells us ----------------------------------------------- */

console.log('');
console.log('  ================ WHAT TO DO WITH THIS ================');
console.log('');
console.log('  Did the printer light actually change?');
console.log('');
console.log('    YES — the printer takes commands from us, and only refuses to print.');
console.log('          That points at the printer\'s own condition rather than our');
console.log('          session: look at the state and any errors printed above, and');
console.log('          check the screen for a warning that needs clearing.');
console.log('');
console.log('    NO  — nothing we send is being acted on, print or otherwise. The');
console.log('          session is the problem, not the print command, and the next');
console.log('          thing to try is the client identifier we connect with.');
console.log('');
console.log('  Either way, paste this whole output and say which it was.');
console.log('');

watch.stop();
process.exit(0);

function reportState() {
  const recent = watch.health().recent;
  const status = recent.map((m) => m.msg).filter((m) => m?.print).pop();
  if (!status) {
    console.log('        no full status arrived — it sends deltas and we caught none');
    return;
  }
  const p = status.print;
  const show = ['gcode_state', 'print_error', 'mc_percent', 'mc_remaining_time', 'subtask_name',
    'print_type', 'nozzle_temper', 'bed_temper', 'sdcard', 'home_flag', 'lifecycle', 'wifi_signal'];
  for (const k of show) if (p[k] !== undefined) console.log(`        ${k}: ${JSON.stringify(p[k])}`);
  if (typeof p.print_error === 'number' && p.print_error !== 0) {
    console.log(`        ^^ print_error is set: ${errorCodeText(p.print_error)}`);
  }
  const hms = Array.isArray(p.hms) ? p.hms : [];
  if (hms.length) {
    console.log(`        HMS warnings active: ${hms.length}`);
    for (const w of hms) console.log(`          ${JSON.stringify(w)}`);
    console.log('        ^^ an unresolved warning can stop it accepting new jobs.');
  } else if (p.hms) {
    console.log('        HMS warnings active: none');
  }
}

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }
