// FILE: lib/core/leitner/deck_baum.dart
// PHASE: X.3 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// PURPOSE: Decks als Baum ordnen — EINE Stelle für die Reihenfolge, in der
//          Deck-Auswahl (X.3), Deck-Seite (X.4) und Filter (X.6) die Decks
//          zeigen. Rein (ohne Flutter, ohne Datenbank).
//
// Regeln:
//   · ein Deck steht direkt unter seinem Eltern-Deck, Geschwister in der
//     Reihenfolge der Eingabe (die Ablage ordnet nach `ordnung`, dann Name);
//   · ein Deck, dessen Eltern-Deck es nicht gibt, steht auf der obersten
//     Ebene (so sieht es auch das Zusammenführen, nutzer_zustand.dart);
//   · ein Kreis (A unter B, B unter A — nur durch einen fehlerhaften Abgleich
//     denkbar) wird aufgebrochen: kein Deck verschwindet, keines steht doppelt.

/// Ein Deck an seiner Stelle im Baum. [tiefe] 0 = oberste Ebene.
typedef DeckKnoten<T> = ({T deck, int tiefe});

/// [decks] in Baum-Reihenfolge (Eltern vor Kindern, Tiefensuche).
List<DeckKnoten<T>> deckBaum<T>(
  Iterable<T> decks, {
  required String Function(T) id,
  required String? Function(T) eltern,
}) {
  final alle = decks.toList();
  final ids = {for (final d in alle) id(d)};
  final kinder = <String?, List<T>>{};
  for (final d in alle) {
    final e = eltern(d);
    (kinder[e != null && ids.contains(e) && e != id(d) ? e : null] ??= [])
        .add(d);
  }
  final ergebnis = <DeckKnoten<T>>[];
  final gesehen = <String>{};
  void gehe(T d, int tiefe) {
    if (!gesehen.add(id(d))) return;
    ergebnis.add((deck: d, tiefe: tiefe));
    for (final k in kinder[id(d)] ?? const []) {
      gehe(k, tiefe + 1);
    }
  }

  for (final d in kinder[null] ?? const []) {
    gehe(d, 0);
  }
  // Rest = Decks in einem Kreis: jedes noch nicht gezeigte beginnt oben.
  for (final d in alle) {
    gehe(d, 0);
  }
  return ergebnis;
}

/// ids von [deckId] und allen Decks darunter (für «ganzes Deck oder ein
/// Subdeck üben», Zähler eines Eltern-Decks = Summe seiner Subdecks).
Set<String> deckMitSubdecks<T>(
  String deckId,
  Iterable<T> decks, {
  required String Function(T) id,
  required String? Function(T) eltern,
}) {
  final ergebnis = <String>{deckId};
  var gewachsen = true;
  while (gewachsen) {
    gewachsen = false;
    for (final d in decks) {
      final e = eltern(d);
      if (e != null && ergebnis.contains(e) && ergebnis.add(id(d))) {
        gewachsen = true;
      }
    }
  }
  return ergebnis;
}
