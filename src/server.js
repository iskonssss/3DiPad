// 3DiPad booth server: serves the kiosk PWA to the tablets, turns each drawing
// into A1 mini g-code, records the lead, queues the job, and (optionally)
// dispatches to a printer + Drive + WhatsApp.

import express from 'express';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadConfig } from './config.js';
import { generate } from './gcode/engine.js';
import { Queue } from './dispatch/queue.js';
import { saveLead } from './leads.js';
import * as notify from './integrations/notify.js';
import * as outbox from './integrations/outbox.js';
import { uploadGcode } from './integrations/drive.js';
import { sendToPrinter } from './integrations/bambu.js';

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
    hole: design.hole,
    filename,
    meta,
    printerId: null,
    notify: null,
  });

  try { saveLead(root, job, design); } catch (e) { console.error('lead save failed', e); }

  // push the lead to the CRM the moment they submit (captures them even if they
  // never collect the print). Best-effort + retried by the outbox.
  notify.onLead(cfg, job).then((r) => queue.setStatus(job.id, job.status, { leadPush: r })).catch(() => {});

  // best-effort Drive upload (never blocks the kid)
  uploadGcode(cfg, filePath).then((r) => { if (r.ok) queue.setStatus(job.id, job.status, { driveLink: r.link }); }).catch(() => {});

  // best-effort auto-dispatch to a free printer
  let printerName = null;
  const printers = cfg.integrations?.printers || [];
  const free = queue.freePrinter(printers);
  if (free) {
    const r = await sendToPrinter(free, filePath).catch((e) => ({ ok: false, error: String(e) }));
    if (r.sent) {
      queue.setStatus(job.id, 'printing', { printerId: free.id });
      printerName = free.name;
    } else if (r.manual) {
      queue.setStatus(job.id, 'assigned', { printerId: free.id });
      printerName = free.name;
    }
  }

  res.json({ ok: true, jobId: job.id, filename, meta, printer: printerName });
});

// ---- operator / dashboard API ----
app.get('/api/jobs', (_req, res) => {
  res.json({
    jobs: queue.active().map(publicJob),
    printers: (cfg.integrations?.printers || []).map((p) => ({ id: p.id, name: p.name, configured: !!p.ip })),
    stats: queue.stats(),
    integrations: {
      drive: !!cfg.integrations?.drive?.enabled,
      notify: cfg.integrations?.notify?.provider || 'none',
      outbox: outbox.stats(),
    },
  });
});

app.post('/api/jobs/:id/status', async (req, res) => {
  const { status, printerId } = req.body || {};
  const job = queue.setStatus(req.params.id, status, printerId ? { printerId } : {});
  if (!job) return res.status(404).json({ ok: false, error: 'no such job' });

  // reaching "ready" fires the pickup notification via the configured provider
  if (status === 'ready') {
    const r = await notify.onReady(cfg, job);
    queue.setStatus(job.id, 'ready', { notify: r });
    return res.json({ ok: true, job: publicJob(job), notify: r });
  }
  res.json({ ok: true, job: publicJob(job) });
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
    colours: j.colours, hole: j.hole, filename: j.filename, status: j.status,
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
  if (phone.replace(/\D/g, '').length < 7) throw new Error('valid phone required');
  return { name, phone };
}

function sanitizeDesign(body) {
  const b = cfg.build;
  const hole = ['left', 'right', 'centre'].includes(body?.hole) ? body.hole : 'centre';
  const colours = {
    layer1: pickColour(body?.colours?.layer1),
    layer2: pickColour(body?.colours?.layer2),
  };
  const design = cleanStrokes(body?.design, b);
  const backing = b.allowBackingDrawing ? cleanStrokes(body?.backing, b) : [];
  return { hole, colours, design, backing };
}

function pickColour(name) {
  const up = String(name ?? '').toUpperCase();
  if (!cfg.palette.includes(up)) throw new Error('invalid colour: ' + name);
  return up;
}

function cleanStrokes(strokes, b, maxStrokes = 400, maxPts = 4000) {
  if (!Array.isArray(strokes)) return [];
  const out = [];
  for (const s of strokes.slice(0, maxStrokes)) {
    if (!Array.isArray(s)) continue;
    const line = [];
    for (const p of s.slice(0, maxPts)) {
      const x = clamp(+p?.x, 0, b.plateWidth);
      const y = clamp(+p?.y, 0, b.plateHeight);
      if (Number.isFinite(x) && Number.isFinite(y)) line.push({ x, y });
    }
    if (line.length) out.push(line);
  }
  return out;
}
const clamp = (v, lo, hi) => (Number.isFinite(v) ? Math.max(lo, Math.min(hi, v)) : NaN);

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`3DiPad booth server on http://localhost:${port}`);
  console.log(`  kiosk:     http://localhost:${port}/`);
  console.log(`  dashboard: http://localhost:${port}/dashboard/`);
  console.log(`  config:    ${cfg._configPath}`);
});
