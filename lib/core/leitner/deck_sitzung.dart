// FILE: lib/core/leitner/deck_sitzung.dart
// PHASE: X.4 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// PURPOSE: Was ein Deck HEUTE zu üben hat und wie weit es ist — EINE Stelle
//          für Deck-Seite, Wiederholung und (X.6) Statistik. Rein (ohne
//          Flutter, ohne Datenbank): bekommt Decks, Zuordnungen und den
//          Fortschritt einer Übung, rechnet daraus.
//
// Entscheidungen Lukas (PHASE_X.md):
//   · Nr. 5  — nur Decks mit Wiederholung werden geübt; ein Notizbuch-Deck
//              nie (seine Zähler zeigt es trotzdem);
//   · Nr. 6  — drei Zustände: neu (nie geübt) · lernt · gelernt;
//   · Nr. 11 — Tageslimit NEUER Wörter wie Anki: Standard 50 für ein Deck
//              der obersten Ebene, 10 für jedes Subdeck; ein Limit begrenzt
//              das Deck SAMT allen Subdecks. Beispiel aus der Entscheidung:
//              Deutsch (50) ⟵ A1 (10) ⟵ L1 (10), L2 (10); A2 (10)
//              ⇒ «Deutsch» = 10 aus A1 + 10 aus A2 = 20 · «A1» = 10.
//              Heute schon begonnene neue Wörter zählen gegen das Limit.
//   · fällige Wörter (schon in Lernphase) haben KEIN Limit.
// Ein Wort in mehreren Decks wird überall nur einmal gezählt und geübt.
import 'deck_baum.dart';
import 'leitner_regeln.dart';

/// Was die Rechnung von einem Deck braucht.
class DeckDaten {
  const DeckDaten({
    required this.id,
    this.eltern,
    this.modus = deckModusNotiz,
    this.neuProTag,
  });

  final String id;
  final String? eltern;
  final String modus;
  final int? neuProTag;

  bool get wiederholen => modus == deckModusWiederholen;
}

/// Zahlen eines Decks samt Subdecks.
class DeckZaehler {
  const DeckZaehler({
    this.woerter = 0,
    this.neu = 0,
    this.lernt = 0,
    this.gelernt = 0,
    this.faellig = 0,
    this.neuHeute = 0,
  });

  /// Alle Wörter (jedes einmal), auch aus Notizbuch-Decks.
  final int woerter;
  final int neu;
  final int lernt;
  final int gelernt;

  /// Heute fällige Wörter in Lernphase (nur Decks mit Wiederholung).
  final int faellig;

  /// Neue Wörter, die heute noch dran sind (nach dem Tageslimit).
  final int neuHeute;

  /// Heute zu üben.
  int get heute => faellig + neuHeute;

  /// Anteil gelernt (0–1); leeres Deck ⇒ 0.
  double get anteilGelernt => woerter == 0 ? 0 : gelernt / woerter;
}

/// Tageslimit eines Decks: eigenes oder Standard (oberste Ebene 50,
/// Subdeck 10). [obersteEbene] = das Deck hat kein (vorhandenes) Eltern-Deck.
int deckLimit(DeckDaten d, {required bool obersteEbene}) =>
    d.neuProTag ?? (obersteEbene ? neuProTagDeck : neuProTagSubdeck);

