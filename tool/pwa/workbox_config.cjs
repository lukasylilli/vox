// L.3 Offline — die EINE Stelle, die festlegt, was VOX offline mitnimmt.
// Genutzt von sw_bauen.cjs (baut build/web/vox_sw.js) und offline_test.cjs.
//
// Warum ein eigener Service Worker (2026-09-24, DevTools-Befund von Lukas):
// Flutter 3.44 erzeugt zwar noch flutter_service_worker.js, aber dieser meldet
// sich beim Aktivieren SELBST ab und legt keinen Cache an ("deprecated").
// Ergebnis: kein Service Worker, "No cache storage", offline startet nichts.
// Außerdem lud die Engine CanvasKit von www.gstatic.com. Deshalb baut
// deploy-web.yml mit `--pwa-strategy=none --no-web-resources-cdn` und dieser
// Ordner erzeugt den Worker mit Workbox (fest gepinnt in package-lock.json).
//
// Aufteilung:
//  • Vorab (precache, beim ersten Besuch): alles, was mit der App-Version
//    wechselt und NICHT mit dem Wortarchiv wächst — App-Code, CanvasKit
//    (beide Varianten: Chromium für Chrome/Android, normal für Safari/iPhone),
//    Lerninhalte, Bilder, Schriften, Wortindex. Jede Datei hat eine Revision
//    (Inhalts-Hash): bei einem neuen Deploy wird nur Geändertes neu geladen.
//  • Bei Gebrauch (runtime): die einzelnen Wortkarten und die Formen-Tabelle.
//    ~26.200 Karten ≈ 100 MB — das darf nie vorab geladen werden (PLAN L.3).
//    Eine einmal geöffnete Karte bleibt offline lesbar und wird im
//    Hintergrund aufgefrischt (StaleWhileRevalidate).
//  • Fremde Server (Supabase, Nachrichten) laufen NIE über den Cache.
'use strict';

const path = require('path');

const BUILD_DIR = path.resolve(__dirname, '../../build/web');

// Diese Dateien MÜSSEN im Vorab-Paket stehen, sonst startet VOX offline nicht.
// sw_bauen.cjs bricht ab, wenn eine fehlt (z. B. still übersprungen, weil zu groß).
const PFLICHT = [
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'locale_guard.js',
  'telegram_guard.js',
  'drift_worker.js',
  'sqlite3.wasm',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/assets/vocab_index.json',
];

// Was ins Vorab-Paket kommt (auch für getManifest in den Prüfungen).
const manifestConfig = {
  globDirectory: BUILD_DIR,
  globPatterns: ['**/*'],
  globIgnores: [
    'vox_sw.js',
    'flutter_service_worker.js',
    '**/*.symbols',
    '**/*.map',
    // Nur canvaskit.js/.wasm (beide Varianten) werden gebraucht; skwasm/wimp
    // gehören zum Wasm-Bau, den VOX nicht nutzt.
    'canvaskit/skwasm*',
    'canvaskit/wimp*',
    'canvaskit/experimental_webparagraph/**',
    // Wortarchiv: wächst mit jeder Karte ⇒ nur bei Gebrauch (siehe oben).
    'assets/assets/vocab/**',
    'assets/assets/vocab_formen/**',
  ],
  // main.dart.js ~5 MB, canvaskit.wasm ~7 MB — Workbox' Vorgabe (2 MB) würde
  // sie STILL weglassen. PFLICHT oben fängt genau das ab.
  maximumFileSizeToCacheInBytes: 25 * 1024 * 1024,
};

// Der Worker selbst.
const config = {
  ...manifestConfig,
  swDest: path.join(BUILD_DIR, 'vox_sw.js'),
  inlineWorkboxRuntime: true,
  mode: 'production',
  sourcemap: false,
  cacheId: 'vox',
  cleanupOutdatedCaches: true,
  // Neue Version erst, wenn alle VOX-Fenster zu sind: nie alter Code mit
  // neuen Dateien gemischt. clientsClaim ist trotzdem sicher — aktiviert
  // wird ja nur, wenn kein Fenster mehr die alte Version benutzt; so steuert
  // der Worker schon den ersten Besuch.
  skipWaiting: false,
  clientsClaim: true,
  navigateFallback: 'index.html',
  runtimeCaching: [
    {
      urlPattern: ({ url, sameOrigin }) =>
        sameOrigin && /\/assets\/assets\/(vocab|vocab_formen)\//.test(url.pathname),
      handler: 'StaleWhileRevalidate',
      options: { cacheName: 'vox-woerter' },
    },
    {
      // Ersatzschriften der Engine (Zeichen, die Vazirmatn nicht hat).
      urlPattern: ({ url }) => url.origin === 'https://fonts.gstatic.com',
      handler: 'CacheFirst',
      options: {
        cacheName: 'vox-schriften',
        expiration: { maxEntries: 60 },
        cacheableResponse: { statuses: [200] },
      },
    },
  ],
};

module.exports = { BUILD_DIR, PFLICHT, manifestConfig, config };
