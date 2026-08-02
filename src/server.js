// 3DiPad booth server: serves the kiosk PWA to the tablets, turns each drawing
// into A1 mini g-code, records the lead, queues the job, and (optionally)
// dispatches to a printer + Drive + WhatsApp.

import express from 'express';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadConfig, syncedFolderWarning } from './config.js';
import { generate } from './gcode/engine.js';
import { Queue } from './dispatch/queue.js';
import { saveLead } from './leads.js';
import * as notify from './integrations/notify.js';
import * as outbox from './integrations/outbox.js';
import { uploadGcode } from './integrations/drive.js';
import { startMonitor } from './dispatch/monitor.js';
import { createDispatcher } from './dispatch/dispatcher.js';
import { publicPrinters, savePrinter, checkPrinter } from './printers.js';
import { lastCommandSent, clearIfStuck, needsClearing } from './integrations/bambu.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// A hand-edited config.json that will not parse is an operator problem, not a
// programmer one. Print what it says and stop, rather than a stack trace whose
// last useful line is buried above six frames of module loader.
let cfg;
try {
  cfg = loadConfig();
} catch (e) {
  if (!e.friendly) throw e;
  console.error('');
  console.error(e.message);
  console.error('');
  process.exit(1);
}
const queue = new Queue(root);
outbox.init(root);
const app = express();
app.use(express.json({ limit: '4mb' }));

// Configurable so the day's files can land in a synced/backup folder while the
// app itself runs from local disk — see output.dir / output.leadsDir.
const outDir = cfg.output.dirResolved;
const leadsDir = cfg.output.leadsResolved;
for (const dir of [outDir, leadsDir]) {
  try {
    fs.mkdirSync(dir, { recursive: true });
    fs.accessSync(dir, fs.constants.W_OK);
  } catch (e) {
    console.error(`Cannot write to ${dir}`);
    console.error(`  ${e.message}`);
    console.error('  Set output.dir / output.leadsDir in config.json to a folder you can write to.');
    process.exit(1);
  }
}

// ---- static ----
app.use(express.static(path.join(root, 'public')));
app.use('/dashboard', express.static(path.join(root, 'dashboard')));
app.use('/output', express.static(outDir));
app.use('/leads', express.static(leadsDir));

// ---- kiosk API ----
app.get('/api/config', (_req, res) => {
  res.json({ palette: cfg.palette, build: cfg.build, limits: cfg.limits });
});

app.post('/api/estimate', (req, res) => {
  try {
    const design = sanitizeDesign(req.body);
    const { meta } = generate(design, cfg);
    res.json({ ok: true, meta });
  } catch (e) {
    res.status(400).json({ ok: false, error: String(e.message || e) });
  }
});

app.post('/api/submit', async (req, res) => {
  let design, contact;
  try {
    design = sanitizeDesign(req.body);
    contact = sanitizeContact(req.body.contact);
  } catch (e) {
    return res.status(400).json({ ok: false, error: String(e.message || e) });
  }

  const { gcode, meta } = generate(design, cfg);
  if (meta.overBudget) {
    return res.status(422).json({ ok: false, error: 'Design exceeds the print-time limit — simplify it.', meta });
  }
  if (!meta.strokeCount) {
    return res.status(422).json({ ok: false, error: 'Nothing to print — draw a design first.', meta });
  }

  const seq = queue.nextSeq();
  const filename = cfg.output.filenamePattern
    .replaceAll('{c1}', design.colours.layer1)
    .replaceAll('{c2}', design.colours.layer2)
    .replaceAll('{seq}', String(seq).padStart(4, '0'));
  const filePath = path.join(outDir, filename);
  fs.writeFileSync(filePath, gcode);

  const job = queue.add({
    id: 'j' + seq,
    seq,
    createdAt: new Date().toISOString(),
    contact,
    colours: design.colours,
    shape: design.shape,
    hole: meta.hole,
    filename,
    meta,
    printerId: null,
    notify: null,
  });

  try { saveLead(leadsDir, job, design, cfg); } catch (e) { console.error('lead save failed', e); }

  // push the lead to the CRM the moment they submit (captures them even if they
  // never collect the print). Best-effort + retried by the outbox.
  notify.onLead(cfg, job).then((r) => queue.setStatus(job.id, job.status, { leadPush: r })).catch(() => {});

  // best-effort Drive upload (never blocks the kid)
  uploadGcode(cfg, filePath).then((r) => { if (r.ok) queue.setStatus(job.id, job.status, { driveLink: r.link }); }).catch(() => {});

  // Reserve a printer now, upload after responding. The FTPS transfer takes a
  // couple of seconds and there is a queue of kids behind this one — the tablet
  // should not sit on "Make it" waiting for a file to cross the network.
  const free = dispatcher.submit(job);
  const queuedAhead = queue.jobs.filter((j) => j.status === 'queued').length;

  res.json({
    ok: true, jobId: job.id, filename, meta,
    printer: free ? free.name : null,
    queuedAhead: free ? 0 : queuedAhead,
  });
});

