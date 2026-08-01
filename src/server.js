// 3DiPad booth server: serves the kiosk PWA to the tablets, turns each drawing
// into A1 mini g-code, records the lead, queues the job, and (optionally)
// dispatches to a printer + Drive + WhatsApp.

import express from 'express';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadConfig } from './config.js';
import { generate } from './gcode/engine.js';
import { Queue } from './dispatch/queue.js';
import { saveLead } from './leads.js';
import * as notify from './integrations/notify.js';
import * as outbox from './integrations/outbox.js';
import { uploadGcode } from './integrations/drive.js';
import { startMonitor } from './dispatch/monitor.js';
import { createDispatcher } from './dispatch/dispatcher.js';
import { publicPrinters, savePrinter, checkPrinter } from './printers.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const cfg = loadConfig();
const queue = new Queue(root);
outbox.init(root);
const app = express();
app.use(express.json({ limit: '4mb' }));

const outDir = path.join(root, 'output');
fs.mkdirSync(outDir, { recursive: true });

// ---- static ----
app.use(express.static(path.join(root, 'public')));
app.use('/dashboard', express.static(path.join(root, 'dashboard')));
app.use('/output', express.static(outDir));
app.use('/leads', express.static(path.join(root, 'leads')));

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

  try { saveLead(root, job, design, cfg); } catch (e) { console.error('lead save failed', e); }

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
  const result = await checkPrinter(printer, monitor.states()[printer.id]);
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

const dispatcher = createDispatcher({
  cfg, queue, outDir, confirmStart,
  onEvent: (e) => {
    if (e.type === 'sent') console.log(`[${e.printer.id}] started ${e.job.filename} for ${e.job.contact?.name}`);
    else if (e.type === 'failed') console.error(`[${e.printer.id}] send failed at ${e.stage}: ${e.error} — ${e.job.filename} back in the queue`);
    else if (e.type === 'manual') console.log(`[${e.printer.id}] ${e.job.filename} needs a manual load (${e.reason})`);
    else if (e.type === 'notstarted') {
      console.error(`[${e.printer.id}] ${e.job.filename} is on the SD card but the printer did not start it.`);
      console.error('           Start it from the printer screen, or press Send on the dashboard.');
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
  if (cfg._defaulted?.length) {
    console.log(`             (${cfg._defaulted.length} newer settings not in your config.json — using shipped defaults: ${cfg._defaulted.slice(0, 6).join(', ')}${cfg._defaulted.length > 6 ? ', …' : ''})`);
  }
  const lan = cfg.integrations?.lan?.enabled;
  const ready = (cfg.integrations?.printers || []).filter((p) => p.ip && p.serial && p.accessCode).length;
  console.log(`  printers:  LAN ${lan ? 'ON' : 'off'}, ${ready} configured`);
});

for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => { monitor.stop(); server.close(() => process.exit(0)); });
}
