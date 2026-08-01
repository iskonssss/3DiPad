// Find out what this printer will actually start, by trying things in order
// and writing down what it says.
//
//   npm run probe-start -- [--reference path/to/bambu-made.3mf] [--printer A1-1]
//
// The A1 mini answers `project_file` with err_code 0x05024007 and does not
// print. That single fact is consistent with several very different faults —
// a 3mf its firmware will not open, a member name it cannot find inside one, a
// directory it will not read from, a command shape it does not accept — and
// testing them one per conversation costs a day each.
//
// So test them all in one pass. Each experiment uploads a file, sends one
// start command, and waits to see whether the printer moves or complains. The
// first one that starts is the answer, and the run stops there so it does not
// interrupt a print it just began.
//
// The most valuable experiment is the first: a 3mf that Bambu Studio produced
// and that has already printed on this exact machine. If that starts, the
// fault is in the file we build. If it is refused identically, the fault is in
// the request, and the file is a red herring.

import fs from 'node:fs';
import zlib from 'node:zlib';
import os from 'node:os';
import path from 'node:path';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { build3mf } from '../src/integrations/bambu3mf.js';
import {
  uploadFile, buildPrintCommand, publishCommand, watchPrinter, isConfigured, readCommandReply,
} from '../src/integrations/bambu.js';

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

const reference = flag('reference');
if (reference && !fs.existsSync(reference)) {
  console.error(`--reference ${reference} does not exist.`);
  process.exit(2);
}

const work = fs.mkdtempSync(path.join(os.tmpdir(), '3dipad-probe-'));
const waitMs = Number(flag('wait', '18000'));

/* ---- the files we will try ------------------------------------------- */

const design = {
  shape: 'rounded', colours: { layer1: 'BLACK', layer2: 'BLACK' }, hole: true, holePos: 'top',
  design: [{ points: [{ x: 25, y: 15 }, { x: 60, y: 28 }, { x: 40, y: 32 }], width: 2.2 }],
};
const built = generate(design, cfg);
const gcodePath = path.join(work, 'PROBE_0001.gcode');
fs.writeFileSync(gcodePath, built.gcode);

const ourThreeMf = path.join(work, 'PROBE_0001.3mf');
fs.writeFileSync(ourThreeMf, build3mf({ gcode: built.gcode, meta: built.meta, cfg, name: 'PROBE_0001' }));

// The same 3mf with the one big part Bambu includes and we do not: the full
// slicer profile. If the firmware reads it to set up the print, its absence
// would explain a project it declines to open.
const withSettings = path.join(work, 'PROBE_0002.3mf');
fs.writeFileSync(withSettings, build3mf({
  gcode: built.gcode, meta: built.meta, cfg, name: 'PROBE_0002',
  extraParts: [{ name: 'Metadata/project_settings.config', data: referenceSettings() ?? '{}' }],
}));

/** Lift project_settings.config out of the reference 3mf, if we were given one. */
function referenceSettings() {
  if (!reference) return null;
  try {
    const buf = fs.readFileSync(reference);
    return readZipMember(buf, 'Metadata/project_settings.config');
  } catch { return null; }
}

/** Minimal central-directory reader — enough to pull one member out. */
function readZipMember(buf, want) {
  const eocd = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  if (eocd < 0) return null;
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  for (let i = 0; i < count; i++) {
    const method = buf.readUInt16LE(p + 10);
    const csize = buf.readUInt32LE(p + 20);
    const nameLen = buf.readUInt16LE(p + 28);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.slice(p + 46, p + 46 + nameLen).toString('utf8');
    if (name === want) {
      const start = local + 30 + buf.readUInt16LE(local + 26) + buf.readUInt16LE(local + 28);
      const body = buf.slice(start, start + csize);
      return method === 8 ? zlib.inflateRawSync(body) : body;
    }
    p += 46 + nameLen + buf.readUInt16LE(p + 30) + buf.readUInt16LE(p + 32);
  }
  return null;
}

/* ---- the experiments -------------------------------------------------- */

const EXPERIMENTS = [
  reference && {
    name: 'Bambu Studio 3mf, as Bambu sends it',
    why: 'if this starts, the request is fine and our 3mf is the problem',
    file: reference, dir: 'cache', variant: 'project_file', param: flag('refparam', 'Metadata/plate_2.gcode'),
  },
  reference && {
    name: 'Bambu Studio 3mf, from the SD card root',
    why: 'separates the directory from the file',
    file: reference, dir: '', variant: 'project_file', param: flag('refparam', 'Metadata/plate_2.gcode'),
  },
  {
    name: 'our 3mf, in cache/',
    why: 'what the booth does today',
    file: ourThreeMf, dir: 'cache', variant: 'project_file', param: 'Metadata/plate_1.gcode',
  },
  {
    name: 'our 3mf, from the SD card root',
    why: 'the directory, again, against our own file',
    file: ourThreeMf, dir: '', variant: 'project_file', param: 'Metadata/plate_1.gcode',
  },
  {
    name: 'our 3mf carrying project_settings.config',
    why: 'the one large part Bambu includes and we do not',
    file: withSettings, dir: 'cache', variant: 'project_file', param: 'Metadata/plate_1.gcode',
    skip: !reference && 'needs --reference to copy the settings from',
  },
  {
    name: 'bare .gcode, gcode_file with /sdcard prefix',
    why: 'the original approach, for the record',
    file: gcodePath, dir: '', variant: 'gcode_file',
  },
  {
    name: 'bare .gcode, gcode_file with just the name',
    why: 'some firmware wants no prefix',
    file: gcodePath, dir: '', variant: 'gcode_file_bare',
  },
].filter(Boolean);

