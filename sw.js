// Instead — Service Worker
// Cache-first strategy: app loads instantly offline,
// updates silently in the background when online.

const CACHE_NAME = 'instead-v2';

// Files to cache on install (adjust the HTML filename if yours differs)
const PRECACHE_URLS = [
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png',
  // Google Fonts — cache both the CSS and the actual font files
  'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=DM+Sans:wght@400;500;600&display=swap',
];

// ── Install: pre-cache everything ────────────────────────
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      // Cache local files strictly; fonts best-effort (may be CORS-restricted)
      return cache.addAll(PRECACHE_URLS.slice(0, 5))
        .then(() => cache.addAll(PRECACHE_URLS.slice(5)).catch(() => {}));
    }).then(() => self.skipWaiting())
  );
});

// ── Activate: delete old caches ───────────────────────────
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// ── Fetch: cache-first, network fallback ──────────────────
self.addEventListener('fetch', event => {
  // Only handle GET requests
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) {
        // Serve from cache immediately, then refresh in background
        const networkFetch = fetch(event.request)
          .then(response => {
            if (response && response.status === 200) {
              caches.open(CACHE_NAME).then(c => c.put(event.request, response.clone()));
            }
            return response;
          })
          .catch(() => {});
        return cached;
      }

      // Not in cache — try network, then cache it
      return fetch(event.request)
        .then(response => {
          if (!response || response.status !== 200 || response.type === 'opaque') {
            return response;
          }
          caches.open(CACHE_NAME).then(c => c.put(event.request, response.clone()));
          return response;
        })
        .catch(() => {
          // Offline and not cached — return the app shell
          return caches.match('./index.html');
        });
    })
  );
});
