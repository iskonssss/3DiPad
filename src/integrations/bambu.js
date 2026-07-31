// Bambu Lab A1 mini — LAN-mode dispatch and status monitoring.
//
// Sending a print over the local network is a two-step Bambu protocol:
//
//   1) FTPS upload (implicit TLS, port 990, user "bblp", password = the
//      printer's LAN Access Code) to put the .gcode on the printer's SD card.
//   2) MQTT over TLS (port 8883, same credentials) publishing a print command
//      to  device/<SERIAL>/request  to start it.
//
// The printer continuously publishes its state to  device/<SERIAL>/report ,
// which we subscribe to so a finished print can fire the "ready" notification
// with no operator tap.
//
// Requirements per printer (config.integrations.printers[]):
//   { id, name, ip, serial, accessCode }
// and on the printer itself: Settings -> Network -> **LAN Mode ON**, then note
// the Access Code and Serial shown there.
//
// NOTE: both TLS endpoints use the printer's self-signed certificate, so
// certificate verification is disabled for these direct-to-printer connections
// (rejectUnauthorized: false). That is how Bambu's own LAN mode works; the
// traffic stays on your local booth network.

import fs from 'node:fs';
import path from 'node:path';
import { Client as FtpClient } from 'basic-ftp';
import mqtt from 'mqtt';

const FTP_PORT = 990;
const MQTT_PORT = 8883;
const USER = 'bblp';

export function isConfigured(printer) {
  return !!(printer && printer.ip && printer.serial && printer.accessCode);
}

/** Sanitise a filename for the printer's SD card (ASCII, no spaces/paths). */
export function sdName(filename) {
  return path
    .basename(String(filename))
    .replace(/[^A-Za-z0-9._-]/g, '_')
    .slice(-60);
}

/** The MQTT payload that starts a print of an already-uploaded .gcode file. */
export function buildPrintCommand(remotePath, opts = {}) {
  return {
    print: {
      sequence_id: String(opts.sequenceId ?? Date.now()),
      command: 'gcode_file',
      param: remotePath,
    },
  };
}

/** Upload a local file to the printer's SD card over implicit-TLS FTPS. */
export async function uploadFile(printer, filePath, cfg) {
  const lan = cfg?.integrations?.lan || {};
  const dir = lan.uploadDir ?? '';
  const name = sdName(path.basename(filePath));
  const client = new FtpClient(lan.timeoutMs ?? 30000);
  client.ftp.verbose = false;
  try {
    await client.access({
      host: printer.ip,
      port: FTP_PORT,
      user: USER,
      password: printer.accessCode,
      secure: 'implicit',
      secureOptions: { rejectUnauthorized: false },
    });
    if (dir) await client.ensureDir(dir);
    await client.uploadFrom(fs.createReadStream(filePath), name);
    return { ok: true, name, remotePath: `${lan.sdPrefix ?? '/sdcard'}${dir ? '/' + dir.replace(/^\/+/, '') : ''}/${name}` };
  } finally {
    client.close();
  }
}

/* ------------------------------------------------------------------ *
 * Shared MQTT connections                                              *
 *                                                                      *
 * A Bambu printer accepts only ONE MQTT client at a time. The status    *
 * monitor holds a persistent connection for the whole booth session, so *
 * opening a second connection just to send the print command gets       *
 * ignored by the printer and times out ("LAN dispatch failed at start:  *
 * MQTT timeout"). So commands are published on the monitor's connection *
 * when there is one, and only fall back to a throwaway connection when  *
 * nothing is watching that printer.                                     *
 * ------------------------------------------------------------------ */

const liveClients = new Map();

function printerKey(printer) {
  return String(printer?.id || printer?.serial || printer?.ip || '');
}

/** Record a long-lived client so publishCommand can reuse it. */
export function registerLiveClient(printer, client) {
  const key = printerKey(printer);
  if (key) liveClients.set(key, client);
}

/** Drop a long-lived client (only if it is still the registered one). */
export function releaseLiveClient(printer, client) {
  const key = printerKey(printer);
  if (key && (!client || liveClients.get(key) === client)) liveClients.delete(key);
}

/** The connected long-lived client for this printer, or null. */
export function getLiveClient(printer) {
  const client = liveClients.get(printerKey(printer));
  return client && client.connected ? client : null;
}

/**
 * Like getLiveClient, but if a monitor connection exists and is still dialling
 * (server just started, or it is mid-reconnect) wait briefly for it rather than
 * racing it with a second connection the printer would refuse.
 */
export async function awaitLiveClient(printer, waitMs = 4000) {
  const client = liveClients.get(printerKey(printer));
  if (!client) return null;
  if (client.connected) return client;
  if (typeof client.once !== 'function') return null;
  const connected = await new Promise((resolve) => {
    let settled = false;
    const onConnect = () => done(true);
    const done = (v) => {
      if (settled) return;
      settled = true;
      try { client.removeListener('connect', onConnect); } catch {}
      resolve(v);
    };
    client.once('connect', onConnect);
    setTimeout(() => done(false), waitMs).unref?.();
  });
  return connected ? client : null;
}

/**
 * Publish a single command to the printer, reusing the monitor's connection.
 *
 * QoS 0, because the printer does not send PUBACK: a QoS 1 publish waits for an
 * acknowledgement that never arrives and reports "MQTT publish timeout" even
 * though the command went out. The monitor's own pushall has always published
 * at QoS 0 over this same connection, which is why status worked while starting
 * a print did not. Whether the print actually began is confirmed from the
 * printer's reported state, not from the transport.
 */
