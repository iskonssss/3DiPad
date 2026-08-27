// Which half makes the printer treat a print as a manual external-spool
// colour change — the FILE or the START COMMAND?
//
//   node tools/probe-change.mjs --printer A1-2 --reference path/to/bambu-made.3mf
//
// The printer writes its task record (/sdcard/cache/<plate>_<name>.bbl) the
// moment it accepts a job, and that record carries manual_color_change. So a
// variant can be sent, read back, and stopped inside twenty seconds, with no
// filament used: each experiment is "upload, start, read the record, stop".
//
// Bambu Studio's own command was captured off the printer's report topic:
//   url "ftp://<name>.gcode.3mf", file, md5, cfg "1", ams_mapping [-1,-1],
//   ams_mapping2 [{ams_id:255,slot_id:0}x2], auto_bed_leveling, extrude_cali_*,
//   nozzle_offset_cali — and NO manual_color_change / ext_change_assist.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { Writable } from 'node:stream';
import { Client as FtpClient } from 'basic-ftp';
import { loadConfig } from '../src/config.js';
import { generate } from '../src/gcode/engine.js';
import { build3mf } from '../src/integrations/bambu3mf.js';
import { uploadFile, buildPrintCommand, buildStopCommand, isConfigured } from '../src/integrations/bambu.js';

// The printer ignores a second MQTT client, so commands go through the booth.
const slot = () => printers.indexOf(printer) + 1;
async function publishCommand(_p, payload) {
  const r = await (await fetch(`http://localhost:3000/api/printers/${slot()}/command`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ payload }) })).json();
  if (!r.ok) console.log('   publish failed:', r.error);
  return r;
}

const argv = process.argv.slice(2);
const flag = (n, d = null) => { const i = argv.indexOf('--' + n); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };
const cfg = loadConfig();
const printers = cfg.integrations?.printers || [];
const printer = printers.find((p) => p.id === flag('printer')) || printers.find(isConfigured);
if (!printer) { console.error('no printer'); process.exit(2); }
const reference = flag('reference');
const only = flag('only');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ---- printer state, read from the booth server, which already holds the
// monitor connection and answers on localhost -------------------------------
async function boothState() {
  try {
    const j = await (await fetch('http://localhost:3000/api/jobs')).json();
    return j.printers.find((p) => p.id === printer.id)?.live?.state || null;
  } catch { return null; }
}
const state = await boothState();
console.log(`printer ${printer.id} is ${state || 'unknown (is the booth running?)'}`);
if (!['IDLE', 'FINISH', 'FAILED'].includes(String(state))) {
  console.error('Not idle — refusing to send anything while it is printing or paused.');
  process.exit(1);
}
const watch = { stop() {} };

// ---- files ---------------------------------------------------------------
const work = fs.mkdtempSync(path.join(os.tmpdir(), '3dipad-probe-change-'));
const design = {
  shape: 'rectangle', colours: { layer1: 'YELLOW', layer2: 'BLACK' }, hole: 'centre',
  design: [{ points: [{ x: 25, y: 15 }, { x: 60, y: 28 }, { x: 40, y: 32 }], width: 2.2 }],
};
const built = generate(design, cfg);
function ours(name, extraParts = []) {
  const p = path.join(work, name + '.3mf');
  fs.writeFileSync(p, build3mf({ gcode: built.gcode, meta: built.meta, cfg, name, extraParts }));
  return p;
}
const md5 = (p) => crypto.createHash('md5').update(fs.readFileSync(p)).digest('hex').toUpperCase();

