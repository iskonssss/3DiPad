import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const source = fs.readFileSync(path.join(root, 'public/sw.js'), 'utf8');

/**
 * Pull isKiosk() out of the worker and run it against a fake `self`. The rule
 * it encodes is the whole point of the file, and it cannot be exercised any
 * other way from node.
 */
function loadIsKiosk(scope = 'http://booth.local/') {
  const self = { location: new URL(scope + 'sw.js') };
  const body = source.slice(source.indexOf('function isKiosk'), source.indexOf('self.addEventListener'));
  return new Function('self', 'URL', `${body}; return isKiosk;`)(self, URL);
}

test('the kiosk worker keeps its hands off the rest of the booth', () => {
  const isKiosk = loadIsKiosk();
  const at = (p) => new URL(p, 'http://booth.local/');

  // Registered from /index.html, the browser hands this worker the whole
  // origin. It used to answer for all of it, so with the booth server
  // unreachable — restarting, or just not up yet — a navigation to the
  // dashboard fell through to the kiosk's cached index.html and the operator
  // got the kids' drawing app instead of their dashboard.
  for (const p of ['/dashboard/', '/dashboard/index.html', '/dashboard/setup.html',
    '/output/BLACK-BLUE_0007.gcode', '/leads/BLACK-BLUE_0007.svg', '/api/jobs']) {
    assert.equal(isKiosk(at(p)), false, `${p} is not the kiosk's to answer`);
  }

  // Its own files, which are the ones that have to work on a tablet whose
  // Wi-Fi has dropped.
  for (const p of ['/', '/index.html', '/standalone.html', '/manifest.webmanifest', '/icon.svg']) {
    assert.equal(isKiosk(at(p)), true, `${p} is the kiosk`);
  }

  // Anything from somewhere else entirely is never ours.
  assert.equal(isKiosk(new URL('http://example.com/index.html')), false);
});

test('the worker cache is versioned, so an old one is replaced not merged', () => {
  const m = source.match(/const CACHE = '([^']+)'/);
  assert.ok(m, 'the cache name is a single named constant');
  // activate() deletes every cache that is not the current one; that only
  // rescues a tablet holding a stale kiosk if the name actually changed.
  assert.match(source, /keys\.filter\(\(k\) => k !== CACHE\)\.map\(\(k\) => caches\.delete\(k\)\)/);
  assert.notEqual(m[1], '3dipad-v3', 'bump the cache name when the worker changes');
});