export async function publishCommand(printer, payload, cfg) {
  const lan = cfg?.integrations?.lan || {};
  const topic = `device/${printer.serial}/request`;
  const qos = lan.qos ?? 0;
  const timeoutMs = (lan.timeoutMs ?? 10000) + 2000;

  const shared = await awaitLiveClient(printer);
  if (shared) {
    return new Promise((resolve) => {
      let settled = false;
      const done = (r) => { if (!settled) { settled = true; resolve(r); } };
      try {
        shared.publish(topic, JSON.stringify(payload), { qos }, (err) =>
          done(err ? { ok: false, error: String(err) } : { ok: true, reused: true }),
        );
      } catch (e) {
        done({ ok: false, error: String(e.message || e) });
      }
      setTimeout(() => done({ ok: false, error: 'MQTT publish timeout' }), timeoutMs).unref?.();
    });
  }

  return new Promise((resolve) => {
    const client = mqtt.connect(`mqtts://${printer.ip}:${MQTT_PORT}`, {
      username: USER,
      password: printer.accessCode,
      rejectUnauthorized: false,
      connectTimeout: lan.timeoutMs ?? 10000,
      reconnectPeriod: 0,
    });
    let settled = false;
    const done = (r) => { if (!settled) { settled = true; try { client.end(true); } catch {} resolve(r); } };
    client.on('connect', () => {
      client.publish(topic, JSON.stringify(payload), { qos }, (err) =>
        done(err ? { ok: false, error: String(err) } : { ok: true }),
      );
    });
    client.on('error', (e) => done({ ok: false, error: String(e.message || e) }));
    setTimeout(() => done({ ok: false, error: 'MQTT timeout' }), timeoutMs);
  });
}

/**
 * Send a sliced .gcode to a printer and start it.
 * Returns { ok, sent, remotePath, error }. Never throws — the caller falls back
 * to manual dispatch from the dashboard, so a booth failure is recoverable.
 */
export async function sendToPrinter(printer, filePath, cfg, opts = {}) {
  if (!cfg?.integrations?.lan?.enabled) {
    return { ok: true, sent: false, manual: true, reason: 'LAN auto-send disabled in config' };
  }
  if (!isConfigured(printer)) {
    return { ok: true, sent: false, manual: true, reason: 'printer missing ip/serial/accessCode' };
  }
  let up;
  try {
    up = await uploadFile(printer, filePath, cfg);
  } catch (e) {
    return { ok: false, sent: false, stage: 'upload', error: String(e.message || e) };
  }
  const pub = await publishCommand(printer, buildPrintCommand(up.remotePath, opts), cfg);
  if (!pub.ok) return { ok: false, sent: false, stage: 'start', uploaded: up.name, error: pub.error };
  return { ok: true, sent: true, name: up.name, remotePath: up.remotePath };
}

/* ------------------------------------------------------------------ *
 * Status monitoring — turns printer reports into job lifecycle events *
 * ------------------------------------------------------------------ */

/** Map a Bambu report payload to a simple state. Exported for testing. */
export function readStatus(msg) {
  const p = msg?.print;
  if (!p) return null;
  const gcodeState = p.gcode_state; // IDLE | PREPARE | RUNNING | PAUSE | FINISH | FAILED
  const out = {};
  if (gcodeState) out.state = String(gcodeState).toUpperCase();
  if (typeof p.mc_percent === 'number') out.percent = p.mc_percent;
  if (typeof p.mc_remaining_time === 'number') out.remainingMin = p.mc_remaining_time;
  if (p.subtask_name) out.file = p.subtask_name;
  if (typeof p.print_error === 'number' && p.print_error !== 0) out.errorCode = p.print_error;
  return Object.keys(out).length ? out : null;
}

/**
 * Watch a printer's report topic. onStatus(status) fires on each meaningful
 * update. Returns a handle with .stop(). Reconnects automatically.
 */
export function watchPrinter(printer, cfg, onStatus) {
  if (!isConfigured(printer) || !cfg?.integrations?.lan?.enabled) return { stop() {} };
  const client = mqtt.connect(`mqtts://${printer.ip}:${MQTT_PORT}`, {
    username: USER,
    password: printer.accessCode,
    rejectUnauthorized: false,
    reconnectPeriod: 10000,
  });
  // Publish commands over this connection too — the printer allows only one.
  registerLiveClient(printer, client);
  const topic = `device/${printer.serial}/report`;
  client.on('connect', () => {
    client.subscribe(topic, { qos: 0 });
    // ask for a full state dump so we don't wait for the next natural push
    client.publish(`device/${printer.serial}/request`, JSON.stringify({ pushing: { sequence_id: '0', command: 'pushall' } }));
  });
  client.on('message', (_t, buf) => {
    let msg;
    try { msg = JSON.parse(buf.toString()); } catch { return; }
    const status = readStatus(msg);
    if (status) { try { onStatus(status); } catch (e) { console.error('printer status handler failed', e); } }
  });
  client.on('error', (e) => console.error(`[${printer.id}] MQTT error:`, e.message || e));
  return { stop() { releaseLiveClient(printer, client); try { client.end(true); } catch {} } };
}
