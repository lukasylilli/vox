// FILE: lib/core/database/dao/leitner_dao.dart
// DEPS: app_database.dart (generated: LeitnerCard, LeitnerCardsCompanion)
// PURPOSE: All CRUD + logic for the Leitner spaced-repetition system
//
// BOX INTERVALS: 1 | 2 | 4 | 8 | 16 days
// Correct answer → advance box (max 5), nextReview = now + interval
// Wrong answer   → reset to box 1,     nextReview = now + 1 day
import 'package:drift/drift.dart';

import '../app_database.dart';

class LeitnerDao {
  LeitnerDao(this._db);
  final AppDatabase _db;

  static const boxIntervals = [1, 2, 4, 8, 16]; // days per box (index = box-1)

  // ── Watch ─────────────────────────────────────────────────────────────────

  /// Cards due today (nextReview <= now), ordered by box ascending (most urgent first).
  Stream<List<LeitnerCard>> watchDue() {
    final now = DateTime.now();
    return (_db.select(_db.leitnerCards)
      ..where((t) => t.nextReview.isSmallerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.boxNumber)]))
        .watch();
  }

  Stream<List<LeitnerCard>> watchAll() =>
      (_db.select(_db.leitnerCards)
        ..orderBy([(t) => OrderingTerm.asc(t.boxNumber)]))
          .watch();

  Stream<List<LeitnerCard>> watchByBox(int box) =>
      (_db.select(_db.leitnerCards)
        ..where((t) => t.boxNumber.equals(box)))
          .watch();

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<List<LeitnerCard>> getDue() {
    final now = DateTime.now();
    return (_db.select(_db.leitnerCards)
      ..where((t) => t.nextReview.isSmallerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.boxNumber)]))
        .get();
  }

  Future<LeitnerCard?> getByWordId(int wordId) =>
      (_db.select(_db.leitnerCards)
        ..where((t) => t.wordId.equals(wordId)))
          .getSingleOrNull();

  Future<bool> isInLeitner(int wordId) async =>
      (await getByWordId(wordId)) != null;

  /// Returns map: boxNumber → count (always has keys 1-5).
  Future<Map<int, int>> countsByBox() async {
    final all = await _db.select(_db.leitnerCards).get();
    final map = {for (var i = 1; i <= 5; i++) i: 0};
    for (final card in all) {
      map[card.boxNumber] = (map[card.boxNumber] ?? 0) + 1;
    }
    return map;
  }

  Future<int> countDue() async {
    final now = DateTime.now();
    return (_db.select(_db.leitnerCards)
      ..where((t) => t.nextReview.isSmallerOrEqualValue(now)))
        .get()
        .then((l) => l.length);
  }

  // ── Mutate ────────────────────────────────────────────────────────────────

  /// Adds a word to box 1 with nextReview = tomorrow.
  /// Safe to call multiple times — uses upsert (no duplicates).
  Future<void> addWord(int wordId) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _db.into(_db.leitnerCards).insertOnConflictUpdate(
      LeitnerCardsCompanion.insert(
        wordId    : wordId,
        nextReview: tomorrow,
      ),
    );
  }

  Future<void> markCorrect(LeitnerCard card) {
    final newBox  = (card.boxNumber + 1).clamp(1, 5);
    final days    = boxIntervals[newBox - 1];
    final next    = DateTime.now().add(Duration(days: days));
    return (_db.update(_db.leitnerCards)
      ..where((t) => t.id.equals(card.id)))
        .write(LeitnerCardsCompanion(
          boxNumber : Value(newBox),
          nextReview: Value(next),
          lastReview: Value(DateTime.now()),
        ));
  }

  Future<void> markWrong(LeitnerCard card) {
    final next = DateTime.now().add(const Duration(days: 1));
    return (_db.update(_db.leitnerCards)
      ..where((t) => t.id.equals(card.id)))
        .write(LeitnerCardsCompanion(
          boxNumber : const Value(1),
          nextReview: Value(next),
          lastReview: Value(DateTime.now()),
        ));
  }

  Future<int> removeCard(int cardId) =>
      (_db.delete(_db.leitnerCards)..where((t) => t.id.equals(cardId))).go();
}
