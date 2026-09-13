// FILE: lib/features/grammatik/controllers/grammatik_lektion_controller.dart
// DEPS: grammatik_lektion.dart
// PURPOSE: Lädt Content-JSONs (assets/data/grammatik/*.json) und indexiert
//          alle Lektionen nach slug (Stufe G2). Neue Import-Batches (G3–G6):
//          Datei zu _contentFiles hinzufügen — kein weiterer Code nötig.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammatik_lektion.dart';

/// Content-JSON-Dateien pro Thema. G3–G6 fügen hier je eine Zeile hinzu.
const _contentFiles = <String>[
  'assets/data/grammatik/verben-grundlagen.json',
];

/// slug → GrammatikLektion (aus allen Content-Dateien gemerged).
final grammatikLektionenProvider =
    FutureProvider<Map<String, GrammatikLektion>>((ref) async {
  final out = <String, GrammatikLektion>{};
  for (final path in _contentFiles) {
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
