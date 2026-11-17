// FILE: lib/core/leitner/leitner_regeln.dart
// PHASE: X.2 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// PURPOSE: Die EINE Stelle für die Regeln des Leitner-Systems: Fächer und
//          Abstände, was eine richtige/falsche Antwort bewirkt, die drei
//          Zustände eines Worts, die Übungsarten. Rein (ohne Flutter, ohne
//          Datenbank) — jede Ablage und jede Anzeige rechnet hiermit.
//
// Entscheidungen Lukas (2026-11-03, PHASE_X.md):
//   · 7 Fächer, Abstände 1 · 2 · 4 · 8 · 16 · 32 · 64 Tage (Nr. 8);
//   · richtig im 7. Fach ⇒ «gelernt» — nie mehr wiederholt (Nr. 9); von Hand
//     zurück in Fach 1 möglich;
//   · falsch ⇒ Fach 1, morgen wieder (Nr. 10);
//   · Fortschritt gehört zu «Wort × Übung», nicht zum Deck (Nr. 1, 7);
//   · drei Zustände: nicht gelernt · in Lernphase · gelernt (Nr. 6).
// Entscheidung Lukas (2026-11-17): Übungen der ersten Stufe sind Bedeutung,
// umgekehrt, Schreiben, Artikel; weitere nach dem Vorbild von Duolingo
// kommen in X.5 dazu (die Ablage kennt die Übung nur als Text).
import '../backup/nutzer_zustand.dart';

export '../backup/nutzer_zustand.dart'
    show
        LeitnerStand,
        deckModusNotiz,
        deckModusWiederholen,
        leitnerFaecher,
        leitnerGelerntFach,
        standardDeckId,
        standardDeckName,
        uebungBedeutung;

/// Tage bis zur nächsten Wiederholung je Fach (Index = Fach − 1).
const List<int> leitnerFachTage = [1, 2, 4, 8, 16, 32, 64];

/// Weitere Übungen der ersten Stufe (X.5 baut ihre Seiten).
const String uebungUmgekehrt = 'umgekehrt'; // Bedeutung ⇒ deutsches Wort
const String uebungSchreiben = 'schreiben'; // Bedeutung ⇒ Wort tippen
const String uebungArtikel = 'artikel'; //     Nomen ⇒ der/die/das

/// Neue Wörter pro Tag, wenn der Nutzer nichts eingestellt hat (Nr. 11):
/// Deck der obersten Ebene 50, jedes Subdeck (in jeder Tiefe) 10.
const int neuProTagDeck = 50;
const int neuProTagSubdeck = 10;

/// Zustand eines Worts in EINER Übung (Entscheidung Nr. 6).
enum LernZustand {
  /// Noch nie in dieser Übung geübt (kein Fortschritt gespeichert).
  neu,

  /// Liegt in einem der Fächer 1–7.
  lernt,

  /// Aus dem letzten Fach heraus.
  gelernt,
}

LernZustand lernZustand(LeitnerStand? stand) => stand == null
    ? LernZustand.neu
    : stand.gelernt
        ? LernZustand.gelernt
        : LernZustand.lernt;

/// Fach für die Anzeige: ein Wort ohne Fortschritt steht in Fach 1.
int anzeigeFach(LeitnerStand? stand) =>
    stand == null ? 1 : stand.fach.clamp(1, leitnerGelerntFach);

/// Ist das Wort in dieser Übung jetzt zu wiederholen? Ein neues Wort (ohne
/// Fortschritt) ist sofort dran; ein gelerntes nie.
bool istFaellig(LeitnerStand? stand, DateTime jetzt) {
  if (stand == null) return true;
  if (stand.gelernt) return false;
  final termin = stand.naechsteWiederholung;
  return termin == null || !termin.isAfter(jetzt);
}

/// Richtig geantwortet: ein Fach weiter; aus dem letzten Fach ⇒ gelernt
/// (ohne Termin). Ein neues Wort ([stand] null) kommt aus Fach 1 in Fach 2.
LeitnerStand nachRichtig(String wortId, LeitnerStand? stand, DateTime jetzt) {
  final bisher = anzeigeFach(stand);
  if (bisher >= leitnerGelerntFach) {
    return LeitnerStand(
        wortId: wortId,
        fach: leitnerGelerntFach,
        letzteWiederholung: stand?.letzteWiederholung ?? jetzt);
  }
  final neu = bisher + 1;
  return LeitnerStand(
    wortId: wortId,
    fach: neu,
    naechsteWiederholung: neu >= leitnerGelerntFach
        ? null
        : jetzt.add(Duration(days: leitnerFachTage[neu - 1])),
    letzteWiederholung: jetzt,
  );
}

/// Falsch geantwortet — oder von Hand zurückgelegt: Fach 1, morgen wieder.
/// Das Datum ist Pflicht: daran erkennt das Zusammenführen zweier Geräte,
/// dass dies jünger ist als ein höheres Fach ([LeitnerStand.zusammen]).
LeitnerStand nachFalsch(String wortId, DateTime jetzt) => LeitnerStand(
      wortId: wortId,
      fach: 1,
      naechsteWiederholung: jetzt.add(Duration(days: leitnerFachTage[0])),
      letzteWiederholung: jetzt,
    );

/// Anteil gelernter Wörter (0–1) unter [wortIds] in einer Übung, deren
/// Fortschritt [fortschritt] ist. Leere Menge ⇒ 0.
double anteilGelernt(
    Iterable<String> wortIds, Map<String, LeitnerStand> fortschritt) {
  var alle = 0, gelernt = 0;
  for (final id in wortIds) {
    alle++;
    if (fortschritt[id]?.gelernt ?? false) gelernt++;
  }
  return alle == 0 ? 0 : gelernt / alle;
}
