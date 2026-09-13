// FILE: lib/features/grammatik/controllers/grammar_controller.dart
// DEPS: grammar_dao.dart, lesson_model.dart, databaseProvider
// PURPOSE: Riverpod providers for GrammarLessons + LessonModel conversion
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/grammar_dao.dart';
import '../../../core/models/lesson_model.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final grammarDaoProvider = Provider<GrammarDao>((ref) =>
    GrammarDao(ref.watch(databaseProvider)));

// ── Streams ───────────────────────────────────────────────────────────────────

final allLessonsProvider = StreamProvider<List<LessonModel>>((ref) =>
    ref.watch(grammarDaoProvider).watchAll().map(
          (rows) => rows.map(_toModel).toList(),
        ));

final lessonsByLevelProvider =
    StreamProvider.family<List<LessonModel>, String>((ref, level) =>
        ref.watch(grammarDaoProvider).watchByLevel(level).map(
              (rows) => rows.map(_toModel).toList(),
            ));

// ── Async fetches ─────────────────────────────────────────────────────────────

final lessonByIdProvider =
    FutureProvider.family<LessonModel?, int>((ref, id) async {
  final row = await ref.watch(grammarDaoProvider).getById(id);
  return row == null ? null : _toModel(row);
});

final levelCountsProvider = FutureProvider<Map<String, int>>((ref) =>
    ref.watch(grammarDaoProvider).countByLevel());

// ── Conversion ────────────────────────────────────────────────────────────────

LessonModel _toModel(GrammarLesson row) => LessonModel.fromRaw(
      id       : row.id,
      title    : row.title,
      level    : row.level,
      content  : row.content,
      sortOrder: row.sortOrder,
    );