bool _gleicherTag(DateTime a, DateTime b) {
  final x = a.toLocal(), y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

class DeckRechner {
  DeckRechner({
    required List<DeckDaten> decks,
    required Map<String, List<String>> woerterJeDeck,
    required Map<String, LeitnerStand> fortschritt,
    required DateTime jetzt,
  })  : _fortschritt = fortschritt,
        _jetzt = jetzt {
    for (final d in decks) {
      _decks[d.id] = d;
    }
    for (final d in decks) {
      final e = d.eltern;
      final elternDa = e != null && _decks.containsKey(e) && e != d.id;
      (_kinder[elternDa ? e : null] ??= []).add(d.id);
    }
    // Reihenfolge der Kinder wie in der Eingabe (= Baum-Reihenfolge).
    _baum = deckBaum<DeckDaten>(decks,
        id: (d) => d.id, eltern: (d) => d.eltern);
    woerterJeDeck.forEach((k, v) => _woerter[k] = v);
  }

  final Map<String, DeckDaten> _decks = {};
  final Map<String?, List<String>> _kinder = {};
  final Map<String, List<String>> _woerter = {};
  final Map<String, LeitnerStand> _fortschritt;
  final DateTime _jetzt;
  late final List<DeckKnoten<DeckDaten>> _baum;

  final Map<String, List<String>> _schlangeCache = {};

  /// Decks in Baum-Reihenfolge.
  List<DeckKnoten<DeckDaten>> get baum => _baum;

  bool _obersteEbene(String id) => (_kinder[null] ?? const []).contains(id);

  /// [id] und alle Decks darunter.
  Set<String> _teilbaum(String id) => deckMitSubdecks<DeckDaten>(
      id, _decks.values,
      id: (d) => d.id, eltern: (d) => _kinderHat(d) ? d.eltern : null);

  // Eltern zählt nur, wenn es das Eltern-Deck gibt (wie im Baum).
  bool _kinderHat(DeckDaten d) =>
      d.eltern != null && _decks.containsKey(d.eltern) && d.eltern != d.id;

  /// Wörter eines Teilbaums, jedes einmal, in Baum-Reihenfolge.
  List<String> _woerterIn(Iterable<String> deckIds, {bool nurWiederholen = false}) {
    final ids = deckIds.toSet();
    final gesehen = <String>{};
    return [
      for (final k in _baum)
        if (ids.contains(k.deck.id) && (!nurWiederholen || k.deck.wiederholen))
          for (final w in _woerter[k.deck.id] ?? const <String>[])
            if (gesehen.add(w)) w,
    ];
  }

  bool _faellig(String w) {
    final s = _fortschritt[w];
    return s != null && !s.gelernt && istFaellig(s, _jetzt);
  }

  bool _neu(String w) => _fortschritt[w] == null;

  bool _heuteBegonnen(String w) {
    final erste = _fortschritt[w]?.ersteWiederholung;
    return erste != null && _gleicherTag(erste, _jetzt);
  }

  /// Neue Wörter, die heute aus [id] (samt Subdecks) dran sind — nach den
  /// Limits dieses Decks und aller Decks darunter (Regel von Anki).
  List<String> neueHeute(String id) => _schlangeCache[id] ??= () {
        final d = _decks[id];
        if (d == null) return const <String>[];
        final begonnen = _woerterIn(_teilbaum(id), nurWiederholen: true)
            .where(_heuteBegonnen)
            .length;
        final frei = deckLimit(d, obersteEbene: _obersteEbene(id)) - begonnen;
        if (frei <= 0) return const <String>[];
        final gesehen = <String>{};
        final kandidaten = <String>[
          if (d.wiederholen)
            for (final w in _woerter[id] ?? const <String>[])
              if (_neu(w) && gesehen.add(w)) w,
          for (final k in _kinder[id] ?? const <String>[])
            for (final w in neueHeute(k))
              if (gesehen.add(w)) w,
        ];
        return kandidaten.take(frei).toList();
      }();

  /// Heute zu übende Wörter von [id] samt Subdecks: erst die fälligen (Fach
  /// aufsteigend, dann Termin), dann die neuen.
  List<String> sitzung(String id) => _sitzung(_teilbaum(id), neueHeute(id));

  /// Heute zu übende Wörter aller Decks (jedes Deck der obersten Ebene mit
  /// seinem Limit).
  List<String> sitzungAlle() {
    final gesehen = <String>{};
    return _sitzung(_decks.keys, [
      for (final r in _kinder[null] ?? const <String>[])
        for (final w in neueHeute(r))
          if (gesehen.add(w)) w,
    ]);
  }

  List<String> _sitzung(Iterable<String> deckIds, List<String> neue) {
    final faellige = _woerterIn(deckIds, nurWiederholen: true)
        .where(_faellig)
        .toList()
      ..sort((a, b) {
        final sa = _fortschritt[a]!, sb = _fortschritt[b]!;
        final f = sa.fach.compareTo(sb.fach);
        if (f != 0) return f;
        final ta = sa.naechsteWiederholung, tb = sb.naechsteWiederholung;
        if (ta == null || tb == null) return ta == null ? -1 : 1;
        return ta.compareTo(tb);
      });
    return [...faellige, ...neue];
  }

  /// Zahlen von [id] samt Subdecks.
  DeckZaehler zaehler(String id) {
    final teil = _teilbaum(id);
    final alle = _woerterIn(teil);
    var neu = 0, lernt = 0, gelernt = 0;
    for (final w in alle) {
      switch (lernZustand(_fortschritt[w])) {
        case LernZustand.neu:
          neu++;
        case LernZustand.lernt:
          lernt++;
        case LernZustand.gelernt:
          gelernt++;
      }
    }
    return DeckZaehler(
      woerter: alle.length,
      neu: neu,
      lernt: lernt,
      gelernt: gelernt,
      faellig: _woerterIn(teil, nurWiederholen: true).where(_faellig).length,
      neuHeute: neueHeute(id).length,
    );
  }
}
