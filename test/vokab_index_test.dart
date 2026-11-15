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

  group('Übersichtskarte «الف» (Vier Fälle, Lukas 2026-11-15)', () {
    Map<String, dynamic> mit(Map<String, dynamic> k, String niveau,
            List<String> fa, {String? ipa}) =>
        {
          ...k,
          'niveau': niveau,
          'uebersetzung': {'fa': fa, 'en': fa},
          'ipa': ?ipa,
        };
    Map<String, Map<String, dynamic>> familie() => {
          'assets/vocab/nomen/nomen_bank.json': mit(
              karte('nomen', 'nomen_bank', 'die Bank',
                  details: {'genus': 'die'}),
              'A2',
              ['نیمکت'],
              ipa: 'baŋk'),
          'assets/vocab/nomen/nomen_bank_2.json': mit(
              karte('nomen', 'nomen_bank_2', 'die Bank',
                  details: {'genus': 'die'}),
              'A1',
              ['بانک']),
          'assets/vocab/nomen/nomen_tisch.json':
              karte('nomen', 'nomen_tisch', 'der Tisch'),
        };

    test('jede Familie bekommt genau eine Übersichtskarte, ohne Datei', () {
      final e = vokabIndexLesen(vokabIndexBauen(familie()));
      final ue = e.where(vokabIstUebersicht).toList();
      expect(ue, hasLength(1));
      final a = ue.single;
      expect(a['id'], 'nomen_bank__alle');
      expect(a['wort'], 'Bank');
      expect(a['bedeutungen_ids'], ['nomen_bank', 'nomen_bank_2']);
      expect(a['ipa'], 'baŋk');
      expect(a['niveau'], 'A1', reason: 'leichtestes Niveau der Bedeutungen');
      expect((a['uebersetzung'] as Map)['fa'], ['نیمکت', 'بانک']);
      // Keine Beispiele, kein Wortnetz (Entwurf Lukas).
      expect(a.containsKey('beispiele'), isFalse);
      expect(a.containsKey('wortnetz'), isFalse);
    });

    test('Bedeutungskarten zeigen auf ihre Übersicht, andere nicht', () {
      final e = {
        for (final k in vokabIndexLesen(vokabIndexBauen(familie())))
          k['id'] as String: k
      };
      expect(e['nomen_bank']!['uebersicht_id'], 'nomen_bank__alle');
      expect(e['nomen_bank_2']!['uebersicht_id'], 'nomen_bank__alle');
      expect(e['nomen_tisch']!.containsKey('uebersicht_id'), isFalse);
      expect(e['nomen_bank']!['homograph_nr'], 1);
      expect(e['nomen_bank_2']!['homograph_nr'], 2);
    });

    test('jede id aus bedeutungen_ids gibt es als Karte', () {
      final e = vokabIndexLesen(vokabIndexBauen(echteKarten()));
      final ids = {for (final k in e) k['id']};
      for (final a in e.where(vokabIstUebersicht)) {
        for (final id in a['bedeutungen_ids'] as List) {
          expect(ids, contains(id), reason: '${a['id']} → $id fehlt');
        }
      }
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

    test('Karten werden neben der App ausgeliefert, nicht als Asset (V.5)',
        () {
      // Seit 2026-11-15: die Karten stehen NICHT in pubspec.yaml (sonst
      // landen alle Namen im Asset-Verzeichnis, das jeder Nutzer beim Start
      // lädt). Stattdessen kopieren beide Bau-Abläufe sie nach
      // build/web/karten/ — fehlt der Schritt, würde keine Karte ausgeliefert.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('- $vokabKartenOrdner/')),
          reason: 'Karten gehören nicht ins Asset-Paket (V.5)');
      expect(pubspec, contains('- $vokabIndexPfad'));
      for (final ablauf in const [
        '.github/workflows/deploy-web.yml',
        '.github/workflows/pruefen.yml',
      ]) {
        expect(
          File(ablauf).readAsStringSync(),
          contains('cp -R $vokabKartenOrdner/. build/web/$vokabKartenWebOrdner/'),
          reason: '$ablauf legt die Karten nicht neben die App',
        );
      }
      for (final wortart in vokabWortarten) {
        expect(Directory('$vokabKartenOrdner/$wortart').existsSync(), isTrue,
            reason: 'Ordner für $wortart fehlt');
      }
    });
  });
}
