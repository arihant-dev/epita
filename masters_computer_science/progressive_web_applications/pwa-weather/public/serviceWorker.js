const urlsToCache = [
  '/index.html',
  '/offline.html',
  './assets/logo.png',
  './manifest.json'
];

const CACHE_NAME = 'weather-app-cache-v2';

const self = this;

// Install service worker
this.addEventListener('install', (event) => {
    event.waitUntil(
      caches.open(CACHE_NAME).then((cache) => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
    );
});

// listen for requests
this.addEventListener('fetch', (event) => {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        // Cache hit - return response
        if (cachedResponse) {
          return cachedResponse;
        }
        return fetch(event.request).catch(() => caches.match('offline.html'));
      })
    );
});

// activate the service worker
this.addEventListener('activate', (event) => {
    const cacheWhitelist = [CACHE_NAME];

    console.log('caches', caches.keys());
    event.waitUntil(
      caches.keys().then((cacheNames) =>
        Promise.all(
          cacheNames.map((cacheName) => {
            if (!cacheWhitelist.includes(cacheName)) {
              return caches.delete(cacheName);
            }
          })
        )
      )
    );
});