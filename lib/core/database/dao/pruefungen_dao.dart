// FILE: lib/core/database/dao/pruefungen_dao.dart
// DEPS: app_database.dart
// PURPOSE: Exam questions — از جدول GrammarLessons با level prefix "pruefung_"
// فرمت level: "pruefung_goethe_a1", "pruefung_telc_b1", "pruefung_oesd_b2" ...
import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class PruefungenDao {
  PruefungenDao(this._db);
  final AppDatabase _db;

  static String levelKey(String org, String level) =>
      'pruefung_${org.toLowerCase()}_${level.toLowerCase()}';

  Stream<List<GrammarLesson>> watchByExam(String org, String level) =>
      (_db.select(_db.grammarLessons)
            ..where((t) => t.level.equals(levelKey(org, level)))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<GrammarLesson>> getByExam(String org, String level) =>
      (_db.select(_db.grammarLessons)
            ..where((t) => t.level.equals(levelKey(org, level)))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  // Count total exercises for an org across all levels
  Future<Map<String, int>> countByLevel(
      String org, List<String> levels) async {
    final counts = <String, int>{};
    for (final lvl in levels) {
      final rows = await getByExam(org, lvl);
      var total = 0;
      for (final r in rows) {
        try {
          final j = jsonDecode(r.content) as Map<String, dynamic>;
          final exList = (j['exercises'] as List?) ?? [];
          total += exList.length;
        } catch (_) {
          total += 1;
        }
      }
      counts[lvl] = total;
    }
    return counts;
  }

  Future<int> insert(GrammarLessonsCompanion c) =>
      _db.into(_db.grammarLessons).insertOnConflictUpdate(c);

  Future<int> delete(int id) =>
      (_db.delete(_db.grammarLessons)..where((t) => t.id.equals(id))).go();
}
