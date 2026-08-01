// Offline shell for the booth kiosk.
//
// The HTML is fetched network-first: on the booth LAN the server is always
// reachable, and a cache-first document meant an updated kiosk never appeared
// on the iPads until the cache was cleared by hand. The cached copy is kept as
// the offline fallback. API calls are never cached.
//
// SCOPE. This worker is registered from /index.html, so the browser gives it
// the whole origin — every page the booth server serves, not just the kiosk.
// It used to act on all of them, which meant opening /dashboard/ got the
// kiosk page instead: a navigation the worker could not answer from cache
// fell back to index.html, and one that it could was answered from a cache
// that only ever holds the kiosk. The operator's dashboard is a different app
// that must always come from the server, and the day's g-code and previews
// under /output and /leads must never be served stale. So the worker now
// handles the kiosk's own files and steps aside for everything else.
const CACHE = '3dipad-v4';
const ASSETS = ['.', 'index.html', 'manifest.webmanifest', 'icon.svg'];

/** Is this one of the kiosk's own URLs? Everything else is none of our business. */
function isKiosk(url) {
  if (url.origin !== self.location.origin) return false;
  const scope = new URL('./', self.location).pathname;      // '/'
  if (!url.pathname.startsWith(scope)) return false;
  const rest = url.pathname.slice(scope.length);
  return rest === '' || ['index.html', 'standalone.html', 'manifest.webmanifest', 'icon.svg'].includes(rest);
}

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (url.pathname.includes('/api/')) return;   // always live
  if (!isKiosk(url)) return;                    // the dashboard, output, leads: not ours

  const isDocument = e.request.mode === 'navigate' || e.request.destination === 'document';
  if (isDocument) {
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          caches.open(CACHE).then((c) => c.put(e.request, res.clone()));
          return res;
        })
        .catch(() => caches.match(e.request).then((hit) => hit || caches.match('index.html'))),
    );
    return;
  }
  e.respondWith(caches.match(e.request).then((hit) => hit || fetch(e.request)));
});
