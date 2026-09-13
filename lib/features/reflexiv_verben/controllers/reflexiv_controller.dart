// FILE: lib/features/reflexiv_verben/controllers/reflexiv_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reflexiv_verb.dart';

final reflexivVerbenProvider = FutureProvider<List<ReflexivVerb>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/reflexiv_data.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map(ReflexivVerb.fromJson).toList();
});

final reflexivGrammarProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/reflexiv_grammar.json');
  return (jsonDecode(raw) as Map<String, dynamic>);
});

// ── Filter state ──────────────────────────────────────────────────────────────

class ReflexivFilter {
  const ReflexivFilter({
    this.cefrLevels      = const {},
    this.reflexivityTypes = const {},
    this.topics          = const {},
  });

  final Set<String>            cefrLevels;
  final Set<ReflexivityType>   reflexivityTypes;
  final Set<String>            topics;

  ReflexivFilter copyWith({
    Set<String>?           cefrLevels,
    Set<ReflexivityType>?  reflexivityTypes,
    Set<String>?           topics,
  }) => ReflexivFilter(
        cefrLevels       : cefrLevels       ?? this.cefrLevels,
        reflexivityTypes : reflexivityTypes  ?? this.reflexivityTypes,
        topics           : topics           ?? this.topics,
      );

  bool get isEmpty =>
      cefrLevels.isEmpty && reflexivityTypes.isEmpty && topics.isEmpty;
}

class ReflexivFilterNotifier extends Notifier<ReflexivFilter> {
  @override
  ReflexivFilter build() => const ReflexivFilter();

  void toggleCefr(String level) {
    final s = {...state.cefrLevels};
    s.contains(level) ? s.remove(level) : s.add(level);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleType(ReflexivityType t) {
    final s = {...state.reflexivityTypes};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(reflexivityTypes: s);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = state.copyWith(topics: s);
  }

  void reset() => state = const ReflexivFilter();
}

final reflexivFilterProvider =
    NotifierProvider<ReflexivFilterNotifier, ReflexivFilter>(
        ReflexivFilterNotifier.new);

final filteredReflexivVerbenProvider =
    Provider<AsyncValue<List<ReflexivVerb>>>((ref) {
  final all    = ref.watch(reflexivVerbenProvider);
  final filter = ref.watch(reflexivFilterProvider);

  return all.whenData((verbs) {
    if (filter.isEmpty) return verbs;
    return verbs.where((v) {
      if (filter.cefrLevels.isNotEmpty &&
          !filter.cefrLevels.contains(v.cefrLevel)) { return false; }
      if (filter.reflexivityTypes.isNotEmpty &&
          !filter.reflexivityTypes.contains(v.reflexivityType)) { return false; }
      if (filter.topics.isNotEmpty && !filter.topics.contains(v.topic)) {
        return false;
      }
      return true;
    }).toList();
  });
});
