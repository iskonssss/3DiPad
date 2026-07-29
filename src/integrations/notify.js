// Notification dispatcher — routes lead/ready events to the configured provider.
//   config.integrations.notify.provider = 'ghl' | 'meta' | 'none'
//
//   onLead  — fired on submit (GHL captures the contact; Meta has no lead step)
//   onReady — fired when a print is marked Ready (the pickup message)

import { sendReady as metaSendReady } from './whatsapp.js';
import * as ghl from './ghl.js';

function provider(cfg) {
  return cfg.integrations?.notify?.provider || 'none';
}

export async function onLead(cfg, job) {
  if (provider(cfg) === 'ghl') return ghl.onLead(cfg, job);
  return { ok: false, skipped: 'no lead push for provider ' + provider(cfg) };
}

export async function onReady(cfg, job) {
  switch (provider(cfg)) {
    case 'ghl': return ghl.onReady(cfg, job);
    case 'meta': return metaSendReady(cfg, job);
    default: return { ok: false, skipped: 'notifications disabled' };
  }
}
