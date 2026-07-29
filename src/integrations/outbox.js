// Tiny persistent outbox for outbound webhooks. A booth's WiFi will blip; a
// captured lead must not be lost to it. post() tries once immediately and, on
// failure, queues the payload to disk and retries in the background with backoff.

import fs from 'node:fs';
import path from 'node:path';

let file = null;
let pending = [];
let timer = null;
let counter = 0;
const MAX_TRIES = 10;

export function init(root) {
  file = path.join(root, 'output', 'outbox.json');
  try {
    pending = JSON.parse(fs.readFileSync(file, 'utf8')).pending || [];
  } catch { pending = []; }
  if (!timer) {
    timer = setInterval(drain, 30_000);
    timer.unref?.();
  }
}

function save() {
  if (!file) return;
  try {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, JSON.stringify({ pending }, null, 2));
  } catch { /* best effort */ }
}

async function attempt(item) {
  item.tries = (item.tries || 0) + 1;
  item.lastTry = new Date().toISOString();
  try {
    const res = await fetch(item.url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(item.payload),
    });
    if (res.ok) return { ok: true, status: res.status };
    return { ok: false, error: `HTTP ${res.status}` };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

/** Fire a webhook. Returns the first-attempt result; keeps retrying in the background if it failed. */
export async function post(name, url, payload) {
  if (!url) return { ok: false, error: 'no webhook url configured' };
  const item = { id: ++counter, name, url, payload, tries: 0, queuedAt: new Date().toISOString() };
  const r = await attempt(item);
  if (!r.ok) {
    pending.push(item);
    save();
    return { ok: false, error: r.error, queued: true };
  }
  return r;
}

async function drain() {
  if (!pending.length) return;
  const keep = [];
  for (const item of pending) {
    if (item.tries >= MAX_TRIES) continue; // give up quietly after MAX_TRIES
    const r = await attempt(item);
    if (!r.ok) keep.push(item);
  }
  pending = keep;
  save();
}

export function stats() {
  return { pending: pending.length };
}
