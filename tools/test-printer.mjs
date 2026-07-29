// Verify LAN connectivity to each configured Bambu printer.
//
//   npm run test-printer            # test every configured printer
//   npm run test-printer A1-2       # test one
//   npm run test-printer A1-2 send  # ALSO upload a sample file and start it
//
// Checks, in order:
//   1. TCP reachability of the FTPS (990) and MQTT (8883) ports
//   2. FTPS login + directory listing (proves the Access Code is right)
//   3. MQTT connect + subscribe, and a pushall to read live printer state
//
// Nothing is printed unless you pass `send`.

import net from 'node:net';
import path from 'node:path';
import fs from 'node:fs';
import mqtt from 'mqtt';
import { Client as FtpClient } from 'basic-ftp';
import { loadConfig, root } from '../src/config.js';
import { sendToPrinter, readStatus } from '../src/integrations/bambu.js';

const cfg = loadConfig();
const [filterId, action] = process.argv.slice(2);
const printers = (cfg.integrations?.printers || []).filter(
  (p) => p.ip && p.serial && p.accessCode && (!filterId || p.id === filterId),
);

if (!printers.length) {
  console.error('No printers with ip + serial + accessCode in config.json.');
  console.error('Set them under integrations.printers, and integrations.lan.enabled = true.');
  process.exit(1);
}

const ok = (s) => `\x1b[32m✓\x1b[0m ${s}`;
const bad = (s) => `\x1b[31m✗\x1b[0m ${s}`;

function tcpCheck(host, port, timeout = 5000) {
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

async function ftpsCheck(p) {
  const client = new FtpClient(15000);
  try {
    await client.access({
      host: p.ip, port: 990, user: 'bblp', password: p.accessCode,
      secure: 'implicit', secureOptions: { rejectUnauthorized: false },
    });
    const list = await client.list();
    return { ok: true, files: list.length };
  } catch (e) {
    return { ok: false, error: String(e.message || e) };
  } finally {
    client.close();
  }
}

function mqttCheck(p, waitMs = 6000) {
  return new Promise((resolve) => {
    const client = mqtt.connect(`mqtts://${p.ip}:8883`, {
      username: 'bblp', password: p.accessCode, rejectUnauthorized: false,
      connectTimeout: 8000, reconnectPeriod: 0,
    });
    let connected = false, status = null;
    const finish = () => { try { client.end(true); } catch {} resolve({ ok: connected, status }); };
    client.on('connect', () => {
      connected = true;
      client.subscribe(`device/${p.serial}/report`, () => {
        client.publish(`device/${p.serial}/request`, JSON.stringify({ pushing: { sequence_id: '0', command: 'pushall' } }));
      });
    });
    client.on('message', (_t, buf) => {
      try { status = readStatus(JSON.parse(buf.toString())) || status; } catch {}
      if (status?.state) finish();
    });
    client.on('error', (e) => { status = { error: String(e.message || e) }; finish(); });
    setTimeout(finish, waitMs);
  });
}

for (const p of printers) {
  console.log(`\n=== ${p.id} (${p.name}) — ${p.ip} ===`);

  const [ftpPort, mqttPort] = await Promise.all([tcpCheck(p.ip, 990), tcpCheck(p.ip, 8883)]);
  console.log(ftpPort ? ok('port 990 (FTPS) reachable') : bad('port 990 (FTPS) unreachable — check IP / same network / LAN Mode ON'));
  console.log(mqttPort ? ok('port 8883 (MQTT) reachable') : bad('port 8883 (MQTT) unreachable'));
  if (!ftpPort && !mqttPort) continue;

  if (ftpPort) {
    const f = await ftpsCheck(p);
    console.log(f.ok ? ok(`FTPS login OK (${f.files} entries on SD)`) : bad(`FTPS login failed — ${f.error}`));
  }
  if (mqttPort) {
    const m = await mqttCheck(p);
    if (m.ok && m.status?.state) console.log(ok(`MQTT OK — printer state: ${m.status.state}${m.status.percent != null ? ` ${m.status.percent}%` : ''}`));
    else if (m.ok) console.log(ok('MQTT connected (no state pushed yet — printer may be idle)'));
    else console.log(bad(`MQTT failed — ${m.status?.error || 'no connection'}`));
  }

  if (action === 'send') {
    const sample = path.join(root, 'output', 'sample_rectangle.gcode');
    if (!fs.existsSync(sample)) {
      console.log(bad('No output/sample_rectangle.gcode — run `npm run gen` first'));
    } else {
      console.log('  uploading and starting a real print…');
      const r = await sendToPrinter(p, sample, { ...cfg, integrations: { ...cfg.integrations, lan: { ...cfg.integrations.lan, enabled: true } } });
      console.log(r.sent ? ok(`print started from ${r.remotePath}`) : bad(`send failed at ${r.stage || '?'} — ${r.error || r.reason}`));
    }
  }
}
console.log('\nDone.');
process.exit(0);
