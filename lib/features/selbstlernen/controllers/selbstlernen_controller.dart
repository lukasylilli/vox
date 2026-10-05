// FILE: lib/features/selbstlernen/controllers/selbstlernen_controller.dart
// DEPS: shared_preferences, flutter_riverpod, app_logger.dart
// PURPOSE: PomodoroNotifier (25/5/15 min cycle). Habit-Providers entfernt
// (2026-09-13) — "Habit/Routine" wird jetzt extern über Root-in
// (github.com/lukasylilli/Root-in) abgedeckt, per Link aus
// selbstlernen_home_screen.dart. Kein Code-Merge zwischen den Projekten.
//
// ⏱️ 2026-10-05 — Bildschirmsperre-Fehler behoben: Der Timer zählte bisher
// Ticks (`secondsLeft - 1` pro `Timer.periodic`). Sperrt man den Bildschirm
// oder wechselt die App in den Hintergrund, drosselt/stoppt der Browser die
// Timer der Seite — die verlorene Zeit wurde nie nachgeholt, die Uhr blieb
// stehen. Jetzt gilt die ECHTE Uhrzeit: beim Start wird der Endzeitpunkt
// (`_endsAt`) festgehalten und `secondsLeft` bei jedem Tick UND beim
// Zurückkehren in die App (AppLifecycleState.resumed) daraus berechnet.
// Der Zustand wird zusätzlich in shared_preferences gesichert, damit er auch
// überlebt, wenn die PWA im Hintergrund beendet wird.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/app_logger.dart';

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

/// Schlüssel des gesicherten Pomodoro-Zustands (shared_preferences).
const String kPomodoroKey = 'pomodoro_zustand_v1';

const AppLogger _log = AppLogger('Pomodoro');

