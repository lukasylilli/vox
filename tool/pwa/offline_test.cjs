// L.3 Offline — Prüfung im ECHTEN Chrome, bei jedem Deploy (deploy-web.yml).
// Roter Lauf ⇒ nichts wird veröffentlicht.
//
// Ablauf wie Lukas' Handtest (2026-09-24):
//  1. online öffnen, warten bis VOX steht und vox_sw.js die Seite steuert
//  2. Netz AUS, neu laden            ⇒ VOX muss starten
//  3. jede Datei des Vorab-Pakets    ⇒ muss offline kommen (auch nie geöffnete
//     Seiten: Lerninhalte, Bilder …)
//  4. neues Fenster, Netz weiter AUS ⇒ VOX muss starten ("App zu, wieder auf")
//  5. Start-Adressen (L.3c): Telegram-Mini-App (`#tgWebAppData=…`) ⇒ Startseite
//     ohne Router-Fehler; `#/` und `#/wortschatz` wie bisher
//
// "VOX steht" = die Ladeanzeige #vox-loading ist weg; die entfernt erst
// main.dart nach dem ersten Bild (lib/core/utils/html_loader.dart).
//
// Chrome: CHROME_PATH, sonst das installierte Google Chrome (ubuntu-latest).
'use strict';

const fs = require('fs');
const http = require('http');
const path = require('path');
const { chromium } = require('playwright-core');
const { getManifest } = require('workbox-build');
const { BUILD_DIR, manifestConfig } = require('./workbox_config.cjs');

const REPO = (process.env.GITHUB_REPOSITORY || '/vox').split('/').pop() || 'vox';
const PORT = 8766;
const BASIS = `http://localhost:${PORT}/${REPO}/`;
const START_MS = 120000;

const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.woff2': 'font/woff2', '.frag': 'application/octet-stream',
};

