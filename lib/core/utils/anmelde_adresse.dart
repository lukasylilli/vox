// FILE: lib/core/utils/anmelde_adresse.dart
// PHASE: P.2 — Passwort-Link (2026-09-22, umgebaut 2026-09-23)
// PURPOSE: Räumt nach `Supabase.initialize` die Reste eines Mail-Links aus der
//          Adresszeile (`?link=passwort`, `#access_token=…`, `#error=…`, `#sb=`)
//          — ohne Neuladen, ein echter `#/…`-Pfad bleibt. Was weg muss,
//          entscheidet die reine Funktion `bereinigteAnmeldeAdresse`
//          (`anmelde_ruecklauf.dart`). Aufruf: `main.dart`, vor `runApp`.
// Weiche (bedingter Export) wie dokument_sprache.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test`.
export 'anmelde_adresse_io.dart'
    if (dart.library.js_interop) 'anmelde_adresse_web.dart';
