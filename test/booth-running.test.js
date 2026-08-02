import { test } from 'node:test';
import assert from 'node:assert/strict';
import net from 'node:net';
import { boothIsRunning } from '../tools/booth-running.mjs';

test('the tools can tell whether the booth already holds the printer', async () => {
  // A Bambu printer accepts one MQTT client. The booth server holds it for the
  // whole session; a diagnostic tool opening its own takes it away, and every
  // printer on the dashboard drops to NO SIGNAL while looking perfectly healthy
  // on the bench. The tools have to know not to do that.
  const port = 4900 + (process.pid % 90);
  assert.equal(await boothIsRunning(port), false, 'nothing listening yet');

  const srv = net.createServer((c) => c.end());
  await new Promise((r) => srv.listen(port, '127.0.0.1', r));
  assert.equal(await boothIsRunning(port), true, 'the booth is up');

  await new Promise((r) => srv.close(r));
  assert.equal(await boothIsRunning(port), false, 'and gone again');
});

test('every printer tool refuses to steal the connection', async () => {
  const fs = await import('node:fs');
  for (const f of ['clear-printer', 'probe-commands', 'probe-start', 'send-file']) {
    const src = fs.readFileSync(new URL(`../tools/${f}.mjs`, import.meta.url), 'utf8');
    assert.match(src, /refuseIfBoothRunning/, `${f} can still blind the dashboard`);
  }
});
