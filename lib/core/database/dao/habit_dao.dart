// FILE: lib/core/database/dao/habit_dao.dart
// DEPS: app_database.dart
// PURPOSE: CRUD برای Habits + HabitSessions — streak، completion tracking
import 'package:drift/drift.dart';

import '../app_database.dart';

class HabitDao {
  HabitDao(this._db);
  final AppDatabase _db;

  // ── Habits ────────────────────────────────────────────────────────────────

  Stream<List<Habit>> watchAll() =>
      (_db.select(_db.habits)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Stream<List<Habit>> watchActive() =>
      (_db.select(_db.habits)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<Habit?> getById(int id) =>
      (_db.select(_db.habits)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertHabit(HabitsCompanion c) =>
      _db.into(_db.habits).insert(c);

  Future<bool> updateHabit(HabitsCompanion c) =>
      _db.update(_db.habits).replace(c);

  Future<void> setActive(int id, {required bool active}) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id)))
          .write(HabitsCompanion(isActive: Value(active)));

  Future<int> deleteHabit(int id) async {
    await (_db.delete(_db.habitSessions)
          ..where((t) => t.habitId.equals(id)))
        .go();
    return (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  Future<void> incrementStreak(int id) async {
    final h = await getById(id);
    if (h == null) return;
    await (_db.update(_db.habits)..where((t) => t.id.equals(id)))
        .write(HabitsCompanion(streakCount: Value(h.streakCount + 1)));
  }

  Future<void> resetStreak(int id) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id)))
          .write(const HabitsCompanion(streakCount: Value(0)));

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<int> addSession(int habitId, {int? durationMinutes}) =>
      _db.into(_db.habitSessions).insert(HabitSessionsCompanion(
            habitId        : Value(habitId),
            completedAt    : Value(DateTime.now()),
            durationMinutes: Value(durationMinutes),
          ));

  Future<List<HabitSession>> getSessionsInRange(
      int habitId, DateTime from, DateTime to) =>
      (_db.select(_db.habitSessions)
            ..where((t) =>
                t.habitId.equals(habitId) &
                t.completedAt.isBiggerOrEqualValue(from) &
                t.completedAt.isSmallerOrEqualValue(to))
            ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
          .get();

  Future<bool> wasCompletedToday(int habitId) async {
    final now   = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end   = start.add(const Duration(days: 1));
    final rows  = await getSessionsInRange(habitId, start, end);
    return rows.isNotEmpty;
  }

  // Last 7 days completion counts (date → count)
  Future<Map<DateTime, int>> last7DaysCounts(int habitId) async {
    final now  = DateTime.now();
    final result = <DateTime, int>{};
    for (var i = 6; i >= 0; i--) {
      final day   = DateTime(now.year, now.month, now.day - i);
      final next  = day.add(const Duration(days: 1));
      final rows  = await getSessionsInRange(habitId, day, next);
      result[day] = rows.length;
    }
    return result;
  }
}
