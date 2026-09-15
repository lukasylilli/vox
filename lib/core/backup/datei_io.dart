// FILE: lib/core/backup/datei_io.dart
// PHASE: فاز S, Schritt S.2 (2026-09-15)
// PURPOSE: Die einzige Stelle, die eine Datei beim Nutzer öffnet oder ablegt.
//          Getrennt von backup_service.dart, damit die Sicherungslogik ohne
//          Browser prüfbar bleibt.
//
// Weiche (bedingter Export) wie external_link_opener.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test`.
export 'datei_io_io.dart'
    if (dart.library.js_interop) 'datei_io_web.dart';
