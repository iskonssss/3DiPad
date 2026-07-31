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

/** A dispatcher whose printer transport is faked, recording every call. */
function harness(printers = PRINTERS, sendImpl) {
  const { root, queue, outDir } = scratchQueue();
  const sends = [];
  const cfg = { integrations: { lan: { enabled: true }, printers } };
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
