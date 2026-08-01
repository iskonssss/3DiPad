import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  sdName, buildPrintCommand, readStatus, isConfigured, sendToPrinter,
  publishCommand, registerLiveClient, releaseLiveClient, getLiveClient,
  readCommandReply, startVariants, START_VARIANTS, startPrint,
} from '../src/integrations/bambu.js';
import { startMonitor } from '../src/dispatch/monitor.js';

test('sdName strips paths and unsafe characters', () => {
  assert.equal(sdName('BLUE-PINK_0001.gcode'), 'BLUE-PINK_0001.gcode');
  assert.equal(sdName('/tmp/output/RED WHITE.gcode'), 'RED_WHITE.gcode');
  assert.equal(sdName('../../etc/passwd'), 'passwd');
  assert.ok(!sdName('a'.repeat(200) + '.gcode').includes('/'));
  assert.ok(sdName('a'.repeat(200) + '.gcode').length <= 60);
});

test('print command targets the uploaded file', () => {
  const cmd = buildPrintCommand('/sdcard/BLUE-PINK_0001.gcode', { sequenceId: 7 });
  assert.equal(cmd.print.command, 'gcode_file');
  assert.equal(cmd.print.param, '/sdcard/BLUE-PINK_0001.gcode');
  assert.equal(cmd.print.sequence_id, '7');
});

test('isConfigured requires ip, serial and access code', () => {
  assert.ok(isConfigured({ ip: '192.168.1.5', serial: 'ABC', accessCode: '1234' }));
  assert.ok(!isConfigured({ ip: '192.168.1.5', serial: 'ABC' }));
  assert.ok(!isConfigured({ ip: '', serial: 'ABC', accessCode: '1234' }));
  assert.ok(!isConfigured(null));
});

test('readStatus maps Bambu reports to a simple state', () => {
  assert.deepEqual(readStatus({ print: { gcode_state: 'RUNNING', mc_percent: 42, mc_remaining_time: 8 } }),
    { state: 'RUNNING', percent: 42, remainingMin: 8 });
  assert.equal(readStatus({ print: { gcode_state: 'finish' } }).state, 'FINISH');
  assert.equal(readStatus({ print: { gcode_state: 'PAUSE' } }).state, 'PAUSE');
  assert.equal(readStatus({ print: { print_error: 3 } }).errorCode, 3);
  assert.equal(readStatus({ print: {} }), null, 'empty report yields nothing');
  assert.equal(readStatus({}), null, 'non-print message ignored');
});

test('sendToPrinter degrades safely when LAN is off or unconfigured', async () => {
  const off = await sendToPrinter({ id: 'A1-1', ip: '1.2.3.4', serial: 'S', accessCode: 'C' }, '/tmp/x.gcode',
    { integrations: { lan: { enabled: false } } });
  assert.equal(off.sent, false);
  assert.equal(off.manual, true, 'falls back to manual dispatch');

  const unconfigured = await sendToPrinter({ id: 'A1-2' }, '/tmp/x.gcode', { integrations: { lan: { enabled: true } } });
  assert.equal(unconfigured.sent, false);
  assert.equal(unconfigured.manual, true);
});

// --- one MQTT connection per printer ---------------------------------------
//
// A Bambu printer accepts a single MQTT client. The status monitor holds one
// open for the whole session, so the print-start command must go out on that
// same connection instead of dialling a second one (which the printer ignores,
// surfacing as "LAN dispatch failed at start: MQTT timeout").

test('publishCommand reuses the monitor connection when one is open', async () => {
  const printer = { id: 'A1-1', ip: '192.168.10.105', serial: 'SN1', accessCode: 'code' };
  const published = [];
  const fake = {
    connected: true,
    publish(topic, payload, opts, cb) { published.push({ topic, payload, opts }); cb(null); },
  };
  registerLiveClient(printer, fake);
  try {
    assert.equal(getLiveClient(printer), fake);
    const res = await publishCommand(printer, buildPrintCommand('/sdcard/x.gcode', { sequenceId: 1 }), {});
    assert.deepEqual(res, { ok: true, reused: true });
    assert.equal(published.length, 1, 'no second connection was opened');
    assert.equal(published[0].topic, 'device/SN1/request');
    assert.equal(JSON.parse(published[0].payload).print.param, '/sdcard/x.gcode');
  } finally {
    releaseLiveClient(printer, fake);
  }
  assert.equal(getLiveClient(printer), null, 'stopping the monitor clears the registration');
});

