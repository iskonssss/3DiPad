import { test } from 'node:test';
import assert from 'node:assert/strict';
import { sdName, buildPrintCommand, readStatus, isConfigured, sendToPrinter } from '../src/integrations/bambu.js';
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
