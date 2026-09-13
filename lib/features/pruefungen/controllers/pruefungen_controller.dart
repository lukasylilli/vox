// FILE: lib/features/pruefungen/controllers/pruefungen_controller.dart
// DEPS: pruefungen_dao.dart, lesson_model.dart
// PURPOSE: Providers + ExamOrg enum + timer state برای Prüfungen
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dao/pruefungen_dao.dart';
import '../../../core/models/lesson_model.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── Exam organization ─────────────────────────────────────────────────────────

enum ExamOrg { goethe, telc, oesd }

extension ExamOrgExt on ExamOrg {
  String get displayName => switch (this) {
        ExamOrg.goethe => 'Goethe-Zertifikat',
        ExamOrg.telc   => 'telc Deutsch',
        ExamOrg.oesd   => 'ÖSD',
      };

  String get key => switch (this) {
        ExamOrg.goethe => 'goethe',
        ExamOrg.telc   => 'telc',
        ExamOrg.oesd   => 'oesd',
      };

  String get shortName => switch (this) {
        ExamOrg.goethe => 'Goethe',
        ExamOrg.telc   => 'telc',
        ExamOrg.oesd   => 'ÖSD',
      };

  List<String> get levels => switch (this) {
        ExamOrg.goethe => ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
        ExamOrg.telc   => ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
        ExamOrg.oesd   => ['A2', 'B1', 'B2', 'C1', 'C2'],
      };

  // Default exam time in minutes per level
  int timeLimitMinutes(String level) => switch (level.toUpperCase()) {
        'A1' || 'A2' => 60,
        'B1' || 'B2' => 90,
        _            => 120,
      };
}

// ── DAO provider ──────────────────────────────────────────────────────────────

final pruefungenDaoProvider = Provider<PruefungenDao>(
  (ref) => PruefungenDao(ref.watch(databaseProvider)),
);

// ── Data providers ────────────────────────────────────────────────────────────

// ({org, level}) key for family providers
typedef ExamKey = ({String org, String level});

final examLessonsProvider =
    FutureProvider.family<List<LessonModel>, ExamKey>((ref, key) async {
  final rows = await ref
      .watch(pruefungenDaoProvider)
      .getByExam(key.org, key.level);
  return rows
      .map((r) => LessonModel.fromRaw(
            id       : r.id,
            title    : r.title,
            level    : r.level,
            content  : r.content,
            sortOrder: r.sortOrder,
          ))
      .toList();
});

final examLevelCountsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, org) async {
  final dao    = ref.watch(pruefungenDaoProvider);
  final orgObj = ExamOrg.values.firstWhere((e) => e.key == org,
      orElse: () => ExamOrg.goethe);
  return dao.countByLevel(org, orgObj.levels);
});

// ── All exercises flattened for a given exam ──────────────────────────────────

final examExercisesProvider =
    FutureProvider.family<List<GrammarExercise>, ExamKey>(
        (ref, key) async {
  final lessons =
      await ref.watch(examLessonsProvider(key).future);
  return lessons.expand((l) => l.exercises).toList();
});
