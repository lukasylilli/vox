// FILE: lib/features/selbstlernen/services/pomodoro_geraet_io.dart
// PURPOSE: Fassung ohne Browser (Tests, spätere native Apps) — tut nichts.
// Native Apps bekommen später eigene Fassungen (Wakelock/Benachrichtigung),
// siehe PLAN.md → فاز Z.
import 'pomodoro_geraet_basis.dart';

class _KeinWach implements BildschirmWach {
  @override
  Future<bool> halten() async => false;

  @override
  Future<void> loslassen() async {}
}

class _KeinKlang implements PomodoroKlang {
  @override
  void vorbereiten() {}

  @override
  Future<void> spielen() async {}
}

BildschirmWach neuerBildschirmWach() => _KeinWach();
PomodoroKlang neuerPomodoroKlang() => _KeinKlang();
