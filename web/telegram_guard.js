// FILE: web/telegram_guard.js
// PHASE: فاز LAUNCH / L.3c — Start als Telegram-Mini-App (2026-09-24)
//
// PROBLEM: Telegram hängt beim Öffnen der Mini-App seine Startdaten an die
// Adresse: `#tgWebAppData=…&tgWebAppVersion=…&tgWebAppPlatform=…` (bei einer
// Adresse mit eigenem Pfad auch `#/pfad?tgWebAppData=…`). VOX nutzt go_router
// mit Hash-Adressen — `#…` IST der Pfad. Der Router liest also
// `tgWebAppData=…` als Seite und zeigt „GoException: no routes for location".
//
// LÖSUNG: Dieses Skript läuft in `web/index.html` VOR flutter_bootstrap.js und
// greift NUR ein, wenn die Adresse `tgWebAppData` enthält (normale Browser-
// und PWA-Starts bleiben völlig unberührt, `#/` und `#/…` wie bisher):
//   1. Telegrams offizielles SDK (telegram-web-app.js) laden — synchron und
//      VOR dem Säubern, denn das SDK liest seine Startdaten selbst aus
//      `location.hash` (danach: `Telegram.WebApp.initData` / `initDataUnsafe`,
//      und das SDK merkt sie sich für ein Neuladen in sessionStorage).
//   2. Die Telegram-Teile aus der Adresse entfernen (history.replaceState,
//      ohne Neuladen). Ein echter VOX-Pfad davor (`#/pfad?tgWebAppData=…`)
//      bleibt erhalten; sonst beginnt VOX auf der Startseite.
//
// Warum das SDK nur in Telegram geladen wird: Ein synchrones <script> von
// telegram.org im <head> würde JEDEN Start blockieren, bis telegram.org
// antwortet — offline und dort, wo telegram.org gesperrt ist, sehr lange.
// Scheitert das Laden (offline, gesperrt), läuft Schritt 2 trotzdem.
//
// ⚠️ Nutzerdaten NIE aus der Adresse lesen, sondern nur aus
// `window.Telegram.WebApp.initData` (bzw. `initDataUnsafe` für Anzeige);
// alles, was vertraut werden soll, muss der Server mit initData prüfen.
(function () {
  'use strict';
  var MARKE = 'tgWebAppData';
  if (location.hash.indexOf(MARKE) < 0) return;

  // Aufgerufen direkt NACH dem SDK (siehe document.write unten) — auch wenn
  // das SDK nicht geladen werden konnte.
  window.__voxTelegramAdresseSaeubern = function () {
    try { delete window.__voxTelegramAdresseSaeubern; } catch (e) { /* alt */ }
    var hash = location.hash;
    if (hash.indexOf(MARKE) < 0) return;
    // `#/pfad?tgWebAppData=…` ⇒ `#/pfad`; alles andere ⇒ ohne `#`.
    var pfad = '';
    var frage = hash.indexOf('?');
    if (hash.charAt(1) === '/' && frage > 1 && frage < hash.indexOf(MARKE)) {
      pfad = hash.slice(0, frage);
    }
    history.replaceState(null, '', location.pathname + location.search + pfad);
  };

  // document.write, weil nur so ein bedingt geladenes Skript den Parser
  // anhält, bevor flutter_bootstrap.js startet. Das zweite <script> läuft
  // garantiert erst nach dem SDK (geladen oder gescheitert).
  document.write(
    '<script src="https://telegram.org/js/telegram-web-app.js"><\/script>' +
    '<script>window.__voxTelegramAdresseSaeubern &&' +
    ' window.__voxTelegramAdresseSaeubern();<\/script>'
  );
})();
