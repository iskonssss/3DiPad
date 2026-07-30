// Fill in a printer's LAN details without hand-editing JSON.
//
//   node tools/set-printer.mjs <slot> <ip> <serial> <accessCode> [name]
//
// e.g.  node tools/set-printer.mjs 1 192.168.10.105 0309BA461400280 e94e9beb
//       node tools/set-printer.mjs 2 192.168.10.106 0309BA461400281 a1b2c3d4 "Printer 2"
//
// Creates config.json from config.example.json on first run, turns LAN mode on,
// and writes the details into printer slot <slot> (1, 2 or 3).
// config.json is git-ignored, so access codes never reach the repository.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const cfgPath = path.join(root, 'config.json');
const examplePath = path.join(root, 'config.example.json');

const [slotArg, ip, serial, accessCode, nameArg] = process.argv.slice(2);

function usage(msg) {
  if (msg) console.error('Error: ' + msg + '\n');
  console.error('Usage: node tools/set-printer.mjs <slot 1-3> <ip> <serial> <accessCode> [name]');
  console.error('e.g.   node tools/set-printer.mjs 1 192.168.10.105 0309BA461400280 e94e9beb');
  process.exit(1);
}

const slot = Number(slotArg);
if (!Number.isInteger(slot) || slot < 1 || slot > 3) usage('slot must be 1, 2 or 3');
if (!ip || !/^\d{1,3}(\.\d{1,3}){3}$/.test(ip)) usage('ip must look like 192.168.10.105');
if (!serial) usage('serial is required (printer screen: Settings > Device)');
if (!accessCode) usage('accessCode is required (printer screen: Settings > Network, LAN mode)');

if (!fs.existsSync(cfgPath)) {
  fs.copyFileSync(examplePath, cfgPath);
  console.log('created config.json from config.example.json');
}

const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
cfg.integrations = cfg.integrations || {};
cfg.integrations.lan = cfg.integrations.lan || {};
cfg.integrations.lan.enabled = true;
cfg.integrations.printers = cfg.integrations.printers || [];
while (cfg.integrations.printers.length < slot) {
  const n = cfg.integrations.printers.length + 1;
  cfg.integrations.printers.push({ id: `A1-${n}`, name: `Printer ${n}`, ip: '', serial: '', accessCode: '' });
}

const existing = cfg.integrations.printers[slot - 1] || {};
cfg.integrations.printers[slot - 1] = {
  id: existing.id || `A1-${slot}`,
  name: nameArg || existing.name || `Printer ${slot}`,
  ip,
  serial,
  accessCode,
};

fs.writeFileSync(cfgPath, JSON.stringify(cfg, null, 2) + '\n');

const mask = (s) => s.slice(0, 2) + '*'.repeat(Math.max(0, s.length - 2));
const p = cfg.integrations.printers[slot - 1];
console.log(`\nSlot ${slot} set: ${p.name} (${p.id})`);
console.log(`  ip          ${p.ip}`);
console.log(`  serial      ${p.serial}`);
console.log(`  accessCode  ${mask(p.accessCode)}`);
console.log(`  LAN mode    enabled`);
const ready = cfg.integrations.printers.filter((q) => q.ip && q.serial && q.accessCode).length;
console.log(`\n${ready} printer(s) configured. Next:  npm run test-printer\n`);
