import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

/**
 * "I have cleared the bed — this printer is ready."
 *
 * A Bambu does not leave FAILED on its own. It accepts `stop`, answers
 * "success", and goes on reporting FAILED and naming the job that died. The
 * board repeated that faithfully, so a machine standing empty and willing
 * showed up red for the rest of the day and the operator who had already
 * scraped the plate had no way to say so.
 */

/** The endpoint, lifted out of the server so it runs without opening MQTT. */
function loadReset({ state = 'FAILED', live = true, job = null, published = { ok: true } } = {}) {
  const src = fs.readFileSync(path.join(root, 'src/server.js'), 'utf8');
  const from = src.indexOf("app.post('/api/printers/:id/reset'");
  const to = src.indexOf("app.post('/api/jobs/:id/status'");
  assert.ok(from >= 0 && to > from, 'the reset endpoint moved');

  const calls = { stopped: 0, acknowledged: [], pumped: 0, status: [] };
  const states = live ? { 'A1-1': { state, file: 'PINK-BLACK_0009.gcode' } } : {};
  let handler = null;

  new Function('app', 'cfg', 'monitor', 'queue', 'dispatcher', 'publishCommand', 'buildStopCommand', 'console', 'calls',
    src.slice(from, to))(
    { post: (_r, h) => { handler = h; } },
    { integrations: { printers: [{ id: 'A1-1', name: 'Printer 1' }] } },
    {
      states: () => states,
      acknowledge: (id) => { calls.acknowledged.push(id); const a = { state: states[id]?.state, at: 'now' }; states[id].acknowledged = a; return a; },
    },
    {
      active: () => (job ? [job] : []),
      setStatus: (id, s, extra) => { calls.status.push([id, s, extra]); },
    },
    { pump: () => { calls.pumped++; } },
    async () => { calls.stopped++; return published; },
    () => ({ print: { command: 'stop' } }),
    { log: () => {} },
    calls,
  );

  return async (id = 'A1-1') => {
    let code = 200, payload = null;
    await handler({ params: { id } }, { status(c) { code = c; return this; }, json(o) { payload = o; return this; } });
    return { code, calls, states, ...payload };
  };
}

test('clearing a failed printer frees it, and the printer is still told to stop', async () => {
  const r = await (loadReset({ state: 'FAILED' }))();
  assert.equal(r.ok, true);
  assert.equal(r.was, 'FAILED');
  assert.equal(r.calls.stopped, 1, 'the stop should still go out — sometimes it does take');
  assert.deepEqual(r.calls.acknowledged, ['A1-1']);
  assert.equal(r.calls.pumped, 1, 'a freed printer should pull the next job');
});

test('a printer that is genuinely printing is not reset out from under the print', async () => {
  for (const state of ['RUNNING', 'PREPARE', 'SLICING']) {
    const r = await (loadReset({ state }))();
    assert.equal(r.ok, false, `${state} must be refused`);
    assert.equal(r.code, 409);
    assert.match(r.error, /Stop first/);
    assert.equal(r.calls.stopped, 0, 'nothing should be sent to a printing machine');
  }
});

test('a printer we cannot see is not pretended to be ready', async () => {
  const r = await (loadReset({ live: false }))();
  assert.equal(r.ok, false);
  assert.equal(r.code, 409);
  assert.match(r.error, /no status/);
});

test('the job stuck on the printer is released so it can be sent again', async () => {
  const job = { id: 'j9', printerId: 'A1-1', status: 'printing', filename: 'PINK-BLACK_0009.gcode' };
  const r = await (loadReset({ job }))();
  assert.equal(r.released, 'PINK-BLACK_0009.gcode');
  assert.deepEqual(r.calls.status[0].slice(0, 2), ['j9', 'failed']);
});

test('a reset still works when the printer will not take the stop', async () => {
  // The commonest case there is: it answers success and stays FAILED. Whether
  // the stop lands has no bearing on whether the operator cleared the bed.
  const r = await (loadReset({ published: { ok: false, error: 'MQTT publish timeout' } }))();
  assert.equal(r.ok, true, 'the operator\'s word does not depend on the printer agreeing');
  assert.deepEqual(r.calls.acknowledged, ['A1-1']);
});

/**
 * The dismissal must never be able to hide the *next* failure — that would turn
 * a nuisance into a machine quietly sitting broken while the board says READY.
 */
test('any new word from the printer drops the operator dismissal', () => {
  const src = fs.readFileSync(path.join(root, 'src/dispatch/monitor.js'), 'utf8');
  const cb = src.slice(src.indexOf('const h = watchPrinter('), src.indexOf('handles.push(h)'));
  assert.match(cb, /status\.state !== prev\.state/, 'the drop must hang off a real state change');
  assert.match(cb, /delete states\[printer\.id\]\.acknowledged/, 'a state change must clear the dismissal');

  // And the pre-send check must honour it. The tile said READY on the
  // operator's word while the send refused on the printer's, and "NOT SENT —
  // holding a FAILED job" came back after every Bed-cleared press.
  const srv = fs.readFileSync(path.join(root, 'src/server.js'), 'utf8');
  const from = srv.indexOf('function clearBeforeSend');
  const body = srv.slice(from, srv.indexOf('const dispatcher = createDispatcher', from));
  assert.match(body, /acknowledged\)\s*return \{ needed: false/, 'an acknowledged printer is not cleared or blocked');
  // and it must happen before the transition is acted on, so nothing downstream
  // sees a stale acknowledgement
  assert.ok(cb.indexOf('delete states') < cb.indexOf('applyTransition'), 'clear it before acting on the change');
});