class PomodoroNotifier extends Notifier<PomodoroState>
    with WidgetsBindingObserver {
  /// [jetzt] ist nur für Tests austauschbar (falsche Uhr).
  PomodoroNotifier({DateTime Function()? jetzt})
      : _jetzt = jetzt ?? DateTime.now;

  final DateTime Function() _jetzt;

  Timer?    _timer;
  DateTime? _endsAt;          // gesetzt ⇔ Phase läuft
  bool      _beobachtet = false;
  bool      _entsorgt   = false;
  bool      _beruehrt   = false; // Nutzer hat schon bedient ⇒ nichts mehr wiederherstellen
  Future<void> _schreiben = Future<void>.value();
  late Future<void> _bereit;

  /// Nur für Tests: fertig, sobald der gesicherte Zustand geladen ist.
  @visibleForTesting
  Future<void> get bereit => _bereit;

  /// Nur für Tests: fertig, sobald alle bisherigen Sicherungen geschrieben sind.
  @visibleForTesting
  Future<void> get gespeichert => _schreiben;

  @override
  PomodoroState build() {
    _entsorgt = false;
    _beruehrt = false;
    _endsAt   = null;
    ref.onDispose(() {
      _entsorgt = true;
      _beenden();
    });
    _bereit = _wiederherstellen();
    return const PomodoroState();
  }

  // ── Bedienung ──────────────────────────────────────────────────────────────

  void start() {
    _beruehrt = true;
    if (state.running) return;
    _endsAt = _jetzt().add(Duration(seconds: state.secondsLeft));
    state = state.copyWith(running: true);
    _planen();
    _speichern();
  }

  void pause() {
    _beruehrt = true;
    _sync(); // erst die tatsächlich verstrichene Zeit abziehen
    if (!state.running) return; // Phase war inzwischen schon zu Ende
    _beenden();
    _endsAt = null;
    state = state.copyWith(running: false);
    _speichern();
  }

  void reset() {
    _beruehrt = true;
    _beenden();
    _endsAt = null;
    state = PomodoroState(
      phase        : state.phase,
      secondsLeft  : state.phase.defaultSeconds,
      sessionCount : state.sessionCount,
    );
    _speichern();
  }

  void skipPhase() {
    _beruehrt = true;
    _beenden();
    _endsAt = null;
    _advancePhase();
  }

  // ── Zeit ───────────────────────────────────────────────────────────────────

  /// Berechnet `secondsLeft` aus der echten Uhr. Läuft bei jedem Tick und beim
  /// Zurückkehren in die App — so zählt die Zeit auch, während der Bildschirm
  /// gesperrt war und kein einziger Tick kam.
  void _sync() {
    final ende = _endsAt;
    if (!state.running || ende == null) return;

    final ms = ende.difference(_jetzt()).inMilliseconds;
    if (ms <= 0) {
      _beenden();
      _endsAt = null;
      _advancePhase();
      return;
    }

    var sek = (ms / 1000).ceil();
    final hoechstens = state.phase.defaultSeconds;
    if (sek > hoechstens) {
      // Systemuhr wurde zurückgestellt: nie mehr als die volle Phase anzeigen.
      sek = hoechstens;
      _endsAt = _jetzt().add(Duration(seconds: hoechstens));
    }
    if (sek != state.secondsLeft) {
      state = state.copyWith(secondsLeft: sek);
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
    _speichern();
  }

  // ── Timer + Rückkehr in die App ────────────────────────────────────────────

  /// 250 ms statt 1 s: der Zustand ändert sich nur, wenn die Sekunde wechselt
  /// (kein Mehraufwand), aber eine verspätete Tick-Folge überspringt keine
  /// Anzeigesekunde.
  void _planen() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _sync());
    if (!_beobachtet) {
      WidgetsBinding.instance.addObserver(this);
      _beobachtet = true;
    }
  }

  void _beenden() {
    _timer?.cancel();
    _timer = null;
    if (_beobachtet) {
      WidgetsBinding.instance.removeObserver(this);
      _beobachtet = false;
    }
  }

  // Parametername bewusst anders als in WidgetsBindingObserver (`state`): hier
  // würde er das `state` des Notifiers verdecken.
  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle != AppLifecycleState.resumed || !state.running) return;
    _sync();
    // Der Browser kann den Timer im Hintergrund eingefroren haben ⇒ neu starten.
    if (state.running) _planen();
  }

  // ── Sichern / Wiederherstellen ─────────────────────────────────────────────

  void _speichern() {
    final json = jsonEncode(<String, Object?>{
      'phase'       : state.phase.index,
      'sessionCount': state.sessionCount,
      'secondsLeft' : state.secondsLeft,
      'running'     : state.running,
      'endsAtMs'    : _endsAt?.millisecondsSinceEpoch,
    });
    // Hintereinander, damit der letzte Stand garantiert zuletzt geschrieben wird.
    _schreiben = _schreiben.then((_) => _ablegen(json));
  }

  Future<void> _ablegen(String json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPomodoroKey, json);
    } catch (e) {
      _log.e('Sichern fehlgeschlagen', e);
    }
  }

  Future<void> _wiederherstellen() async {
    Map<String, Object?>? gelesen;
    try {
      final prefs = await SharedPreferences.getInstance();
      final roh = prefs.get(kPomodoroKey);
      if (roh is String) {
        final j = jsonDecode(roh);
        if (j is Map) gelesen = Map<String, Object?>.from(j);
      }
    } catch (e) {
      _log.e('Wiederherstellen fehlgeschlagen', e);
    }
    final daten = gelesen;
    if (daten == null || _entsorgt || _beruehrt) return;

    final phaseIdx = daten['phase'];
    final zaehler  = daten['sessionCount'];
    if (phaseIdx is! int || phaseIdx < 0 || phaseIdx >= PomodoroPhase.values.length) return;
    if (zaehler is! int || zaehler < 0) return;

    final phase = PomodoroPhase.values[phaseIdx];
    final endMs = daten['endsAtMs'];

    if (daten['running'] == true && endMs is int) {
      // Lief, als die App zuletzt gesehen wurde ⇒ aus dem echten Endzeitpunkt
      // weiterrechnen (oder, falls schon vorbei, in die nächste Phase wechseln).
      _endsAt = DateTime.fromMillisecondsSinceEpoch(endMs);
      state = PomodoroState(
        phase        : phase,
        secondsLeft  : phase.defaultSeconds,
        sessionCount : zaehler,
        running      : true,
      );
      _sync();
      if (state.running) _planen();
      return;
    }

    final rest = daten['secondsLeft'];
    state = PomodoroState(
      phase        : phase,
      secondsLeft  : (rest is int && rest >= 1 && rest <= phase.defaultSeconds)
          ? rest
          : phase.defaultSeconds,
      sessionCount : zaehler,
    );
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);
