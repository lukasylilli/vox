// FILE: lib/features/dativ_verben/controllers/dativ_verben_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dativ_verb.dart';

final dativVerbenProvider = FutureProvider<List<DativVerb>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/dativ_akkusativ_data.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(DativVerb.fromJson).toList();
});

// Filter state
class DativFilter {
  const DativFilter({
    this.cefrLevels  = const {},
    this.caseTypes   = const {},
    this.topics      = const {},
  });

  final Set<String>   cefrLevels;
  final Set<CaseType> caseTypes;
  final Set<String>   topics;

  DativFilter copyWith({
    Set<String>?   cefrLevels,
    Set<CaseType>? caseTypes,
    Set<String>?   topics,
  }) => DativFilter(
        cefrLevels : cefrLevels  ?? this.cefrLevels,
        caseTypes  : caseTypes   ?? this.caseTypes,
        topics     : topics      ?? this.topics,
      );

  bool get isEmpty => cefrLevels.isEmpty && caseTypes.isEmpty && topics.isEmpty;
}

class DativFilterNotifier extends Notifier<DativFilter> {
  @override
  DativFilter build() => const DativFilter();

  void toggleCefr(String level) {
    final s = {...state.cefrLevels};
    s.contains(level) ? s.remove(level) : s.add(level);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleCaseType(CaseType ct) {
    final s = {...state.caseTypes};
    s.contains(ct) ? s.remove(ct) : s.add(ct);
    state = state.copyWith(caseTypes: s);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(topics: s);
  }

  void reset() => state = const DativFilter();
}

final dativFilterProvider =
    NotifierProvider<DativFilterNotifier, DativFilter>(DativFilterNotifier.new);

// Grammar JSON model
final dativGrammarProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/dativ_akkusativ_grammar.json');
  return (jsonDecode(raw) as Map<String, dynamic>);
});

final filteredDativVerbenProvider = Provider<AsyncValue<List<DativVerb>>>((ref) {
  final all    = ref.watch(dativVerbenProvider);
  final filter = ref.watch(dativFilterProvider);

  return all.whenData((verbs) {
    if (filter.isEmpty) return verbs;
    return verbs.where((v) {
      if (filter.cefrLevels.isNotEmpty && !filter.cefrLevels.contains(v.cefrLevel)) return false;
      if (filter.caseTypes.isNotEmpty  && !filter.caseTypes.contains(v.caseType))  return false;
      if (filter.topics.isNotEmpty     && !filter.topics.contains(v.topic))         return false;
      return true;
    }).toList();
  });
});
