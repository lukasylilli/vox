// FILE: lib/features/grammatik/controllers/grammatik_lektion_controller.dart
// DEPS: grammatik_lektion.dart
// PURPOSE: Lädt Content-JSONs (assets/data/grammatik/*.json) und indexiert
//          alle Lektionen nach slug (Stufe G2). Neue Content-Datei:
//          in grammatikContentFiles eintragen — kein weiterer Code nötig.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammatik_lektion.dart';

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
