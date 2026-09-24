// L.3 Offline: erzeugt build/web/vox_sw.js — Aufruf in deploy-web.yml nach
// `flutter build web`. Bricht rot ab, statt einen halben Offline-Stand zu
// veröffentlichen. Begründung und Aufteilung: workbox_config.cjs.
'use strict';

const fs = require('fs');
const path = require('path');
const { generateSW, getManifest } = require('workbox-build');
const { BUILD_DIR, PFLICHT, manifestConfig, config } = require('./workbox_config.cjs');

function fehler(text) {
  console.error(`::error::${text}`);
  process.exit(1);
}

async function main() {
  // 1. Der Bau muss mit --pwa-strategy=none --no-web-resources-cdn entstanden
  //    sein. Sonst registriert Flutter seinen sich selbst abmeldenden Worker
  //    (verdrängt vox_sw.js im selben Bereich) bzw. lädt CanvasKit vom CDN.
  const bootstrap = fs.readFileSync(path.join(BUILD_DIR, 'flutter_bootstrap.js'), 'utf8');
  // Nur der Teil NACH dem eingebetteten flutter.js zählt (flutter.js selbst
  // enthält das Wort immer): buildConfig + der Aufruf _flutter.loader.load(…).
  const start = bootstrap.lastIndexOf('_flutter.buildConfig');
  if (start < 0) fehler('flutter_bootstrap.js ohne _flutter.buildConfig — unbekanntes Format.');
  const aufruf = bootstrap.slice(start);
  if (aufruf.includes('serviceWorkerSettings')) {
    fehler('flutter_bootstrap.js registriert Flutters Service Worker — Bau braucht --pwa-strategy=none.');
  }
  if (!/"useLocalCanvasKit"\s*:\s*true/.test(aufruf)) {
    fehler('CanvasKit käme vom CDN (gstatic) — Bau braucht --no-web-resources-cdn.');
  }

  // 2. Vorab-Paket prüfen: keine Warnung, alle Pflichtdateien drin.
  const { manifestEntries, count, size, warnings } = await getManifest(manifestConfig);
  if (warnings.length) fehler(`Workbox-Warnungen: ${warnings.join(' | ')}`);
  const drin = new Set(manifestEntries.map((e) => e.url));
  const fehlt = PFLICHT.filter((p) => !drin.has(p));
  if (fehlt.length) fehler(`Fehlt im Offline-Paket: ${fehlt.join(', ')}`);

  // 3. Worker schreiben.
  const ergebnis = await generateSW(config);
  if (ergebnis.warnings.length) fehler(`Workbox-Warnungen: ${ergebnis.warnings.join(' | ')}`);
  console.log(`vox_sw.js: ${count} Dateien vorab, ${(size / 1024 / 1024).toFixed(1)} MB`);
}

main().catch((e) => fehler(e.stack || String(e)));
