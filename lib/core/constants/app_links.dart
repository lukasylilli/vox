// FILE: lib/core/constants/app_links.dart
// PURPOSE: Einzige Quelle externer Adressen, die die App öffnet
class AppLinks {
  AppLinks._();

  /// Root-in — separates Habit-/Routine-Projekt (eigenes Repo/Deployment).
  /// Wird aus selbstlernen_home_screen.dart per Link geöffnet.
  /// Bewusst KEIN Code-Merge zwischen VOX und Root-in (Entscheidung 2026-09-13).
  static const rootInUrl = 'https://lukasylilli.github.io/Root-in/';
}
