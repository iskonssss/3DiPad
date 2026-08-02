// Is the booth server already running?
//
// A Bambu printer accepts exactly one MQTT client. The booth server holds that
// connection for the whole session, which is the only reason status works at
// all. Every diagnostic tool here opens its own — so running one while the
// booth is up takes the connection away from the server, and the dashboard
// goes to NO SIGNAL on printers that are perfectly healthy.
//
// That is a footgun the tools created, so the tools should be the ones to
// refuse. Nothing here is urgent enough to be worth blinding the booth.

import net from 'node:net';

export function boothIsRunning(port = Number(process.env.PORT) || 3000, timeout = 900) {
  return new Promise((resolve) => {
    const sock = net.connect({ port, host: '127.0.0.1' });
    const done = (v) => { sock.destroy(); resolve(v); };
    sock.once('connect', () => done(true));
    sock.once('error', () => done(false));
    sock.setTimeout(timeout, () => done(false));
  });
}

/**
 * Stop, unless the caller passed --force. Returns true if it is safe to carry
 * on. Exits the process otherwise, having said why.
 */
export async function refuseIfBoothRunning(argv = process.argv, what = 'This tool') {
  if (argv.includes('--force')) return true;
  if (!(await boothIsRunning())) return true;

  console.error('');
  console.error('  The booth server is running, so this would take the printer connection');
  console.error('  away from it.');
  console.error('');
  console.error('  A Bambu printer allows one connection at a time. The booth holds it to');
  console.error('  read status; if this tool takes it, every printer on the dashboard goes to');
  console.error('  NO SIGNAL until the booth wins it back.');
  console.error('');
  console.error('  Close the booth window, run this, then start the booth again.');
  console.error(`  (${what} will run anyway with --force, if you know the dashboard will lie.)`);
  console.error('');
  process.exit(1);
}
