// FILE: lib/features/praepositionen/controllers/praepositionen_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/praep_cluster.dart';

final praepClusterProvider = FutureProvider<List<PraepCluster>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/praepositionen_data.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(PraepCluster.fromJson).toList();
});

class PraepFilter {
  const PraepFilter({
    this.cefrLevels  = const {},
    this.wordClasses = const {},
    this.cases       = const {},
  });

  final Set<String> cefrLevels;
  final Set<String> wordClasses;  // verb / adjective / noun
  final Set<String> cases;        // akkusativ / dativ

  PraepFilter copyWith({
    Set<String>? cefrLevels,
    Set<String>? wordClasses,
    Set<String>? cases,
  }) => PraepFilter(
        cefrLevels  : cefrLevels  ?? this.cefrLevels,
        wordClasses : wordClasses ?? this.wordClasses,
        cases       : cases       ?? this.cases,
      );

  bool get isEmpty =>
      cefrLevels.isEmpty && wordClasses.isEmpty && cases.isEmpty;
}

class PraepFilterNotifier extends Notifier<PraepFilter> {
  @override
  PraepFilter build() => const PraepFilter();

  void toggleCefr(String level) {
    final s = {...state.cefrLevels};
    s.contains(level) ? s.remove(level) : s.add(level);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleWordClass(String wc) {
    final s = {...state.wordClasses};
    s.contains(wc) ? s.remove(wc) : s.add(wc);
    state = state.copyWith(wordClasses: s);
  }

  void toggleCase(String c) {
    final s = {...state.cases};
    s.contains(c) ? s.remove(c) : s.add(c);
    state = state.copyWith(cases: s);
  }

  void reset() => state = const PraepFilter();
}

final praepFilterProvider =
    NotifierProvider<PraepFilterNotifier, PraepFilter>(PraepFilterNotifier.new);

final filteredPraepProvider = Provider<AsyncValue<List<PraepCluster>>>((ref) {
  final all    = ref.watch(praepClusterProvider);
  final filter = ref.watch(praepFilterProvider);

  return all.whenData((clusters) {
    if (filter.isEmpty) return clusters;
    return clusters.where((c) {
      if (filter.cefrLevels.isNotEmpty &&
          !filter.cefrLevels.contains(c.cefrLevel)) {
        return false;
      }
      if (filter.wordClasses.isNotEmpty &&
          !c.members.any((m) => filter.wordClasses.contains(m.wordClass))) {
        return false;
      }
      if (filter.cases.isNotEmpty &&
          !c.members.any((m) => filter.cases.contains(m.grammaticalCase))) {
        return false;
      }
      return true;
    }).toList();
  });
});
