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
// and on the printer itself: Settings -> Network -> **LAN Mode ON** and
// **DEVELOPER MODE ON**, then note the Access Code and Serial shown there.
//
// Developer Mode is not optional and is easy to miss. Bambu gates third-party
// print control behind it, separately from everything else: with it off, the
// printer reports status, obeys ledctrl, and accepts FTPS uploads, while every
// command in the `print` namespace — project_file, gcode_file, even stop —
// comes back with err_code 0x05024007. A booth in that state looks entirely
// healthy and cannot start a single job.
//
// NOTE: both TLS endpoints use the printer's self-signed certificate, so
// certificate verification is disabled for these direct-to-printer connections
// (rejectUnauthorized: false). That is how Bambu's own LAN mode works; the
// traffic stays on your local booth network.

import fs from 'node:fs';
import path from 'node:path';
import { Client as FtpClient } from 'basic-ftp';
import mqtt from 'mqtt';
import { build3mf } from './bambu3mf.js';

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

/* ------------------------------------------------------------------ *
 * Starting a print                                                     *
 *                                                                      *
 * The file uploads over FTPS and appears on the SD card, and then the   *
 * start command goes out over MQTT and nothing happens. The printer     *
 * sends no acknowledgement to a publish, so from our side a command it  *
 * silently discarded looks exactly like one it obeyed.                  *
 *                                                                      *
 * Firmware is not consistent about the shape it wants — whether the     *
 * path carries the /sdcard prefix, and whether a bare .gcode is started *
 * with `gcode_file` or with `project_file` and a file:// url. Rather    *
 * than pick one and hope, we try them in order and keep the one the     *
 * printer actually acts on, which we can see because its own reported   *
 * state turns over. The winner is logged so it can be pinned in config  *
 * (integrations.lan.startCommand) and the probing stops.                *
 * ------------------------------------------------------------------ */

export const START_VARIANTS = ['gcode_file', 'gcode_file_bare', 'project_file'];

/** Which shapes to try, in order. A pinned config value wins outright. */
export function startVariants(cfg) {
  const pinned = cfg?.integrations?.lan?.startCommand;
  if (pinned && pinned !== 'auto') return [pinned];
  // A 3mf is a project by definition — there is one command that starts it and
  // nothing to probe for.
  if (container(cfg) === '3mf') return ['project_file'];
  return START_VARIANTS;
}

/**
 * What we put on the SD card.
 *
 * '3mf' wraps the g-code as a project, which is what Bambu Studio uploads and
 * what the printer's own task record points at. 'gcode' is the original bare
 * upload, kept because it is one config line away if a firmware prefers it.
 */
export function container(cfg) {
  return cfg?.integrations?.lan?.container ?? '3mf';
}

/** The MQTT payload that starts a print of an already-uploaded .gcode file. */
export function buildPrintCommand(remotePath, opts = {}) {
  const sequence_id = String(opts.sequenceId ?? Date.now());
  const name = path.basename(remotePath);
  const bare = name.replace(/\.[^.]+$/, '');

  switch (opts.variant) {
    // Same shape Bambu Studio uses for a real project. The flags are print-task
    // parameters — this is the only route by which bed levelling and flow
    // calibration can be turned off from our side rather than by leaving G29
    // out of the file.
    case 'project_file':
      return {
        print: {
          sequence_id,
          command: 'project_file',
          // Inside a 3mf the g-code is a member of the archive, and this names
          // it. For a bare .gcode upload there is nothing to point at.
          param: opts.gcodePath || '',
          url: `file://${remotePath}`,
          subtask_name: bare,
          timelapse: false,
          bed_leveling: false,
          flow_cali: false,
          vibration_cali: false,
          layer_inspect: false,
          use_ams: false,
          profile_id: '0', project_id: '0', subtask_id: '0', task_id: '0',
        },
      };
    // Some firmware wants the name as it appears in the file browser, with no
    // /sdcard in front of it.
    case 'gcode_file_bare':
      return { print: { sequence_id, command: 'gcode_file', param: name } };
    default:
      return { print: { sequence_id, command: 'gcode_file', param: remotePath } };
  }
}

/**
 * Tell the printer to let go of the job it is still holding.
 *
 * A Bambu that has failed a print does not return to idle on its own: it sits
 * in gcode_state FAILED, still naming the job that died, and refuses every new
 * print command until someone clears it. The refusal is the same whatever you
 * send, which is why seven different requests — a 3mf Bambu Studio made, one we
 * made, two directories, three command shapes — all came back
 * err_code 0x05024007. It was never about the request.
 *
 * `stop` is what the printer's own screen sends when you dismiss a failed job.
 */
