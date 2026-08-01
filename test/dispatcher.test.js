import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { Queue } from '../src/dispatch/queue.js';
import { createDispatcher } from '../src/dispatch/dispatcher.js';

// The dispatcher is exercised through a real Queue on a scratch directory, with
// only the printer transport stubbed — that is the part that needs hardware.

function scratchQueue() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), '3dipad-test-'));
  fs.mkdirSync(path.join(root, 'output'), { recursive: true });
  return { root, queue: new Queue(root), outDir: path.join(root, 'output') };
}

let nextSeq = 0;
function addJob(queue, name = 'Kid') {
  const seq = ++nextSeq;
  return queue.add({ id: 'j' + seq, seq, contact: { name }, colours: { layer1: 'BLUE', layer2: 'BLACK' }, filename: `f${seq}.gcode`, printerId: null });
}

/** Let the background uploads kicked off by submit() settle. */
const settle = () => new Promise((r) => setTimeout(r, 5));

const PRINTERS = [
  { id: 'A1-1', name: 'Printer 1', ip: '10.0.0.1', serial: 'S1', accessCode: 'c' },
  { id: 'A1-2', name: 'Printer 2', ip: '10.0.0.2', serial: 'S2', accessCode: 'c' },
];

/**
 * A dispatcher whose printer transport is faked, recording every call.
 * autoDispatch is switched on here because these tests are about the automatic
 * path; the booth default is off, covered separately at the bottom.
 */
function harness(printers = PRINTERS, sendImpl) {
  const { root, queue, outDir } = scratchQueue();
  const sends = [];
  const cfg = { integrations: { lan: { enabled: true, autoDispatch: true }, printers } };
  const transport = async (printer, filePath, _cfg, opts) => {
    sends.push({ printer: printer.id, seq: opts.sequenceId });
    return sendImpl ? sendImpl(printer, opts) : { ok: true, sent: true, remotePath: '/sdcard/x.gcode' };
  };
  const dispatcher = createDispatcher({ cfg, queue, outDir, transport });
  return { root, queue, cfg, dispatcher, sends };
}

test('a job submitted while every printer is busy waits instead of vanishing', async () => {
  const { queue, dispatcher, sends } = harness([PRINTERS[0]]);
  const first = addJob(queue, 'Ada');
  assert.ok(dispatcher.submit(first), 'the first job gets the printer');
  await settle();

  const second = addJob(queue, 'Bo');
  assert.equal(dispatcher.submit(second), null, 'no printer free for the second');
  assert.equal(queue.get(second.id).status, 'queued', 'it stays in the queue');
  assert.equal(sends.length, 1, 'nothing was sent for it yet');
});

test('a queued job goes as soon as a printer frees up', async () => {
  const { queue, dispatcher, sends } = harness([PRINTERS[0]]);
  const first = addJob(queue, 'Ada');
  dispatcher.submit(first);
  await settle();
  const second = addJob(queue, 'Bo');
  dispatcher.submit(second);

  // the printer finishes — this is what the monitor reports
  queue.setStatus(first.id, 'ready');
  await dispatcher.pump();

  assert.equal(queue.get(second.id).status, 'printing', 'the waiting job went on the freed printer');
  assert.equal(queue.get(second.id).printerId, 'A1-1');
  assert.deepEqual(sends.map((s) => s.seq), [first.seq, second.seq]);
});

test('the longest-waiting kid goes first', async () => {
  const { queue, dispatcher, sends } = harness([PRINTERS[0]]);
  const running = addJob(queue, 'Ada');
  dispatcher.submit(running);
  await settle();
  const bo = addJob(queue, 'Bo');
  const cy = addJob(queue, 'Cy');
  dispatcher.submit(bo); dispatcher.submit(cy);

  queue.setStatus(running.id, 'ready');
  await dispatcher.pump();
  assert.equal(queue.get(bo.id).status, 'printing', 'Bo waited longer than Cy');
  assert.equal(queue.get(cy.id).status, 'queued');
  assert.equal(sends[sends.length - 1].seq, bo.seq);
});

