// FILE: lib/features/selbstlernen/services/pomodoro_geraet.dart
// PHASE: Selbstlernen / Pomodoro (2026-10-05)
// PURPOSE: Die zwei Geräte-Fähigkeiten des Pomodoro-Timers, getrennt von der
//          Zeitlogik, damit sie im Test durch Attrappen ersetzbar sind:
//          • BildschirmWach — Bildschirm nicht automatisch sperren, solange
//            der Timer läuft (Screen Wake Lock API).
//          • PomodoroKlang  — kurzer Ton am Ende einer Phase (Web Audio).
//
// Weiche (bedingter Export) wie install_state.dart: package:web darf NICHT
// ungeschützt importiert werden, sonst bricht `flutter test`.
export 'pomodoro_geraet_basis.dart';
export 'pomodoro_geraet_io.dart'
    if (dart.library.js_interop) 'pomodoro_geraet_web.dart';