export function buildStopCommand(sequenceId) {
  return { print: { sequence_id: String(sequenceId ?? Date.now()), command: 'stop', param: '' } };
}

/** States a printer will not accept a new job from until it is cleared. */
export const STUCK_STATES = ['FAILED', 'FINISH'];

export function needsClearing(state) {
  return STUCK_STATES.includes(String(state || '').toUpperCase());
}

/**
 * Clear a stuck printer and wait for it to say it is idle again.
 * Returns { cleared, state } — cleared false means it never let go.
 */
export async function clearIfStuck(printer, cfg, readState, opts = {}) {
  const before = readState();
  if (!needsClearing(before?.state)) return { cleared: false, needed: false, state: before?.state };

  await publishCommand(printer, buildStopCommand(opts.sequenceId), cfg);

  const deadline = Date.now() + (opts.waitMs ?? cfg?.integrations?.lan?.clearWaitMs ?? 8000);
  while (Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, 400));
    const now = readState();
    if (!needsClearing(now?.state)) return { cleared: true, needed: true, state: now?.state };
  }
  return { cleared: false, needed: true, state: readState()?.state };
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

/** The last command sent to each printer, for explaining a print that never began. */
const lastPublished = new Map();
export function lastCommandSent(printer) {
  return lastPublished.get(printerKey(printer)) || null;
}

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

  lastPublished.set(printerKey(printer), { at: new Date().toISOString(), topic, payload });
  if (lan.debug) {
    console.log(`[${printer.id}] PUBLISH ${topic}`);
    console.log('           ' + JSON.stringify(payload));
  }

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
  let up, send = filePath, gcodePath = '';
  try {
    if (container(cfg) === '3mf') {
      send = wrapAs3mf(filePath, cfg, opts.meta);
      gcodePath = 'Metadata/plate_1.gcode';
    }
    up = await uploadFile(printer, send, cfg);
  } catch (e) {
    return { ok: false, sent: false, stage: 'upload', error: String(e.message || e) };
  }

  const started = await startPrint(printer, up.remotePath, cfg, { ...opts, gcodePath });
  if (!started.ok) return { ...started, sent: false, uploaded: up.name };
  return { ok: true, sent: true, name: up.name, remotePath: up.remotePath, variant: started.variant, confirmed: started.confirmed, unverified: started.unverified };
}

/**
 * Write <name>.3mf next to the .gcode and return its path.
 *
 * Kept on disk rather than in a temp file on purpose: if the network dies at
 * the fair, this is the file to copy onto a USB stick or hand to Bambu Studio,
 * and it is the one the printer would have been given.
 */
export function wrapAs3mf(gcodePath, cfg, meta) {
  const out = gcodePath.replace(/\.gcode$/i, '') + '.3mf';
  const gcode = fs.readFileSync(gcodePath, 'utf8');
  const name = path.basename(gcodePath).replace(/\.gcode$/i, '');
  fs.writeFileSync(out, build3mf({ gcode, meta, cfg, name }));
  return out;
}

/**
 * Get the printer to act on a file already on its SD card.
 *
 * Tries each command shape in turn and stops at the one that visibly starts the
 * machine. Without a probe (or with a shape pinned in config) this is a single
 * publish, exactly as the booth has always done it.
 */
