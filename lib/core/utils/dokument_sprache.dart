// FILE: lib/core/utils/dokument_sprache.dart
// PHASE: فاز LAUNCH / L.3 — Startsprache (2026-09-16)
// PURPOSE: Setzt `<html lang="…">` auf die aktive Oberflächensprache, damit
//          der Browser die Seite richtig einordnet (z. B. keine Übersetzung
//          „aus dem Persischen" für eine englische Oberfläche anbietet).
// Weiche (bedingter Export) wie external_link_opener.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test`.
export 'dokument_sprache_io.dart'
    if (dart.library.js_interop) 'dokument_sprache_web.dart';
