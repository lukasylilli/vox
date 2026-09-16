// FILE: lib/features/grammatik/controllers/grammatik_lektion_controller.dart
// DEPS: grammatik_lektion.dart
// PURPOSE: Lädt Content-JSONs (assets/data/grammatik/*.json) und indexiert
//          alle Lektionen nach slug (Stufe G2). Neue Content-Datei:
//          in grammatikContentFiles eintragen — kein weiterer Code nötig.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammatik_lektion.dart';
import '../models/grammatik_niveautest.dart';
import '../models/grammatik_uebung.dart';

/// Content-JSON-Dateien pro Thema — alle 17 Dateien der Quelle
/// (`old files Lukasalmani/1/Grammatik`), zusammen die 84 Kern-Lektionen
/// (G3–G6, 2026-09-16). test/grammatik_lektionen_test.dart prüft, dass jede
/// Datei in assets/data/grammatik/ hier steht.
const grammatikContentFiles = <String>[
  'assets/data/grammatik/verben-grundlagen.json',
  'assets/data/grammatik/verben-erweitert.json',
  'assets/data/grammatik/tempus.json',
  'assets/data/grammatik/passiv.json',
  'assets/data/grammatik/konjunktiv.json',
  'assets/data/grammatik/verbergaenzungen.json',
  'assets/data/grammatik/ergaenzungssaetze.json',
  'assets/data/grammatik/nomen.json',
  'assets/data/grammatik/artikel.json',
  'assets/data/grammatik/adjektive.json',
  'assets/data/grammatik/adverbien.json',
  'assets/data/grammatik/pronomen.json',
  'assets/data/grammatik/praepositionen.json',
  'assets/data/grammatik/satzlehre-misc.json',
  'assets/data/grammatik/satzlehre-grundlagen.json',
  'assets/data/grammatik/nebensaetze-semantisch.json',
  'assets/data/grammatik/temporalsaetze.json',
];

/// slug → GrammatikLektion (aus allen Content-Dateien gemerged).
final grammatikLektionenProvider =
    FutureProvider<Map<String, GrammatikLektion>>((ref) async {
  final out = <String, GrammatikLektion>{};
  for (final path in grammatikContentFiles) {
    late final String raw;
    try {
      raw = await rootBundle.loadString(path);
    } catch (_) {
      continue; // Datei fehlt noch (Batch nicht importiert) → überspringen
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    for (final l in (json['lessons'] as List<dynamic>? ?? [])) {
      final lek = GrammatikLektion.fromJson(l as Map<String, dynamic>);
      out[lek.slug] = lek;
    }
  }
  return out;
});

/// Einzelne Lektion nach slug (null, wenn noch nicht importiert).
final grammatikLektionProvider =
    FutureProvider.family<GrammatikLektion?, String>((ref, slug) async {
  final all = await ref.watch(grammatikLektionenProvider.future);
  return all[slug];
});

/// G7a (2026-09-16): alle Übungen der Content-Dateien, nach Lektion
/// gruppiert (slug → Übungen in Quell-Reihenfolge). Übungen, die das Modell
/// nicht sicher lesen kann, fehlen hier — der Test verlangt, dass das bei
/// den echten Daten keine einzige ist.
final grammatikUebungenProvider =
    FutureProvider<Map<String, List<GrammatikUebung>>>((ref) async {
  final out = <String, List<GrammatikUebung>>{};
  for (final path in grammatikContentFiles) {
    late final String raw;
    try {
      raw = await rootBundle.loadString(path);
    } catch (_) {
      continue;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    for (final e in (json['exercises'] as List<dynamic>? ?? [])) {
      if (e is! Map<String, dynamic>) continue;
      final u = GrammatikUebung.ausJson(e);
      if (u == null) continue;
      (out[u.lektionSlug] ??= []).add(u);
    }
  }
  return out;
});

/// Übungen einer Lektion (leer, wenn es keine gibt).
final grammatikLektionUebungenProvider =
    FutureProvider.family<List<GrammatikUebung>, String>((ref, slug) async {
  final all = await ref.watch(grammatikUebungenProvider.future);
  return all[slug] ?? const [];
});

/// G7b: Einstellungen des Niveau-Tests (null ⇒ kein Test anbieten).
const grammatikNiveauTestDatei = 'assets/data/grammatik_niveautest.json';

final grammatikNiveauTestProvider =
    FutureProvider<GrammatikNiveauTest?>((ref) async {
  try {
    final raw = await rootBundle.loadString(grammatikNiveauTestDatei);
    return GrammatikNiveauTest.ausJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