// ---- operator / dashboard API ----
app.get('/api/jobs', (_req, res) => {
  res.json({
    jobs: queue.active().map(publicJob),
    printers: (cfg.integrations?.printers || []).map((p) => ({
      id: p.id, name: p.name, configured: !!(p.ip && p.serial && p.accessCode),
      live: monitor.states()[p.id] || null,
    })),
    stats: queue.stats(),
    integrations: {
      drive: !!cfg.integrations?.drive?.enabled,
      notify: cfg.integrations?.notify?.provider || 'none',
      lan: !!cfg.integrations?.lan?.enabled,
      outbox: outbox.stats(),
    },
  });
});

// Everything ever submitted, so an old design can be printed again — the file
// is still on disk. Kept off /api/jobs because the operator view polls every
// couple of seconds and does not want the whole day's history each time.
app.get('/api/history', (req, res) => {
  const limit = Math.min(500, Math.max(1, Number(req.query.limit) || 200));
  const jobs = queue.history(limit).map(publicJob);
  res.json({
    jobs,
    total: queue.jobs.length,
    printers: (cfg.integrations?.printers || []).map((p) => ({
      id: p.id, name: p.name, configured: !!(p.ip && p.serial && p.accessCode),
      live: monitor.states()[p.id] || null,
    })),
  });
});

/**
 * Run an old job again. Makes a new job pointing at the same g-code file and
 * puts it in the queue, so it can be placed on a printer from the normal board
 * even when every machine is busy right now.
 */
app.post('/api/jobs/:id/reprint', (req, res) => {
  const job = queue.reprint(req.params.id);
  if (!job) return res.status(404).json({ ok: false, error: 'no such job' });
  if (!fs.existsSync(path.join(outDir, job.filename))) {
    queue.setStatus(job.id, 'failed', { dispatch: { ok: false, error: 'g-code file is gone' } });
    return res.status(410).json({ ok: false, error: `${job.filename} is no longer in the output folder` });
  }
  console.log(`[reprint] ${job.filename} queued again as #${String(job.seq).padStart(4, '0')}`);
  dispatcher.pump();
  res.json({ ok: true, job: publicJob(job) });
});

app.post('/api/jobs/:id/status', async (req, res) => {
  const { status, printerId } = req.body || {};
  const job = queue.setStatus(req.params.id, status, printerId ? { printerId } : {});
  if (!job) return res.status(404).json({ ok: false, error: 'no such job' });

  // an operator moving a job off a printer frees it for the next kid
  if (['ready', 'collected', 'failed', 'queued'].includes(status)) dispatcher.pump();

  // reaching "ready" fires the pickup notification via the configured provider
  if (status === 'ready') {
    const r = await notify.onReady(cfg, job);
    queue.setStatus(job.id, 'ready', { notify: r });
    return res.json({ ok: true, job: publicJob(job), notify: r });
  }
  res.json({ ok: true, job: publicJob(job) });
});

