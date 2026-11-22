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
    expect(r.neueHeute('a1').where((w) => w.startsWith('l1_')), hasLength(5),
        reason: 'Subdecks abwechselnd (Lukas 2026-11-22): 5 aus L1 …');
    expect(r.neueHeute('a1').where((w) => w.startsWith('l2_')), hasLength(5),
        reason: '… und 5 aus L2');
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
    expect(r.sitzung('d'), unorderedEquals(['f1', 'f3']),
        reason: 'Limit 0 ⇒ kein neues');
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
    expect(r.sitzung('a'), unorderedEquals(['x', 'y']));
    expect(r.sitzungAlle(), unorderedEquals(['x', 'y', 'z']));
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

  group('gemischt (Wunsch Lukas 2026-11-22)', () {
    DeckDaten lek(String id, String eltern) => DeckDaten(
        id: id, eltern: eltern, modus: deckModusWiederholen, nacheinander: true);

    test('Lektionen eines Standard-Decks: der Reihe nach, nicht gemischt', () {
      final r = DeckRechner(
        decks: [_w('a1'), lek('a1:l1', 'a1'), lek('a1:l2', 'a1')],
        woerterJeDeck: {'a1:l1': _n('l1_', 20), 'a1:l2': _n('l2_', 20)},
        fortschritt: const {},
        jetzt: _jetzt,
      );
      expect(r.neueHeute('a1'), _n('l1_', 10),
          reason: 'erst Lektion 1 (Limit der Lektion 10); Lektion 2 erst, '
              'wenn in Lektion 1 kein neues Wort mehr übrig ist');
    });

    test('Niveau: erst ganz A1 (Lektion für Lektion), dann A2 … bis C2', () {
      final r = DeckRechner(
        decks: [
          _w('niveau', null, 25),
          lek('a1', 'niveau'), lek('a1:l1', 'a1'), lek('a1:l2', 'a1'),
          lek('a2', 'niveau'), lek('a2:l1', 'a2'),
        ],
        woerterJeDeck: {
          'a1:l1': _n('a1l1_', 8),
          'a1:l2': _n('a1l2_', 8),
          'a2:l1': _n('a2l1_', 20),
        },
        fortschritt: const {},
        jetzt: _jetzt,
      );
      // A1 hat Limit 10 (Subdeck) ⇒ 8 aus Lektion 1, 2 aus Lektion 2 — und
      // KEIN A2, solange in A1 noch neue Wörter sind.
      expect(r.neueHeute('niveau'), [..._n('a1l1_', 8), ..._n('a1l2_', 2)]);

      // A1 ganz begonnen ⇒ jetzt A2.
      final gestern = _jetzt.subtract(const Duration(days: 1));
      final r2 = DeckRechner(
        decks: [
          _w('niveau', null, 25),
          lek('a1', 'niveau'), lek('a1:l1', 'a1'), lek('a1:l2', 'a1'),
          lek('a2', 'niveau'), lek('a2:l1', 'a2'),
        ],
        woerterJeDeck: {
          'a1:l1': _n('a1l1_', 8),
          'a1:l2': _n('a1l2_', 8),
          'a2:l1': _n('a2l1_', 20),
        },
        fortschritt: {
          for (final w in [..._n('a1l1_', 8), ..._n('a1l2_', 8)])
            w: LeitnerStand(
                wortId: w,
                fach: 2,
                naechsteWiederholung: _jetzt.add(const Duration(days: 2)),
                ersteWiederholung: gestern),
        },
        jetzt: _jetzt,
      );
      expect(r2.neueHeute('niveau'), _n('a2l1_', 10));
    });

    test('ein Deck: Subdecks abwechselnd ausgewählt und gemischt geübt', () {
      final r = DeckRechner(
        decks: [_w('mutter', null, 12), _w('a', 'mutter'), _w('b', 'mutter'),
            _w('c', 'mutter')],
        woerterJeDeck: {
          'a': _n('a', 30),
          'b': _n('b', 30),
          'c': _n('c', 30),
        },
        fortschritt: const {},
        jetzt: _jetzt,
      );
      final s = r.sitzung('mutter');
      expect(s, hasLength(12));
      for (final p in ['a', 'b', 'c']) {
        expect(s.where((w) => w.startsWith(p)), hasLength(4), reason: p);
      }
      // Durcheinander: nicht erst alle aus einem Subdeck.
      final bloecke = <String>[];
      for (final w in s) {
        if (bloecke.isEmpty || bloecke.last != w[0]) bloecke.add(w[0]);
      }
      expect(bloecke.length, greaterThan(3));
    });

    test('alle üben: Wörter verschiedener Decks durcheinander; am selben Tag '
        'dieselbe Reihenfolge', () {
      DeckRechner rechner(DateTime jetzt) => DeckRechner(
            decks: [_w('x', null, 10), _w('y', null, 10)],
            woerterJeDeck: {'x': _n('x', 30), 'y': _n('y', 30)},
            fortschritt: const {},
            jetzt: jetzt,
          );
      final s = rechner(_jetzt).sitzungAlle();
      expect(s, hasLength(20));
      expect(s.take(10).every((w) => w.startsWith('x')), isFalse);
      expect(s.take(10).every((w) => w.startsWith('y')), isFalse);
      expect(rechner(_jetzt.add(const Duration(hours: 3))).sitzungAlle(), s,
          reason: 'fest für den Tag');
    });
  });
}
