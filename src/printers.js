// Printer slots: reading, saving and checking them.
//
// Setting a booth up meant running `node tools/set-printer.mjs …` in a terminal
// with the IP, serial and access code as positional arguments, then a second
// command to check it worked. That is a bad thing to be doing on a fair floor
// with a queue of parents watching, so the same operations live here and the
// dashboard drives them over HTTP. The CLI tools call into this too, so there is
// one implementation of "what a configured printer is".

import fs from 'node:fs';
import net from 'node:net';
import path from 'node:path';
import { Client as FtpClient } from 'basic-ftp';
import { root } from './config.js';

const FTP_PORT = 990;
const MQTT_PORT = 8883;
const SLOTS = 3;

export const configPath = () => path.join(root, 'config.json');

export function isConfigured(p) {
  return !!(p && p.ip && p.serial && p.accessCode);
}

/** Access codes are secrets; the dashboard only ever needs to see the shape. */
export function maskCode(code) {
  const s = String(code || '');
  if (!s) return '';
  return s.slice(0, 2) + '•'.repeat(Math.max(0, s.length - 2));
}

/** Printer slots as the dashboard should see them — never the code itself. */
export function publicPrinters(cfg) {
  const printers = cfg.integrations?.printers || [];
  const out = [];
  for (let i = 0; i < Math.max(SLOTS, printers.length); i++) {
    const p = printers[i] || { id: `A1-${i + 1}`, name: `Printer ${i + 1}`, ip: '', serial: '', accessCode: '' };
    out.push({
      slot: i + 1,
      id: p.id || `A1-${i + 1}`,
      name: p.name || `Printer ${i + 1}`,
      ip: p.ip || '',
      serial: p.serial || '',
      accessCodeMask: maskCode(p.accessCode),
      configured: isConfigured(p),
    });
  }
  return out;
}

/**
 * Write one printer slot into config.json, creating it from the example on the
 * first run. An empty accessCode keeps whatever is already stored, so the IP can
 * be corrected without retyping the code — the dashboard never had it to send
 * back in the first place.
 */
export function savePrinter(cfg, { slot, ip, serial, accessCode, name, enableLan = true }) {
  const n = Number(slot);
  if (!Number.isInteger(n) || n < 1 || n > SLOTS) throw new Error(`slot must be 1 to ${SLOTS}`);
  if (ip && !/^\d{1,3}(\.\d{1,3}){3}$/.test(ip)) throw new Error('IP must look like 192.168.10.105');

  const file = configPath();
  if (!fs.existsSync(file)) fs.copyFileSync(path.join(root, 'config.example.json'), file);
  const stored = JSON.parse(fs.readFileSync(file, 'utf8'));

  stored.integrations = stored.integrations || {};
  stored.integrations.lan = stored.integrations.lan || {};
  if (enableLan) stored.integrations.lan.enabled = true;
  stored.integrations.printers = stored.integrations.printers || [];
  while (stored.integrations.printers.length < n) {
    const k = stored.integrations.printers.length + 1;
    stored.integrations.printers.push({ id: `A1-${k}`, name: `Printer ${k}`, ip: '', serial: '', accessCode: '' });
  }

  const was = stored.integrations.printers[n - 1] || {};
  const now = {
    id: was.id || `A1-${n}`,
    name: name || was.name || `Printer ${n}`,
    ip: ip ?? was.ip ?? '',
    serial: serial ?? was.serial ?? '',
    accessCode: accessCode || was.accessCode || '',
  };
  stored.integrations.printers[n - 1] = now;
  fs.writeFileSync(file, JSON.stringify(stored, null, 2) + '\n');

  // keep the running config in step so the change takes effect without a restart
  cfg.integrations = cfg.integrations || {};
  cfg.integrations.lan = cfg.integrations.lan || {};
  if (enableLan) cfg.integrations.lan.enabled = true;
  cfg.integrations.printers = cfg.integrations.printers || [];
  while (cfg.integrations.printers.length < n) cfg.integrations.printers.push({ ...now, ip: '', serial: '', accessCode: '' });
  cfg.integrations.printers[n - 1] = { ...now };

  return now;
}

/** Is something listening on host:port? */
export function tcpCheck(host, port, timeout = 5000) {
  return new Promise((resolve) => {
    const sock = new net.Socket();
    const done = (r) => { sock.destroy(); resolve(r); };
    sock.setTimeout(timeout);
    sock.once('connect', () => done(true));
    sock.once('timeout', () => done(false));
    sock.once('error', () => done(false));
    sock.connect(port, host);
  });
}

