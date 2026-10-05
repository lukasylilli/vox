// FILE: lib/features/selbstlernen/controllers/selbstlernen_controller.dart
// DEPS: shared_preferences, flutter_riverpod, app_logger.dart, pomodoro_geraet.dart
// PURPOSE: PomodoroNotifier (25/5/15 min cycle). Habit-Providers entfernt
// (2026-09-13) — "Habit/Routine" wird jetzt extern über Root-in
// (github.com/lukasylilli/Root-in) abgedeckt, per Link aus
// selbstlernen_home_screen.dart. Kein Code-Merge zwischen den Projekten.
//
// ⏱️ 2026-10-05 (B-14) — Bildschirmsperre-Fehler behoben: Der Timer zählte
// bisher Ticks (`secondsLeft - 1` pro `Timer.periodic`). Sperrt man den
// Bildschirm oder wechselt die App in den Hintergrund, drosselt/stoppt der
// Browser die Timer der Seite — die verlorene Zeit wurde nie nachgeholt, die
// Uhr blieb stehen. Jetzt gilt die ECHTE Uhrzeit: beim Start wird der
// Endzeitpunkt (`_endsAt`) festgehalten und `secondsLeft` bei jedem Tick UND
// beim Zurückkehren in die App (AppLifecycleState.resumed) daraus berechnet.
// Der Zustand wird zusätzlich in shared_preferences gesichert, damit er auch
// überlebt, wenn die PWA im Hintergrund beendet wird.
//
// 🔔 2026-10-05 (B-14b) — drei Verbesserungen, alle Nutzer-Schalter:
//  • `wachHalten` (Standard AN): Bildschirm sperrt nicht von selbst, solange
//    der Timer läuft (Screen Wake Lock; nach dem Zurückkehren neu angefragt).
//  • Phasenende wird gemeldet: `beendetePhase` (Banner im Screen, bis der
//    Nutzer etwas tut) + kurzer Ton (`klang`, Standard AN) — auch wenn die
//    Phase erst während der Sperre zu Ende ging.
//  • `autoWeiter` (Standard AUS = bisheriges Verhalten): die nächste Phase
//    startet von selbst. Bei langer Sperre werden alle dazwischenliegenden
//    Phasen aus der echten Uhr nachgerechnet (Sitzungen werden mitgezählt).
import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/app_logger.dart';
import '../services/pomodoro_geraet.dart';

// ── Pomodoro ──────────────────────────────────────────────────────────────────

enum PomodoroPhase { work, shortBreak, longBreak }

extension PomodoroPhaseExt on PomodoroPhase {
  String get labelFa => switch (this) {
        PomodoroPhase.work       => 'pomo_focus',
        PomodoroPhase.shortBreak => 'pomo_short_break',
        PomodoroPhase.longBreak  => 'pomo_long_break',
      };

  /// Schlüssel für „Phase X ist zu Ende" (Banner im Screen).
  String get endeKey => switch (this) {
        PomodoroPhase.work       => 'pomo_ended_focus',
        PomodoroPhase.shortBreak => 'pomo_ended_short_break',
        PomodoroPhase.longBreak  => 'pomo_ended_long_break',
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
    this.autoWeiter   = false,
    this.wachHalten   = true,
    this.klang        = true,
    this.beendetePhase,
    this.beendetUm,
  });

  final PomodoroPhase phase;
  final int           secondsLeft;
  final int           sessionCount;
  final bool          running;

  /// Nächste Phase startet von selbst (Standard: aus).
  final bool autoWeiter;

  /// Bildschirm bleibt an, solange der Timer läuft (Standard: an).
  final bool wachHalten;

  /// Ton am Phasenende (Standard: an).
  final bool klang;

  /// Zuletzt zu Ende gegangene Phase — für das Banner im Screen. `null`, sobald
  /// der Nutzer etwas bedient (oder, im Auto-Modus, nach 30 Sekunden).
  final PomodoroPhase? beendetePhase;
  final DateTime?      beendetUm;

  double get progress =>
      secondsLeft / phase.defaultSeconds;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int?           secondsLeft,
    int?           sessionCount,
    bool?          running,
    bool?          autoWeiter,
    bool?          wachHalten,
    bool?          klang,
    PomodoroPhase? beendetePhase,
    DateTime?      beendetUm,
    bool           beendetLoeschen = false,
  }) =>
      PomodoroState(
        phase        : phase         ?? this.phase,
        secondsLeft  : secondsLeft   ?? this.secondsLeft,
        sessionCount : sessionCount  ?? this.sessionCount,
        running      : running       ?? this.running,
        autoWeiter   : autoWeiter    ?? this.autoWeiter,
        wachHalten   : wachHalten    ?? this.wachHalten,
        klang        : klang         ?? this.klang,
        beendetePhase: beendetLoeschen ? null : (beendetePhase ?? this.beendetePhase),
        beendetUm    : beendetLoeschen ? null : (beendetUm     ?? this.beendetUm),
      );
}