test('two free printers take two jobs', async () => {
  const { queue, dispatcher } = harness();
  const a = addJob(queue, 'Ada');
  const b = addJob(queue, 'Bo');
  const c = addJob(queue, 'Cy');
  dispatcher.submit(a); dispatcher.submit(b); dispatcher.submit(c);
  await settle();

  const on = (id) => queue.get(id).printerId;
  assert.equal(queue.get(a.id).status, 'printing');
  assert.equal(queue.get(b.id).status, 'printing');
  assert.notEqual(on(a.id), on(b.id), 'they went to different printers');
  assert.equal(queue.get(c.id).status, 'queued', 'the third waits for one to finish');
});

test('a failed send puts the job back in the queue, not on the floor', async () => {
  let attempt = 0;
  const { queue, dispatcher } = harness([PRINTERS[0]], () => {
    attempt++;
    return attempt === 1 ? { ok: false, sent: false, stage: 'upload', error: 'connection reset' } : { ok: true, sent: true };
  });
  const job = addJob(queue, 'Ada');
  dispatcher.submit(job);
  await settle();

  assert.equal(queue.get(job.id).status, 'queued', 'back in the queue after the failure');
  assert.equal(queue.get(job.id).printerId, null, 'and the printer is released');
  assert.equal(attempt, 1, 'it did not immediately hammer the same broken printer');

  await dispatcher.pump(); // the next nudge — a printer freeing, or the operator
  assert.equal(queue.get(job.id).status, 'printing', 'the retry got it printing');
  assert.equal(attempt, 2);
});

test('a printer that fails every time does not spin the whole queue', async () => {
  let attempts = 0;
  const { queue, dispatcher } = harness([PRINTERS[0]], () => {
    attempts++;
    return { ok: false, sent: false, stage: 'upload', error: 'printer is switched off' };
  });
  const job = addJob(queue, 'Ada');
  dispatcher.submit(job);
  await settle();
  for (let i = 0; i < 10; i++) await dispatcher.pump();

  assert.equal(attempts, 3, 'gives up after the attempt cap instead of retrying for ever');
  assert.equal(queue.get(job.id).status, 'queued', 'the job is still there for the operator');
  assert.equal(queue.get(job.id).dispatchAttempts, 3);
});

test('overlapping pumps never hand the same job to two printers', async () => {
  const { queue, dispatcher, sends } = harness();
  addJob(queue, 'Ada');
  addJob(queue, 'Bo');
  // several finishes landing at once, as when printers sync up
  await Promise.all([dispatcher.pump(), dispatcher.pump(), dispatcher.pump()]);

  const seen = sends.map((s) => s.seq);
  assert.equal(new Set(seen).size, seen.length, `a job was dispatched twice: ${seen.join(', ')}`);
  assert.equal(seen.length, 2, 'both jobs went out exactly once');
});

test('with no printers configured the queue simply holds everything', async () => {
  const { queue, dispatcher, sends } = harness([]);
  const job = addJob(queue, 'Ada');
  assert.equal(dispatcher.submit(job), null);
  await dispatcher.pump();
  assert.equal(queue.get(job.id).status, 'queued');
  assert.equal(sends.length, 0);
});

// --- did it actually start? -------------------------------------------------
//
// The printer sends no acknowledgement of the start command, so "the command
// went out" and "the print began" are different facts. The file is on the SD
// card either way, which is why a print that never starts looks exactly like a
// successful send until someone walks over and looks at the printer.

test('a print that never starts is caught and handed back to the operator', async () => {
  const { queue, dispatcher } = harness([PRINTERS[0]]);
  let asked = 0;
  const confirm = () => { asked++; return Promise.resolve(false); };
  const d2 = createDispatcher({
    cfg: { integrations: { lan: { enabled: true, autoDispatch: true }, printers: [PRINTERS[0]] } },
    queue, outDir: '/tmp', confirmStart: confirm,
    transport: async () => ({ ok: true, sent: true, remotePath: '/sdcard/x.gcode' }),
  });
  const job = addJob(queue, 'Ada');
  d2.submit(job);
  await settle();

  assert.equal(asked, 1, 'the printer state was checked');
  const after = queue.get(job.id);
  assert.equal(after.status, 'assigned', 'left assigned for a manual start, not reported as printing');
  assert.equal(after.printerId, 'A1-1', 'and still on the printer holding its file');
  assert.equal(after.dispatch.uploaded, true, 'the record says the file did reach the SD card');
});

