// FILE: lib/features/verb_praep/controllers/verb_praep_controller.dart
// PURPOSE: Riverpod providers for Verben mit Präpositionen
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/verb_praep.dart';

// ─── Data providers ───────────────────────────────────────────────────────────

final verbPraepProvider = FutureProvider<List<VerbPraep>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/verb_praep_data.json');
  final list = jsonDecode(raw) as List;
  return list.map((e) => VerbPraep.fromJson(e as Map<String, dynamic>)).toList();
});

final verbPraepGrammarProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/verb_praep_grammar.json');
  return jsonDecode(raw) as Map<String, dynamic>;
});

// ─── Filter ───────────────────────────────────────────────────────────────────

class VerbPraepFilter {
  const VerbPraepFilter({
    this.cefrLevels = const {},
    this.prepCases  = const {},
    this.topics     = const {},
  });

  final Set<String>          cefrLevels;
  final Set<PrepositionCase> prepCases;
  final Set<String>          topics;

  bool get isEmpty => cefrLevels.isEmpty && prepCases.isEmpty && topics.isEmpty;

  VerbPraepFilter copyWith({
    Set<String>?          cefrLevels,
    Set<PrepositionCase>? prepCases,
    Set<String>?          topics,
  }) => VerbPraepFilter(
        cefrLevels: cefrLevels ?? this.cefrLevels,
        prepCases : prepCases  ?? this.prepCases,
        topics    : topics     ?? this.topics,
      );
}

class VerbPraepFilterNotifier extends Notifier<VerbPraepFilter> {
  @override
  VerbPraepFilter build() => const VerbPraepFilter();

  void toggleLevel(String l) {
    final s = {...state.cefrLevels};
    s.contains(l) ? s.remove(l) : s.add(l);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleCase(PrepositionCase c) {
    final s = {...state.prepCases};
    s.contains(c) ? s.remove(c) : s.add(c);
    state = state.copyWith(prepCases: s);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(topics: s);
  }

  void clearAll() => state = const VerbPraepFilter();
}

final verbPraepFilterProvider =
    NotifierProvider<VerbPraepFilterNotifier, VerbPraepFilter>(
        VerbPraepFilterNotifier.new);

// ─── Filtered list ────────────────────────────────────────────────────────────

final filteredVerbPraepProvider = Provider<AsyncValue<List<VerbPraep>>>((ref) {
  final all    = ref.watch(verbPraepProvider);
  final filter = ref.watch(verbPraepFilterProvider);

  return all.whenData((list) {
    if (filter.isEmpty) return list;
    return list.where((v) {
      if (filter.cefrLevels.isNotEmpty && !filter.cefrLevels.contains(v.cefrLevel)) {
        return false;
      }
      if (filter.prepCases.isNotEmpty && !filter.prepCases.contains(v.prepositionCase)) {
        return false;
      }
      if (filter.topics.isNotEmpty && !filter.topics.contains(v.topic)) {
        return false;
      }
      return true;
    }).toList();
  });
});