// ---- commands --------------------------------------------------------------
const oursCmd = (name) => buildPrintCommand(`/sdcard/cache/${name}.3mf`, { variant: 'project_file', gcodePath: 'Metadata/plate_1.gcode', sequenceId: 9000 + Math.floor(Math.random() * 999) });
const studioCmd = (name, file) => ({ print: {
  ams_mapping: [-1, -1],
  ams_mapping2: [{ ams_id: 255, slot_id: 0 }, { ams_id: 255, slot_id: 0 }],
  auto_bed_leveling: 1, bed_leveling: false, bed_type: 'textured_plate', cfg: '1',
  command: 'project_file', extrude_cali_flag: 1, extrude_cali_manual_mode: 0,
  file: `${name}.gcode.3mf`, flow_cali: false, layer_inspect: false, md5: md5(file), nozzle_offset_cali: 2,
  param: 'Metadata/plate_1.gcode', profile_id: '0', project_id: '0', sequence_id: String(20000 + Math.floor(Math.random() * 999)),
  subtask_id: '0', subtask_name: name, task_id: '0', timelapse: false, url: `ftp://${name}.gcode.3mf`, use_ams: false, vibration_cali: false,
} });

// ---- one experiment --------------------------------------------------------
async function readRecord(name) {
  const c = new FtpClient(20000);
  try {
    await c.access({ host: printer.ip, port: 990, user: 'bblp', password: printer.accessCode, secure: 'implicit', secureOptions: { rejectUnauthorized: false } });
    let buf = '';
    await c.downloadTo(new Writable({ write(ch, _e, cb) { buf += ch; cb(); } }), `/cache/1_${name}.bbl`);
    return JSON.parse(buf);
  } catch (e) { return { error: e.message }; } finally { c.close(); }
}
async function run(label, file, cmd) {
  const name = path.basename(file, '.3mf');
  console.log(`\n== ${label}  (${name})`);
  // upload under the plain name; Studio's ftp://X.gcode.3mf resolves to /cache/X.3mf on this printer
  await uploadFile(printer, file, cfg);
  await publishCommand(printer, cmd, cfg);
  await sleep(Number(flag('wait', '7000')));
  const rec = await readRecord(name);
  await publishCommand(printer, buildStopCommand(), cfg);
  console.log('   manual_color_change:', rec.manual_color_change, '| use ams:', rec['use ams'], '| file_size:', rec.file_size, rec.error ? '| ' + rec.error : '');
  await sleep(8000);
  return rec.manual_color_change;
}

const experiments = [];
if (reference) experiments.push(['A: Studio 3mf + OUR command', () => { const p = path.join(work, 'PROBEA.3mf'); fs.copyFileSync(reference, p); return [p, oursCmd('PROBEA')]; }]);
experiments.push(['B: our 3mf + STUDIO command', () => { const p = ours('PROBEB'); return [p, studioCmd('PROBEB', p)]; }]);
// Sub-bisect of the command: our 3mf, our command plus one group of Studio's fields.
const withExtra = (name, extra) => { const p = ours(name); const c = oursCmd(name); Object.assign(c.print, typeof extra === 'function' ? extra(p) : extra); return [p, c]; };
experiments.push(['D: ours + Studio url form (ftp://X.gcode.3mf + file)', () => withExtra('PROBED', { url: 'ftp://PROBED.gcode.3mf', file: 'PROBED.gcode.3mf' })]);
experiments.push(['E: ours + cfg/md5', () => withExtra('PROBEE', (p) => ({ cfg: '1', md5: md5(p) }))]);
experiments.push(['E1: ours + cfg only', () => withExtra('PROBEE1', { cfg: '1' })]);
experiments.push(['E2: ours + md5 only', () => withExtra('PROBEE2', (p) => ({ md5: md5(p) }))]);
experiments.push(['F: ours + cali flags', () => withExtra('PROBEF', { auto_bed_leveling: 1, extrude_cali_flag: 1, extrude_cali_manual_mode: 0, nozzle_offset_cali: 2 })]);
experiments.push(['C: our 3mf + our command (control)', () => { const p = ours('PROBEC'); return [p, oursCmd('PROBEC')]; }]);

for (const [label, make] of experiments) {
  if (only && !label.startsWith(only)) continue;
  const [file, cmd] = make();
  await run(label, file, cmd);
}
watch.stop();
process.exit(0);
