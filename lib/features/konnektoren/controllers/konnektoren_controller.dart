// FILE: lib/features/konnektoren/controllers/konnektoren_controller.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/konnektor.dart';
import '../models/konnektor_rich.dart';

// ─── data providers ──────────────────────────────────────────────────────────

final konnektorenProvider = FutureProvider<List<Konnektor>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/konnektoren_data.json');
  final list = jsonDecode(raw) as List;
  return list
      .cast<Map<String, dynamic>>()
      .map(Konnektor.fromJson)
      .toList();
});

final konnektorenRichProvider =
    FutureProvider<Map<int, KonnektorRich>>((ref) async {
  final raw  = await rootBundle.loadString('assets/data/konnektoren_rich.json');
  final list = jsonDecode(raw) as List;
  final map  = <int, KonnektorRich>{};
  for (final item in list.cast<Map<String, dynamic>>()) {
    final r = KonnektorRich.fromJson(item);
    map[r.id] = r;
  }
  return map;
});

final konnektorenGrammarProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/konnektoren_grammar.json');
  return jsonDecode(raw) as Map<String, dynamic>;
});

// ─── filter ──────────────────────────────────────────────────────────────────

class KonnektorFilter {
  const KonnektorFilter({
    this.cefrLevels       = const {},
    this.connectorTypes   = const {},
    this.semanticRoles    = const {},
    this.wordOrderEffects = const {},
  });

  final Set<String>          cefrLevels;
  final Set<ConnectorType>   connectorTypes;
  final Set<SemanticRole>    semanticRoles;
  final Set<WordOrderEffect> wordOrderEffects;

  bool get isEmpty =>
      cefrLevels.isEmpty &&
      connectorTypes.isEmpty &&
      semanticRoles.isEmpty &&
      wordOrderEffects.isEmpty;
}

class KonnektorFilterNotifier extends Notifier<KonnektorFilter> {
  @override
  KonnektorFilter build() => const KonnektorFilter();

  void toggleCefr(String lvl) => state = KonnektorFilter(
    cefrLevels      : _toggle(state.cefrLevels, lvl),
    connectorTypes  : state.connectorTypes,
    semanticRoles   : state.semanticRoles,
    wordOrderEffects: state.wordOrderEffects,
  );

  void toggleType(ConnectorType ct) => state = KonnektorFilter(
    cefrLevels      : state.cefrLevels,
    connectorTypes  : _toggle(state.connectorTypes, ct),
    semanticRoles   : state.semanticRoles,
    wordOrderEffects: state.wordOrderEffects,
  );

  void toggleSemanticRole(SemanticRole r) => state = KonnektorFilter(
    cefrLevels      : state.cefrLevels,
    connectorTypes  : state.connectorTypes,
    semanticRoles   : _toggle(state.semanticRoles, r),
    wordOrderEffects: state.wordOrderEffects,
  );

  void toggleWordOrderEffect(WordOrderEffect e) => state = KonnektorFilter(
    cefrLevels      : state.cefrLevels,
    connectorTypes  : state.connectorTypes,
    semanticRoles   : state.semanticRoles,
    wordOrderEffects: _toggle(state.wordOrderEffects, e),
  );

  void reset() => state = const KonnektorFilter();

  Set<T> _toggle<T>(Set<T> s, T v) {
    final n = Set<T>.from(s);
    if (n.contains(v)) { n.remove(v); } else { n.add(v); }
    return n;
  }
}

final konnektorFilterProvider =
    NotifierProvider<KonnektorFilterNotifier, KonnektorFilter>(
        KonnektorFilterNotifier.new);

final filteredKonnektorenProvider =
    Provider<AsyncValue<List<Konnektor>>>((ref) {
  final all    = ref.watch(konnektorenProvider);
  final filter = ref.watch(konnektorFilterProvider);

  return all.when(
    loading: () => const AsyncValue.loading(),
    error  : (e, st) => AsyncValue.error(e, st),
    data   : (list) {
      if (filter.isEmpty) return AsyncValue.data(list);
      return AsyncValue.data(list.where((k) {
        if (filter.cefrLevels.isNotEmpty &&
            !filter.cefrLevels.contains(k.cefrLevel)) { return false; }
        if (filter.connectorTypes.isNotEmpty &&
            !filter.connectorTypes.contains(k.connectorType)) { return false; }
        if (filter.semanticRoles.isNotEmpty &&
            !filter.semanticRoles.contains(k.semanticRole)) { return false; }
        if (filter.wordOrderEffects.isNotEmpty &&
            !filter.wordOrderEffects.contains(k.wordOrderEffect)) { return false; }
        return true;
      }).toList());
    },
  );
});
