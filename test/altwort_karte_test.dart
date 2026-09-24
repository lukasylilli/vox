// FILE: test/altwort_karte_test.dart
// PHASE: L.4b (2026-09-24)
// PURPOSE: Wächter der Paarung altes App-Wort ↔ Prompt-Karte
//          (lib/features/wortschatz/data/altwort_karte.dart).
//          Grundregel (Lukas, 2026-09-24): jede Karte hat IMMER ihre eigene
//          Seite und Zeile; eine alte Seite zeigt sie höchstens ZUSÄTZLICH.
//          Nichts gelöscht; gepaart wird nur, was eindeutig ist — nie geraten.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/wortschatz/data/altwort_karte.dart';

AltwortEintrag _w(int id, String german, String typ, {bool ausApp = true}) =>
    AltwortEintrag(id: id, german: german, wordType: typ, ausApp: ausApp);

Map<String, dynamic> _k(String id, String wort, String wortart) => {
  'id': id,
  'wort': wort,
  'wortart': wortart,
};

void main() {
  group('altwortZuordnen', () {
    test(
      'gleiches Lemma + verträgliche Wortart ⇒ Paar in beide Richtungen',
      () {
        final z = altwortZuordnen(
          [_w(1, 'helfen', 'verb')],
          [_k('verb_helfen', 'helfen', 'verb')],
        );
        expect(z.karteZuWort, {'verb_helfen': 1});
        expect(z.wortZuKarte, {1: 'verb_helfen'});
      },
    );

    test('Artikel und Groß/Klein zählen nicht', () {
      final z = altwortZuordnen(
        [_w(2, 'die Angst', 'nomen')],
        [_k('nomen_angst', 'die Angst', 'nomen')],
      );
      expect(z.wortZuKarte[2], 'nomen_angst');
    });

    test('andere Wortart ⇒ kein Paar (der Konnektor ≠ der Artikel)', () {
      final z = altwortZuordnen(
        [_w(3, 'der', 'konnektor'), _w(4, 'doch', 'konnektor')],
        [
          _k('artikel_der', 'der', 'artikel'),
          _k('partikel_doch', 'doch', 'partikel'),
        ],
      );
      expect(z.karteZuWort, isEmpty);
    });

    test('eigenes Wort des Nutzers (ausApp=false) ⇒ nie gepaart', () {
      final z = altwortZuordnen(
        [_w(5, 'helfen', 'verb', ausApp: false)],
        [_k('verb_helfen', 'helfen', 'verb')],
      );
      expect(z.karteZuWort, isEmpty);
    });

    test(
      'Wort + feste Präposition (L.4b-2) ⇒ Paar nur mit passender grammarNote',
      () {
        final mit = altwortZuordnen(
          [
            const AltwortEintrag(
              id: 6,
              german: 'warten auf',
              wordType: 'verb',
              ausApp: true,
              grammarNote: 'auf + Akk',
            ),
          ],
          [_k('verb_warten', 'warten', 'verb')],
        );
        expect(mit.wortZuKarte, {6: 'verb_warten'});
        expect(mit.karteZuWort, {'verb_warten': 6});

        // ohne grammarNote (z. B. NVV-Ausdruck) wird nie gekürzt
        final ohne = altwortZuordnen(
          [_w(7, 'denken an', 'verb')],
          [_k('verb_denken', 'denken', 'verb')],
        );
        expect(ohne.karteZuWort, isEmpty);
      },
    );

    test('Ausdruck (NVV) wird nie mit der Wortkarte gepaart (L.4c)', () {
      final z = altwortZuordnen(
        [_w(8, 'eine Entscheidung treffen', 'sonstige')],
        [_k('nomen_entscheidung', 'die Entscheidung', 'nomen')],
      );
      expect(z.karteZuWort, isEmpty);
    });

    test(
      'eine Karte unter mehreren alten Seiten; Link ⇒ Seite ohne Präposition',
      () {
        AltwortEintrag p(int id, String g, String note) => AltwortEintrag(
          id: id,
          german: g,
          wordType: 'verb',
          ausApp: true,
          grammarNote: note,
        );
        final z = altwortZuordnen(
          [
            p(12, 'vertrauen in', 'in + Akk'),
            p(11, 'vertrauen auf', 'auf + Akk'),
            _w(10, 'vertrauen', 'verb'),
          ],
          [_k('verb_vertrauen', 'vertrauen', 'verb')],
        );
        expect(z.wortZuKarte, {
          10: 'verb_vertrauen',
          11: 'verb_vertrauen',
          12: 'verb_vertrauen',
        });
        expect(z.karteZuWort, {'verb_vertrauen': 10});

        // ohne Seite ohne Präposition ⇒ alphabetisch erste
        final nurMit = altwortZuordnen(
          [
            p(21, 'arbeiten bei', 'bei + Dat'),
            p(20, 'arbeiten an', 'an + Dat'),
          ],
          [_k('verb_arbeiten', 'arbeiten', 'verb')],
        );
        expect(nurMit.karteZuWort, {'verb_arbeiten': 20});
        expect(nurMit.wortZuKarte.length, 2);
      },
    );

    test('nicht eindeutig ⇒ kein Paar', () {
      // zwei Karten passen auf ein Wort (sonstige ⇒ artikel ODER adverb)
      final a = altwortZuordnen(
        [_w(7, 'da', 'sonstige')],
        [_k('adverb_da', 'da', 'adverb'), _k('artikel_da', 'da', 'artikel')],
      );
      expect(a.karteZuWort, isEmpty);
      // zwei alte Wörter passen auf eine Karte
      final b = altwortZuordnen(
        [_w(8, 'Bank', 'nomen'), _w(9, 'bank', 'nomen')],
        [_k('nomen_bank', 'die Bank', 'nomen')],
      );
      expect(b.karteZuWort, isEmpty);
    });
  });

  // Echte Daten: veröffentlichte App-Wörter (L.1e) × echte Karten.
  test('echte Daten: bekannte Paare stehen, keine Karte doppelt', () {
    final woerter = <AltwortEintrag>[];
    var id = 0;
    for (final zeile in File(
      'test/daten/seed_schluessel_veroeffentlicht.txt',
    ).readAsLinesSync()) {
      if (zeile.trim().isEmpty || zeile.startsWith('#')) continue;
      final i = zeile.lastIndexOf('|');
      woerter.add(_w(++id, zeile.substring(0, i), zeile.substring(i + 1)));
    }
    // Präpositionen-Deck mit grammarNote wie DataSeedService (L.4b-2).
    final praep =
        (jsonDecode(
                  File(
                    'assets/data/praepositionen_data.json',
                  ).readAsStringSync(),
                )
                as List)
            .cast<Map<String, dynamic>>();
    final mitNote = <String>{};
    for (final c in praep) {
      for (final m in (c['members'] as List).cast<Map<String, dynamic>>()) {
        final g = '${m['lemma']} ${m['preposition']}';
        if (!mitNote.add(g)) continue;
        woerter.add(
          AltwortEintrag(
            id: ++id,
            german: g,
            wordType: switch ((m['word_class'] as String? ?? '')
                .toLowerCase()) {
              'verb' => 'verb',
              'noun' => 'nomen',
              'adjective' => 'adjektiv',
              _ => 'sonstige',
            },
            ausApp: true,
            grammarNote: '${m['preposition']} + ${m['case'] ?? ''}',
          ),
        );
      }
    }
    woerter.removeWhere(
      (w) => w.grammarNote == null && mitNote.contains(w.german),
    );
    final karten = <Map<String, dynamic>>[
      for (final f in Directory('assets/vocab').listSync(recursive: true))
        if (f is File && f.path.endsWith('.json'))
          (jsonDecode(f.readAsStringSync()) as Map).cast<String, dynamic>(),
    ];

    final z = altwortZuordnen(woerter, karten);
    expect(
      z.karteZuWort.keys,
      containsAll(['verb_helfen', 'konjunktion_weil']),
    );
    expect(z.karteZuWort, isNot(contains('artikel_der')));
    expect(z.karteZuWort, isNot(contains('partikel_doch')));
    // L.4b-2: «warten auf» / «stolz auf» hängen an ihrer Karte.
    expect(z.karteZuWort.keys, containsAll(['verb_warten', 'adjektiv_stolz']));
    // jede Karte hat genau ein Linkziel, und das zeigt auch auf sie zurück
    z.karteZuWort.forEach((karte, wort) => expect(z.wortZuKarte[wort], karte));
  });

  // Grundregel (Lukas, 2026-09-24): jede Karte behält ihre eigene Seite und
  // Zeile. Wächter gegen die frühere Umleitung/Ausblendung (L.4b alt).
  test('Grundregel: keine Umleitung, kein Ausblenden, Zähler zählt alles', () {
    final seite = File(
      'lib/features/vokabular/screens/wort_seite_screen.dart',
    ).readAsStringSync();
    expect(seite, isNot(contains('WordDetailScreen(')));
    expect(seite, isNot(contains('altwortZuordnungProvider')));
    for (final pfad in [
      'lib/features/wortschatz/screens/wortschatz_list_screen.dart',
      'lib/features/wortschatz/screens/wortschatz_home_screen.dart',
    ]) {
      final code = File(pfad).readAsStringSync();
      expect(code, isNot(contains('altwortZuordnungProvider')), reason: pfad);
      expect(code, isNot(contains('karteZuWort')), reason: pfad);
    }
  });
}
