// FILE: lib/features/vokabular/controllers/vokabular_controller.dart
// PURPOSE: Wortdaten des Vokabular-Archivs für die App (فاز V).
//
// V.2 (2026-09-16): ZWEI Stufen statt „alles beim Start":
//   · [vokabIndexProvider] — EINE Datei (assets/vocab_index.json) mit den
//     Feldern für Liste, Suche, Zähler und Symbol. Beim Start geladen.
//   · [vokabKarteProvider] — die VOLLE Karte eines Worts, erst beim Öffnen
//     der Wort-Seite (eine Datei aus assets/vocab/<wortart>/<id>.json).
// Vorher las dieser Provider jede Karten-Datei beim Start — im Browser eine
// Netzanfrage je Wort, bei ~26.200 Wörtern nicht mehr lauffähig.
//
// Inhalt ist read-only; der Nutzerzustand (Leitner, Listen, Notizen) liegt
// getrennt in drift (vokabular_user_state.dart → UserStateRepository).
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vokab_index.dart';

// vokabId (ID-Regel 5) lebt in vokab_schema.dart (reines Dart) — EINE
// Quelle für App + tool/vokabular_import.dart; hier re-exportiert, damit
// Screens/Tests weiter aus dem Controller importieren können.
export '../data/vokab_schema.dart' show vokabId;

/// Alle Wörter des Archivs als INDEX-Einträge, sortiert nach Wort.
///
/// ⚠️ Das sind NICHT die vollen Karten — nur id, wort, wortart, niveau,
/// uebersetzung und die Symbol-Felder aus details (vokab_index.dart). Wer
/// Beispiele, Konjugation oder Wortnetz braucht, nimmt [vokabKarteProvider].
final vokabIndexProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return vokabIndexLesen(await rootBundle.loadString(vokabIndexPfad));
});

/// Schneller Lookup id → Index-Eintrag (gibt es das Wort? — Wortnetz-Links,
/// Dativ-Liste).
final vokabIndexByIdProvider =
    FutureProvider<Map<String, Map<String, dynamic>>>((ref) async {
  final eintraege = await ref.watch(vokabIndexProvider.future);
  return {for (final e in eintraege) (e['id'] as String? ?? ''): e};
});

/// Die VOLLE Karte eines Worts — erst beim Öffnen geladen. `null`, wenn es
/// die id im Archiv nicht gibt. Der Pfad folgt aus Wortart + id; dass jede
/// Datei genau dort liegt, prüft der Index-Bau (sonst bleibt der Bau rot).
final vokabKarteProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final eintrag = (await ref.watch(vokabIndexByIdProvider.future))[id];
  if (eintrag == null) return null;
  final text = await rootBundle
      .loadString(vokabKartenPfad(eintrag['wortart'] as String, id));
  return jsonDecode(text) as Map<String, dynamic>;
});

/// Suche über wort + Übersetzungen (DE / FA / EN). Funktioniert für volle
/// Karten und Index-Einträge gleich (gleiche Schlüssel).
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
