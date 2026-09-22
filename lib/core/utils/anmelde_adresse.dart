// FILE: lib/core/utils/anmelde_adresse.dart
// PHASE: P.2 — Passwort-Link (2026-09-22)
// PURPOSE: Entfernt `?token_hash=…&type=recovery` aus der Adresszeile, nachdem
//          der Link eingelöst wurde — ohne Neuladen, der `#/…`-Pfad bleibt.
// Weiche (bedingter Export) wie dokument_sprache.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test`.
export 'anmelde_adresse_io.dart'
    if (dart.library.js_interop) 'anmelde_adresse_web.dart';