// Send a job to a printer by hand — for a job whose upload failed, or one the
// operator wants on a particular machine. Without this the only path to a
// printer was the instant of submission.
app.post('/api/jobs/:id/dispatch', async (req, res) => {
  const job = queue.get(req.params.id);
  if (!job) return res.status(404).json({ ok: false, error: 'no such job' });

  const wanted = String(req.body?.printerId || '');
  const printers = cfg.integrations?.printers || [];
  const printer = wanted
    ? printers.find((p) => p.id === wanted)
    : queue.freePrinter(printers);
  if (!printer) return res.status(409).json({ ok: false, error: wanted ? 'no such printer' : 'every printer is busy' });

  // an operator asking for it explicitly clears the give-up counter
  queue.setStatus(job.id, 'assigned', { printerId: printer.id, dispatchAttempts: 0 });
  const r = await dispatcher.send(job, printer);
  res.json({ ok: !!(r.sent || r.manual), printer: printer.name, result: r, job: publicJob(queue.get(job.id)) });
});

// ---- printer setup ----
//
// Configuring a printer used to mean a terminal, four positional arguments and a
// second command to check it worked. None of that belongs on a fair floor, so
// the dashboard does it. Access codes go in and never come back out.

app.get('/api/printers', (_req, res) => {
  const live = monitor.states();
  res.json({
    lan: !!cfg.integrations?.lan?.enabled,
    printers: publicPrinters(cfg).map((p) => ({ ...p, live: live[p.id] || null })),
  });
});

app.post('/api/printers/:slot', (req, res) => {
  try {
    const saved = savePrinter(cfg, {
      slot: req.params.slot,
      ip: String(req.body?.ip ?? '').trim(),
      serial: String(req.body?.serial ?? '').trim(),
      accessCode: String(req.body?.accessCode ?? '').trim(),
      name: String(req.body?.name ?? '').trim() || undefined,
    });
    // the monitor holds one MQTT connection per printer, opened at boot with the
    // old details — reopen them or the new printer is saved but unwatched
    restartMonitor();
    dispatcher.pump();
    res.json({ ok: true, printer: publicPrinters(cfg).find((p) => p.id === saved.id) });
  } catch (e) {
    res.status(400).json({ ok: false, error: String(e.message || e) });
  }
});

app.post('/api/printers/:slot/test', async (req, res) => {
  const list = cfg.integrations?.printers || [];
  const printer = list[Number(req.params.slot) - 1];
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer slot' });
  const result = await checkPrinter(printer, monitor.states()[printer.id], monitor.health()[printer.id], cfg);
  res.json({ ok: result.ok, findings: result.findings });
});

app.post('/api/jobs/:id/notify', async (req, res) => {
  const job = queue.get(req.params.id);
  if (!job) return res.status(404).json({ ok: false, error: 'no such job' });
  const r = await notify.onReady(cfg, job);
  queue.setStatus(job.id, job.status, { notify: r });
  res.json({ ok: r.ok, notify: r });
});

function publicJob(j) {
  return {
    id: j.id, seq: j.seq, name: j.contact.name, phone: j.contact.phone,
    colours: j.colours, shape: j.shape, hole: j.hole, filename: j.filename, status: j.status,
    reprintOf: j.reprintOf || null, failure: j.failure || null,
    est: j.meta?.estMinutes, printerId: j.printerId, createdAt: j.createdAt,
    driveLink: j.driveLink || null, notify: j.notify || null, leadPush: j.leadPush || null,
    previewUrl: '/leads/' + j.filename.replace(/\.gcode$/, '') + '.svg',
    gcodeUrl: '/output/' + j.filename,
  };
}

// ---- input sanitising ----
function sanitizeContact(c) {
  const name = String(c?.name ?? '').trim().slice(0, 40);
  const phone = String(c?.phone ?? '').trim().slice(0, 24);
  if (!name) throw new Error('name required');
  const digits = phone.replace(/\D/g, '');
  if (digits.length < 7) throw new Error('valid phone required');
  // the kiosk sends the country prefix split out; keep it if present
  const phoneE164 = String(c?.phoneE164 ?? '').trim().slice(0, 24) || '+' + digits;
  const country = String(c?.country ?? '').trim().slice(0, 40);
  return { name, phone, phoneE164, country };
}

const SHAPES = ['rectangle', 'square', 'circle', 'heart', 'custom'];