test('a confirmed start stays printing', async () => {
  const { queue } = harness([PRINTERS[0]]);
  const d2 = createDispatcher({
    cfg: { integrations: { lan: { enabled: true, autoDispatch: true }, printers: [PRINTERS[0]] } },
    queue, outDir: '/tmp', confirmStart: () => Promise.resolve(true),
    transport: async () => ({ ok: true, sent: true, remotePath: '/sdcard/x.gcode' }),
  });
  const job = addJob(queue, 'Bo');
  d2.submit(job);
  await settle();
  assert.equal(queue.get(job.id).status, 'printing');
});

test('confirmation does not hold up the other printers', async () => {
  // It waits tens of seconds for the printer to turn over; the queue must not.
  const { queue } = harness();
  let released;
  const slow = () => new Promise((r) => { released = r; });
  const d2 = createDispatcher({
    cfg: { integrations: { lan: { enabled: true, autoDispatch: true }, printers: PRINTERS } },
    queue, outDir: '/tmp', confirmStart: slow,
    transport: async () => ({ ok: true, sent: true, remotePath: '/sdcard/x.gcode' }),
  });
  const a = addJob(queue, 'Ada');
  const b = addJob(queue, 'Bo');
  d2.submit(a);
  await settle();
  d2.submit(b);
  await settle();

  assert.equal(queue.get(a.id).status, 'printing');
  assert.equal(queue.get(b.id).status, 'printing', 'the second printer was fed while the first was still unconfirmed');
  released(true);
});

test('the monitor seeing the print run beats a late confirmation timeout', async () => {
  const { queue } = harness([PRINTERS[0]]);
  let release;
  const d2 = createDispatcher({
    cfg: { integrations: { lan: { enabled: true, autoDispatch: true }, printers: [PRINTERS[0]] } },
    queue, outDir: '/tmp',
    confirmStart: () => new Promise((r) => { release = r; }),
    transport: async () => ({ ok: true, sent: true, remotePath: '/sdcard/x.gcode' }),
  });
  const job = addJob(queue, 'Ada');
  d2.submit(job);
  await settle();
  // the colour-change pause arrives before confirmation gives up
  queue.setStatus(job.id, 'colour_change');
  release(false);
  await settle();
  assert.equal(queue.get(job.id).status, 'colour_change', 'a stale timeout must not clobber real progress');
});

// --- the booth default: nothing moves without an operator -------------------
//
// Every printer holds particular filament, so which machine a job goes to is a
// decision about colour. Sending to "whichever is free" is exactly how a kid's
// drawing comes out in the wrong colour, so by default it does not happen.

function manualHarness(printers = PRINTERS) {
  const { queue, outDir } = scratchQueue();
  const sends = [];
  const cfg = { integrations: { lan: { enabled: true }, printers } };  // autoDispatch absent
  const dispatcher = createDispatcher({
    cfg, queue, outDir,
    transport: async (printer, _f, _c, opts) => {
      sends.push({ printer: printer.id, seq: opts.sequenceId });
      return { ok: true, sent: true, remotePath: '/sdcard/x.gcode' };
    },
  });
  return { queue, dispatcher, sends, cfg };
}

test('a submitted job waits in the queue, even with a printer sitting idle', async () => {
  const { queue, dispatcher, sends } = manualHarness();
  const job = addJob(queue, 'Ada');
  assert.equal(dispatcher.submit(job), null, 'no printer is reserved');
  await settle();
  assert.equal(queue.get(job.id).status, 'queued');
  assert.equal(queue.get(job.id).printerId, null);
  assert.equal(sends.length, 0, 'nothing was uploaded anywhere');
});

test('a printer finishing does not pull the next job onto it', async () => {
  const { queue, dispatcher, sends } = manualHarness();
  const first = addJob(queue, 'Ada');
  const second = addJob(queue, 'Bo');
  await dispatcher.send(first, PRINTERS[0]);      // operator sends the first
  assert.equal(sends.length, 1);

  queue.setStatus(first.id, 'ready');             // it finishes
  await dispatcher.pump();
  await settle();

  assert.equal(queue.get(second.id).status, 'queued', 'the next kid still waits for a person');
  assert.equal(sends.length, 1, 'and nothing was sent');
});

