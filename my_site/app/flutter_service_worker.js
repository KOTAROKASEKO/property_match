'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "580cc04978731fb03d98b273d08806ac",
"assets/AssetManifest.bin.json": "8ea2c3ad632152c9badffc9c959ef4fe",
"assets/AssetManifest.json": "38f6205321721bdbda6682c51b30bc98",
"assets/assets/ai_chat_background.png": "03bd1bc73fa92433542c2f47ab46a32f",
"assets/assets/background.png": "d6c58b4b10c5386b659a16e180424ed2",
"assets/assets/chat.riv": "d12d61f02c7d676ff1edf1586ed86384",
"assets/assets/default.ttf": "30bbfaf1881a04a75d232352a268303f",
"assets/assets/default_avatar.png": "efaa757b26724fb231900c34c07dea29",
"assets/assets/door_opening.json": "f4a7b82a2c6aaa0b188b1d75abf033b6",
"assets/assets/fancy.ttf": "0821276254a0fb009f9fdef2a0d46283",
"assets/assets/fancy2.ttf": "4bd158bddf752bc39e5cb8786243017f",
"assets/assets/fancy3.ttf": "5aee7a8bf379299dd7baac424f3a9b7b",
"assets/assets/google_logo.png": "139b0d256b17655fcaf612cc43be41f2",
"assets/assets/home.json": "925689b187a9f9f1e52938bfb1b41170",
"assets/assets/kaku.ttf": "34d5d6012ea49de969026d29c75eb81a",
"assets/assets/like.riv": "f6acf8aa7a190130f8465638d64bdf03",
"assets/assets/login.ttf": "30bbfaf1881a04a75d232352a268303f",
"assets/assets/logo.png": "1d3ebaa3b43d2ba9005b1eca8f24212c",
"assets/assets/recording.json": "093a5a9fc6a72b4656e2fbc7c50c9310",
"assets/assets/signin_dog.json": "80fc21bb509fb04f9d70228248d141ac",
"assets/FontManifest.json": "2b2929018c83217247ccc612c37aa850",
"assets/fonts/MaterialIcons-Regular.otf": "1d27b42d81e85f4e53931ad423816a89",
"assets/NOTICES": "393376b7081c3b2ae64191f4ddecbd79",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/google_places_flutter/images/location.json": "afa33acf2c340246c901718f4efdfccf",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/record_web/assets/js/record.worklet.js": "6d247986689d283b7e45ccdf7214c2ff",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"cors.json": "f2c45427a3fff22e3e73e13e2ef327f6",
"drift_worker.dart.js": "ddd68588fa15312846c3f03b6da681a1",
"favicon.png": "afa53129607901b4e283b30b60a8aa63",
"firebase-messaging-sw.js": "8d3ec79e21cbaba834ff241317d778bd",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "f8e474fdd93f380a8a62180b8b7da792",
"icon.png": "13446c280beffcb999e79f3a31816650",
"icons/favicon.png": "504e3a74d6048dcc146265026ec6632c",
"icons/Icon-192.png": "f518bcb866c0cfd9545a73b70dc64ee8",
"icons/Icon-512.png": "d3a7c867165392bdcc6b23b180f70f20",
"icons/Icon-maskable-192.png": "f518bcb866c0cfd9545a73b70dc64ee8",
"icons/Icon-maskable-512.png": "d3a7c867165392bdcc6b23b180f70f20",
"icon_converter.py": "38861546110ac45701c386f7c5e1d874",
"index.html": "b541aa05ee54a04e403afc4633c96ceb",
"/": "b541aa05ee54a04e403afc4633c96ceb",
"main.dart.js": "2ae683be6a8d210fafe90f908ad8aca7",
"manifest.json": "c872c536df43d3fbac1a4edd35fe5a01",
"splash/img/dark-1x.png": "4e384c87ba253f86a65df600ab6f6bb2",
"splash/img/dark-2x.png": "b9b902aa2071ece77cacfba3ef79bf9d",
"splash/img/dark-3x.png": "7796846fbe6bab8f24d0cd4de3ad0de5",
"splash/img/dark-4x.png": "cbd4d4136306bd2575e4deade9227066",
"splash/img/light-1x.png": "4e384c87ba253f86a65df600ab6f6bb2",
"splash/img/light-2x.png": "b9b902aa2071ece77cacfba3ef79bf9d",
"splash/img/light-3x.png": "7796846fbe6bab8f24d0cd4de3ad0de5",
"splash/img/light-4x.png": "cbd4d4136306bd2575e4deade9227066",
"sqlite3.wasm": "079cc69bb70ead058d8d7330eded9e03",
"version.json": "e0f7aea07e71289e1f271117ba0bba15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