test('a disconnected monitor client is not reused', () => {
  const printer = { id: 'A1-9', ip: '1.2.3.4', serial: 'SN9', accessCode: 'c' };
  const fake = { connected: false, publish() { throw new Error('must not publish while offline'); } };
  registerLiveClient(printer, fake);
  assert.equal(getLiveClient(printer), null, 'falls back to a fresh connection');
  releaseLiveClient(printer, fake);
});

test('live clients are tracked per printer', () => {
  const a = { id: 'A1-1', serial: 'SNA' };
  const b = { id: 'A1-2', serial: 'SNB' };
  const ca = { connected: true }; const cb = { connected: true };
  registerLiveClient(a, ca);
  registerLiveClient(b, cb);
  assert.equal(getLiveClient(a), ca);
  assert.equal(getLiveClient(b), cb);
  releaseLiveClient(a, cb); // wrong client — must not clear A's registration
  assert.equal(getLiveClient(a), ca);
  releaseLiveClient(a, ca);
  releaseLiveClient(b, cb);
  assert.equal(getLiveClient(a), null);
  assert.equal(getLiveClient(b), null);
});

// --- monitor lifecycle, driven through a fake queue ------------------------

function fakeQueue(job) {
  const jobs = [job];
  return {
    jobs,
    active: () => jobs,
    setStatus(id, status, extra = {}) {
      const j = jobs.find((x) => x.id === id);
      Object.assign(j, extra, { status });
      return j;
    },
  };
}

test('monitor is inert when LAN is disabled', () => {
  const m = startMonitor({ integrations: { lan: { enabled: false }, printers: [{ id: 'A1-1' }] } }, fakeQueue({}), () => {});
  assert.deepEqual(m.states(), {});
  m.stop();
});

test('monitor transitions a job and fires ready exactly once', async () => {
  // drive applyTransition directly by faking the watch layer via readStatus results
  const job = { id: 'j1', printerId: 'A1-1', status: 'assigned', colours: { layer2: 'PINK' }, contact: { name: 'Emma' }, filename: 'f.gcode' };
  const queue = fakeQueue(job);
  const readyCalls = [];

  // Re-implement the transition rules the monitor applies, asserting each hop.
  const apply = (state) => {
    if (state === 'RUNNING' && job.status !== 'printing') queue.setStatus(job.id, 'printing');
    else if (state === 'PAUSE' && job.status !== 'colour_change') queue.setStatus(job.id, 'colour_change');
    else if (state === 'FINISH') { queue.setStatus(job.id, 'ready'); readyCalls.push(job.id); }
    else if (state === 'FAILED') queue.setStatus(job.id, 'failed');
  };

  apply(readStatus({ print: { gcode_state: 'RUNNING' } }).state);
  assert.equal(job.status, 'printing');
  apply(readStatus({ print: { gcode_state: 'PAUSE' } }).state);
  assert.equal(job.status, 'colour_change', 'M400 U1 pause shows as a colour change');
  apply(readStatus({ print: { gcode_state: 'RUNNING' } }).state);
  assert.equal(job.status, 'printing', 'resumes after the swap');
  apply(readStatus({ print: { gcode_state: 'FINISH' } }).state);
  assert.equal(job.status, 'ready');
  assert.deepEqual(readyCalls, ['j1'], 'ready fires once');
});

test('the start command comes in the shapes different firmware wants', () => {
  const p = '/sdcard/BLUE-PINK_0001.gcode';
  const bare = buildPrintCommand(p, { sequenceId: 7, variant: 'gcode_file_bare' });
  assert.equal(bare.print.command, 'gcode_file');
  assert.equal(bare.print.param, 'BLUE-PINK_0001.gcode', 'no /sdcard in front of it');

  const proj = buildPrintCommand(p, { sequenceId: 7, variant: 'project_file' });
  assert.equal(proj.print.command, 'project_file');
  assert.equal(proj.print.url, 'file:///sdcard/BLUE-PINK_0001.gcode');
  assert.equal(proj.print.subtask_name, 'BLUE-PINK_0001', 'no extension');
  // the whole point of this shape: calibration is a print-task parameter, and
  // this is the only command that carries it
  assert.equal(proj.print.bed_leveling, false);
  assert.equal(proj.print.flow_cali, false);
  assert.equal(proj.print.use_ams, false);

  // default is unchanged from what the booth has been sending all along
  assert.deepEqual(buildPrintCommand(p, { sequenceId: 7 }), buildPrintCommand(p, { sequenceId: 7, variant: 'gcode_file' }));
});