function sanitizeDesign(body) {
  const b = cfg.build;
  const shape = SHAPES.includes(body?.shape) ? body.shape : 'rectangle';
  const colours = {
    layer1: pickColour(body?.colours?.layer1),
    layer2: pickColour(body?.colours?.layer2),
  };
  // the drawing area is bounded by the largest shape we allow
  const lim = Math.max(b.customMax[0], b.customMax[1], ...Object.values(b.shapeSizes).flat());
  const design = cleanStrokes(body?.design, lim);
  const customOutline = shape === 'custom' ? cleanPoints(body?.customOutline, b.customMax[0], b.customMax[1]) : null;
  const holePos = ['left', 'right', 'top'].includes(body?.holePos) ? body.holePos : null;
  const hole = body?.hole && Number.isFinite(+body.hole.x) && Number.isFinite(+body.hole.y)
    ? { x: clamp(+body.hole.x, 0, lim), y: clamp(+body.hole.y, 0, lim) }
    : null;
  return { shape, colours, design, customOutline, hole, holePos: holePos || 'top' };
}

function pickColour(name) {
  const up = String(name ?? '').toUpperCase();
  if (!cfg.palette.includes(up)) throw new Error('invalid colour: ' + name);
  return up;
}

function cleanPoints(pts, maxX, maxY, maxN = 4000) {
  if (!Array.isArray(pts)) return null;
  const out = [];
  for (const p of pts.slice(0, maxN)) {
    const x = clamp(+p?.x, 0, maxX), y = clamp(+p?.y, 0, maxY);
    if (Number.isFinite(x) && Number.isFinite(y)) out.push({ x, y });
  }
  return out.length >= 3 ? out : null;
}

// Strokes arrive as { w, pts:[{x,y}] }; legacy flat arrays are accepted too.
function cleanStrokes(strokes, lim, maxStrokes = 400, maxPts = 4000) {
  if (!Array.isArray(strokes)) return [];
  const [pLo, pHi] = cfg.build.penRange;
  const out = [];
  for (const s of strokes.slice(0, maxStrokes)) {
    const pts = Array.isArray(s?.pts) ? s.pts : Array.isArray(s) ? s : null;
    if (!pts) continue;
    const w = clamp(+(s?.w ?? cfg.build.beadWidth), pLo, pHi);
    const line = [];
    for (const p of pts.slice(0, maxPts)) {
      const x = clamp(+p?.x, 0, lim), y = clamp(+p?.y, 0, lim);
      if (Number.isFinite(x) && Number.isFinite(y)) line.push({ x, y });
    }
    if (line.length) out.push({ w: Number.isFinite(w) ? w : cfg.build.beadWidth, pts: line });
  }
  return out;
}
const clamp = (v, lo, hi) => (Number.isFinite(v) ? Math.max(lo, Math.min(hi, v)) : NaN);

/**
 * Did the printer actually start? The MQTT command is fire-and-forget — the
 * printer sends no acknowledgement — so the only honest confirmation is its own
 * reported state turning over from idle. Resolves false if it never does, which
 * leaves the job assigned and the file on the SD card for a manual start.
 */
function confirmStart(printer) {
  const waitMs = cfg.integrations?.lan?.startConfirmMs ?? 25000;
  const deadline = Date.now() + waitMs;
  const busy = (s) => s && (['RUNNING', 'PREPARE', 'PAUSE', 'SLICING'].includes(s.state) || (s.percent ?? 0) > 0);
  return new Promise((resolve) => {
    const poll = () => {
      if (busy(monitor.states()[printer.id])) return resolve(true);
      if (Date.now() >= deadline) return resolve(false);
      setTimeout(poll, 1000).unref?.();
    };
    poll();
  });
}

/**
 * Short version of confirmStart, used to find out which start command this
 * firmware actually obeys. A printer that accepted the command leaves idle
 * within a few seconds — it starts heating before it does anything else — so
 * this does not need the full start timeout.
 */
function probeStart(printer) {
  // No status from this printer means we cannot tell whether the command
  // landed. Say so rather than guessing — startPrint stops instead of firing
  // another start at a machine that might already be printing.
  const seen = () => monitor.states()[printer.id];
  if (!seen()?.state) return Promise.resolve(null);

  const waitMs = cfg.integrations?.lan?.startProbeMs ?? 12000;
  const deadline = Date.now() + waitMs;
  const moved = (s) => s && (['RUNNING', 'PREPARE', 'PAUSE', 'SLICING'].includes(s.state) || (s.percent ?? 0) > 0);
  return new Promise((resolve) => {
    const poll = () => {
      const s = seen();
      if (moved(s)) return resolve(true);
      // it went quiet mid-probe: back to "cannot tell"
      if (!s?.state) return resolve(null);
      if (Date.now() >= deadline) return resolve(false);
      setTimeout(poll, 500).unref?.();
    };
    poll();
  });
}

