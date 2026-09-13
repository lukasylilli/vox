// FILE: lib/features/redemittel/controllers/redemittel_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemittel_item.dart';

// ─── Raw loaders ────────────────────────────────────────────────────────────

List<RedemittelItem> _parse(String raw) =>
    (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(RedemittelItem.fromJson)
        .toList();

final redemittelGoetheB2Provider = FutureProvider<List<RedemittelItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/redemittel_goethe_b2.json');
  return _parse(raw);
});

final redemittelOesdB2Provider = FutureProvider<List<RedemittelItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/redemittel_oesd_b2.json');
  return _parse(raw);
});

final redemittelOesdC1Provider = FutureProvider<List<RedemittelItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/redemittel_oesd_c1.json');
  return _parse(raw);
});

final redemittel1010Provider = FutureProvider<List<RedemittelItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/redemittel_1010.json');
  return _parse(raw);
});

// ─── Filter state ────────────────────────────────────────────────────────────

class Redemittel1010Filter {
  const Redemittel1010Filter({
    this.cefrLevels  = const {},
    this.topics      = const {},
    this.registers   = const {},
    this.grammarPats = const {},
    this.query       = '',
  });

  final Set<String> cefrLevels;
  final Set<String> topics;
  final Set<String> registers;
  final Set<String> grammarPats;
  final String      query;

  bool get isEmpty =>
      cefrLevels.isEmpty && topics.isEmpty &&
      registers.isEmpty && grammarPats.isEmpty && query.isEmpty;

  Redemittel1010Filter copyWith({
    Set<String>? cefrLevels,
    Set<String>? topics,
    Set<String>? registers,
    Set<String>? grammarPats,
    String?      query,
  }) => Redemittel1010Filter(
    cefrLevels  : cefrLevels  ?? this.cefrLevels,
    topics      : topics      ?? this.topics,
    registers   : registers   ?? this.registers,
    grammarPats : grammarPats ?? this.grammarPats,
    query       : query       ?? this.query,
  );
}

class Redemittel1010FilterNotifier extends Notifier<Redemittel1010Filter> {
  @override
  Redemittel1010Filter build() => const Redemittel1010Filter();

  void toggleCefr(String v) {
    final s = {...state.cefrLevels};
    s.contains(v) ? s.remove(v) : s.add(v);
    state = state.copyWith(cefrLevels: s);
  }

  void toggleTopic(String v) {
    final s = {...state.topics};
    s.contains(v) ? s.remove(v) : s.add(v);
    state = state.copyWith(topics: s);
  }

  void toggleRegister(String v) {
    final s = {...state.registers};
    s.contains(v) ? s.remove(v) : s.add(v);
    state = state.copyWith(registers: s);
  }

  void toggleGrammar(String v) {
    final s = {...state.grammarPats};
    s.contains(v) ? s.remove(v) : s.add(v);
    state = state.copyWith(grammarPats: s);
  }

  void setQuery(String q) => state = state.copyWith(query: q.toLowerCase().trim());

  void clearAll() => state = const Redemittel1010Filter();
}

final redemittel1010FilterProvider =
    NotifierProvider<Redemittel1010FilterNotifier, Redemittel1010Filter>(
        Redemittel1010FilterNotifier.new);

// ─── Filtered list ───────────────────────────────────────────────────────────

final filteredRedemittel1010Provider = Provider<AsyncValue<List<RedemittelItem>>>((ref) {
  final allAsync = ref.watch(redemittel1010Provider);
  final filter   = ref.watch(redemittel1010FilterProvider);

  return allAsync.whenData((all) {
    if (filter.isEmpty) return all;

    return all.where((p) {
      if (filter.cefrLevels.isNotEmpty &&
          !filter.cefrLevels.contains(p.cefrLevel.toUpperCase())) { return false; }
      if (filter.topics.isNotEmpty && !filter.topics.contains(p.topic)) { return false; }
      if (filter.registers.isNotEmpty && !filter.registers.contains(p.register)) { return false; }
      if (filter.grammarPats.isNotEmpty &&
          !filter.grammarPats.contains(p.grammarPattern)) { return false; }
      if (filter.query.isNotEmpty) {
        final q = filter.query;
        if (!p.phraseDe.toLowerCase().contains(q) &&
            !p.phraseFa.contains(q) &&
            !p.phraseEn.toLowerCase().contains(q) &&
            !p.sectionTitleDe.toLowerCase().contains(q) &&
            !p.sectionTitleFa.contains(q) &&
            !p.sectionTitleEn.toLowerCase().contains(q)) { return false; }
      }
      return true;
    }).toList();
  });
});

// ─── Section grouping helper ─────────────────────────────────────────────────

/// Groups a flat list into ordered sections.
/// Returns list of (sectionTitleDe, sectionTitleFa, sectionTitleEn, phrases).
List<(String, String, String, List<RedemittelItem>)> groupBySectionTitle(
    List<RedemittelItem> items) {
  final seen   = <String>[];
  final groups = <String, List<RedemittelItem>>{};
  for (final p in items) {
    final key = p.sectionTitleDe;
    if (!groups.containsKey(key)) {
      seen.add(key);
      groups[key] = [];
    }
    groups[key]!.add(p);
  }
  return [
    for (final k in seen)
      (k, groups[k]!.first.sectionTitleFa,
       groups[k]!.first.sectionTitleEn, groups[k]!),
  ];
}
