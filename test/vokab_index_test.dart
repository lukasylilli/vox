// FILE: test/vokab_index_test.dart
// PHASE: فاز V, Schritt V.2 (2026-09-16)
// PURPOSE: Sichert den Wortindex ab — das Format (reines Dart) und, an den
//          ECHTEN Karten aus assets/vocab/, dass Liste und Symbol aus dem Index
//          genau so aussehen wie aus der vollen Karte.
//
// Die drei Wächter unten schlagen an, wenn
//   · der Resolver ein neues details-Feld liest, das der Index nicht trägt,
//   · ein Workflow vergisst, den Index vor den Tests neu zu bauen,
//   · eine Wortart-Ordner in pubspec.yaml fehlt (Karte gebaut, aber nie ausgeliefert).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/grammatikon_resolver.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

Map<String, dynamic> karte(String wortart, String id, String wort,
        {Map<String, dynamic> details = const {}}) =>
    {
      'id': id,
      'wort': wort,
      'wortart': wortart,
      'niveau': 'A1',
      'uebersetzung': {
        'fa': ['x'],
        'en': ['y'],
      },
      'details': details,
      'beispiele': [
        {'de': 'Satz'},
      ],
      'box': 1,
    };

/// Alle echten Karten, Schlüssel = Pfad wie im Index-Bau.
Map<String, Map<String, dynamic>> echteKarten() => {
      for (final f in Directory(vokabKartenOrdner)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json')))
        f.path.replaceAll('\\', '/'):
            (jsonDecode(f.readAsStringSync()) as Map).cast<String, dynamic>(),
    };

void main() {
  group('Format', () {
    test('Eintrag trägt nur Listenfelder — kein Lernstand, kein Seiteninhalt',
        () {
      final e = vokabIndexEintrag(karte('verb', 'verb_gehen', 'gehen',
          details: {'regelmaessig': false, 'trennbar': false, 'konjugation': {}}));
      expect(e.keys.toSet(),
          {'id', 'wort', 'wortart', 'niveau', 'uebersetzung', 'details'});
      expect(e['details'], {'regelmaessig': false, 'trennbar': false});
    });

    test('bauen → lesen ergibt die Einträge, sortiert nach Wort', () {
      final text = vokabIndexBauen({
        'assets/vocab/verb/verb_lernen.json':
            karte('verb', 'verb_lernen', 'lernen'),
        'assets/vocab/adjektiv/adjektiv_alt.json':
            karte('adjektiv', 'adjektiv_alt', 'alt'),
      });
      final eintraege = vokabIndexLesen(text);
      expect(eintraege.map((e) => e['id']), ['adjektiv_alt', 'verb_lernen']);
    });

    test('falscher Ort, fehlende id, unbekannte Wortart: ALLE Gründe', () {
      expect(
        () => vokabIndexBauen({
          'assets/vocab/nomen/verb_lernen.json':
              karte('verb', 'verb_lernen', 'lernen'),
          'assets/vocab/verb/ohne.json': karte('verb', '', 'ohne'),
          'assets/vocab/fantasie/x.json': karte('fantasie', 'x', 'x'),
        }),
        throwsA(isA<VokabIndexFehler>()
            .having((f) => f.gruende.length, 'Anzahl Gründe', 3)),
      );
    });

    test('fremde Fassung wird abgelehnt statt still leer gelesen', () {
      expect(() => vokabIndexLesen('{"version":99,"karten":[]}'),
          throwsFormatException);
    });
  });

  group('Echte Karten (assets/vocab/)', () {
    test('Symbol und Farbe aus dem Index = aus der vollen Karte', () {
      final karten = echteKarten();
      expect(karten, isNotEmpty);
      for (final e in karten.entries) {
        final voll = GrammatikonResolver.resolve(e.value);
        final index = GrammatikonResolver.resolve(vokabIndexEintrag(e.value));
        expect(
          [index.shape, index.fuellung, index.color, index.marker, index.innen],
          [voll.shape, voll.fuellung, voll.color, voll.marker, voll.innen],
          reason: '${e.key}: dem Index fehlt ein details-Feld, das der '
              'Resolver liest → vokabIndexDetailFelder ergänzen',
        );
      }
    });

    test('der ausgelieferte Index ist frisch gebaut', () {
      final datei = File(vokabIndexPfad);
      expect(datei.existsSync(), isTrue,
          reason: 'Vor den Tests `dart run tool/vokab_index.dart` ausführen '
              '— jeder Workflow tut das direkt vor `flutter analyze`.');
      expect(datei.readAsStringSync(), vokabIndexBauen(echteKarten()),
          reason: 'Index veraltet — ein Workflow baut ihn nicht neu.');
    });

    test('jede Wortart hat ihren Ordner in pubspec.yaml, der Index auch', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final wortart in vokabWortarten) {
        expect(pubspec, contains('- $vokabKartenOrdner/$wortart/'),
            reason: 'Karten dieser Wortart würden nie ausgeliefert');
      }
      expect(pubspec, contains('- $vokabIndexPfad'));
    });
  });
}
