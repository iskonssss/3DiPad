import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

/**
 * The PIN in front of the send-to-printer panel.
 *
 * This is a lock on a booth, not on a bank: it stops the child who watched an
 * adult hold the corner button and wants a turn. The properties that actually
 * matter for that are small and worth pinning down, because getting any of them
 * wrong either lets every child in or locks the operator out mid-queue.
 */

// The endpoint, lifted out of the server so it can be exercised without booting
// the booth (which opens MQTT connections to printers that are not here).
function loadUnlock({ pin = '', lockMinutes = 10, now = () => Date.now() } = {}) {
  const src = fs.readFileSync(path.join(root, 'src/server.js'), 'utf8');
  const from = src.indexOf('const pinTries = new Map();');
  const to = src.indexOf('app.post(\'/api/estimate\'');
  assert.ok(from >= 0 && to > from, 'the unlock endpoint moved');
  let body = src.slice(from, to);

  let handler = null;
  const app = { post: (_route, h) => { handler = h; } };
  const cfg = { operator: { lockMinutes } };
  const operatorPin = () => pin;
  // Real clock in the handler, faked only where the test needs to move time.
  const RealDate = Date;
  const FakeDate = class extends RealDate { static now() { return now(); } };
  new Function('app', 'cfg', 'operatorPin', 'Date', body)(app, cfg, operatorPin, FakeDate);

  return async (reqBody, ip = '1.1.1.1') => {
    let code = 200, payload = null;
    const res = {
      status(c) { code = c; return this; },
      json(o) { payload = o; return this; },
    };
    await handler({ body: reqBody, ip }, res);
    return { code, ...payload };
  };
}

test('with no PIN set, the hold is the whole lock', async () => {
  const unlock = loadUnlock({ pin: '' });
  const r = await unlock({});
  assert.equal(r.ok, true);
  assert.equal(r.pinRequired, false);
});

test('an empty body asks whether a PIN is wanted, and is not a guess', async () => {
  const unlock = loadUnlock({ pin: '2468' });
  // Opening the panel six times must not lock the operator out of their booth.
  for (let i = 0; i < 6; i++) {
    const r = await unlock({});
    assert.equal(r.ok, false);
    assert.equal(r.pinRequired, true);
    assert.equal(r.code, 200, 'a probe is not a failed attempt');
  }
  assert.equal((await unlock({ pin: '2468' })).ok, true, 'the real PIN still works after six probes');
});

test('the right PIN opens it and the wrong one does not', async () => {
  const unlock = loadUnlock({ pin: '2468' });
  assert.equal((await unlock({ pin: '1111' })).ok, false);
  assert.equal((await unlock({ pin: '2468' })).ok, true);
  // A number and a string of digits are not the same thing over JSON.
  assert.equal((await unlock({ pin: 2468 })).ok, true, 'a numeric PIN must still match');
});

test('guessing shuts the door, and says so on the guess that shuts it', async () => {
  const unlock = loadUnlock({ pin: '2468' });
  for (let i = 0; i < 4; i++) {
    const r = await unlock({ pin: '0000' });
    assert.equal(r.code, 401, `try ${i + 1} should just be wrong`);
  }
  const fifth = await unlock({ pin: '0000' });
  assert.equal(fifth.code, 429, 'the fifth wrong guess must lock out');
  assert.ok(fifth.retryInSec > 0, 'and say how long for');
  // Even the correct PIN waits out the lockout.
  assert.equal((await unlock({ pin: '2468' })).code, 429);
});

test('one tablet guessing does not lock out the other', async () => {
  const unlock = loadUnlock({ pin: '2468' });
  for (let i = 0; i < 5; i++) await unlock({ pin: '0000' }, '10.0.0.9');
  assert.equal((await unlock({ pin: '0000' }, '10.0.0.9')).code, 429);
  assert.equal((await unlock({ pin: '2468' }, '10.0.0.10')).ok, true, 'the operator iPad is unaffected');
});

test('the PIN is never built into the page the tablets load', () => {
  const build = fs.readFileSync(path.join(root, 'tools/build-kiosk.mjs'), 'utf8');
  assert.match(build, /SERVER_ONLY\s*=\s*\[[^\]]*'operator'/, 'operator config must be stripped from the build');
  for (const f of ['public/index.html', 'public/standalone.html']) {
    const page = fs.readFileSync(path.join(root, f), 'utf8');
    assert.ok(!/"operator"\s*:/.test(page), `${f} carries the operator block`);
    assert.ok(!page.includes('BOOTH_ADMIN_PIN'), `${f} names the PIN env var`);
  }
});

test('the kiosk asks the server about the PIN rather than being told in advance', () => {
  const kiosk = fs.readFileSync(path.join(root, 'src/kiosk/kiosk.html'), 'utf8');
  assert.match(kiosk, /api\/admin\/unlock/, 'the kiosk must verify against the server');
  // A client-side comparison would put the PIN in the page, which is the one
  // thing this design exists to avoid.
  assert.ok(!/CFG\.operator|operator\.pin\b/.test(kiosk), 'the kiosk must not read a PIN out of its config');
});