/**
 * Hand the printer back to itself before giving it something new.
 *
 * gcode_state stays FAILED after a print dies — the machine goes on naming the
 * job that failed and refuses everything else. FINISH behaves the same way
 * until the plate is taken. Both are cleared with the same command the
 * printer's own screen sends.
 */
function clearBeforeSend(printer) {
  return clearIfStuck(printer, cfg, () => monitor.states()[printer.id]);
}

const dispatcher = createDispatcher({
  cfg, queue, outDir, confirmStart, probeStart, beforeSend: clearBeforeSend,
  onEvent: (e) => {
    if (e.type === 'cleared') {
      console.log(e.ok
        ? `[${e.printer.id}] was holding a finished/failed job — cleared it first`
        : `[${e.printer.id}] is stuck in ${e.state} and would not clear. Dismiss the last print on its screen.`);
    }
    else if (e.type === 'variant') {
      // Only say a command worked when the printer was actually seen to move.
      // This used to print "start command that worked" for the only command we
      // tried, on a printer that never started — a log line asserting the exact
      // opposite of what happened, directly above the line reporting it.
      const pinned = cfg.integrations?.lan?.startCommand;
      if (e.confirmed && (!pinned || pinned === 'auto') && e.variant !== 'gcode_file') {
        console.log(`[${e.printer.id}] start command that worked: "${e.variant}"`);
        console.log(`           Pin it to skip the probing: integrations.lan.startCommand = "${e.variant}"`);
      }
    }
    else if (e.type === 'sent') console.log(`[${e.printer.id}] started ${e.job.filename} for ${e.job.contact?.name}`);
    else if (e.type === 'failed') console.error(`[${e.printer.id}] send failed at ${e.stage}: ${e.error} — ${e.job.filename} back in the queue`);
    else if (e.type === 'manual') console.log(`[${e.printer.id}] ${e.job.filename} needs a manual load (${e.reason})`);
    else if (e.type === 'notstarted') {
      console.error(`[${e.printer.id}] ${e.job.filename} is on the SD card but the printer did not start it.`);
      // The start command and the status stream travel the same MQTT topics, so
      // if nothing is arriving, nothing is being delivered either — and the
      // usual reason is a serial number that does not match the printer.
      const h = monitor.health()[e.printer.id] || {};
      if (h.lastCommand) {
        const c = h.lastCommand;
        console.error(`           It answered "${c.command}" with ${c.result || '?'}${c.reason ? ` — ${c.reason}` : ''}.`);
      }
      // Both sides of the exchange, printed without anyone having to switch a
      // debug flag on and reproduce it. This is the failure we cannot reproduce
      // here — the evidence has to survive the one time it happens at a booth.
      const sent = lastCommandSent(e.printer);
      if (sent) {
        console.error(`           We sent, to ${sent.topic}:`);
        console.error(`             ${JSON.stringify(sent.payload)}`);
      }
      if (h.recent?.length) {
        console.error('           The printer said, around that moment:');
        for (const r of h.recent.slice(-5)) console.error(`             ${r.text}`);
      } else if (h.messages) {
        console.error('           The printer sent status the whole time and never mentioned the command.');
      }
      if (h.connected && !h.messages) {
        console.error(`           The printer has never sent anything on device/${e.printer.serial}/report.`);
        console.error('           That serial number is probably wrong — check Settings > Device on the printer');
        console.error('           and correct it on the setup page. Commands go to the same topic, which is');
        console.error('           why the file uploads but nothing starts.');
      } else if (!h.connected) {
        console.error('           The control connection is down — check the setup page for this printer.');
      } else {
        console.error('           Start it from the printer screen, or press Send on the dashboard.');
      }
    }
  },
});

