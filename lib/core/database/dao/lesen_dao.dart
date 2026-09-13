// FILE: lib/core/database/dao/lesen_dao.dart
// DEPS: app_database.dart (generated: ReadingText, ReadingTextsCompanion)
// PURPOSE: CRUD for reading_texts table
import 'package:drift/drift.dart';

import '../app_database.dart';

class LesenDao {
  LesenDao(this._db);
  final AppDatabase _db;

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<ReadingText>> watchAll() =>
      (_db.select(_db.readingTexts)
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .watch();

  Stream<List<ReadingText>> watchByLevel(String level) =>
      (_db.select(_db.readingTexts)
        ..where((t) => t.level.equals(level))
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .watch();

  // ── Fetches ────────────────────────────────────────────────────────────────

  Future<ReadingText?> getById(int id) =>
      (_db.select(_db.readingTexts)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<Map<String, int>> countByLevel() async {
    final all = await _db.select(_db.readingTexts).get();
    final map = <String, int>{
      'a1': 0, 'a2': 0, 'b1': 0, 'b2': 0, 'c1': 0, 'c2': 0,
    };
    for (final t in all) {
      final key = t.level.toLowerCase();
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  // ── Mutate ─────────────────────────────────────────────────────────────────

  Future<int> insert(ReadingTextsCompanion companion) =>
      _db.into(_db.readingTexts).insert(companion);

  Future<bool> update(ReadingTextsCompanion companion) =>
      _db.update(_db.readingTexts).replace(companion);

  Future<int> delete(int id) =>
      (_db.delete(_db.readingTexts)..where((t) => t.id.equals(id))).go();
}