/** Log in over FTPS and list the SD card — this is what proves the access code. */
export async function ftpsCheck(printer, timeout = 15000) {
  const client = new FtpClient(timeout);
  try {
    await client.access({
      host: printer.ip, port: FTP_PORT, user: 'bblp', password: printer.accessCode,
      secure: 'implicit', secureOptions: { rejectUnauthorized: false },
    });
    const list = await client.list();
    return { ok: true, files: list.length };
  } catch (e) {
    return { ok: false, error: String(e.message || e) };
  } finally {
    try { client.close(); } catch {}
  }
}

/**
 * Check a printer and return findings a person can act on.
 *
 * `liveState` is the status monitor's last report and `health` its connection
 * record, both passed in rather than fetched: the printer accepts one MQTT
 * client at a time and the monitor already holds it, so opening another to test
 * would be testing whether we can break our own connection.
 */
export async function checkPrinter(printer, liveState = null, health = null) {
  const findings = [];
  const fail = (msg, hint) => findings.push({ ok: false, msg, hint });
  const pass = (msg) => findings.push({ ok: true, msg });

  if (!printer.ip) fail('No IP address set', 'Printer screen: Settings > Network');
  if (!printer.serial) fail('No serial set', 'Printer screen: Settings > Device');
  if (!printer.accessCode) fail('No access code set', 'Printer screen: Settings > Network, with LAN Mode on');
  if (findings.length) return { ok: false, findings };

  const [ftpPort, mqttPort] = await Promise.all([
    tcpCheck(printer.ip, FTP_PORT),
    tcpCheck(printer.ip, MQTT_PORT),
  ]);

  if (ftpPort) pass('Reachable on the file-transfer port');
  else fail(`Nothing answering at ${printer.ip}:${FTP_PORT}`, 'Check the IP, that the printer is on the same Wi-Fi, and that LAN Mode is on');
  if (mqttPort) pass('Reachable on the control port');
  else fail(`Nothing answering at ${printer.ip}:${MQTT_PORT}`, 'Turn LAN Mode on from the printer screen');

  if (ftpPort) {
    const f = await ftpsCheck(printer);
    if (f.ok) pass(`Access code accepted (${f.files} items on the SD card)`);
    else fail('The printer refused the access code', 'Re-read it from the printer screen — it changes when LAN Mode is toggled');
  }

  // "No status" has two causes that look identical and need opposite fixes.
  // The port being open only proves something is listening; whether the MQTT
  // session got as far as connecting, and whether anything then arrived on this
  // printer's report topic, is what tells them apart.
  if (liveState?.state) {
    pass(`Printer says: ${liveState.state}${liveState.percent != null ? ` ${liveState.percent}%` : ''}`);
  } else if (health && health.connected && health.messages === 0) {
    fail('Connected to the printer, but it is not sending anything back',
      `Nothing has arrived on device/${printer.serial}/report — the serial number is almost certainly wrong. Check it against Settings > Device on the printer, digit for digit.`);
  } else if (health && !health.connected && health.connections === 0 && (mqttPort || health.lastError)) {
    // the port scan is beside the point once the session itself has reported
    // back — an error from the printer is conclusive on its own
    fail('The printer refused the control connection',
      health.lastError ? `MQTT said: ${health.lastError}` : 'Re-read the access code from the printer screen, then Save again');
  } else if (health && !health.connected && health.connections > 0) {
    fail('The control connection dropped', 'It reconnects on its own every 10s — check again shortly, and check the Wi-Fi if it keeps dropping');
  } else if (mqttPort) {
    // Not a pass. This test used to end "all okay" here while the dashboard
    // greyed that printer's button out, because the button needs a reported
    // state and there isn't one — two screens disagreeing about the same
    // printer. Say what it means for the booth.
    findings.push({
      ok: null,
      msg: 'No status received yet — the dashboard will show this printer as NO SIGNAL',
      hint: 'Give it a few seconds after saving and check again. If it stays this way the serial is the thing to re-check. You can still send to it: the file goes to the SD card and you press Print on the printer.',
    });
  }

  // Whatever the printer last said about a command we sent it. When a file
  // uploads but never starts, this is usually the only place the reason exists.
  if (health?.lastCommand) {
    const c = health.lastCommand;
    const good = String(c.result || '').toUpperCase() === 'SUCCESS';
    findings.push({
      ok: good ? true : false,
      msg: `Last command "${c.command}": ${c.result || 'no result'}${c.reason ? ` — ${c.reason}` : ''}`,
      hint: good ? undefined : 'This is the printer refusing the start command, not a network problem.',
    });
  }

  return { ok: findings.every((f) => f.ok !== false), findings };
}
