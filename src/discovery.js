// Where the printers are right now.
//
// A Bambu printer announces itself over SSDP every few seconds: a UDP packet
// to port 2021 carrying its serial (USN), its address (Location), its name and
// model. Bambu Studio's device list is built from exactly these packets.
//
// The booth needs them because printers move. The same A1 mini is at
// 192.168.100.64 at home and 192.168.10.105 at the studio, and a config.json
// that remembers the first address produces the booth's most misleading
// failure: the file uploads (over a stale link), the start command goes
// nowhere, and the log says "printer did not start". Listening here lets the
// booth follow the printer instead — the serial is the identity, the IP is
// just where it happens to be today.

import dgram from 'node:dgram';

export const SSDP_PORT = 2021;
const MULTICAST = '239.255.255.250';

/** Parse one announcement. Exported for testing. Returns null if it is not a Bambu one. */
export function parseAnnouncement(text, fromAddress = '') {
  const field = (name) => {
    const m = new RegExp(`^${name}:\\s*(.*?)\\s*$`, 'im').exec(text);
    return m ? m[1] : '';
  };
  const serial = field('USN');
  if (!serial || !/^[0-9A-Z]{10,20}$/i.test(serial)) return null;
  const ip = field('Location') || fromAddress;
  if (!/^\d{1,3}(\.\d{1,3}){3}$/.test(ip)) return null;
  return {
    serial: serial.toUpperCase(),
    ip,
    name: field('DevName\\.bambu\\.com'),
    model: field('DevModel\\.bambu\\.com'),
    at: new Date().toISOString(),
  };
}

/**
 * Listen for announcements. `onSeen(printer)` fires for every announcement
 * whose serial is new or whose address changed since the last one. Returns
 * { seen(): [...], stop() }.
 *
 * Failing to bind (port in use, or a firewall) is not fatal — the booth ran
 * for months without this. It is logged once and the booth carries on with
 * whatever config.json says.
 */
export function startDiscovery(onSeen, log = console) {
  const known = new Map();
  let socket = null;
  try {
    socket = dgram.createSocket({ type: 'udp4', reuseAddr: true });
    socket.on('error', (e) => { log.error(`printer discovery stopped: ${e.message}`); try { socket.close(); } catch {} socket = null; });
    socket.on('message', (msg, rinfo) => {
      const p = parseAnnouncement(msg.toString(), rinfo.address);
      if (!p) return;
      const prev = known.get(p.serial);
      known.set(p.serial, p);
      if (!prev || prev.ip !== p.ip) {
        try { onSeen(p, prev || null); } catch (e) { log.error('discovery handler failed', e); }
      }
    });
    socket.bind(SSDP_PORT, () => {
      try { socket.addMembership(MULTICAST); } catch { /* unicast announcements still arrive */ }
    });
  } catch (e) {
    log.error(`printer discovery not running: ${e.message}`);
    socket = null;
  }
  return {
    seen: () => [...known.values()].sort((a, b) => a.name.localeCompare(b.name)),
    stop() { try { socket?.close(); } catch {} socket = null; },
  };
}
