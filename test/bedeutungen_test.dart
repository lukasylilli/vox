// FILE: test/bedeutungen_test.dart
// PHASE: L.4 (2026-10-19) — Wunsch Lukas: Hat EIN Wort mehrere deutlich
//        verschiedene Bedeutungen (die Birne = گلابی / لامپ), soll niemand
//        rätseln, warum beides auf einer Karte steht ⇒ nummeriert
//        («۱. گلابی  ۲. لامپ»), jedes Beispiel zeigt seine Bedeutung, in der
//        Lernkarte reicht die erste. Prüft Schema (Prompt-Regel 20), Index
//        und die Liste.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

Map<String, dynamic> birne() => {
      'schema': '3.0',
      'id': 'nomen_birne',
      'wort': 'die Birne',
      'wortart': 'nomen',
      'uebersetzung': {
        'fa': ['گلابی', 'لامپ'],
        'en': ['pear', 'light bulb'],
      },
      'bedeutungen': [
        {
          'fa': ['گلابی'],
          'en': ['pear'],
        },
        {
          'fa': ['لامپ'],
          'en': ['light bulb'],
        },
      ],
      'niveau': 'A2',
      'beispiele': [
        {'niveau': 'A2', 'satz': 'Die Birne ist süß.', 'bedeutung': 1},
        {
          'niveau': 'B1',
          'satz': 'Die Birne in der Küche ist kaputt.',
          'bedeutung': 2,
        },
      ],
      'details': {
        'genus': 'die',
        'plural': 'die Birnen',
        'deklinationstyp': 'normal',
        'zaehlbar': true,
      },
      'wortnetz': {
        'grundwort': null,
        'woerter': [
          for (final w in ['Apfel', 'Obst', 'Lampe', 'Licht', 'Baum'])
            {
              'wort': 'der $w',
              'wortart': 'nomen',
              'id_ref': vokabId('nomen', 'der $w'),
            },
        ],
      },
      'box': 1,
      'nextReviewDate': null,
    };

void main() {
  group('Schema (Regel 20)', () {
    test('zwei Bedeutungen mit je einem Beispiel: ok, keine Warnung', () {
      final p = vokabPruefeKarte(birne());
      expect(p.fehler, isEmpty);
      expect(p.warnungen, isEmpty);
      expect(vokabBedeutungen(p.karte!)!.length, 2);
    });

    test('uebersetzung wird aus den Bedeutungen gesetzt', () {
      final roh = birne();
      (roh['uebersetzung'] as Map)['en'] = ['pear'];
      final p = vokabPruefeKarte(roh);
      expect(p.warnungen.join(), contains('uebersetzung.en'));
      expect((p.karte!['uebersetzung'] as Map)['en'], ['pear', 'light bulb']);
    });

    test('nur eine Gruppe ⇒ null; kaputte Gruppe ⇒ fatal', () {
      final eine = birne()
        ..['bedeutungen'] = [
          {
            'fa': ['گلابی'],
            'en': ['pear'],
          },
        ];
      for (final b in eine['beispiele'] as List) {
        (b as Map).remove('bedeutung');
      }
      final p = vokabPruefeKarte(eine);
      expect(p.karte!['bedeutungen'], isNull);
      expect(p.warnungen.join(), contains('nur 1 Gruppe'));

      final kaputt = birne()
        ..['bedeutungen'] = [
          {'fa': <String>[], 'en': ['pear']},
          {
            'fa': ['لامپ'],
            'en': ['light bulb'],
          },
        ];
      expect(vokabPruefeKarte(kaputt).ok, isFalse);
    });

    test('Bedeutung ohne Beispiel ⇒ Warnung; falsche Nummer ⇒ entfernt', () {
      final roh = birne();
      ((roh['beispiele'] as List)[1] as Map)['bedeutung'] = 7;
      final p = vokabPruefeKarte(roh);
      expect(p.warnungen.join(),
          allOf(contains('bedeutung 7 ungültig'), contains('Bedeutung 2 ohne')));
      expect(((p.karte!['beispiele'] as List)[1] as Map).containsKey('bedeutung'),
          isFalse);
    });

    test('«bedeutung» ohne bedeutungen ⇒ entfernt', () {
      final roh = birne()..['bedeutungen'] = null;
      final p = vokabPruefeKarte(roh);
      expect(p.warnungen.join(), contains('keine bedeutungen'));
    });
  });

  test('Index trägt die Bedeutungen — Liste/Lernkarte brauchen keine volle Karte',
      () {
    final text =
        vokabIndexBauen({'assets/vocab/nomen/nomen_birne.json': birne()});
    final eintrag = (jsonDecode(text)['karten'] as List).single as Map;
    expect((eintrag['bedeutungen'] as List).length, 2);
  });

  testWidgets('Liste: Bedeutungen nummeriert in einer Zeile', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: WortCard(card: birne())),
    ));
    expect(find.text('1. pear   2. light bulb'), findsOneWidget);
  });
}
