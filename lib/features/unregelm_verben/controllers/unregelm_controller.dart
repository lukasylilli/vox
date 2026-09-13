// FILE: lib/features/unregelm_verben/controllers/unregelm_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/unregelm_verb.dart';

// ── data providers ────────────────────────────────────────────────────────────

final unregelVerbenProvider = FutureProvider<List<UnregelmVerb>>((ref) async {
  final raw = await rootBundle.loadString(
      'assets/data/unregelm_verb_data.json');
  final list = json.decode(raw) as List<dynamic>;
  return list
      .map((e) => UnregelmVerb.fromJson(e as Map<String, dynamic>))
      .toList();
});

final unregelVerbenGrammarProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString(
      'assets/data/unregelm_verb_grammar.json');
  return json.decode(raw) as Map<String, dynamic>;
});

// ── filter ────────────────────────────────────────────────────────────────────

class UnregelmFilter {
  const UnregelmFilter({
    this.cefrLevels   = const {},
    this.verbClasses  = const {},
    this.topics       = const {},
  });

  final Set<String>    cefrLevels;
  final Set<VerbClass> verbClasses;
  final Set<String>    topics;

  bool get isEmpty =>
      cefrLevels.isEmpty && verbClasses.isEmpty && topics.isEmpty;
}

class UnregelmFilterNotifier extends Notifier<UnregelmFilter> {
  @override
  UnregelmFilter build() => const UnregelmFilter();

  void toggleLevel(String l) {
    final s = {...state.cefrLevels};
    s.contains(l) ? s.remove(l) : s.add(l);
    state = UnregelmFilter(
        cefrLevels: s, verbClasses: state.verbClasses, topics: state.topics);
  }

  void toggleClass(VerbClass c) {
    final s = {...state.verbClasses};
    s.contains(c) ? s.remove(c) : s.add(c);
    state = UnregelmFilter(
        cefrLevels: state.cefrLevels, verbClasses: s, topics: state.topics);
  }

  void toggleTopic(String t) {
    final s = {...state.topics};
    s.contains(t) ? s.remove(t) : s.add(t);
    state = UnregelmFilter(
        cefrLevels: state.cefrLevels, verbClasses: state.verbClasses, topics: s);
  }

  void clearAll() => state = const UnregelmFilter();
}

final unregelVerbenFilterProvider =
    NotifierProvider<UnregelmFilterNotifier, UnregelmFilter>(
        UnregelmFilterNotifier.new);

final filteredUnregelmProvider =
    Provider<AsyncValue<List<UnregelmVerb>>>((ref) {
  final all    = ref.watch(unregelVerbenProvider);
  final filter = ref.watch(unregelVerbenFilterProvider);

  return all.whenData((list) {
    if (filter.isEmpty) return list;
    return list.where((v) {
      if (filter.cefrLevels.isNotEmpty &&
          !filter.cefrLevels.contains(v.cefrLevel)) {
        return false;
      }
      if (filter.verbClasses.isNotEmpty &&
          !filter.verbClasses.contains(v.verbClass)) {
        return false;
      }
      if (filter.topics.isNotEmpty && !filter.topics.contains(v.topic)) {
        return false;
      }
      return true;
    }).toList();
  });
});
