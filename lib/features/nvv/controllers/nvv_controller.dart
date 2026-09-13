// FILE: lib/features/nvv/controllers/nvv_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nvv_phrase.dart';

final nvvPhrasesProvider = FutureProvider<List<NvvPhrase>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/nvv_data.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(NvvPhrase.fromJson).toList();
});

class NvvFilter {
  const NvvFilter({
    this.cefrLevels      = const {},
    this.topics          = const {},
    this.onlyPreposition = false,
  });

  final Set<String> cefrLevels;
  final Set<String> topics;
  final bool        onlyPreposition;

  NvvFilter copyWith({
    Set<String>? cefrLevels,
    Set<String>? topics,
    bool?        onlyPreposition,
  }) => NvvFilter(
        cefrLevels      : cefrLevels      ?? this.cefrLevels,
        topics          : topics          ?? this.topics,
        onlyPreposition : onlyPreposition ?? this.onlyPreposition,
      );

  bool get isEmpty => cefrLevels.isEmpty && topics.isEmpty && !onlyPreposition;
}

class NvvFilterNotifier extends Notifier<NvvFilter> {
  @override
  NvvFilter build() => const NvvFilter();

  void toggleCefr(String level) {
    final s = {...state.cefrLevels};
    s.contains(level) ? s.remove(level) : s.add(level);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(topics: s);
  }

  void togglePrepositionOnly() =>
      state = state.copyWith(onlyPreposition: !state.onlyPreposition);

  void reset() => state = const NvvFilter();
}

final nvvFilterProvider =
    NotifierProvider<NvvFilterNotifier, NvvFilter>(NvvFilterNotifier.new);

final filteredNvvProvider = Provider<AsyncValue<List<NvvPhrase>>>((ref) {
  final all    = ref.watch(nvvPhrasesProvider);
  final filter = ref.watch(nvvFilterProvider);

  return all.whenData((phrases) {
    if (filter.isEmpty) return phrases;
    return phrases.where((p) {
      if (filter.cefrLevels.isNotEmpty && !filter.cefrLevels.contains(p.cefrLevel)) return false;
      if (filter.topics.isNotEmpty     && !filter.topics.contains(p.topic))         return false;
      if (filter.onlyPreposition       && !p.hasPreposition)                        return false;
      return true;
    }).toList();
  });
});
