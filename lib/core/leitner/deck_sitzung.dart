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
//
// Gemischt (Wunsch Lukas 2026-11-22): beim Üben kommen die Wörter
// verschiedener Decks durcheinander, nicht erst alle aus einem Deck und
// dann das nächste —
//   · «alle üben»: die Decks der obersten Ebene abwechselnd;
//   · ein Deck: seine Subdecks abwechselnd (Reißverschluss) — auch beim
//     Auswählen der neuen Wörter unter dem Limit, sonst füllte das erste
//     Subdeck das ganze Limit;
//   · AUSNAHME Decks, die der Reihe nach gelernt werden
//     ([DeckDaten.nacheinander]): Lektionen/Teile der Standard-Decks (dafür
//     gibt es sie — feste Lektionen zu 20 Wörtern) und die Niveaus A1…C2
//     unter «Niveau» (Lukas 2026-11-22: «erst A1 Lektion 1 … bis zur letzten
//     Lektion von C2»);
//   · die Reihenfolge einer Sitzung ist zufällig, aber für einen Tag fest
//     ([_tagesRang]) — ein neu berechneter Stapel springt nicht.
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
    this.nacheinander = false,
  });

  final String id;
  final String? eltern;
  final String modus;
  final int? neuProTag;

  /// Wird mit seinen Geschwistern der Reihe nach gelernt, nicht gemischt
  /// (Lektion/Teil eines Standard-Decks, Niveau A1…C2).
  final bool nacheinander;

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
    // Kinder aus dem BAUM (deck_baum.dart bricht Kreise auf, fehlende
    // Eltern ⇒ oberste Ebene) — so kann keine Rechnung im Kreis laufen.
    _baum = deckBaum<DeckDaten>(decks,
        id: (d) => d.id, eltern: (d) => d.eltern);
    final pfad = <String>[];
    for (final k in _baum) {
      pfad.length = k.tiefe;
      (_kinder[k.tiefe == 0 ? null : pfad.last] ??= []).add(k.deck.id);
      pfad.add(k.deck.id);
    }
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

  // ── Teilbäume, gemerkt (X.4b: mit Lektionen ~2.800 Decks) ──────────────

  final Map<String, List<String>> _woerterCache = {};
  final Map<String, List<String>> _wiederholWoerterCache = {};
  final Map<String, bool> _hatWiederholungCache = {};

  /// Wörter eines Teilbaums, jedes einmal, in Baum-Reihenfolge.
  List<String> _woerterVon(String id, {bool nurWiederholen = false}) {
    final cache = nurWiederholen ? _wiederholWoerterCache : _woerterCache;
    return cache[id] ??= () {
      final gesehen = <String>{};
      final d = _decks[id];
      return [
        if (d != null && (!nurWiederholen || d.wiederholen))
          for (final w in _woerter[id] ?? const <String>[])
            if (gesehen.add(w)) w,
        for (final k in _kinder[id] ?? const <String>[])
          for (final w in _woerterVon(k, nurWiederholen: nurWiederholen))
            if (gesehen.add(w)) w,
      ];
    }();
  }

  /// Gibt es im Teilbaum ein Deck mit Wiederholung?
  bool _hatWiederholung(String id) => _hatWiederholungCache[id] ??=
      (_decks[id]?.wiederholen ?? false) ||
          (_kinder[id] ?? const <String>[]).any(_hatWiederholung);

  /// Wörter mehrerer Teilbäume, jedes einmal.
  List<String> _woerterIn(Iterable<String> wurzeln,
      {bool nurWiederholen = false}) {
    final gesehen = <String>{};
    return [
      for (final r in wurzeln)
        for (final w in _woerterVon(r, nurWiederholen: nurWiederholen))
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
        if (d == null || !_hatWiederholung(id)) return const <String>[];
        final begonnen = _woerterVon(id, nurWiederholen: true)
            .where(_heuteBegonnen)
            .length;
        final frei = deckLimit(d, obersteEbene: _obersteEbene(id)) - begonnen;
        if (frei <= 0) return const <String>[];
        final gesehen = <String>{};
        final kandidaten = <String>[];
        void dazu(String w) {
          if (kandidaten.length < frei && gesehen.add(w)) kandidaten.add(w);
        }

        final kinder = _kinder[id] ?? const <String>[];
        final eigene = [
          if (d.wiederholen)
            for (final w in _woerter[id] ?? const <String>[])
              if (_neu(w)) w,
        ];
        if (kinder.isNotEmpty &&
            kinder.every((k) => _decks[k]!.nacheinander)) {
          // Der Reihe nach (Lektion 1, 2 … · A1, A2 … C2): das nächste
          // Geschwister erst, wenn im vorigen KEIN neues Wort mehr übrig ist
          // — auch wenn dessen eigenes Limit für heute erreicht ist (sonst
          // kämen täglich je 10 aus A1, A2, … statt erst ganz A1).
          eigene.forEach(dazu);
          for (final k in kinder) {
            if (kandidaten.length >= frei) break;
            final heute = neueHeute(k);
            heute.forEach(dazu);
            final uebrig = _woerterVon(k, nurWiederholen: true).where(_neu);
            if (uebrig.length > heute.length) break;
          }
        } else {
          // Subdecks abwechselnd (Wunsch Lukas 2026-11-22).
          _reissverschluss([eigene, for (final k in kinder) neueHeute(k)])
              .forEach(dazu);
        }
        return kandidaten;
      }();

  /// Abwechselnd aus jeder Liste eines: [a1, b1, c1, a2, b2, …].
  static List<String> _reissverschluss(List<List<String>> listen) {
    final aus = <String>[];
    for (var i = 0;; i++) {
      var noch = false;
      for (final l in listen) {
        if (i < l.length) {
          aus.add(l[i]);
          noch = true;
        }
      }
      if (!noch) return aus;
    }
  }

  /// Zufälliger, aber für einen Tag fester Rang eines Worts (FNV-1a über
  /// Datum + id): ordnet eine Sitzung durcheinander, ohne dass sich die
  /// Reihenfolge innerhalb eines Tages ändert.
  int _tagesRang(String w) {
    final t = _jetzt.toLocal();
    var h = 0x811c9dc5;
    for (final c in '${t.year}-${t.month}-${t.day}|$w'.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    // Endmischung (MurmurHash3 fmix32): sonst bleiben Wörter mit gleichem
    // Anfang (aus demselben Deck) beieinander.
    h ^= h >> 16;
    h = (h * 0x85ebca6b) & 0xffffffff;
    h ^= h >> 13;
    h = (h * 0xc2b2ae35) & 0xffffffff;
    h ^= h >> 16;
    return h;
  }

  /// Heute zu übende Wörter von [id] samt Subdecks — fällige und neue,
  /// gemischt (fest für den Tag).
  List<String> sitzung(String id) => _sitzung([id], neueHeute(id));

  /// Heute zu übende Wörter aller Decks (jedes Deck der obersten Ebene mit
  /// seinem Limit).
  List<String> sitzungAlle() {
    final gesehen = <String>{};
    final oben = _kinder[null] ?? const <String>[];
    return _sitzung(oben, [
      for (final w in _reissverschluss([for (final r in oben) neueHeute(r)]))
        if (gesehen.add(w)) w,
    ]);
  }

  List<String> _sitzung(Iterable<String> deckIds, List<String> neue) {
    final faellige =
        _woerterIn(deckIds, nurWiederholen: true).where(_faellig);
    // Fällige und neue, aus allen Decks durcheinander (Lukas 2026-11-22).
    final rang = <String, int>{};
    return [...faellige, ...neue]
      ..sort((a, b) => (rang[a] ??= _tagesRang(a))
          .compareTo(rang[b] ??= _tagesRang(b)));
  }

  /// Zahlen von [id] samt Subdecks.
  DeckZaehler zaehler(String id) {
    final alle = _woerterVon(id);
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
      faellig: _woerterVon(id, nurWiederholen: true).where(_faellig).length,
      neuHeute: neueHeute(id).length,
    );
  }
}
