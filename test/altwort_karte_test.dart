// FILE: test/altwort_karte_test.dart
// PHASE: L.4b (2026-09-24)
// PURPOSE: Wächter der Paarung altes App-Wort ↔ Prompt-Karte
//          (lib/features/wortschatz/data/altwort_karte.dart).
//          Regel (Lukas): alte Seite wird um die Karte erweitert, nichts
//          gelöscht; gepaart wird nur, was eindeutig ist — nie geraten.
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

    test('Lemma mit Präposition ⇒ kein Paar mit dem blanken Verb', () {
      final z = altwortZuordnen(
        [_w(6, 'denken an', 'verb')],
        [_k('verb_denken', 'denken', 'verb')],
      );
      expect(z.karteZuWort, isEmpty);
    });

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
    expect(z.karteZuWort.length, z.wortZuKarte.length);
  });
}
