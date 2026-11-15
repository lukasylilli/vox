// FILE: lib/features/vokabular/data/vokab_karten_lader.dart
// PHASE: V.5 (Audit 2026-11-15, Paket 8.2 — Entscheidung Lukas: Weg «ب»)
// PURPOSE: Die einzige Stelle, die den TEXT einer vollen Wortkarte holt.
//
// WARUM: Bis V.5 lagen die ~20.000 Karten als Flutter-Assets im Paket. Jede
//        Karte stand dadurch im Asset-Verzeichnis (AssetManifest.bin.json),
//        das JEDER Nutzer beim Start lädt und bei jeder Wortrunde neu lädt —
//        gemessen 2,7 MB roh / 300 kB komprimiert, zu 99,6 % nur Kartennamen
//        (docs/PLAN_DETAIL.md → «📏 V.5»). Jetzt liegen die Karten als
//        gewöhnliche Dateien NEBEN der App (build/web/karten/, kopiert in
//        deploy-web.yml); geladen wird weiterhin nur die eine geöffnete Karte.
//
// Quelle im Repository bleibt assets/vocab/ (Werkzeuge, Tests, Wortrunden).
//
// Weiche (bedingter Export) wie datei_io.dart: im Browser per HTTP neben der
// App, in Tests (Dart-VM) direkt aus assets/vocab/ im Projektordner.
export 'vokab_karten_lader_io.dart'
    if (dart.library.js_interop) 'vokab_karten_lader_web.dart';
