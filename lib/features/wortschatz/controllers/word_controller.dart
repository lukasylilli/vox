// FILE: lib/features/wortschatz/controllers/word_controller.dart
// DEPS: app_database.dart (generated), word_dao.dart, word_model.dart
// PURPOSE: Riverpod providers — database singleton, word streams, search, insert
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/word_dao.dart';
import '../../../core/models/word_model.dart';

// ── Database & DAO singletons ────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordDaoProvider = Provider<WordDao>((ref) =>
    WordDao(ref.watch(databaseProvider)));

// ── Word streams ─────────────────────────────────────────────────────────────

final allWordsProvider = StreamProvider<List<Word>>((ref) =>
    ref.watch(wordDaoProvider).watchAll());

final wordsByLevelProvider =
    StreamProvider.family<List<Word>, String>((ref, level) =>
        ref.watch(wordDaoProvider).watchByLevel(level));

final wordsByTypeProvider =
    StreamProvider.family<List<Word>, String>((ref, type) =>
        ref.watch(wordDaoProvider).watchByType(type));

final wordsByBookProvider =
    StreamProvider.family<List<Word>, int>((ref, bookId) =>
        ref.watch(wordDaoProvider).watchByBook(bookId));

final allBooksProvider = StreamProvider<List<Book>>((ref) =>
    ref.watch(wordDaoProvider).watchAllBooks());

// ── Search ───────────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Word>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return Future.value([]);
  return ref.watch(wordDaoProvider).search(query);
});

// ── Single word ──────────────────────────────────────────────────────────────

final wordByIdProvider = FutureProvider.family<Word?, int>((ref, id) =>
    ref.watch(wordDaoProvider).getById(id));

// ── Convert drift Word → WordModel (for UI) ──────────────────────────────────

extension WordToModel on Word {
  WordModel toModel() => WordModel.fromRaw(
    id             : id,
    german         : german,
    wordType       : wordType,
    meaningFa      : meaningFa,
    article        : article,
    plural         : plural,
    level          : level,
    meaningEn      : meaningEn,
    pronunciation  : pronunciation,
    examplesJson   : examplesJson,
    conjugationJson: conjugationJson,
    etymology      : etymology,
    commonErrors   : commonErrors,
    grammarNote    : grammarNote,
  );
}

// ── Convert WordModel → WordsCompanion (for DB insert/update) ─────────────────

extension ModelToCompanion on WordModel {
  WordsCompanion toCompanion() => WordsCompanion.insert(
    german          : german,
    wordType        : wordType.name,
    meaningFa       : meaningFa,
    article         : Value(article),
    plural          : Value(plural),
    level           : Value(level?.label),
    meaningEn       : Value(meaningEn),
    pronunciation   : Value(pronunciation),
    examplesJson    : Value(examples.isEmpty ? null : jsonEncode(examples)),
    conjugationJson : Value(conjugation == null ? null : jsonEncode(conjugation!.toJson())),
    etymology       : Value(etymology),
    commonErrors    : Value(commonErrors),
    grammarNote     : Value(grammarNote),
  );
}