// Watch the printers so prints advance (and notify) with no operator tap.
// A printer leaving its job — finished or failed — is the moment the next
// queued kid can go on, so every transition gives the dispatcher a nudge.
let monitor = startMonitor(cfg, queue, onPrintReady, () => dispatcher.pump());

async function onPrintReady(job) {
  const r = await notify.onReady(cfg, job);
  queue.setStatus(job.id, 'ready', { notify: r });
}

/** Reopen the printer connections after the setup page changes them. */
function restartMonitor() {
  try { monitor.stop(); } catch (e) { console.error('monitor stop failed', e); }
  monitor = startMonitor(cfg, queue, onPrintReady, () => dispatcher.pump());
}

/**
 * This machine's addresses on the booth Wi-Fi, so the tablet URL is printed at
 * startup instead of being looked up with ipconfig at the fair. Router DHCP can
 * hand out a different address after a reboot, so it is worth re-reading each
 * time the server starts.
 */
function lanAddresses() {
  const out = [];
  for (const [name, addrs] of Object.entries(os.networkInterfaces())) {
    for (const a of addrs || []) {
      if (a.family !== 'IPv4' && a.family !== 4) continue;
      if (a.internal) continue;
      out.push({ name, address: a.address });
    }
  }
  // Prefer ordinary private ranges — a VPN or virtual adapter address is no use to an iPad.
  const priority = (ip) => (/^192\.168\./.test(ip) ? 0 : /^10\./.test(ip) ? 1 : /^172\.(1[6-9]|2\d|3[01])\./.test(ip) ? 2 : 3);
  return out.sort((a, b) => priority(a.address) - priority(b.address));
}

const port = process.env.PORT || 3000;
const server = app.listen(port, () => {
  console.log(`3DiPad booth server on http://localhost:${port}`);
  const nics = lanAddresses();
  if (nics.length) {
    console.log('');
    console.log('  ON THE IPADS, OPEN:');
    for (const n of nics) console.log(`     http://${n.address}:${port}      (${n.name})`);
    console.log('');
  } else {
    console.log('  no Wi-Fi address found — the tablets cannot reach this laptop until it joins the booth network');
  }
  console.log(`  kiosk:     http://localhost:${port}/`);
  console.log(`  dashboard: http://localhost:${port}/dashboard/`);
  console.log(`  config:    ${cfg._configPath}`);
  if (outDir !== path.join(root, 'output')) console.log(`  gcode:     ${outDir}`);
  if (leadsDir !== path.join(root, 'leads')) console.log(`  leads:     ${leadsDir}`);
  if (cfg._defaulted?.length) {
    console.log(`             (${cfg._defaulted.length} newer settings not in your config.json — using shipped defaults: ${cfg._defaulted.slice(0, 6).join(', ')}${cfg._defaulted.length > 6 ? ', …' : ''})`);
  }
  const lan = cfg.integrations?.lan?.enabled;
  const ready = (cfg.integrations?.printers || []).filter((p) => p.ip && p.serial && p.accessCode).length;
  console.log(`  printers:  LAN ${lan ? 'ON' : 'off'}, ${ready} configured`);

  const synced = syncedFolderWarning();
  if (synced) {
    console.log('');
    console.log('  ⚠ ' + synced);
  }
});

/**
 * Starting the booth twice is the easiest mistake to make — close the window
 * without stopping the server, double-click the launcher again, and Node dumps
 * a twenty-line stack trace whose actual meaning is "it is already running".
 * At the fair that reads as a broken booth. Say the true thing instead.
 */
server.on('error', (err) => {
  if (err.code !== 'EADDRINUSE') throw err;
  console.error('');
  console.error(`  The booth server is already running on port ${port}.`);
  console.error('');
  console.error('  If that is the one you want, just open it:');
  console.error(`     http://localhost:${port}/dashboard/`);
  console.error('');
  console.error('  If it is a leftover from earlier and you want a fresh one, stop it first:');
  console.error(process.platform === 'win32'
    ? `     Get-NetTCPConnection -LocalPort ${port} | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }`
    : `     kill $(lsof -ti tcp:${port})`);
  console.error('');
  console.error(`  Or run this one somewhere else:   PORT=3001 npm start`);
  console.error('');
  process.exit(1);
});

for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => { monitor.stop(); server.close(() => process.exit(0)); });
}
