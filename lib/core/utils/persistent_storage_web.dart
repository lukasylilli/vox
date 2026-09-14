// FILE: lib/core/utils/persistent_storage_web.dart
// PURPOSE: Browser-Fassung — siehe persistent_storage.dart.
// HERKUNFT: Root-in · lib/core/services/web_storage/request_persistent_storage_web.dart
//           commit 607cba65c2dcd94ebc25358e718da1e2f9c2fc93 · 2026-09-15
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> requestPersistentStorage() async {
  try {
    // Erst fragen, ob der Speicher schon dauerhaft ist. Ein zweites persist()
    // schadet nicht, aber manche Browser koppeln die Bitte an eine Rückfrage
    // beim Nutzer — die soll er nicht bei jedem Start sehen.
    final schon = await web.window.navigator.storage.persisted().toDart;
    if (schon.toDart) return true;

    final zugesagt = await web.window.navigator.storage.persist().toDart;
    return zugesagt.toDart;
  } catch (_) {
    // Ältere Browser kennen die Schnittstelle nicht. Das ist kein Fehler, der
    // den Start aufhalten darf — die App läuft auch ohne Zusage.
    return false;
  }
}
