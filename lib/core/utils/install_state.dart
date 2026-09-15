// FILE: lib/core/utils/install_state.dart
// PHASE: فاز S, Schritt S.1b (2026-09-15)
// PURPOSE: Sagt, ob VOX als Web-App auf der Startseite läuft — und wenn nicht,
//          welche Anleitung der Nutzer braucht.
//
// WARUM DAS ZÄHLT: Safari löscht IndexedDB und localStorage nach sieben Tagen
// Safari-Nutzung ohne Interaktion mit der Seite. Zur Startseite hinzugefügte
// Web-Apps sind davon ausgenommen — sie zählen eigene Nutzungstage. Die
// Einladung zur Installation ist deshalb kein Komfort, sondern der wirksamste
// Schutz gegen stillen Datenverlust (PLAN.md → فاز S).
//
// Weiche (bedingter Export) wie external_link_opener.dart: package:web darf
// NICHT ungeschützt importiert werden, sonst bricht `flutter test`.
export 'install_hinweis.dart';
export 'install_state_io.dart'
    if (dart.library.js_interop) 'install_state_web.dart';
