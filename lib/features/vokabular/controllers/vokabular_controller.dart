// FILE: lib/features/vokabular/controllers/vokabular_controller.dart
// PURPOSE: Lädt die Wort-Karten (SUPER-PROMPT Schema 2.0) des Vokabular-Archivs
//          aus assets/vocab/<wortart>/<id>.json (فاز V, Stufe ۳).
//          ⚠️ Brücke: für die Testphase (wenige Wörter) direkt aus Assets;
//          V.2/V.3 ersetzt NUR diesen Provider durch prebuilt vocab.db —
//          Screens/Widgets bleiben unverändert (gleiche Map-Karten).
//          Inhalt (Karten) ist read-only; User-Zustand (imLeitner, Kategorien)
//          liegt getrennt in vokabular_user_state.dart.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// vokabId (ID-Regel 5) lebt jetzt in vokab_schema.dart (reines Dart) — EINE
// Quelle für App + tool/vokabular_import.dart; hier re-exportiert, damit
// Screens/Tests weiter aus dem Controller importieren können.
export '../data/vokab_schema.dart' show vokabId;

/// Alle Karten des Archivs, sortiert nach Lemma (deutsch).
final vokabularProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final pfade = manifest
      .listAssets()
      .where((p) => p.startsWith('assets/vocab/') && p.endsWith('.json'))
      .toList();

  final karten = <Map<String, dynamic>>[];
  for (final pfad in pfade) {
    karten.add(
        jsonDecode(await rootBundle.loadString(pfad)) as Map<String, dynamic>);
  }
  karten.sort((a, b) => (a['wort'] as String? ?? '')
      .toLowerCase()
      .compareTo((b['wort'] as String? ?? '').toLowerCase()));
  return karten;
});

/// Schneller Lookup id → Karte (für Wort-Seite und Wortnetz-Links).
final vokabularByIdProvider =
    FutureProvider<Map<String, Map<String, dynamic>>>((ref) async {
  final karten = await ref.watch(vokabularProvider.future);
  return {for (final k in karten) (k['id'] as String? ?? ''): k};
});

/// Suche über wort + Übersetzungen (DE / FA / EN).
bool vokabKartePasst(Map<String, dynamic> karte, String query) {
  final q = query.toLowerCase();
  if ((karte['wort'] as String? ?? '').toLowerCase().contains(q)) return true;
  final u = (karte['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
  for (final lang in ['fa', 'en']) {
    final list = (u[lang] as List?)?.cast<String>() ?? const [];
    if (list.any((t) => t.toLowerCase().contains(q))) return true;
  }
  return false;
}
