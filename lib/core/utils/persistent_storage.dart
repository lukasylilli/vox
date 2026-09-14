// FILE: lib/core/utils/persistent_storage.dart
// PHASE: فاز S, Schritt S.1 (2026-09-15)
// PURPOSE: Bittet den Browser, den Speicher dieser Seite dauerhaft zu behalten.
//          Liefert true, wenn er zusagt.
//
// HERKUNFT: übernommen aus Root-in —
//   repo   github.com/lukasylilli/Root-in
//   pfad   lib/core/services/web_storage/request_persistent_storage.dart
//   commit 607cba65c2dcd94ebc25358e718da1e2f9c2fc93
//   datum  2026-09-15
// Bewusst kopiert statt geteilt (PLAN.md → فاز S): beide Repos bleiben
// eigenständig. tool/check_vendored.py meldet, wenn das Original sich ändert.
//
// Hintergrund: Im Browser liegen die Daten im Speicher der Website, und den
// darf der Browser bei Platzmangel aufräumen. Mit dieser Bitte stuft er die
// Seite als wichtig ein und räumt sie zuletzt oder gar nicht ab.
//
// ⚠️ Das ist eine Bitte, KEINE Garantie. Browser entscheiden selbst, manche
//    fragen gar nicht erst. Die eigentliche Absicherung bleibt Export/Import
//    (S.2) und das Konto (S.3). Gegen Safaris Sieben-Tage-Regel hilft vor
//    allem, die App zur Startseite hinzuzufügen — solche Web-Apps sind davon
//    ausgenommen.
//
// Weiche (bedingter Export) wie external_link_opener.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test` auf der
// Dart-VM — `flutter analyze` bemerkt das nicht.
export 'persistent_storage_io.dart'
    if (dart.library.js_interop) 'persistent_storage_web.dart';