/* ---- run them --------------------------------------------------------- */

const state = { live: null };
const watch = watchPrinter(printer, { ...cfg, integrations: { ...cfg.integrations, lan: { ...cfg.integrations.lan, debug: false } } },
  (s) => { state.live = { ...(state.live || {}), ...s }; });

const busy = () => ['RUNNING', 'PREPARE', 'PAUSE', 'SLICING'].includes(String(state.live?.state || '').toUpperCase());

console.log('');
console.log(`  Probing ${printer.name} (${printer.id}) at ${printer.ip}`);
console.log(`  ${EXPERIMENTS.length} experiments, up to ${Math.round(waitMs / 1000)}s each.`);
if (!reference) {
  console.log('');
  console.log('  NOTE: no --reference given, so the most useful experiment is missing.');
  console.log('  Point it at a .3mf that Bambu Studio made and that has printed on this');
  console.log('  printer:  npm run probe-start -- --reference "C:\\path\\to\\plate.3mf"');
}
console.log('');

await sleep(3000);   // let the first status arrive
if (busy()) {
  console.log(`  The printer is ${state.live.state}. Stop or finish that print first.`);
  watch.stop();
  process.exit(1);
}

const results = [];
for (const [i, ex] of EXPERIMENTS.entries()) {
  const label = `${i + 1}/${EXPERIMENTS.length}  ${ex.name}`;
  if (ex.skip) { console.log(`  SKIP  ${label} — ${ex.skip}`); results.push({ ...ex, outcome: 'skipped' }); continue; }

  console.log(`  ---- ${label}`);
  console.log(`        ${ex.why}`);

  const sendCfg = { ...cfg, integrations: { ...cfg.integrations, lan: { ...cfg.integrations.lan, uploadDir: ex.dir, debug: false } } };
  let up;
  try {
    up = await uploadFile(printer, ex.file, sendCfg);
  } catch (e) {
    console.log(`        upload FAILED: ${e.message || e}`);
    results.push({ ...ex, outcome: 'upload failed', detail: String(e.message || e) });
    continue;
  }

  const before = watch.health().recent.length;
  const payload = buildPrintCommand(up.remotePath, { sequenceId: 900 + i, variant: ex.variant, gcodePath: ex.param });
  const pub = await publishCommand(printer, payload, sendCfg);
  if (!pub.ok) {
    console.log(`        publish FAILED: ${pub.error}`);
    results.push({ ...ex, outcome: 'publish failed', detail: pub.error });
    continue;
  }
  console.log(`        sent ${ex.variant} -> ${up.remotePath}${ex.param ? `  param=${ex.param}` : ''}`);

  const verdict = await watchOutcome(before, waitMs);
  console.log(`        ${verdict.outcome}${verdict.detail ? ' — ' + verdict.detail : ''}`);
  results.push({ ...ex, ...verdict });

  if (verdict.outcome === 'STARTED') {
    console.log('');
    console.log('  It started. Stopping here so the print is not interrupted.');
    break;
  }
  await sleep(1500);
}

/* ---- what we learned -------------------------------------------------- */

console.log('');
console.log('  ================ RESULTS ================');
for (const r of results) {
  console.log(`  ${String(r.outcome).padEnd(14)} ${r.name}${r.detail ? `\n                 ${r.detail}` : ''}`);
}
console.log('');
const started = results.find((r) => r.outcome === 'STARTED');
if (started) {
  console.log(`  WORKS: ${started.name}`);
  console.log(`         command=${started.variant} dir=${started.dir || '(root)'} param=${started.param || '(none)'}`);
} else {
  console.log('  Nothing started. Paste this whole output — the pattern across the rows');
  console.log('  says more than any single row does.');
}
console.log('');
watch.stop();
process.exit(0);

/** Wait for the printer to move, or to complain about the command we just sent. */
async function watchOutcome(sinceIndex, ms) {
  const deadline = Date.now() + ms;
  while (Date.now() < deadline) {
    if (busy()) return { outcome: 'STARTED', detail: `printer is ${state.live.state}` };
    const h = watch.health();
    const fresh = h.recent.slice(sinceIndex);
    for (const m of fresh) {
      // Same parser the monitor uses, so a refusal shape it understands is one
      // this understands too — no second, drifting copy of that knowledge.
      const reply = readCommandReply(m.msg);
      if (reply && reply.result !== 'success') {
        return { outcome: 'refused', detail: reply.reason || reply.result || 'no reason given' };
      }
    }
    await sleep(400);
  }
  return { outcome: 'no answer', detail: 'the printer neither moved nor complained' };
}

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }
