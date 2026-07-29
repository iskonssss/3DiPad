// GoHighLevel integration via Inbound Webhook.
//
// The booth fires two events; a GHL workflow (triggered by the Inbound Webhook)
// upserts the contact, tags it, sends the approved WhatsApp template, and runs
// the nurture sequence. GHL owns all messaging — the booth only supplies data.
//
//   - onLead  (submit): capture the parent immediately (lead-gen safety net)
//   - onReady (print done): fire the "your print is ready" pickup message
//
// Webhook URLs live in .env (GHL_LEAD_WEBHOOK_URL / GHL_READY_WEBHOOK_URL) or
// config.integrations.ghl. A single URL is fine — switch on payload.event/status
// inside the GHL workflow.

import { post } from './outbox.js';

export function buildPayload(cfg, job, event) {
  const g = cfg.integrations?.ghl || {};
  const c = job.colours;
  const name = job.contact.name || '';
  return {
    event, // 'lead' | 'ready'
    status: job.status,
    // contact — mapped to GHL standard fields
    first_name: name.split(' ')[0] || name,
    full_name: name,
    phone: job.contact.phone, // as entered, e.g. "+65 91234567"
    phone_e164: job.contact.phoneE164 || toE164(job.contact.phone),
    country: job.contact.country || '',
    // context — map to GHL custom fields / used in the template
    fair: g.eventName || 'Not So Little Fair',
    tags: g.tags || [],
    job_id: job.id,
    seq: job.seq,
    filename: job.filename,
    colours: `${c.layer1}-${c.layer2}`,
    layer1: c.layer1,
    layer2: c.layer2,
    hole: job.hole,
    est_minutes: job.meta?.estMinutes ?? null,
    drive_link: job.driveLink || null, // public link to the design/gcode if Drive is on
    submitted_at: job.createdAt,
  };
}

export async function onLead(cfg, job) {
  const url = process.env.GHL_LEAD_WEBHOOK_URL || cfg.integrations?.ghl?.leadWebhookUrl;
  if (!url) return { ok: false, skipped: 'no GHL lead webhook configured' };
  return post('ghl-lead', url, buildPayload(cfg, job, 'lead'));
}

export async function onReady(cfg, job) {
  const url =
    process.env.GHL_READY_WEBHOOK_URL ||
    cfg.integrations?.ghl?.readyWebhookUrl ||
    process.env.GHL_LEAD_WEBHOOK_URL ||
    cfg.integrations?.ghl?.leadWebhookUrl;
  if (!url) return { ok: false, skipped: 'no GHL webhook configured' };
  return post('ghl-ready', url, buildPayload(cfg, job, 'ready'));
}

// Best-effort E.164: keep a leading +, else assume it already includes a country
// code. Booth staff should enter numbers with the country code to be safe.
function toE164(phone) {
  const s = String(phone || '').trim();
  const digits = s.replace(/[^\d]/g, '');
  if (s.startsWith('+')) return '+' + digits;
  return digits ? '+' + digits.replace(/^0+/, '') : '';
}
