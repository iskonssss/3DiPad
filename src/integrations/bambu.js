// Bambu A1 mini LAN dispatch.
//
// Sending a print to an A1 over the local network is a two-step Bambu protocol:
//   1) upload the file to the printer's SD over FTPS (implicit TLS, port 990,
//      user "bblp", password = the printer's LAN Access Code), then
//   2) publish an MQTT "project_file" / "start" command to
//      device/<SERIAL>/request (TLS 8883, same access code) to begin the print.
//
// That needs an FTPS + MQTT client and per-printer credentials, and can only be
// verified against real hardware. This module exposes the interface and a safe
// stub; wire a library such as `bambulabs-api` (or `mqtt` + `basic-ftp`) here to
// go fully automatic. Until then the operator dashboard drives printing manually
// and the .gcode is available locally + on Drive.
//
//   npm install bambulabs-api
//
// Requirements per printer (config.integrations.printers[]):
//   { id, name, ip, serial, accessCode }   // LAN mode must be ON on the printer

const AUTO_SEND = false; // flip to true once a real LAN client is wired below

export function isEnabled(printer) {
  return AUTO_SEND && !!(printer && printer.ip && printer.serial && printer.accessCode);
}

/**
 * Send a sliced .gcode to a printer and start it.
 * Returns { ok, sent, error }. The stub reports not-sent so the dashboard shows
 * the job as needing a manual start — never silently claims success.
 */
export async function sendToPrinter(printer, filePath, opts = {}) {
  if (!isEnabled(printer)) {
    return { ok: true, sent: false, manual: true, reason: 'LAN auto-send not configured' };
  }
  // --- Wire real implementation here ---
  // const ftp = new ftps.Client(); await ftp.access({ host: printer.ip, port: 990, secure: 'implicit', user: 'bblp', password: printer.accessCode });
  // await ftp.uploadFrom(filePath, `/${path.basename(filePath)}`);
  // const client = mqtt.connect(`mqtts://${printer.ip}:8883`, { username: 'bblp', password: printer.accessCode, rejectUnauthorized: false });
  // client.publish(`device/${printer.serial}/request`, JSON.stringify(printCommand(filePath)));
  return { ok: false, sent: false, error: 'real LAN client not wired' };
}
