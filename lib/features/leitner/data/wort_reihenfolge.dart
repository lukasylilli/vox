// FILE: lib/features/leitner/data/wort_reihenfolge.dart
// PHASE: X.4b (2026-11-17) — feste Lektionen der Standard-Decks
// PURPOSE: Die FESTE Reihenfolge aller Karten (assets/leitner/reihenfolge.json)
//          — daraus entstehen die Lektionen der Standard-Decks (je 20 Wörter,
//          Entscheidung Lukas 2026-11-22: «درس‌های ثابت»).
//
// Regel: die Datei wird NUR verlängert. Neue Karten kommen ans Ende, eine
// einmal vergebene Stelle ändert sich nie ⇒ jede Lektion bleibt für immer
// dieselbe; ein neues Wort landet in der letzten Lektion seines Decks oder
// in einer neuen dahinter. Weil die Datei zur App gehört (nicht zum Nutzer),
// sind die Lektionen auf allen Geräten und für alle Nutzer gleich.
//
// Gepflegt von tool/wort_reihenfolge.dart (läuft in jeder Wortrunde,
// tool/wort_runde.sh); test/standard_decks_test.dart prüft, dass jede Karte
// darin steht — sonst bleibt der Bau rot.
import 'dart:convert';

/// Asset-Pfad (in pubspec.yaml eingetragen).
const String wortReihenfolgeAsset = 'assets/leitner/reihenfolge.json';

/// Text der Datei → Stelle je Karten-id (0, 1, 2 …).
Map<String, int> wortReihenfolgeLesen(String text) {
  final roh = jsonDecode(text);
  final ids = roh is Map ? roh['ids'] : null;
  if (ids is! List) {
    throw const FormatException('reihenfolge.json ohne Liste "ids"');
  }
  return {for (var i = 0; i < ids.length; i++) ids[i] as String: i};
}

/// Bisherige Reihenfolge [bisher] + alle [karten] (Index-Einträge), die noch
/// fehlen — angehängt in der Reihenfolge Wort (klein), dann id. Nichts wird
/// entfernt oder umgestellt.
List<String> wortReihenfolgeVerlaengern(
    List<String> bisher, Iterable<Map<String, dynamic>> karten) {
  final da = bisher.toSet();
  final neu = [
    for (final k in karten)
      if (!da.contains(k['id'])) k,
  ]..sort((a, b) {
      final c = (a['wort'] as String? ?? '')
          .toLowerCase()
          .compareTo((b['wort'] as String? ?? '').toLowerCase());
      return c != 0 ? c : (a['id'] as String).compareTo(b['id'] as String);
    });
  return [...bisher, for (final k in neu) k['id'] as String];
}

/// Text der Datei (eine id je Zeile — kleine Diffs bei jeder Runde).
String wortReihenfolgeText(List<String> ids) =>
    '{"version":1,"ids":[\n${ids.map(jsonEncode).join(',\n')}\n]}\n';