export async function startPrint(printer, remotePath, cfg, opts = {}) {
  const variants = startVariants(cfg);
  const publish = opts.publish || publishCommand;
  const probe = opts.confirmStarted;
  let last = null;
  for (let i = 0; i < variants.length; i++) {
    const variant = variants[i];
    const pub = await publish(printer, buildPrintCommand(remotePath, { ...opts, variant }), cfg);
    if (!pub.ok) return { ok: false, stage: 'start', error: pub.error, variant };
    last = variant;
    if (!probe || i === variants.length - 1) break;

    // Only send another start command if we can see that this one did nothing.
    // A second "start" arriving at a printer that is already printing is not a
    // no-op — it can abort the job. So the probe answers three ways, and only a
    // definite "still idle" earns another try:
    //   true  -> it started. Stop, and report which shape worked.
    //   false -> definitely still idle. Try the next shape.
    //   null  -> we cannot see this printer's state at all. Stop: firing more
    //            commands blind is how you cancel someone's keychain.
    const moved = await probe(printer, variant);
    if (moved !== false) return { ok: true, variant, confirmed: moved === true, unverified: moved == null };
  }
  return { ok: true, variant: last, confirmed: false };
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
 * A reply to a command we sent, as opposed to a routine status push. Exported
 * for testing.
 */
export function readCommandReply(msg) {
  // Replies come back under whichever namespace the command was sent in:
  // print for jobs, system for the light and the like, pushing for status.
  // Reading only `print` meant the booth watched a ledctrl answer
  // "result":"success" go past and reported that the printer had not answered
  // at all — the one reply that proved the session was trusted.
  const p = msg?.print || msg?.system || msg?.pushing || msg?.info || msg?.camera;
  if (!p || !p.command) return null;
  // push_status is the printer talking to itself on a timer, not to us
  if (p.command === 'push_status' || p.command === 'pushall') return null;
  // err_code is how the A1 mini refuses a print command: it echoes the whole
  // request back with this one field added. We were only looking for `result`
  // and `reason`, so the refusal read as an unremarkable message and got
  // filed away with the rest.
  const err = p.err_code ?? p.errno;
  if (p.result == null && p.reason == null && err == null) return null;
  return {
    command: String(p.command),
    result: p.result != null ? String(p.result) : (err ? 'error' : null),
    reason: p.reason != null ? String(p.reason) : (err ? errorCodeText(err) : null),
    errCode: err ?? null,
    sequenceId: p.sequence_id != null ? String(p.sequence_id) : null,
    at: new Date().toISOString(),
  };
}

/**
 * Bambu reports errors as a 32-bit number that is only legible in hex — the
 * booth saw "err_code":84033543, which is 0x05024007 and searchable, while the
 * decimal is not.
 */
export function errorCodeText(code) {
  const n = Number(code);
  if (!Number.isFinite(n)) return String(code);
  const hex = `0x${(n >>> 0).toString(16).toUpperCase().padStart(8, '0')}`;
  return `err_code ${n} (${hex})`;
}

/**
 * What we know about a refusal code, if anything.
 *
 * 0x05024007 was returned identically for seven different requests — Bambu's
 * own 3mf and ours, from /sdcard and /sdcard/cache, as project_file and as
 * gcode_file. Nothing about the payload changed the answer, which is the
 * signature of a permission rather than a malformed request.
 */
export function errorCodeHint(code) {
  const hex = `0x${(Number(code) >>> 0).toString(16).toUpperCase().padStart(8, '0')}`;
  return {
    // Measured, not guessed: on this printer every command in the `print`
    // namespace comes back with this code — project_file, gcode_file, and
    // stop alike — while `system` commands (ledctrl) answer "success" and the
    // light physically obeys, and `pushing` (pushall) returns full status.
    // A whole namespace refused while its neighbours work is an authorisation
    // boundary, not a bad request and not a printer state: `stop` is valid in
    // every state there is, including the FAILED one it was sent in.
    '0x05024007': 'every command in the print namespace is being refused, while system and status ' +
      'commands from the same connection succeed. That is third-party print control being switched ' +
      'off rather than anything wrong with the request. Look for Developer Mode / "LAN Mode developer" ' +
      'in the printer\'s network settings or in Bambu Handy, and turn it on.',
  }[hex] || null;
}

/**
 * Watch a printer's report topic. onStatus(status) fires on each meaningful
 * update. Returns a handle with .stop(). Reconnects automatically.
 */
export function watchPrinter(printer, cfg, onStatus, onRaw = null) {
  // Health is reported separately from status because the two failures look
  // identical from outside and need opposite fixes: an MQTT session that never
  // connects is credentials or network, while one that connects and then hears
  // nothing means we are subscribed to the wrong topic — i.e. the serial number
  // is wrong. Both present as "no status yet".
  // `recent` is a small ring of the messages that were not routine status
  // pushes. A print that will not start is diagnosed from what the printer said
  // around the moment we asked, and asking an operator to turn a debug flag on
  // and reproduce it is asking them to do that during a fair. Keep it always.
  const health = { connected: false, connections: 0, messages: 0, lastMessageAt: null, lastError: null, recent: [] };
  if (!isConfigured(printer) || !cfg?.integrations?.lan?.enabled) {
    return { stop() {}, health: () => ({ ...health, configured: false }) };
  }
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
    health.connected = true;
    health.connections += 1;
    client.subscribe(topic, { qos: 0 });
    // ask for a full state dump so we don't wait for the next natural push
    client.publish(`device/${printer.serial}/request`, JSON.stringify({ pushing: { sequence_id: '0', command: 'pushall' } }));
  });
  client.on('close', () => { health.connected = false; });
  client.on('offline', () => { health.connected = false; });
  client.on('message', (_t, buf) => {
    health.messages += 1;
    health.lastMessageAt = new Date().toISOString();
    let msg;
    try { msg = JSON.parse(buf.toString()); } catch { return; }
    // Everything, including the routine status pushes that `recent` filters
    // out. The full state only ever arrives in one of those, so a diagnostic
    // that reads `recent` can never see it — which is how "no full status
    // arrived" was reported by a tool watching a printer that was pushing
    // status the whole time.
    if (onRaw) { try { onRaw(msg); } catch (e) { console.error('raw handler failed', e); } }
    // With debug on, print everything that is not the routine status push. If a
    // start command is being refused for a reason we have not learned to
    // recognise, this is where it will be visible.
    if (msg?.print?.command !== 'push_status') {
      const text = JSON.stringify(msg).slice(0, 600);
      // The parsed message is kept beside the text: the diagnostics print the
      // text, and tools/probe-start.mjs reads the reply out of `msg` with the
      // same parser the monitor uses, rather than pattern-matching the string.
      health.recent.push({ at: new Date().toISOString(), text, msg });
      if (health.recent.length > 12) health.recent.shift();
      if (cfg.integrations.lan.debug) console.log(`[${printer.id}] REPORT ${text}`);
    }
    // The printer does answer commands — it just answers on the report topic,
    // mixed in with status. We were parsing these messages for status only and
    // dropping everything else, so a start command the printer refused was
    // refused silently. If it is telling us why it will not print, say so.
    const reply = readCommandReply(msg);
    if (reply) {
      health.lastCommand = reply;
      const bad = reply.result && reply.result.toUpperCase() !== 'SUCCESS';
      const line = `[${printer.id}] printer answered "${reply.command}": ${reply.result || '?'}${reply.reason ? ` — ${reply.reason}` : ''}`;
      if (bad) console.error(line); else console.log(line);
    }
    const status = readStatus(msg);
    if (status) { try { onStatus(status); } catch (e) { console.error('printer status handler failed', e); } }
  });
  client.on('error', (e) => {
    health.lastError = String(e.message || e);
    console.error(`[${printer.id}] MQTT error:`, health.lastError);
  });
  return {
    stop() { releaseLiveClient(printer, client); try { client.end(true); } catch {} },
    health: () => ({ ...health, configured: true, topic }),
  };
}

