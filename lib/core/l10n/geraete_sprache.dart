// FILE: lib/core/l10n/geraete_sprache.dart
// PHASE: فاز LAUNCH / L.3 — Startsprache (2026-09-16)
// DEPS: dart:ui
// EXPORTS: GeraeteSprache
// PURPOSE: Sprache der Oberfläche, solange der Nutzer in den Einstellungen
//          noch nichts gewählt hat.
//
// REGEL (Entscheidung Lukas, 2026-09-16): Standard ist **Englisch**. Nur wenn
// das Gerät Persisch meldet, startet VOX auf Persisch. Grund: Ein englisch-
// sprachiger Besucher, der beim ersten Öffnen eine persische Oberfläche sieht,
// schließt die App sofort wieder.
//
// Wie Root-in (`resolveLocale`) werden die Gerätesprachen der Reihe nach
// durchgegangen; die erste, die VOX kann (fa oder en), entscheidet. So bekommt
// z. B. ein Gerät „Deutsch, dann Persisch" die persische Oberfläche, ein Gerät
// „Deutsch, dann Englisch" die englische, ein Gerät nur mit „Deutsch" Englisch.
//
// Eine ausdrückliche Wahl in den Einstellungen (`ui_language`) hat immer
// Vorrang — diese Datei wird nur ohne gespeicherte Wahl gefragt und speichert
// selbst nichts. Dadurch folgt VOX der Gerätesprache, bis der Nutzer wählt.
import 'dart:ui' show Locale, PlatformDispatcher;

abstract final class GeraeteSprache {
  /// Sprachcodes, die als Persisch gelten (`prs` = Dari).
  static const persischeCodes = {'fa', 'prs'};

  /// Sprache, wenn das Gerät keine von VOX unterstützte Sprache meldet.
  static const rueckfall = 'en';

  /// Reine Regel (testbar): wählt 'fa' oder 'en' aus den Gerätesprachen.
  static String aus(List<Locale> geraeteSprachen) {
    for (final sprache in geraeteSprachen) {
      final code = sprache.languageCode.toLowerCase();
      if (persischeCodes.contains(code)) return 'fa';
      if (code == 'en') return 'en';
    }
    return rueckfall;
  }

  /// Startsprache für dieses Gerät (im Browser: navigator.languages).
  static String get aktuell => aus(PlatformDispatcher.instance.locales);
}