test('the operator sending it explicitly does upload and start it', async () => {
  const { queue, dispatcher, sends } = manualHarness();
  const job = addJob(queue, 'Ada');
  dispatcher.submit(job);
  await settle();

  // this is what the dashboard's printer button does
  const r = await dispatcher.send(job, PRINTERS[1]);
  assert.equal(r.sent, true);
  assert.equal(queue.get(job.id).status, 'printing');
  assert.equal(queue.get(job.id).printerId, 'A1-2', 'onto the printer that was chosen, not the first free one');
  assert.deepEqual(sends, [{ printer: 'A1-2', seq: job.seq }]);
});

test('the automatic path is still there when it is asked for', async () => {
  const { queue, dispatcher, cfg } = manualHarness();
  cfg.integrations.lan.autoDispatch = true;
  const job = addJob(queue, 'Ada');
  assert.ok(dispatcher.submit(job), 'now it reserves a printer');
  await settle();
  assert.equal(queue.get(job.id).status, 'printing');
});

// --- history ----------------------------------------------------------------
//
// Jobs do not stop being useful when they are collected: a print fails, a plate
// gets knocked, a parent loses the keychain on the way home. The g-code is still
// on disk, so the operator needs to find the old job and run it again.

test('history keeps collected and failed jobs that the active view drops', () => {
  const { queue } = scratchQueue();
  const a = addJob(queue, 'Ada');
  const b = addJob(queue, 'Bo');
  const c = addJob(queue, 'Cy');
  queue.setStatus(a.id, 'collected');
  queue.setStatus(b.id, 'failed');

  assert.deepEqual(queue.active().map((j) => j.contact.name), ['Cy'], 'the operator view shows only live work');
  assert.deepEqual(queue.history().map((j) => j.contact.name), ['Cy', 'Bo', 'Ada'], 'history keeps everything, newest first');
});

test('history is capped so a long day does not ship the lot', () => {
  const { queue } = scratchQueue();
  for (let i = 0; i < 40; i++) addJob(queue, 'Kid' + i);
  assert.equal(queue.history(10).length, 10);
  assert.equal(queue.history(10)[0].contact.name, 'Kid39', 'the cap keeps the newest');
  assert.equal(queue.history().length, 40, 'and the default is generous enough for a fair');
});

test('a collected job can be sent to a printer again', async () => {
  const { queue, dispatcher, sends } = manualHarness();
  const job = addJob(queue, 'Ada');
  queue.setStatus(job.id, 'collected');

  await dispatcher.send(job, PRINTERS[0]);
  assert.equal(queue.get(job.id).status, 'printing', 'it comes back out of history and prints');
  assert.equal(sends.length, 1);
});

test('an old job can be run again without rewriting what happened to it', () => {
  const { queue: q } = scratchQueue();
  const first = q.add({ id: 'j1', seq: q.nextSeq(), filename: 'RED-BLUE_0001.gcode', contact: { name: 'Ana' }, colours: { layer1: 'RED', layer2: 'BLUE' }, printerId: null });
  q.setStatus(first.id, 'printing', { printerId: 'A1-1' });
  q.setStatus(first.id, 'ready', { notify: { ok: true } });
  q.setStatus(first.id, 'collected');

  const again = q.reprint(first.id);
  assert.ok(again, 'reprint returns the new job');
  assert.notEqual(again.id, first.id, 'a new job, not the old one moved back');
  assert.equal(again.status, 'queued');
  assert.equal(again.filename, first.filename, 'points at the g-code already on disk');
  assert.equal(again.reprintOf, first.id);
  assert.equal(again.printerId, null, 'not still on the printer it used last time');
  assert.equal(again.notify, null, 'the first run notified — this one has not');
  assert.equal(again.history.length, 1, 'its own history starts here');

  // the original is untouched: it really was collected
  assert.equal(q.get(first.id).status, 'collected');
  assert.equal(q.get(first.id).printerId, 'A1-1');

  // and it shows on the live board again, which history alone did not
  assert.ok(q.active().some((j) => j.id === again.id));
  assert.ok(!q.active().some((j) => j.id === first.id));

  // a reprint of a reprint still points back at the original
  assert.equal(q.reprint(again.id).reprintOf, first.id);
  assert.equal(q.reprint('nope'), null);
});