/**
 * Say what the shape of the results means, rather than leaving seven identical
 * rows to be interpreted by hand.
 *
 * The useful signal is not any single row: it is whether the answer changed
 * when the request did. Seven different requests answered identically is a
 * different finding from seven different answers, and points somewhere else
 * entirely.
 */
export function readPattern(rows) {
  const refused = rows.filter((r) => r.outcome === 'refused');
  const codes = new Set(refused.map((r) => r.detail));
  const out = ['  WHAT THIS MEANS', ''];

  if (refused.length >= 2 && codes.size === 1) {
    const [only] = [...codes];
    out.push(`  All ${refused.length} requests were refused with the same answer:`);
    out.push(`      ${only}`);
    out.push('');
    out.push('  The file was not the problem: a 3mf Bambu Studio made and one we made were');
    out.push('  refused alike. Nor was the folder, nor the command — /sdcard and /sdcard/cache,');
    out.push('  project_file and gcode_file, all the same answer. Nothing about what we sent');
    out.push('  changed it, which is what a permission looks like rather than a bad request.');
    const code = /\((0x[0-9A-F]+)\)/.exec(only)?.[1];
    const hint = code && errorCodeHint(parseInt(code, 16));
    if (hint) {
      out.push('');
      out.push('  Most likely: ' + hint.replace(/\s+/g, ' '));
    }
    out.push('');
    out.push('  To check: on the printer, Settings > Network. If LAN Only Mode is off, turn');
    out.push('  it on, take the new access code, put it in on the setup page, and run this');
    out.push('  again. If it was already on, paste this output and we will look further.');
  } else if (codes.size > 1) {
    out.push('  The answer changed with the request, so the request is the thing to fix:');
    for (const r of refused) out.push(`      ${r.detail}   <- ${r.name}`);
  } else {
    out.push('  Nothing started and nothing was refused, so the printer did not answer at all.');
    out.push('  Paste this whole output.');
  }
  return out;
}
