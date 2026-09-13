// FILE: lib/core/database/dao/hoeren_dao.dart
// DEPS: app_database.dart
// PURPOSE: CRUD für audio_items — watchAll, watchByLevel, getById, countByLevel
import 'package:drift/drift.dart';

import '../app_database.dart';

class HoerenDao {
  HoerenDao(this._db);
  final AppDatabase _db;

  Stream<List<AudioItem>> watchAll() =>
      (_db.select(_db.audioItems)..orderBy([(t) => OrderingTerm.asc(t.level)])).watch();

  Stream<List<AudioItem>> watchByLevel(String level) =>
      (_db.select(_db.audioItems)
            ..where((t) => t.level.equals(level))
            ..orderBy([(t) => OrderingTerm.asc(t.title)]))
          .watch();

  Future<AudioItem?> getById(int id) =>
      (_db.select(_db.audioItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Map<String, int>> countByLevel() async {
    final rows  = await _db.select(_db.audioItems).get();
    final counts = <String, int>{};
    for (final lvl in ['a1', 'a2', 'b1', 'b2', 'c1', 'c2']) {
      counts[lvl] = 0;
    }
    for (final r in rows) {
      counts[r.level] = (counts[r.level] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> insert(AudioItemsCompanion c) =>
      _db.into(_db.audioItems).insertOnConflictUpdate(c);

  Future<bool> update(AudioItemsCompanion c) =>
      _db.update(_db.audioItems).replace(c);

  Future<int> delete(int id) =>
      (_db.delete(_db.audioItems)..where((t) => t.id.equals(id))).go();
}
