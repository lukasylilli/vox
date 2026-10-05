// FILE: lib/features/selbstlernen/services/pomodoro_geraet_basis.dart
// PURPOSE: Die Verträge — siehe pomodoro_geraet.dart.

/// Hält den Bildschirm wach. Jede Methode darf still scheitern (Browser ohne
/// Unterstützung, Akkusparmodus, Seite im Hintergrund): der Timer läuft dann
/// trotzdem richtig, nur die Anzeige darf ausgehen.
abstract class BildschirmWach {
  /// `true`, wenn der Bildschirm jetzt wach gehalten wird.
  Future<bool> halten();

  Future<void> loslassen();
}

/// Kurzer Ton am Phasenende.
abstract class PomodoroKlang {
  /// MUSS innerhalb einer Nutzer-Geste (Tippen auf Start) aufgerufen werden —
  /// Browser geben Ton erst danach frei. Später, nach dem Entsperren, spielt
  /// [spielen] dann auch ohne neue Geste.
  void vorbereiten();

  Future<void> spielen();
}
