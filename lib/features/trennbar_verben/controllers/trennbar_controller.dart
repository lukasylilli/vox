// FILE: lib/features/trennbar_verben/controllers/trennbar_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trennbar_verb.dart';

final trennbarVerbenProvider = FutureProvider<List<TrennbarVerb>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/trennbar_data.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(TrennbarVerb.fromJson).toList();
});

final trennbarGrammarProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/trennbar_grammar.json');
  return (jsonDecode(raw) as Map<String, dynamic>);
});

// ── Filter state ──────────────────────────────────────────────────────────────

class TrennbarFilter {
  const TrennbarFilter({
    this.cefrLevels   = const {},
    this.prefixTypes  = const {},
    this.topics       = const {},
  });

  final Set<String>      cefrLevels;
  final Set<PrefixType>  prefixTypes;
  final Set<String>      topics;

  TrennbarFilter copyWith({
    Set<String>?     cefrLevels,
    Set<PrefixType>? prefixTypes,
    Set<String>?     topics,
  }) => TrennbarFilter(
        cefrLevels  : cefrLevels  ?? this.cefrLevels,
        prefixTypes : prefixTypes ?? this.prefixTypes,
        topics      : topics      ?? this.topics,
      );

  bool get isEmpty =>
      cefrLevels.isEmpty && prefixTypes.isEmpty && topics.isEmpty;
}

class TrennbarFilterNotifier extends Notifier<TrennbarFilter> {
  @override
  TrennbarFilter build() => const TrennbarFilter();

  void toggleCefr(String level) {
    final s = {...state.cefrLevels};
    s.contains(level) ? s.remove(level) : s.add(level);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleType(PrefixType t) {
    final s = {...state.prefixTypes};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(prefixTypes: s);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(topics: s);
  }

  void reset() => state = const TrennbarFilter();
}

final trennbarFilterProvider =
    NotifierProvider<TrennbarFilterNotifier, TrennbarFilter>(
        TrennbarFilterNotifier.new);

final filteredTrennbarVerbenProvider =
    Provider<AsyncValue<List<TrennbarVerb>>>((ref) {
  final all    = ref.watch(trennbarVerbenProvider);
  final filter = ref.watch(trennbarFilterProvider);

  return all.whenData((verbs) {
    if (filter.isEmpty) return verbs;
    return verbs.where((v) {
      if (filter.cefrLevels.isNotEmpty &&
          !filter.cefrLevels.contains(v.cefrLevel)) { return false; }
      if (filter.prefixTypes.isNotEmpty &&
          !filter.prefixTypes.contains(v.prefixType)) { return false; }
      if (filter.topics.isNotEmpty && !filter.topics.contains(v.topic)) {
        return false;
      }
      return true;
    }).toList();
  });
});
