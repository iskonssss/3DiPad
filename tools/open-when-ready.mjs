// Open the dashboard once the booth server is actually listening.
//
//   node tools/open-when-ready.mjs [port] [path ...]
//
// Every path given opens in its own tab once the port answers — the dashboard
// and the kiosk together, so the laptop can be the third tablet.
//
// The launchers used to open the browser on the line before `npm start`, so it
// always raced the server and usually won: the operator got "localhost refused
// to connect" on a booth that was starting perfectly normally. A fixed sleep
// only narrows the race — a cold start after an npm install, or a laptop busy
// with a Windows update, takes as long as it takes.
//
// This is a node script rather than a line of PowerShell inside a .cmd because
// node is already required to run the booth (the launcher checks for it), and
// because a script can be tested. Nested quoting inside a batch file cannot.

import net from 'node:net';
import { spawn } from 'node:child_process';

const port = Number(process.argv[2]) || 3000;
const urlPaths = process.argv.slice(3).length ? process.argv.slice(3) : ['/dashboard/'];
const urls = urlPaths.map((p) => `http://localhost:${port}${p}`);
const timeoutMs = Number(process.env.OPEN_TIMEOUT_MS) || 60000;

/** Resolves once something accepts a connection on the port, or false on timeout. */
export function waitForPort(p, deadline, probeMs = 400) {
  return new Promise((resolve) => {
    const attempt = () => {
      if (Date.now() >= deadline) return resolve(false);
      const sock = net.connect({ port: p, host: '127.0.0.1' });
      // NOT unref'd. Between probes this timer is the only thing holding the
      // event loop open, and an unref'd one let the script exit after its first
      // failed attempt — which is every time, since the whole point is that it
      // starts before the server does.
      const retry = () => { sock.destroy(); setTimeout(attempt, probeMs); };
      sock.once('connect', () => { sock.end(); resolve(true); });
      sock.once('error', retry);
      sock.setTimeout(2000, retry);
    };
    attempt();
  });
}

/** Hand a URL to whatever the desktop uses to open links. */
export function openBrowser(target, platform = process.platform) {
  const [cmd, args] = platform === 'win32' ? ['cmd', ['/c', 'start', '', target]]
    : platform === 'darwin' ? ['open', [target]]
    : ['xdg-open', [target]];
  const child = spawn(cmd, args, { detached: true, stdio: 'ignore' });
  child.on('error', () => {
    // No browser, or no desktop session. Not worth failing a booth over —
    // the address is printed by the server anyway.
    console.error(`Could not open a browser. Go to ${target} yourself.`);
  });
  child.unref();
  return child;
}

// Only act when run directly, so the two functions above stay testable.
if (process.argv[1] && import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) {
  const ready = await waitForPort(port, Date.now() + timeoutMs);
  if (ready) for (const url of urls) openBrowser(url);
  else console.error(`The booth server did not come up on port ${port}. Open ${urls.join(' and ')} once it does.`);
}
