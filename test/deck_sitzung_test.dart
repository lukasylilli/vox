// FILE: test/deck_sitzung_test.dart
// PHASE: X.4 (2026-11-17) — was ein Deck heute zu üben hat
//        (lib/core/leitner/deck_sitzung.dart), Entscheidungen Lukas Nr. 5,
//        6, 11 in docs/zukunft/PHASE_X.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/leitner/deck_sitzung.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';

final _jetzt = DateTime(2026, 11, 17, 9);

DeckDaten _w(String id, [String? eltern, int? limit]) => DeckDaten(
    id: id, eltern: eltern, modus: deckModusWiederholen, neuProTag: limit);

List<String> _n(String p, int n) => [for (var i = 0; i < n; i++) '$p$i'];

void main() {
  test('Beispiel aus Entscheidung Nr. 11: Deutsch (50) ⟵ A1 (10) ⟵ L1, L2; '
      'A2 (10)', () {
    final r = DeckRechner(
      decks: [
        _w('deutsch'),
        _w('a1', 'deutsch'),
        _w('l1', 'a1'),
        _w('l2', 'a1'),
        _w('a2', 'deutsch'),
      ],
      woerterJeDeck: {
        'l1': _n('l1_', 30),
        'l2': _n('l2_', 30),
        'a2': _n('a2_', 30),
      },
      fortschritt: const {},
      jetzt: _jetzt,
    );
    expect(r.neueHeute('deutsch'), hasLength(20));
    expect(r.neueHeute('a1'), hasLength(10));
    expect(r.neueHeute('l1'), hasLength(10));
    expect(r.neueHeute('a1'), everyElement(startsWith('l1_')),
        reason: 'Reihenfolge: erst L1, dann L2');
    expect(r.sitzungAlle(), hasLength(20));
    expect(r.zaehler('deutsch').woerter, 90);
    expect(r.zaehler('deutsch').neu, 90);
  });

  test('Standard 50 oben, 10 im Subdeck; eigenes Limit gilt', () {
    final r = DeckRechner(
      decks: [_w('oben'), _w('sub', 'oben'), _w('frei', null, 3)],
      woerterJeDeck: {
        'oben': _n('o', 70),
        'sub': _n('s', 30),
        'frei': _n('f', 9),
      },
      fortschritt: const {},
      jetzt: _jetzt,
    );
    expect(r.neueHeute('sub'), hasLength(10));
    expect(r.neueHeute('oben'), hasLength(50));
    expect(r.neueHeute('frei'), hasLength(3));
  });

  test('heute begonnene neue Wörter zählen gegen das Limit — gestern '
      'begonnene nicht', () {
    final fortschritt = {
      for (final w in _n('h', 4))
        w: LeitnerStand(
            wortId: w,
            fach: 2,
            naechsteWiederholung: _jetzt.add(const Duration(days: 2)),
            ersteWiederholung: _jetzt.subtract(const Duration(hours: 1))),
      for (final w in _n('g', 5))
        w: LeitnerStand(
            wortId: w,
            fach: 2,
            naechsteWiederholung: _jetzt.add(const Duration(days: 1)),
            ersteWiederholung: _jetzt.subtract(const Duration(days: 1))),
    };
    final r = DeckRechner(
      decks: [_w('d', null, 10)],
      woerterJeDeck: {'d': [..._n('h', 4), ..._n('g', 5), ..._n('x', 20)]},
      fortschritt: fortschritt,
      jetzt: _jetzt,
    );
    expect(r.neueHeute('d'), hasLength(6));
  });

  test('fällig ohne Limit, Fach aufsteigend; gelernt und später fällig nie',
      () {
    LeitnerStand s(String w, int fach, int tage) => LeitnerStand(
        wortId: w,
        fach: fach,
        naechsteWiederholung: _jetzt.add(Duration(days: tage)));
    final r = DeckRechner(
      decks: [_w('d', null, 0)],
      woerterJeDeck: {
        'd': ['spaet', 'f3', 'f1', 'gelernt', 'neu']
      },
      fortschritt: {
        'spaet': s('spaet', 2, 3),
        'f3': s('f3', 3, -1),
        'f1': s('f1', 1, -2),
        'gelernt': const LeitnerStand(wortId: 'gelernt', fach: 8),
      },
      jetzt: _jetzt,
    );
    expect(r.sitzung('d'), ['f1', 'f3'], reason: 'Limit 0 ⇒ kein neues');
    final z = r.zaehler('d');
    expect((z.woerter, z.neu, z.lernt, z.gelernt, z.faellig, z.neuHeute),
        (5, 1, 3, 1, 2, 0));
    expect(z.anteilGelernt, 0.2);
  });

  test('Notizbuch-Deck: gezählt, nie geübt; Subdeck mit Wiederholung darunter '
      'schon', () {
    final r = DeckRechner(
      decks: const [
        DeckDaten(id: 'notiz'),
        DeckDaten(id: 'lern', eltern: 'notiz', modus: deckModusWiederholen),
      ],
      woerterJeDeck: {
        'notiz': ['a', 'b'],
        'lern': ['c'],
      },
      fortschritt: const {},
      jetzt: _jetzt,
    );
    expect(r.sitzung('notiz'), ['c']);
    expect(r.zaehler('notiz').woerter, 3);
    expect(r.zaehler('notiz').heute, 1);
    expect(r.sitzungAlle(), ['c']);
  });

  test('ein Wort in zwei Decks: einmal gezählt, einmal geübt', () {
    final r = DeckRechner(
      decks: [_w('a'), _w('b'), _w('a1', 'a')],
      woerterJeDeck: {
        'a': ['x', 'y'],
        'a1': ['x'],
        'b': ['x', 'z'],
      },
      fortschritt: const {},
      jetzt: _jetzt,
    );
    expect(r.zaehler('a').woerter, 2);
    expect(r.sitzung('a'), ['x', 'y']);
    expect(r.sitzungAlle(), ['x', 'y', 'z']);
  });

  test('fehlendes Eltern-Deck ⇒ oberste Ebene (Limit 50)', () {
    final r = DeckRechner(
      decks: [_w('waise', 'weg')],
      woerterJeDeck: {'waise': _n('w', 60)},
      fortschritt: const {},
      jetzt: _jetzt,
    );
    expect(r.neueHeute('waise'), hasLength(50));
  });
}
