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
import { startDiscovery } from './discovery.js';
import { lastCommandSent, clearIfStuck, needsClearing, publishCommand, buildStopCommand, buildLightCommand } from './integrations/bambu.js';

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

/**
 * The PIN behind the send-to-printer panel.
 *
 * This is a lock on a booth, not on a bank. It stops the child who watched an
 * adult hold the corner button and wants to try it themselves, and it stops an
 * idle tap during the ten seconds nobody is watching the iPad. It does not stop
 * anyone who can reach the booth Wi-Fi and POST to the API directly, and it is
 * not meant to — the printers are two feet away and have their own screens.
 */
/** Is this an operator saying yes? A PIN match, or any override at all when no PIN is set. */
function operatorApproves(override) {
  if (!override) return false;
  const pin = operatorPin();
  return pin ? String(override.pin || '') === pin : true;
}

function operatorPin() {
  return String(process.env.BOOTH_ADMIN_PIN || cfg.operator?.pin || '').trim();
}

// Wrong guesses, by address. Four digits is 10,000 tries, which is nothing for
// a script and a very long afternoon for a seven-year-old — so the delay grows
// and then the door shuts, which is enough for the second case and honest about
// the first.
const pinTries = new Map();
app.post('/api/admin/unlock', async (req, res) => {
  const pin = operatorPin();
  const lockMinutes = cfg.operator?.lockMinutes ?? 10;
  const given = String(req.body?.pin ?? '');

  // No PIN configured: the hold is the whole lock, and the panel opens.
  if (!pin) return res.json({ ok: true, pinRequired: false, lockMinutes });

  // An empty body is the kiosk asking "do you want a PIN?", not a guess at one.
  // Counting it as a wrong try would lock the operator out of their own booth
  // simply for opening the panel five times.
  if (!given) return res.json({ ok: false, pinRequired: true, lockMinutes });

  const who = req.ip || 'unknown';
  const rec = pinTries.get(who) || { wrong: 0, until: 0 };
  if (Date.now() < rec.until) {
    return res.status(429).json({ ok: false, pinRequired: true, error: 'Too many wrong tries', retryInSec: Math.ceil((rec.until - Date.now()) / 1000) });
  }
  // The same pause on every guess, right or wrong, so the answer cannot be
  // timed and a rapid-fire guesser gets nowhere.
  await new Promise((r) => setTimeout(r, 350));

  if (given === pin) {
    pinTries.delete(who);
    return res.json({ ok: true, pinRequired: true, lockMinutes });
  }
  rec.wrong += 1;
  if (rec.wrong >= 5) { rec.until = Date.now() + 60000; rec.wrong = 0; }
  pinTries.set(who, rec);
  // Say so on the guess that shuts the door, not on the next one. An operator
  // who mistypes their way into a lockout should find out then, rather than
  // getting an unexplained "wait 60s" the next time they reach for the panel.
  if (rec.until > Date.now()) {
    return res.status(429).json({ ok: false, pinRequired: true, error: 'Too many wrong tries', retryInSec: Math.ceil((rec.until - Date.now()) / 1000) });
  }
  res.status(401).json({ ok: false, pinRequired: true, error: 'Wrong PIN' });
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
  // Over the time budget: refused, unless an operator approves it from the
  // tablet. The approval is the operator PIN (the same one that opens the
  // send panel), sent along with the design; with no PIN configured, the hold
  // gesture alone is the approval, as it is for the panel.
  const approved = meta.overBudget && operatorApproves(req.body.override);
  if (meta.overBudget && !approved) {
    return res.status(422).json({ ok: false, error: 'Design exceeds the print-time limit — simplify it, or an operator can approve it.', meta });
  }
  if (approved) meta.approvedByOperator = true;
  if (!meta.hasDesign) {
    return res.status(422).json({ ok: false, error: 'Nothing to print — draw or upload a design first.', meta });
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

  if (meta.approvedByOperator) console.log(`[queue] ${filename} is over the ${cfg.limits.maxPrintMinutes}-min budget (~${meta.estMinutes} min) — approved by the operator`);
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
      levelNext: dispatcher.levelNext(p.id),
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
      levelNext: dispatcher.levelNext(p.id),
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

/**
 * Stop whatever a printer is doing, now.
 *
 * There was no way to do this without a terminal, which is the wrong answer at
 * a booth: a print going wrong in front of a queue of parents is exactly when
 * nobody should be looking up a command. The printer is left in FAILED, which
 * the monitor turns into a failed job, and the card then offers Print again.
 */
app.post('/api/printers/:id/stop', async (req, res) => {
  const printer = (cfg.integrations?.printers || []).find((p) => p.id === req.params.id);
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer' });

  const r = await publishCommand(printer, buildStopCommand(), cfg);
  if (!r.ok) return res.status(502).json({ ok: false, error: `could not reach ${printer.name}: ${r.error}` });

  const job = queue.active().find((j) => j.printerId === printer.id && ['assigned', 'printing', 'colour_change'].includes(j.status));
  if (job) queue.setStatus(job.id, 'failed', { failure: 'stopped from the dashboard' });
  console.log(`[${printer.id}] STOPPED from the dashboard${job ? ` — ${job.filename}` : ''}`);
  res.json({ ok: true, stopped: job ? job.filename : null });
});

/**
 * "I have cleared the bed — this printer is ready."
 *
 * The printer will not say so itself. FAILED is where a Bambu stays after a
 * print dies: it takes `stop`, answers success, and goes on reporting FAILED
 * and naming the dead job until something else is printed. The board repeated
 * that faithfully, so a machine standing empty and willing showed up red, and
 * an operator who had already scraped the plate had no way to say so.
 *
 * We still send the stop — sometimes it does take — but the operator's word is
 * what the tile goes by afterwards.
 */
app.post('/api/printers/:id/reset', async (req, res) => {
  const printer = (cfg.integrations?.printers || []).find((p) => p.id === req.params.id);
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer' });

  const live = monitor.states()[printer.id];
  if (!live) return res.status(409).json({ ok: false, error: `no status from ${printer.name} — check it on the setup page` });

  // Never let a reset quietly kill a print that is genuinely under way.
  if (['RUNNING', 'PREPARE', 'SLICING'].includes(String(live.state || '').toUpperCase())) {
    return res.status(409).json({ ok: false, error: `${printer.name} is printing — use Stop first` });
  }

  const r = await publishCommand(printer, buildStopCommand(), cfg);
  const ack = monitor.acknowledge(printer.id);

  // A job still pinned to this printer is not coming back; release it so the
  // printer counts as free and the job can be sent again from History.
  const job = queue.active().find((j) => j.printerId === printer.id && ['assigned', 'printing', 'colour_change'].includes(j.status));
  if (job) queue.setStatus(job.id, 'failed', { failure: 'cleared by the operator' });

  console.log(`[${printer.id}] reset by the operator — was ${live.state}${job ? `, released ${job.filename}` : ''}${r.ok ? '' : ` (stop did not go out: ${r.error})`}`);
  dispatcher.pump();
  res.json({ ok: true, was: live.state, acknowledged: ack, released: job ? job.filename : null });
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
  const r = (await dispatcher.send(job, printer)) || { ok: false, sent: false, error: 'not sent' };
  res.json({ ok: !!(r.sent || r.manual), error: r.sent || r.manual ? undefined : r.error, printer: printer.name, result: r, job: publicJob(queue.get(job.id)) });
});

// ---- printer setup ----
//
// Configuring a printer used to mean a terminal, four positional arguments and a
// second command to check it worked. None of that belongs on a fair floor, so
// the dashboard does it. Access codes go in and never come back out.

app.get('/api/printers', (_req, res) => {
  const live = monitor.states();
  const seen = discovery.seen();
  const bySerial = Object.fromEntries(seen.map((d) => [d.serial, d]));
  const printers = publicPrinters(cfg).map((p) => ({ ...p, live: live[p.id] || null, seen: bySerial[String(p.serial || '').toUpperCase()] || null }));
  const claimed = new Set(printers.map((p) => String(p.serial || '').toUpperCase()));
  res.json({
    lan: !!cfg.integrations?.lan?.enabled,
    printers,
    // printers announcing themselves on this network that no slot names yet
    discovered: seen.filter((d) => !claimed.has(d.serial)),
  });
});

// Drop and reopen every printer connection. The fix for a printer that went
// quiet after changing networks was "press Save again" — this is that, named.
app.post('/api/printers/reconnect', (_req, res) => {
  restartMonitor();
  dispatcher.pump();
  console.log('[booth] printer connections reopened from the setup page');
  res.json({ ok: true });
});
// (before /:slot, or Express reads "reconnect" as a slot number)
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

// "Level the bed before the next print on this printer." One-shot, from the
// dashboard, no restart — the config's bedLevel is every print or none.
app.post('/api/printers/:id/level', (req, res) => {
  const printer = (cfg.integrations?.printers || []).find((p) => p.id === req.params.id);
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer' });
  const on = dispatcher.setLevelNext(printer.id, req.body?.on !== false);
  console.log(`[${printer.id}] bed level on the next print: ${on ? 'ON' : 'off'}`);
  res.json({ ok: true, levelNext: on });
});

// The last few things this printer said that were not routine status — command
// echoes and replies. A print command sent by ANY client (Bambu Studio included)
// comes back on the report topic with every field, so this is how another
// program's exact request can be read without a packet capture.
app.get('/api/printers/:slot/recent', (req, res) => {
  const list = cfg.integrations?.printers || [];
  const printer = list[Number(req.params.slot) - 1];
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer slot' });
  const h = monitor.health()[printer.id] || {};
  res.json({ ok: true, connected: !!h.connected, messages: h.messages || 0, recent: (h.recent || []).map((r) => ({ at: r.at, msg: r.msg })) });
});

// Publish an arbitrary command over the booth's own printer connection. For
// tools/probe-change.mjs: the printer ignores a second MQTT client, so a
// diagnostic that needs to be heard has to speak through this one. Localhost
// only — this is a raw pipe to the printer.
app.post('/api/printers/:slot/command', async (req, res) => {
  const ip = String(req.ip || '');
  if (!/^(::1|127\.0\.0\.1|::ffff:127\.0\.0\.1)$/.test(ip)) return res.status(403).json({ ok: false, error: 'localhost only' });
  const list = cfg.integrations?.printers || [];
  const printer = list[Number(req.params.slot) - 1];
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer slot' });
  const payload = req.body?.payload;
  if (!payload || typeof payload !== 'object') return res.status(400).json({ ok: false, error: 'payload required' });
  const r = await publishCommand(printer, payload, cfg);
  res.json({ ok: !!r.ok, error: r.error || null });
});

// Toggle the chamber light from the setup page. Test reports what the printer
// says; this is for seeing a command land with your own eyes, from the setup
// page, on a printer that is not printing anything.
app.post('/api/printers/:slot/light', async (req, res) => {
  const list = cfg.integrations?.printers || [];
  const printer = list[Number(req.params.slot) - 1];
  if (!printer) return res.status(404).json({ ok: false, error: 'no such printer slot' });
  const on = !!req.body?.on;
  const seq = String(Date.now() % 100000);
  const sent = await publishCommand(printer, buildLightCommand(on, seq), cfg);
  if (!sent.ok) return res.status(502).json({ ok: false, error: `could not reach ${printer.name}: ${sent.error}` });

  // The reply lands on the monitor's connection as health.lastCommand; wait a
  // moment for it, keyed on our sequence id so an older answer is not mistaken
  // for this one.
  let reply = null;
  const deadline = Date.now() + 4000;
  while (Date.now() < deadline && !reply) {
    const c = monitor.health()[printer.id]?.lastCommand;
    if (c && c.command === 'ledctrl' && c.sequenceId === seq) reply = c;
    else await new Promise((r) => setTimeout(r, 200));
  }
  const success = reply && String(reply.result || '').toUpperCase() === 'SUCCESS';
  res.json({
    ok: !!success, on, sent: true,
    reply: reply ? { result: reply.result, reason: reply.reason } : null,
  });
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
    reprintOf: j.reprintOf || null, failure: j.failure || null, dispatch: j.dispatch || null,
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
  const image = sanitizeImage(body?.image);
  const customOutline = shape === 'custom' ? cleanPoints(body?.customOutline, b.customMax[0], b.customMax[1]) : null;
  const holePos = ['left', 'right', 'top', 'none'].includes(body?.holePos) ? body.holePos : null;
  const hole = body?.hole && Number.isFinite(+body.hole.x) && Number.isFinite(+body.hole.y)
    ? { x: clamp(+body.hole.x, 0, lim), y: clamp(+body.hole.y, 0, lim) }
    : null;
  return { shape, colours, design, image, customOutline, hole, holePos: holePos || 'top' };
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
// An uploaded drawing arrives already decoded and thresholded by the browser:
// { w, h, data } where data is base64 bit-packed ink (see image.js). Cap the
// dimensions — a plate-resolution mask needs no more than about 850 cells on
// its long side, and the point of the cap is to refuse a payload that would
// blow the mask past what imageCoverage will raster.
function sanitizeImage(img) {
  if (!img || typeof img !== 'object') return null;
  const w = img.w | 0, h = img.h | 0;
  if (w < 1 || h < 1 || w > 2000 || h > 2000 || w * h > 3_000_000) return null;
  if (typeof img.data !== 'string' || !img.data.length) return null;
  // base64 of a bit-packed mask: about ceil(w*h/8) bytes, ~1.34x as base64.
  if (img.data.length > Math.ceil((w * h) / 8) * 2 + 8) return null;
  const out = { w, h, data: img.data };
  // the size slider, as a fraction of the contain-fit; anything odd means 1
  const scale = Number(img.scale);
  if (Number.isFinite(scale) && scale > 0 && scale <= 1) out.scale = scale;
  // dragged position, plate mm from centred; bounded so nothing silly is stored
  const ox = Number(img.offset?.x), oy = Number(img.offset?.y);
  if (Number.isFinite(ox) && Number.isFinite(oy) && Math.abs(ox) <= 300 && Math.abs(oy) <= 300) out.offset = { x: ox, y: oy };
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
    let asked = false;
    const poll = () => {
      if (busy(monitor.states()[printer.id])) return resolve(true);
      if (Date.now() >= deadline) return resolve(false);
      // Ask for the whole picture once, half way through — the same lesson
      // clearIfStuck already carries, and it applies here for the same reason.
      //
      // The printer reports in DELTAS, and a delta need not mention gcode_state
      // at all. Waiting passively for one to say RUNNING can outlast this
      // timeout while the print is running perfectly, and the booth then
      // announces "on the SD card but the printer did not start it" about a job
      // that is already laying its first layer. Whether that happens is pure
      // timing, which is why it can behave for days and then not.
      if (!asked && Date.now() > deadline - waitMs / 2) {
        asked = true;
        publishCommand(printer, { pushing: { sequence_id: '2', command: 'pushall' } }, cfg).catch(() => {});
      }
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
 *
 * PAUSE is cleared here too, and ONLY here. A paused printer holds the machine
 * exactly like a failed one: the next file uploads to the SD card, the print
 * command is accepted, and nothing ever starts. It is the state a booth ends up
 * in every time an operator abandons a colour change, which on a bad day is
 * several times an hour.
 *
 * It must never go in STUCK_STATES itself. A pause in the middle of a job is
 * the colour change doing its job, and anything that treats that as stuck would
 * stop a print with a child's keychain half finished. Here, on the way to
 * dispatching a NEW job, any pause belongs to a job we are already done with.
 */
function clearBeforeSend(printer) {
  // The operator has pressed "Bed cleared". The printer goes on reporting
  // FAILED until its next print regardless, so the dashboard shows READY on
  // their word — and this check was still refusing the send on the printer's.
  // Trust the operator here too; if the print then does not start,
  // confirmStart hands the job back and says so.
  const s0 = monitor.states()[printer.id];
  if (s0?.acknowledged) return { needed: false, acknowledged: true, state: s0.state };
  const read = () => {
    const s = monitor.states()[printer.id];
    if (!s || String(s.state || '').toUpperCase() !== 'PAUSE') return s;
    return { ...s, state: 'FAILED' };   // treat a leftover pause as stuck, here only
  };
  return clearIfStuck(printer, cfg, read);
}

const dispatcher = createDispatcher({
  cfg, queue, outDir, confirmStart, probeStart, beforeSend: clearBeforeSend,
  onEvent: (e) => {
    if (e.type === 'cleared') {
      // Not a failure to report loudly. FAILED may simply be the printer's
      // record of how the last job ended rather than a lock on the next one —
      // it accepts `stop` and answers "success" while staying there. The send
      // goes ahead either way; this line is a note, not an alarm.
      console.log(e.ok
        ? `[${e.printer.id}] was holding a finished/failed job — cleared it first`
        : `[${e.printer.id}] still reports ${e.state} after a stop it accepted — sending anyway`);
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
    else if (e.type === 'blocked') {
      // Said plainly, and naming the one action that works. Nothing the booth
      // can send moves a printer out of this — `stop` is accepted and ignored.
      console.error('');
      console.error(`[${e.printer.id}] NOT SENT — ${e.printer.name} is holding a ${e.state} job.`);
      console.error('           Clear it on the PRINTER\'S OWN SCREEN (dismiss the finished/failed');
      console.error('           job, and take the plate off), then press Send on the dashboard.');
      console.error(`           ${e.job.filename} stays assigned to it and will go as soon as it is clear.`);
      console.error('');
    }
    else if (e.type === 'levelled') {
      console.log(`[${e.printer.id}] ${e.job.filename} sent WITH a bed level, as asked. Next print will skip it again.`);
    }
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

/**
 * Follow a printer that moved. The serial is the identity; the address in
 * config.json is only where it was last time. When an announcement puts a
 * configured serial at a different address, take the new one and reopen the
 * connection — the access code is unchanged unless LAN Mode was toggled, and
 * if it was, the setup page's Test will say so.
 */
const discovery = startDiscovery((p) => {
  const list = cfg.integrations?.printers || [];
  const slot = list.findIndex((c) => String(c.serial || '').toUpperCase() === p.serial);
  if (slot < 0) return;
  const printer = list[slot];
  if (printer.ip === p.ip) return;
  const from = printer.ip || '(none)';
  try {
    savePrinter(cfg, { slot: slot + 1, ip: p.ip, serial: printer.serial, accessCode: '', name: printer.name });
    console.log(`[${printer.id}] is on this network at ${p.ip} (config said ${from}) — following it`);
    restartMonitor();
    dispatcher.pump();
  } catch (e) {
    console.error(`[${printer.id}] seen at ${p.ip} but could not update the config: ${e.message}`);
  }
});

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

  // Which colour change is actually in effect. config.json wins over the
  // shipped default, so changing the default does not necessarily change what
  // this booth does — and the difference between the two is the difference
  // between the printer cutting and unloading by itself and an operator working
  // the filament menu at every swap. Worth one line rather than a guess.
  if (cfg.colourChange?.gcode) {
    // The trap this line exists for. `gcode` replaces the whole block, so a
    // config carrying it ignores `mode` completely — and a booth that had been
    // set up with a bare "M400 U1" was emitting only that: no park, no retract,
    // no purge, whatever mode said. From outside a generated file the two are
    // indistinguishable, and telling someone to change `mode` in that state is
    // advice that cannot work.
    const lines = [].concat(cfg.colourChange.gcode);
    console.log(`  swap:      YOUR OWN GCODE, ${lines.length} line${lines.length === 1 ? '' : 's'} — colourChange.mode is ignored`);
    console.log(`             ${String(lines[0]).slice(0, 62)}`);
    console.log('             To use the printer\'s own cut-and-reload instead, DELETE the');
    console.log('             "gcode" key from colourChange in config.json and set mode = "bambu".');
  } else if (cfg.colourChange?.mode === 'bambu') {
    console.log('  swap:      the printer cuts and reloads by itself (colourChange.mode = "bambu")');
    console.log('             Undocumented Bambu commands. Watch the first one — if it stalls,');
    console.log('             set colourChange.mode back to "purge" in config.json.');
  } else {
    console.log(`  swap:      "${cfg.colourChange?.mode || 'purge'}" — the operator unloads and loads from the printer's menu`);
    console.log('             Set colourChange.mode = "bambu" in config.json to have the printer do it.');
  }

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

// A thrown error in an async route used to take the whole booth down: Node
// exits on an unhandled rejection, the launcher window closed with it, and the
// operator saw the iPads disconnect with no message anywhere. Log it, loudly,
// and keep serving — one bad request is not a reason to stop the fair.
for (const kind of ['unhandledRejection', 'uncaughtException']) {
  process.on(kind, (err) => {
    console.error('');
    console.error(`  !! ${kind} — the booth is still running, but this is a bug. Take a photo of this:`);
    console.error(err?.stack || err);
    console.error('');
  });
}

for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => { monitor.stop(); discovery.stop(); server.close(() => process.exit(0)); });
}
