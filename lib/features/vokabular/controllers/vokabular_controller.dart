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
import '../data/vokab_formen.dart';

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

/// Welche Stücke der Formen-Tabelle es gibt (L.5f-Nachtrag 2026-09-23).
final vokabFormenStueckeProvider = FutureProvider<Set<String>>((ref) async {
  final text = await rootBundle.loadString(vokabFormenStueckeDatei);
  return (jsonDecode(text) as List).cast<String>().toSet();
});

/// Ein Stück der Formen-Tabelle: Schlüssel der gebeugten Form → Karten-ids.
final vokabFormenStueckProvider =
    FutureProvider.family<Map<String, List<String>>, String>(
        (ref, datei) async {
  final roh = jsonDecode(await rootBundle.loadString(datei)) as Map;
  return {
    for (final e in roh.entries)
      e.key as String: (e.value as List).cast<String>(),
  };
});

/// Index-Einträge der Karten, zu denen die GEBEUGTE Form [schluessel] gehört
/// («aalartige» ⇒ Karte «aalartig»). Leer, wenn keine.
final vokabNachFormProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, schluessel) async {
  if (schluessel.isEmpty) return const [];
  final datei = vokabFormenDatei(schluessel);
  final stuecke = await ref.watch(vokabFormenStueckeProvider.future);
  if (!stuecke.contains(datei)) return const [];
  final tabelle = await ref.watch(vokabFormenStueckProvider(datei).future);
  final ids = tabelle[schluessel] ?? const <String>[];
  if (ids.isEmpty) return const [];
  final nachId = await ref.watch(vokabIndexByIdProvider.future);
  return [for (final id in ids) if (nachId[id] != null) nachId[id]!];
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
