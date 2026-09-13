// FILE: lib/features/selbstlernen/controllers/selbstlernen_controller.dart
// DEPS: -
// PURPOSE: PomodoroNotifier (25/5/15 min cycle). Habit-Providers entfernt
// (2026-09-13) — "Habit/Routine" wird jetzt extern über Root-in
// (github.com/lukasylilli/Root-in) abgedeckt, per Link aus
// selbstlernen_home_screen.dart. Kein Code-Merge zwischen den Projekten.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  final PomodoroPhase phase;
  final int           secondsLeft;
  final int           sessionCount;
  final bool          running;

  double get progress =>
      secondsLeft / phase.defaultSeconds;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int?           secondsLeft,
    int?           sessionCount,
    bool?          running,
  }) =>
      PomodoroState(
        phase        : phase         ?? this.phase,
        secondsLeft  : secondsLeft   ?? this.secondsLeft,
        sessionCount : sessionCount  ?? this.sessionCount,
        running      : running       ?? this.running,
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
    );
  }

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
    );
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);
