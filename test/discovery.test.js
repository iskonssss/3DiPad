import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseAnnouncement } from '../src/discovery.js';

// One announcement as a real A1 mini sent it on the studio network, the day
// the booth spent twenty minutes sending prints to an address the printer no
// longer had. Serial is the identity; the address is where it is today.
const REAL = [
  'NOTIFY * HTTP/1.1', 'HOST: 239.255.255.250:2021', 'Server: Buildroot/2018.02-rc3 UPnP/1.0 ssdpd/1.8',
  'Location: 192.168.10.105', 'NT: urn:bambulab-com:device:3dprinter:1', 'USN: 0309BA461400280',
  'Cache-Control: max-age=1800', 'DevModel.bambu.com: N1', 'DevName.bambu.com: Forgecraft A1 Mini',
  'DevSignal.bambu.com: -52', 'DevConnect.bambu.com: lan', 'DevBind.bambu.com: free', '', '',
].join('\r\n');

test('a Bambu announcement yields serial, address, name and model', () => {
  const p = parseAnnouncement(REAL, '192.168.10.105');
  assert.equal(p.serial, '0309BA461400280');
  assert.equal(p.ip, '192.168.10.105');
  assert.equal(p.name, 'Forgecraft A1 Mini');
  assert.equal(p.model, 'N1');
});

test('anything else on the multicast group is ignored', () => {
  assert.equal(parseAnnouncement('NOTIFY * HTTP/1.1\r\nUSN: uuid:some-tv-thing::urn:schemas\r\n', '10.0.0.5'), null);
  assert.equal(parseAnnouncement('', '10.0.0.5'), null);
  // no Location: the sender address stands in
  assert.equal(parseAnnouncement('USN: 0309BA461400280\r\n', '192.168.10.9').ip, '192.168.10.9');
});
