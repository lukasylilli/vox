// FILE: lib/core/database/dao/memorize_dao.dart
// DEPS: app_database.dart
// PURPOSE: CRUD برای memorize_items — watchByCategory، countByCategory
import 'package:drift/drift.dart';

import '../app_database.dart';

class MemorizeDao {
  MemorizeDao(this._db);
  final AppDatabase _db;

  Stream<List<MemorizeItem>> watchAll() =>
      (_db.select(_db.memorizeItems)
            ..orderBy([(t) => OrderingTerm.asc(t.category)]))
          .watch();

  Stream<List<MemorizeItem>> watchByCategory(String category) =>
      (_db.select(_db.memorizeItems)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<List<MemorizeItem>> getByCategory(String category) =>
      (_db.select(_db.memorizeItems)
            ..where((t) => t.category.equals(category)))
          .get();

  Future<MemorizeItem?> getById(int id) =>
      (_db.select(_db.memorizeItems)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<Map<String, int>> countByCategory(List<String> categories) async {
    final rows   = await _db.select(_db.memorizeItems).get();
    final counts = {for (final c in categories) c: 0};
    for (final r in rows) {
      if (counts.containsKey(r.category)) {
        counts[r.category] = counts[r.category]! + 1;
      }
    }
    return counts;
  }

  Future<int> insert(MemorizeItemsCompanion c) =>
      _db.into(_db.memorizeItems).insert(c);

  Future<bool> update(MemorizeItemsCompanion c) =>
      _db.update(_db.memorizeItems).replace(c);

  Future<int> delete(int id) =>
      (_db.delete(_db.memorizeItems)..where((t) => t.id.equals(id))).go();
}
