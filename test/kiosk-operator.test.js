import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const kiosk = fs.readFileSync(path.join(root, 'src/kiosk/kiosk.html'), 'utf8');
const dash = fs.readFileSync(path.join(root, 'dashboard/index.html'), 'utf8');

/**
 * The operator panel on the iPad and the board on the laptop both decide which
 * printers a job can be sent to, and they decide it from the same two facts.
 * They are written in different files, and nothing but this test stops them
 * drifting apart — which matters because they will be looked at side by side on
 * the fair floor, one in someone's hands and one on the table, and a printer
 * that is green on one and grey on the other is worse than either answer alone.
 */
function extract(source, name, end) {
  const from = source.indexOf(`function ${name}(`);
  assert.ok(from >= 0, `${name} is gone from its file`);
  const to = source.indexOf(end, from);
  assert.ok(to > from, `could not find the end of ${name}`);
  return new Function(`${source.slice(from, to)}; return ${name};`)();
}

const admPrinterState = extract(kiosk, 'admPrinterState', '\nasync function admRefresh');
const printerState = extract(dash, 'printerState', '\n      function renderPrinters');

/** Both files answer with their own vocabulary. Reduce each to the decision. */
const admSendable = (s) => (s.send === 'can' ? 'sure' : s.send ? 'careful' : 'no');
const dashSendable = (s) => (s.send === 'ok' ? 'sure' : s.send ? 'careful' : 'no');

const P = { id: 'A1-1', name: 'Printer 1', configured: true };
const job = (over) => ({
  id: 'j1', name: 'Mia', seq: 7, status: 'queued', printerId: null,
  colours: { layer1: 'BLACK', layer2: 'PINK' }, est: 14, ...over,
});

const CASES = [
  ['never set up', { ...P, configured: false, live: null }, [], 'no'],
  ['not talking to us', { ...P, live: null }, [], 'careful'],
  ['idle and empty', { ...P, live: { state: 'IDLE' } }, [], 'sure'],
  ['finished its last job', { ...P, live: { state: 'FINISH' } }, [], 'sure'],
  ['printing', { ...P, live: { state: 'RUNNING', percent: 40, remainingMin: 8 } },
    [job({ status: 'printing', printerId: 'A1-1' })], 'no'],
  ['heating up', { ...P, live: { state: 'PREPARE', percent: 0 } },
    [job({ status: 'printing', printerId: 'A1-1' })], 'no'],
  ['waiting for a filament swap', { ...P, live: { state: 'PAUSE' } },
    [job({ status: 'colour_change', printerId: 'A1-1' })], 'no'],
  // The one that cost a machine a whole day: a failed print leaves the printer
  // standing idle with a ruined keychain on the bed, and it stays FAILED until
  // it is given something else to do. Greying it out is a trap it never escapes.
  ['failed, bed not cleared', { ...P, live: { state: 'FAILED' } }, [], 'careful'],
  ['idle but already holding a job', { ...P, live: { state: 'IDLE' } },
    [job({ status: 'assigned', printerId: 'A1-1' })], 'no'],
];

test('the iPad panel and the laptop board agree on every printer', () => {
  for (const [what, printer, jobs, expected] of CASES) {
    const a = admSendable(admPrinterState(printer, jobs));
    const d = dashSendable(printerState(printer, jobs));
    assert.equal(a, expected, `iPad got ${what} wrong`);
    assert.equal(d, expected, `laptop got ${what} wrong`);
  }
});

test('every printer the panel offers is labelled, and the label is plain', () => {
  for (const [, printer, jobs] of CASES) {
    const s = admPrinterState(printer, jobs);
    assert.match(s.cls, /^(free|busy|soon|dead)$/);
    assert.ok(s.label && s.label === s.label.toLowerCase(), `"${s.label}" should read as a lowercase aside`);
  }
});

/**
 * A tap is what a curious child does, and every button behind the gear starts a
 * real print on a real machine. The panel is also meaningless without a server
 * to queue against, so the standalone build must never show the way in.
 */
test('the way into the operator panel is a hold, and only on the booth build', () => {
  const init = kiosk.slice(kiosk.indexOf('function admInit()'), kiosk.indexOf('function admOpen()'));
  assert.match(init, /__BOOTH_SERVER__/, 'the gear must hide itself off the booth build');
  assert.match(init, /setTimeout\(admOpen,\s*(\d{3,})\)/, 'opening must be on a timer, not a tap');
  assert.ok(Number(init.match(/setTimeout\(admOpen,\s*(\d+)\)/)[1]) >= 600, 'the hold is too short to be deliberate');
  for (const ev of ['touchend', 'touchmove', 'touchcancel', 'mouseup']) {
    assert.ok(init.includes(ev), `a hold interrupted by ${ev} must not open the panel`);
  }
  assert.ok(kiosk.includes('admInit()'), 'admInit is never called');
});

test('the built kiosk carries the panel, and the standalone build carries no server calls', () => {
  const booth = fs.readFileSync(path.join(root, 'public/index.html'), 'utf8');
  const alone = fs.readFileSync(path.join(root, 'public/standalone.html'), 'utf8');
  assert.ok(booth.includes('adm-dot') && booth.includes('__BOOTH_SERVER__'), 'run npm run build');
  assert.ok(!alone.includes('__BOOTH_SERVER__ = true'), 'the standalone build must not think it has a server');
});