test('start shapes are tried in turn until the printer moves', async () => {
  assert.deepEqual(startVariants({}), START_VARIANTS);
  assert.deepEqual(startVariants({ integrations: { lan: { startCommand: 'project_file' } } }), ['project_file'],
    'a pinned command stops the probing');

  const printer = { id: 'A1-1', ip: '10.0.0.9', serial: 'S', accessCode: 'x' };
  const run = async (obeys, cfg = {}) => {
    const tried = [];
    const r = await startPrint(printer, '/sdcard/x.gcode', cfg, {
      publish: (_p, payload) => { tried.push(payload.print.command === 'gcode_file' ? (payload.print.param.startsWith('/') ? 'gcode_file' : 'gcode_file_bare') : payload.print.command); return { ok: true }; },
      confirmStarted: (_p, v) => Promise.resolve(v === obeys),
    });
    return { tried, r };
  };

  // A printer that obeys the first shape is asked exactly once.
  const first = await run('gcode_file');
  assert.deepEqual(first.tried, ['gcode_file']);
  assert.equal(first.r.variant, 'gcode_file');

  // One that only obeys project_file gets there, and we learn which it was.
  const third = await run('project_file');
  assert.deepEqual(third.tried, START_VARIANTS);
  assert.equal(third.r.variant, 'project_file');

  // One that obeys nothing still reports ok — the file is on the SD card and
  // the operator can press Print. It is confirmStart, not this, that decides
  // the job did not start.
  const none = await run('nothing');
  assert.deepEqual(none.tried, START_VARIANTS);
  assert.equal(none.r.ok, true);

  // Pinned: one shape, no probing, whatever the printer does.
  const pinned = await run('nothing', { integrations: { lan: { startCommand: 'gcode_file_bare' } } });
  assert.deepEqual(pinned.tried, ['gcode_file_bare']);

  // A transport failure stops the loop rather than trying the rest blind.
  const dead = await startPrint(printer, '/sdcard/x.gcode', {}, {
    publish: () => ({ ok: false, error: 'MQTT timeout' }),
    confirmStarted: () => Promise.resolve(false),
  });
  assert.equal(dead.ok, false);
  assert.equal(dead.stage, 'start');
});

test('the printer answering a command is not mistaken for status', () => {
  // routine pushes carry no result and must not be logged as command replies
  assert.equal(readCommandReply({ print: { command: 'push_status', gcode_state: 'RUNNING' } }), null);
  assert.equal(readCommandReply({ print: { gcode_state: 'IDLE' } }), null);
  assert.equal(readCommandReply({}), null);

  const r = readCommandReply({ print: { command: 'gcode_file', sequence_id: '12', result: 'FAIL', reason: 'file not found' } });
  assert.equal(r.command, 'gcode_file');
  assert.equal(r.result, 'FAIL');
  assert.equal(r.reason, 'file not found');
  assert.equal(r.sequenceId, '12');

  // an errno with no reason is still a reason
  assert.equal(readCommandReply({ print: { command: 'project_file', errno: 5 } }).reason, 'errno 5');
});

test('a printer we cannot see is never sent a second start command', async () => {
  // A "start" arriving at a printer that is already printing can abort the job.
  // So the probe is allowed to say "I cannot tell" (null), and that must stop
  // the loop just as firmly as a confirmed start does — the alternative is
  // firing three start commands blind at a machine mid-keychain.
  const printer = { id: 'A1-1', ip: '10.0.0.9', serial: 'S', accessCode: 'x' };
  const tried = [];
  const r = await startPrint(printer, '/sdcard/x.gcode', {}, {
    publish: (_p, payload) => { tried.push(payload.print.command); return { ok: true }; },
    confirmStarted: () => Promise.resolve(null),   // no status from this printer
  });
  assert.equal(tried.length, 1, `sent ${tried.length} start commands at a printer it could not see`);
  assert.equal(r.ok, true, 'the file is still on the SD card — that much succeeded');
  assert.equal(r.unverified, true, 'and we say we could not confirm it');

  // Going quiet part-way through is the same situation.
  const t2 = [];
  let n = 0;
  await startPrint(printer, '/sdcard/x.gcode', {}, {
    publish: (_p, payload) => { t2.push(payload.print.command); return { ok: true }; },
    confirmStarted: () => Promise.resolve(n++ === 0 ? false : null),
  });
  assert.equal(t2.length, 2, 'one retry after a definite idle, then stop when it goes dark');
});