/// Schlüssel des gesicherten Pomodoro-Zustands (shared_preferences).
const String kPomodoroKey = 'pomodoro_zustand_v1';

/// So lange bleibt das „Phase zu Ende"-Banner im Auto-Modus stehen.
const Duration kPomodoroBannerDauer = Duration(seconds: 30);

const AppLogger _log = AppLogger('Pomodoro');

class PomodoroNotifier extends Notifier<PomodoroState>
    with WidgetsBindingObserver {
  /// [jetzt], [wach] und [klang] sind nur für Tests austauschbar
  /// (falsche Uhr, Attrappen für Bildschirm und Ton).
  PomodoroNotifier({
    DateTime Function()? jetzt,
    BildschirmWach?      wach,
    PomodoroKlang?       klang,
  })  : _jetzt = jetzt ?? DateTime.now,
        _wach  = wach  ?? neuerBildschirmWach(),
        _klang = klang ?? neuerPomodoroKlang();

  final DateTime Function() _jetzt;
  final BildschirmWach      _wach;
  final PomodoroKlang       _klang;

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
      unawaited(_wach.loslassen());
    });
    _bereit = _wiederherstellen();
    return const PomodoroState();
  }

  // ── Bedienung ──────────────────────────────────────────────────────────────

  void start() {
    _beruehrt = true;
    if (state.running) return;
    _klang.vorbereiten(); // läuft noch innerhalb des Tippens ⇒ Ton ist freigegeben
    _endsAt = _jetzt().add(Duration(seconds: state.secondsLeft));
    state = state.copyWith(running: true, beendetLoeschen: true);
    _planen();
    _wachAbgleich();
    _speichern();
  }

  void pause() {
    _beruehrt = true;
    _sync(); // erst die tatsächlich verstrichene Zeit abziehen
    if (!state.running) return; // Phase war inzwischen schon zu Ende (ohne Auto)
    _beenden();
    _endsAt = null;
    state = state.copyWith(running: false, beendetLoeschen: true);
    _wachAbgleich();
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
      autoWeiter   : state.autoWeiter,
      wachHalten   : state.wachHalten,
      klang        : state.klang,
    );
    _wachAbgleich();
    _speichern();
  }

  /// Zur nächsten Phase springen. Lief der Timer und ist „automatisch weiter"
  /// an, läuft die nächste Phase sofort; sonst wartet sie auf Start.
  void skipPhase() {
    _beruehrt = true;
    final weiter = state.running && state.autoWeiter;
    _beenden();
    _endsAt = null;
    final f = _folgephase(state.phase, state.sessionCount);
    state = state.copyWith(
      phase          : f.phase,
      sessionCount   : f.zaehler,
      secondsLeft    : f.phase.defaultSeconds,
      running        : false,
      beendetLoeschen: true,
    );
    if (weiter) {
      _endsAt = _jetzt().add(Duration(seconds: f.phase.defaultSeconds));
      state = state.copyWith(running: true);
      _planen();
    }
    _wachAbgleich();
    _speichern();
  }

  // ── Einstellungen ──────────────────────────────────────────────────────────

  void setzeAutoWeiter(bool wert) {
    _beruehrt = true;
    state = state.copyWith(autoWeiter: wert);
    _speichern();
  }

  void setzeWachHalten(bool wert) {
    _beruehrt = true;
    state = state.copyWith(wachHalten: wert);
    _wachAbgleich();
    _speichern();
  }

  void setzeKlang(bool wert) {
    _beruehrt = true;
    if (wert) _klang.vorbereiten(); // der Schalter ist selbst eine Nutzer-Geste
    state = state.copyWith(klang: wert);
    _speichern();
  }

  // ── Zeit ───────────────────────────────────────────────────────────────────

  ({PomodoroPhase phase, int zaehler}) _folgephase(PomodoroPhase p, int zaehler) {
    final neu = p == PomodoroPhase.work ? zaehler + 1 : zaehler;
    final naechste = p == PomodoroPhase.work
        ? (neu % 4 == 0 ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak)
        : PomodoroPhase.work;
    return (phase: naechste, zaehler: neu);
  }

  /// Berechnet `secondsLeft` aus der echten Uhr. Läuft bei jedem Tick und beim
  /// Zurückkehren in die App — so zählt die Zeit auch, während der Bildschirm
  /// gesperrt war und kein einziger Tick kam.
  void _sync() {
    final ende = _endsAt;
    if (!state.running || ende == null) return;

    final jetzt = _jetzt();
    if (!ende.isAfter(jetzt)) {
      _phasenAbschliessen(ende, jetzt);
      return;
    }

    var sek = (ende.difference(jetzt).inMilliseconds / 1000).ceil();
    final hoechstens = state.phase.defaultSeconds;
    if (sek > hoechstens) {
      // Systemuhr wurde zurückgestellt: nie mehr als die volle Phase anzeigen.
      sek = hoechstens;
      _endsAt = jetzt.add(Duration(seconds: hoechstens));
    }

    final um = state.beendetUm;
    final bannerAlt = um != null && jetzt.difference(um) > kPomodoroBannerDauer;
    if (sek != state.secondsLeft || bannerAlt) {
      state = state.copyWith(secondsLeft: sek, beendetLoeschen: bannerAlt);
    }
  }

  /// Die laufende Phase ist zu Ende ([ende] ≤ [jetzt]). Ohne „automatisch
  /// weiter" ⇒ nächste Phase, wartet auf Start. Mit ⇒ alle Phasen, die in der
  /// Zwischenzeit (z. B. bei Bildschirmsperre) zu Ende gingen, aus der echten
  /// Uhr nachrechnen und in der laufenden weitermachen.
  void _phasenAbschliessen(DateTime ende, DateTime jetzt) {
    final weiter = state.autoWeiter;
    var phase    = state.phase;
    var zaehler  = state.sessionCount;
    var vorbei   = phase;
    var grenze   = ende;
    var runden   = 0;

    do {
      runden++;
      vorbei = phase;
      final f = _folgephase(phase, zaehler);
      phase   = f.phase;
      zaehler = f.zaehler;
      if (!weiter) break;
      grenze = grenze.add(Duration(seconds: phase.defaultSeconds));
    } while (!grenze.isAfter(jetzt) && runden < 500);

    var rest = phase.defaultSeconds;
    if (weiter) {
      // Wochenlange Lücke (Sicherung gegen Endlosschleife): neu beginnen.
      if (!grenze.isAfter(jetzt)) grenze = jetzt.add(Duration(seconds: rest));
      _endsAt = grenze;
      rest = (grenze.difference(jetzt).inMilliseconds / 1000)
          .ceil()
          .clamp(1, phase.defaultSeconds);
    } else {
      _beenden();
      _endsAt = null;
    }

    state = state.copyWith(
      phase        : phase,
      sessionCount : zaehler,
      secondsLeft  : rest,
      running      : weiter,
      beendetePhase: vorbei,
      beendetUm    : jetzt,
    );
    _wachAbgleich();
    _speichern();
    if (state.klang) unawaited(_klang.spielen());
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
    if (state.running) {
      // Der Browser kann den Timer im Hintergrund eingefroren haben ⇒ neu
      // starten; die Wake-Lock-Sperre gibt er beim Verbergen selbst frei ⇒
      // erneut anfragen.
      _planen();
      _wachAbgleich();
    }
  }

  /// Bildschirm wach, solange (läuft ∧ Schalter an) — sonst freigeben.
  void _wachAbgleich() {
    if (_entsorgt) return;
    if (state.running && state.wachHalten) {
      unawaited(_wach.halten());
    } else {
      unawaited(_wach.loslassen());
    }
  }

  // ── Sichern / Wiederherstellen ─────────────────────────────────────────────

  void _speichern() {
    final json = jsonEncode(<String, Object?>{
      'phase'       : state.phase.index,
      'sessionCount': state.sessionCount,
      'secondsLeft' : state.secondsLeft,
      'running'     : state.running,
      'endsAtMs'    : _endsAt?.millisecondsSinceEpoch,
      'autoWeiter'  : state.autoWeiter,
      'wachHalten'  : state.wachHalten,
      'klang'       : state.klang,
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

    // Schalter: fehlt oder kaputt ⇒ Standardwert.
    final auto  = daten['autoWeiter'] is bool ? daten['autoWeiter'] as bool : false;
    final wach  = daten['wachHalten'] is bool ? daten['wachHalten'] as bool : true;
    final klang = daten['klang'] is bool ? daten['klang'] as bool : true;

    if (daten['running'] == true && endMs is int) {
      // Lief, als die App zuletzt gesehen wurde ⇒ aus dem echten Endzeitpunkt
      // weiterrechnen (oder, falls schon vorbei, in die nächste Phase wechseln).
      _endsAt = DateTime.fromMillisecondsSinceEpoch(endMs);
      state = PomodoroState(
        phase        : phase,
        secondsLeft  : phase.defaultSeconds,
        sessionCount : zaehler,
        running      : true,
        autoWeiter   : auto,
        wachHalten   : wach,
        klang        : klang,
      );
      _sync();
      if (state.running) {
        _planen();
        _wachAbgleich();
      }
      return;
    }

    final rest = daten['secondsLeft'];
    state = PomodoroState(
      phase        : phase,
      secondsLeft  : (rest is int && rest >= 1 && rest <= phase.defaultSeconds)
          ? rest
          : phase.defaultSeconds,
      sessionCount : zaehler,
      autoWeiter   : auto,
      wachHalten   : wach,
      klang        : klang,
    );
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);