function server() {
  return http.createServer((req, res) => {
    const u = new URL(req.url, BASIS);
    const praefix = `/${REPO}/`;
    if (!u.pathname.startsWith(praefix)) { res.writeHead(404); return res.end(); }
    let rel = decodeURIComponent(u.pathname.slice(praefix.length)) || 'index.html';
    if (rel.endsWith('/')) rel += 'index.html';
    const datei = path.join(BUILD_DIR, rel);
    if (!datei.startsWith(BUILD_DIR) || !fs.existsSync(datei) || fs.statSync(datei).isDirectory()) {
      res.writeHead(404); return res.end();
    }
    res.writeHead(200, {
      'Content-Type': MIME[path.extname(datei).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'max-age=600', // wie GitHub Pages
    });
    fs.createReadStream(datei).pipe(res);
  }).listen(PORT);
}

function fehler(text) {
  console.error(`::error::Offline-Test: ${text}`);
  process.exitCode = 1;
}

async function vox_steht(page, wo) {
  try {
    await page.waitForFunction(() => !document.getElementById('vox-loading'), null, { timeout: START_MS });
    console.log(`✅ ${wo}: VOX gestartet`);
    return true;
  } catch (_) {
    fehler(`${wo}: VOX startet nicht (Ladeanzeige nach ${START_MS / 1000}s noch da)`);
    return false;
  }
}

// Öffnet BASIS+hash in einem neuen Fenster; VOX muss starten, die Adresse
// danach `erwartet` erfüllen und go_router darf keinen „no routes"-Fehler melden.
async function adresse_pruefen(context, hash, erwartet, wo) {
  const p = await context.newPage();
  const meldungen = [];
  p.on('console', (m) => meldungen.push(m.text()));
  p.on('pageerror', (e) => meldungen.push(e.message));
  try {
    await p.goto(BASIS + hash);
    if (!(await vox_steht(p, wo))) return;
    await p.waitForTimeout(1000); // Router hat den ersten Pfad sicher gelesen
    const h = await p.evaluate(() => location.hash);
    const routerFehler = meldungen.filter((m) => /GoException|no routes for location/i.test(m));
    if (routerFehler.length) return fehler(`${wo}: Router-Fehler: ${routerFehler[0]}`);
    if (!erwartet(h)) return fehler(`${wo}: Adresse danach ${JSON.stringify(h)}`);
    console.log(`✅ ${wo} (Adresse danach ${JSON.stringify(h)})`);
  } finally {
    await p.close();
  }
}

async function main() {
  const srv = server();
  const browser = await chromium.launch(
    process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : { channel: 'chrome' },
  );
  try {
    const context = await browser.newContext({ serviceWorkers: 'allow' });
    const page = await context.newPage();
    page.on('pageerror', (e) => console.log(`  (Seitenfehler: ${e.message})`));

    // 1. online
    await page.goto(BASIS);
    if (!(await vox_steht(page, 'online'))) return;
    const gesteuert = await page.waitForFunction(async () => {
      const reg = await navigator.serviceWorker.getRegistration();
      return !!(reg && reg.active && navigator.serviceWorker.controller
        && navigator.serviceWorker.controller.scriptURL.endsWith('/vox_sw.js'));
    }, null, { timeout: START_MS, polling: 500 }).then(() => true, () => false);
    if (!gesteuert) return fehler('vox_sw.js wurde nicht aktiv bzw. steuert die Seite nicht');
    console.log('✅ vox_sw.js aktiv und steuert die Seite');

    // 2. offline neu laden — mit goto statt reload: page.reload() umgeht bei
    //    Playwrights Offline-Emulation den Service Worker (ERR_INTERNET_DISCONNECTED),
    //    ein echter Browser tut das nicht; goto ist derselbe Seitenaufruf.
    await context.setOffline(true);
    await page.goto(BASIS);
    if (!(await vox_steht(page, 'offline neu geladen'))) return;

    // 3. jede Datei des Vorab-Pakets offline abrufbar
    const { manifestEntries } = await getManifest(manifestConfig);
    const urls = manifestEntries.map((e) => e.url);
    const kaputt = await page.evaluate(async (liste) => {
      const schlecht = [];
      for (const u of liste) {
        try { const r = await fetch(u); if (!r.ok) schlecht.push(`${u} (${r.status})`); }
        catch (e) { schlecht.push(`${u} (${e.message})`); }
      }
      return schlecht;
    }, urls);
    if (kaputt.length) return fehler(`offline nicht abrufbar: ${kaputt.join(', ')}`);
    console.log(`✅ alle ${urls.length} Dateien des Vorab-Pakets offline abrufbar`);

    // 4. neues Fenster, weiter offline
    const page2 = await context.newPage();
    await page2.goto(BASIS);
    if (!(await vox_steht(page2, 'neues Fenster offline'))) return;

    // 5. Start-Adressen (L.3c, web/telegram_guard.js) — je ein NEUES Fenster,
    //    sonst wäre es nur ein Hash-Wechsel ohne Neustart. Weiter offline:
    //    so hängt die Prüfung nicht an telegram.org (das SDK scheitert, das
    //    Säubern muss trotzdem laufen).
    await adresse_pruefen(context, '#tgWebAppData=test&tgWebAppVersion=7.0',
      (h) => h.indexOf('tgWebAppData') < 0, 'Telegram-Start ⇒ Startseite');
    await adresse_pruefen(context, '#/wortschatz?tgWebAppData=test',
      (h) => h.startsWith('#/wortschatz') && h.indexOf('tgWebAppData') < 0, 'Telegram-Start mit Pfad ⇒ Pfad bleibt');
    await adresse_pruefen(context, '#/',
      (h) => h === '#/' || h === '', 'normaler Start #/');
    await adresse_pruefen(context, '#/wortschatz',
      (h) => h.startsWith('#/wortschatz'), 'normaler Start #/wortschatz');
  } finally {
    await browser.close();
    srv.close();
  }
}

main().catch((e) => fehler(e.stack || String(e)));
