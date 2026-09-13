// FILE: lib/features/selbstlernen/controllers/selbstlernen_controller.dart
// DEPS: habit_dao.dart
// PURPOSE: Habit providers + PomodoroNotifier (25/5/15 min cycle)
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/habit_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final habitDaoProvider = Provider<HabitDao>(
  (ref) => HabitDao(ref.watch(databaseProvider)),
);

// ── Habit providers ───────────────────────────────────────────────────────────

final allHabitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitDaoProvider).watchAll(),
);

final activeHabitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitDaoProvider).watchActive(),
);

final habitByIdProvider = FutureProvider.family<Habit?, int>(
  (ref, id) => ref.watch(habitDaoProvider).getById(id),
);

final habitLast7DaysProvider =
    FutureProvider.family<Map<DateTime, int>, int>((ref, habitId) =>
        ref.watch(habitDaoProvider).last7DaysCounts(habitId));

// ── Day names ─────────────────────────────────────────────────────────────────

const dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const dayNamesFa = ['wd_mo', 'wd_tu', 'wd_we', 'wd_th', 'wd_fr', 'wd_sa', 'wd_su'];
const shiftOptions = ['morning', 'afternoon', 'evening'];
const shiftLabelsFa = ['shift_morning', 'shift_afternoon', 'shift_evening'];

// ── Pomodoro ──────────────────────────────────────────────────────────────────

enum PomodoroPhase { work, shortBreak, longBreak }

extension PomodoroPhaseExt on PomodoroPhase {
  String get labelFa => switch (this) {
        PomodoroPhase.work       => 'pomo_focus',
        PomodoroPhase.shortBreak => 'pomo_short_break',
        PomodoroPhase.longBreak  => 'pomo_long_break',
      };

  int get defaultSeconds => switch (this) {
        PomodoroPhase.work       => 25 * 60,
        PomodoroPhase.shortBreak =>  5 * 60,
        PomodoroPhase.longBreak  => 15 * 60,
      };
}

class PomodoroState {
  const PomodoroState({
    this.phase        = PomodoroPhase.work,
    this.secondsLeft  = 25 * 60,
    this.sessionCount = 0,
    this.running      = false,
    this.linkedHabitId,
  });

  final PomodoroPhase phase;
  final int           secondsLeft;
  final int           sessionCount;
  final bool          running;
  final int?          linkedHabitId;

  double get progress =>
      secondsLeft / phase.defaultSeconds;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int?           secondsLeft,
    int?           sessionCount,
    bool?          running,
    int?           linkedHabitId,
    bool           clearHabit = false,
  }) =>
      PomodoroState(
        phase        : phase         ?? this.phase,
        secondsLeft  : secondsLeft   ?? this.secondsLeft,
        sessionCount : sessionCount  ?? this.sessionCount,
        running      : running       ?? this.running,
        linkedHabitId: clearHabit ? null : (linkedHabitId ?? this.linkedHabitId),
      );
}

class PomodoroNotifier extends Notifier<PomodoroState> {
  Timer? _timer;

  @override
  PomodoroState build() {
    ref.onDispose(() => _timer?.cancel());
    return const PomodoroState();
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    state = state.copyWith(running: true);
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(running: false);
  }

  void reset() {
    _timer?.cancel();
    state = PomodoroState(
      phase        : state.phase,
      secondsLeft  : state.phase.defaultSeconds,
      sessionCount : state.sessionCount,
      linkedHabitId: state.linkedHabitId,
    );
  }

  void setLinkedHabit(int? habitId) =>
      state = state.copyWith(linkedHabitId: habitId, clearHabit: habitId == null);

  void skipPhase() {
    _timer?.cancel();
    _advancePhase();
  }

  void _tick() {
    if (state.secondsLeft <= 1) {
      _timer?.cancel();
      _advancePhase();
    } else {
      state = state.copyWith(secondsLeft: state.secondsLeft - 1);
    }
  }

  void _advancePhase() {
    final completedWork = state.phase == PomodoroPhase.work;
    final newCount = completedWork ? state.sessionCount + 1 : state.sessionCount;

    final nextPhase = completedWork
        ? (newCount % 4 == 0
            ? PomodoroPhase.longBreak
            : PomodoroPhase.shortBreak)
        : PomodoroPhase.work;

    state = PomodoroState(
      phase        : nextPhase,
      secondsLeft  : nextPhase.defaultSeconds,
      sessionCount : newCount,
      running      : false,
      linkedHabitId: state.linkedHabitId,
    );
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);

// ── Habit completion ──────────────────────────────────────────────────────────

final habitCompletedTodayProvider = FutureProvider.family<bool, int>(
  (ref, habitId) => ref.watch(habitDaoProvider).wasCompletedToday(habitId),
);

// ── Habit actions (create / update / delete / toggleToday) ───────────────────

class HabitActions {
  HabitActions(this._dao);
  final HabitDao _dao;

  List<int> _parseDays(String json) =>
      (jsonDecode(json) as List).cast<int>();

  Future<void> createHabit({
    required String   name,
    required List<int> scheduledDays,
    required String   shift,
  }) =>
      _dao.insertHabit(HabitsCompanion.insert(
        name    : name,
        daysJson: jsonEncode(scheduledDays),
        shift   : shift,
      ));

  Future<void> updateHabit({
    required int      id,
    required String   name,
    required List<int> scheduledDays,
    required String   shift,
  }) =>
      _dao.updateHabit(HabitsCompanion(
        id      : Value(id),
        name    : Value(name),
        daysJson: Value(jsonEncode(scheduledDays)),
        shift   : Value(shift),
      ));

  Future<void> deleteHabit(int id) => _dao.deleteHabit(id);

  Future<void> toggleToday(int id) async {
    final done = await _dao.wasCompletedToday(id);
    if (!done) await _dao.addSession(id);
  }

  List<int> parseDays(Habit habit) => _parseDays(habit.daysJson);
}

final habitActionsProvider = Provider<HabitActions>(
  (ref) => HabitActions(ref.read(habitDaoProvider)),
);
