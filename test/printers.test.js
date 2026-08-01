import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { maskCode, publicPrinters, savePrinter, checkPrinter, configPath } from '../src/printers.js';

// Setting a printer up used to mean four positional arguments in a terminal.
// These cover the pieces the dashboard now drives instead.

test('access codes are never handed back out', () => {
  assert.equal(maskCode('e94e9beb'), 'e9••••••');
  assert.equal(maskCode(''), '');
  assert.equal(maskCode(null), '');

  const cfg = { integrations: { printers: [{ id: 'A1-1', name: 'P1', ip: '10.0.0.1', serial: 'S1', accessCode: 'secret99' }] } };
  const shown = publicPrinters(cfg);
  const json = JSON.stringify(shown);
  assert.ok(!json.includes('secret99'), 'the code itself is not in what the dashboard receives');
  assert.equal(shown[0].accessCodeMask, 'se••••••');
  assert.equal(shown[0].configured, true);
});

test('empty slots are still listed, so all three can be set up', () => {
  const shown = publicPrinters({ integrations: { printers: [] } });
  assert.equal(shown.length, 3);
  assert.deepEqual(shown.map((p) => p.id), ['A1-1', 'A1-2', 'A1-3']);
  assert.deepEqual(shown.map((p) => p.configured), [false, false, false]);
});

// --- saving, against a real config.json in a scratch copy of the repo ---

function withScratchConfig(fn) {
  const file = configPath();
  const had = fs.existsSync(file);
  const backup = had ? fs.readFileSync(file, 'utf8') : null;
  try {
    if (had) fs.rmSync(file);
    return fn();
  } finally {
    if (had) fs.writeFileSync(file, backup);
    else if (fs.existsSync(file)) fs.rmSync(file);
  }
}

test('saving a printer creates config.json and turns LAN on', () => {
  withScratchConfig(() => {
    const cfg = { integrations: {} };
    const saved = savePrinter(cfg, { slot: 1, ip: '192.168.10.105', serial: '0309BA46', accessCode: 'e94e9beb' });
    assert.equal(saved.ip, '192.168.10.105');
    assert.equal(cfg.integrations.lan.enabled, true, 'LAN auto-send is switched on by setting a printer up');

    const onDisk = JSON.parse(fs.readFileSync(configPath(), 'utf8'));
    assert.equal(onDisk.integrations.printers[0].accessCode, 'e94e9beb');
    assert.equal(onDisk.integrations.lan.enabled, true);
    assert.ok(onDisk.build, 'the rest of the config came from the example');
  });
});

test('a blank access code keeps the stored one', () => {
  withScratchConfig(() => {
    const cfg = { integrations: {} };
    savePrinter(cfg, { slot: 2, ip: '10.0.0.9', serial: 'SN9', accessCode: 'keepme12' });
    // the dashboard never receives the code, so correcting the IP sends it blank
    savePrinter(cfg, { slot: 2, ip: '10.0.0.10', serial: 'SN9', accessCode: '' });

    const p = JSON.parse(fs.readFileSync(configPath(), 'utf8')).integrations.printers[1];
    assert.equal(p.ip, '10.0.0.10', 'the corrected IP was saved');
    assert.equal(p.accessCode, 'keepme12', 'and the code survived');
  });
});

test('nonsense is refused rather than written', () => {
  withScratchConfig(() => {
    const cfg = { integrations: {} };
    assert.throws(() => savePrinter(cfg, { slot: 0, ip: '10.0.0.1' }), /slot/);
    assert.throws(() => savePrinter(cfg, { slot: 9, ip: '10.0.0.1' }), /slot/);
    assert.throws(() => savePrinter(cfg, { slot: 1, ip: 'my-printer.local' }), /IP/);
    assert.ok(!fs.existsSync(configPath()), 'nothing was written');
  });
});

// --- checking ---

test('an unconfigured printer says what is missing, without touching the network', async () => {
  const r = await checkPrinter({ id: 'A1-3', name: 'P3', ip: '', serial: '', accessCode: '' });
  assert.equal(r.ok, false);
  const text = r.findings.map((f) => f.msg).join(' | ');
  assert.match(text, /IP/);
  assert.match(text, /serial/);
  assert.match(text, /access code/);
  for (const f of r.findings) assert.ok(f.hint, `"${f.msg}" should say where to find it`);
});

test('an unreachable printer explains itself instead of just failing', async () => {
  // 203.0.113.0 is reserved for documentation and never routes anywhere
  const r = await checkPrinter({ id: 'A1-1', name: 'P1', ip: '203.0.113.0', serial: 'S', accessCode: 'c' });
  assert.equal(r.ok, false);
  const bad = r.findings.filter((f) => f.ok === false);
  assert.ok(bad.length, 'reported a problem');
  assert.ok(bad.every((f) => f.hint), 'every problem comes with something to try');
  assert.match(bad.map((f) => f.hint).join(' '), /LAN Mode/i);
});

test('a live status reading is reported back', async () => {
  const r = await checkPrinter({ id: 'A1-1', name: 'P1', ip: '203.0.113.0', serial: 'S', accessCode: 'c' },
    { state: 'RUNNING', percent: 42 });
  assert.match(r.findings.map((f) => f.msg).join(' '), /RUNNING 42%/);
});

test('the example config ships three empty slots for the dashboard to fill', () => {
  const example = JSON.parse(fs.readFileSync(path.join(path.dirname(configPath()), 'config.example.json'), 'utf8'));
  assert.equal(example.integrations.printers.length, 3);
  for (const p of example.integrations.printers) assert.equal(p.accessCode, '', 'no access code is committed to the repo');
});
