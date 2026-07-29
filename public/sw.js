// Minimal offline shell so the kiosk keeps drawing even if WiFi hiccups.
// API calls always go to the network; only static assets are cached.
const CACHE = '3dipad-v2';
const ASSETS = ['.', 'index.html', 'manifest.webmanifest', 'icon.svg'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (url.pathname.includes('/api/')) return; // never cache API
  e.respondWith(caches.match(e.request).then((hit) => hit || fetch(e.request)));
});
