// FILE: lib/features/home/controllers/search_controller.dart
// DEPS: app_database.dart
// PURPOSE: Globale Suche — Wörter + Grammatik + Auswendiglernen parallel durchsuchen
import 'package:drift/drift.dart' hide Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../../../core/l10n/app_l10n.dart';

// ── Result model ──────────────────────────────────────────────────────────────

enum SearchResultType { word, grammarLesson, memorizePhrases }

class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final SearchResultType type;
  final int              id;
  final String           title;
  final String           subtitle;
  final String           route;
}

// ── Query state ───────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.query   = '',
    this.results = const [],
    this.loading = false,
  });

  final String             query;
  final List<SearchResult> results;
  final bool               loading;

  SearchState copyWith({
    String?             query,
    List<SearchResult>? results,
    bool?               loading,
  }) =>
      SearchState(
        query  : query   ?? this.query,
        results: results ?? this.results,
        loading: loading ?? this.loading,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GlobalSearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: q, loading: true);

    final results = <SearchResult>[];
    final like    = '%$q%';

    // Words
    final words = await (_db.select(_db.words)
          ..where((t) =>
              t.german.like(like) |
              t.meaningFa.like(like)))
        .get();
    for (final w in words) {
      results.add(SearchResult(
        type    : SearchResultType.word,
        id      : w.id,
        title   : w.german,
        subtitle: AppL10n.activeLang == 'fa'
            ? w.meaningFa
            : (w.meaningEn ?? w.meaningFa),
        route   : '/wortschatz/word/${w.id}',
      ));
    }

    // Grammar lessons
    final lessons = await (_db.select(_db.grammarLessons)
          ..where((t) =>
              t.title.like(like) |
              t.content.like(like)))
        .get();
    for (final l in lessons) {
      results.add(SearchResult(
        type    : SearchResultType.grammarLesson,
        id      : l.id,
        title   : l.title,
        subtitle: 'Grammatik · ${l.level.toUpperCase()}',
        route   : '/grammatik/lesson/${l.id}',
      ));
    }

    // Memorize items
    final phrases = await (_db.select(_db.memorizeItems)
          ..where((t) =>
              t.phrase.like(like) |
              t.meaning.like(like)))
        .get();
    for (final p in phrases) {
      final m = AppL10n.activeLang == 'fa'
          ? p.meaning
          : (p.meaningEn ?? p.meaning);
      results.add(SearchResult(
        type    : SearchResultType.memorizePhrases,
        id      : p.id,
        title   : p.phrase,
        subtitle: '$m · ${p.category}',
        route   : '/auswendiglernen',
      ));
    }

    state = state.copyWith(results: results, loading: false);
  }

  void clear() => state = const SearchState();
}

final globalSearchProvider =
    NotifierProvider<GlobalSearchNotifier, SearchState>(
        GlobalSearchNotifier.new);
