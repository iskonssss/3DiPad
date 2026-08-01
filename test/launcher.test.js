import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import net from 'node:net';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { waitForPort, openBrowser } from '../tools/open-when-ready.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

test('the browser is not opened until the server is really listening', async () => {
  // The bug: both launchers opened the browser on the line before `npm start`,
  // so it raced the server and usually won. The operator saw "localhost refused
  // to connect" on a booth that was starting perfectly normally.
  const port = 4700 + (process.pid % 200);
  const started = Date.now();

  const waiting = waitForPort(port, Date.now() + 10000, 100);

  // nothing is listening yet — the wait must still be pending
  await new Promise((r) => setTimeout(r, 400));
  let settled = false;
  waiting.then(() => { settled = true; });
  await new Promise((r) => setTimeout(r, 50));
  assert.equal(settled, false, 'it decided the server was up before anything was listening');

  const srv = net.createServer((c) => c.end());
  await new Promise((r) => srv.listen(port, '127.0.0.1', r));

  assert.equal(await waiting, true, 'it never noticed the server come up');
  assert.ok(Date.now() - started >= 400, 'it should have waited for the port, not returned at once');
  await new Promise((r) => srv.close(r));
});

test('a server that never arrives gives up instead of hanging the launcher', async () => {
  const t0 = Date.now();
  assert.equal(await waitForPort(4999, Date.now() + 600, 100), false);
  assert.ok(Date.now() - t0 < 5000, 'it kept waiting past its deadline');
});

test('opening a browser never takes the booth down with it', () => {
  // There is no browser on a headless box, and there may be none on a locked-
  // down laptop either. Failing to open one is not a reason for the booth not
  // to start, so this must not throw or reject.
  const child = openBrowser('http://localhost:3000/dashboard/', 'linux');
  assert.ok(child, 'returned a child process');
  child.kill?.();
});

test('both launchers wait for the port rather than racing it', () => {
  for (const file of ['Start Booth.cmd', 'start-booth.sh']) {
    const text = fs.readFileSync(path.join(root, file), 'utf8');
    assert.match(text, /open-when-ready\.mjs/, `${file} still opens the browser its own way`);

    // and the wait has to be started before the server, not after — the start
    // command blocks, so anything below it never runs at all. Match the command
    // itself, not the word: the comment above it says "npm start" too.
    const waiter = text.indexOf('open-when-ready.mjs');
    const start = text.search(/^\s*(call|exec)\s+npm start/m);
    assert.ok(start > 0, `${file} does not appear to start the server`);
    assert.ok(waiter < start, `${file} launches the waiter after npm start, which never returns`);

    // the old bug, spelled out so it cannot come back
    assert.ok(!/start "" http:\/\/localhost/.test(text) && !/^\(sleep \d+ &&/m.test(text),
      `${file} still opens the browser without waiting`);
  }
});
