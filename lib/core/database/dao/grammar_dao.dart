// FILE: lib/core/database/dao/grammar_dao.dart
// DEPS: app_database.dart (generated: GrammarLesson, GrammarLessonsCompanion)
// PURPOSE: CRUD for GrammarLessons table
import 'package:drift/drift.dart';

import '../app_database.dart';

class GrammarDao {
  GrammarDao(this._db);
  final AppDatabase _db;

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<GrammarLesson>> watchAll() =>
      (_db.select(_db.grammarLessons)
        ..orderBy([
          (t) => OrderingTerm.asc(t.level),
          (t) => OrderingTerm.asc(t.sortOrder),
        ]))
          .watch();

  Stream<List<GrammarLesson>> watchByLevel(String level) =>
      (_db.select(_db.grammarLessons)
        ..where((t) => t.level.equals(level))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  // ── Fetches ────────────────────────────────────────────────────────────────

  Future<List<GrammarLesson>> getAll() =>
      (_db.select(_db.grammarLessons)
        ..orderBy([
          (t) => OrderingTerm.asc(t.level),
          (t) => OrderingTerm.asc(t.sortOrder),
        ]))
          .get();

  Future<List<GrammarLesson>> getByLevel(String level) =>
      (_db.select(_db.grammarLessons)
        ..where((t) => t.level.equals(level))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<GrammarLesson?> getById(int id) =>
      (_db.select(_db.grammarLessons)
        ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Map of level → lesson count (always includes all 6 levels).
  Future<Map<String, int>> countByLevel() async {
    final all = await getAll();
    final map = <String, int>{
      'a1': 0, 'a2': 0, 'b1': 0, 'b2': 0, 'c1': 0, 'c2': 0,
    };
    for (final l in all) {
      final key = l.level.toLowerCase();
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  // ── Mutate ─────────────────────────────────────────────────────────────────

  Future<int> insert(GrammarLessonsCompanion companion) =>
      _db.into(_db.grammarLessons).insert(companion);

  Future<bool> update(GrammarLessonsCompanion companion) =>
      _db.update(_db.grammarLessons).replace(companion);

  Future<int> delete(int id) =>
      (_db.delete(_db.grammarLessons)..where((t) => t.id.equals(id))).go();
}
