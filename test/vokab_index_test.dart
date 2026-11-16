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
      expect(() => vokabIndexStueckLesen('{"version":99,"karten":[]}'),
          throwsFormatException);
      expect(() => vokabIndexStueckeLesen('{"version":99,"stuecke":[]}'),
          throwsFormatException);
    });
  });

  group('In Stücken (2026-11-16)', () {
    Map<String, Map<String, dynamic>> bestand() => {
          'assets/vocab/nomen/nomen_apfel.json':
              karte('nomen', 'nomen_apfel', 'der Apfel'),
          'assets/vocab/adjektiv/adjektiv_alt.json':
              karte('adjektiv', 'adjektiv_alt', 'alt'),
          'assets/vocab/nomen/nomen_bank.json':
              karte('nomen', 'nomen_bank', 'die Bank'),
          'assets/vocab/nomen/nomen_bank_2.json':
              karte('nomen', 'nomen_bank_2', 'die Bank'),
          'assets/vocab/adjektiv/adjektiv_aehnlich.json':
              karte('adjektiv', 'adjektiv_aehnlich', 'ähnlich'),
          'assets/vocab/numerale/numerale_3d.json':
              karte('numerale', 'numerale_3d', '3D'),
        };

    test('Stück = erster Buchstabe der id nach der Wortart, sonst Rest', () {
      expect(vokabIndexStueck('nomen', 'nomen_apfel'),
          'assets/vocab_index/a.json');
      expect(vokabIndexStueck('adjektiv', 'adjektiv_aehnlich'),
          'assets/vocab_index/a.json');
      expect(vokabIndexStueck('nomen', 'nomen_bank__alle'),
          'assets/vocab_index/b.json');
      expect(vokabIndexStueck('numerale', 'numerale_3d'),
          'assets/vocab_index/0.json');
      expect(vokabIndexStueck('nomen', 'nomen_'), 'assets/vocab_index/0.json');
    });

    test('Dateien: je Stück eine + Liste; jede Karte genau einmal', () {
      final dateien = vokabIndexBauen(bestand());
      expect(dateien.keys.toSet(), {
        'assets/vocab_index/0.json',
        'assets/vocab_index/a.json',
        'assets/vocab_index/b.json',
        vokabIndexStueckeDatei,
      });
      final liste = jsonDecode(dateien[vokabIndexStueckeDatei]!) as Map;
      expect(liste['stuecke'], [
        'assets/vocab_index/0.json',
        'assets/vocab_index/a.json',
        'assets/vocab_index/b.json',
      ]);
      // 6 Karten + 1 Übersichtskarte «الف» der Familie Bank.
      expect(liste['anzahl'], 7);
      final ids = [for (final e in vokabIndexLesen(dateien)) e['id']];
      expect(ids, hasLength(7));
      expect(ids.toSet(), hasLength(7));
    });

    test('Familie und ihre Übersichtskarte liegen im selben Stück', () {
      final b = vokabIndexStueckLesen(
          vokabIndexBauen(bestand())['assets/vocab_index/b.json']!);
      expect({for (final e in b) e['id']},
          {'nomen_bank', 'nomen_bank_2', 'nomen_bank__alle'});
    });

    test('ein neues Wort ändert nur sein Stück (und die Liste)', () {
      final vorher = vokabIndexBauen(bestand());
      final nachher = vokabIndexBauen({
        ...bestand(),
        'assets/vocab/verb/verb_baden.json': karte('verb', 'verb_baden', 'baden'),
      });
      final geaendert = {
        for (final d in nachher.keys)
          if (nachher[d] != vorher[d]) d
      };
      expect(geaendert, {'assets/vocab_index/b.json', vokabIndexStueckeDatei});
    });

    test('Reihenfolge wie bisher: nach Wort (klein), dann id — über alle Stücke',
        () {
      final e = vokabIndexLesen(vokabIndexBauen(bestand()));
      final erwartet = [...e]..sort((a, b) {
          final c = (a['wort'] as String)
              .toLowerCase()
              .compareTo((b['wort'] as String).toLowerCase());
          return c != 0 ? c : (a['id'] as String).compareTo(b['id'] as String);
        });
      expect([for (final k in e) k['id']], [for (final k in erwartet) k['id']]);
      expect(e.first['id'], 'numerale_3d');
    });

    test('nennt die Liste ein Stück, das fehlt ⇒ Fehler, nie halber Index', () {
      final dateien = vokabIndexBauen(bestand())
        ..remove('assets/vocab_index/b.json');
      expect(() => vokabIndexLesen(dateien), throwsFormatException);
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
      final ordner = Directory(vokabIndexOrdner);
      expect(ordner.existsSync(), isTrue,
          reason: 'Vor den Tests `dart run tool/vokab_index.dart` ausführen '
              '— jeder Workflow tut das direkt vor `flutter analyze`.');
      final aufPlatte = {
        for (final f in ordner.listSync().whereType<File>())
          f.path.replaceAll('\\', '/'): f.readAsStringSync(),
      };
      final frisch = vokabIndexBauen(echteKarten());
      expect(aufPlatte.keys.toSet(), frisch.keys.toSet(),
          reason: 'Index veraltet — ein Workflow baut ihn nicht neu.');
      for (final d in frisch.keys) {
        expect(aufPlatte[d] == frisch[d], isTrue,
            reason: '$d veraltet — ein Workflow baut den Index nicht neu.');
      }
    });

    test('kein Stück wird so groß wie früher der ganze Index', () {
      // Sinn der Aufteilung: eine Wortrunde lädt beim Nutzer nur ein kleines
      // Stück nach. Wächst ein Buchstabe über diese Grenze, muss die
      // Aufteilung feiner werden (vokabIndexStueck) — nicht die Grenze höher.
      for (final e in vokabIndexBauen(echteKarten()).entries) {
        expect(utf8.encode(e.value).length, lessThan(1500 * 1024),
            reason: '${e.key} ist zu groß geworden');
      }
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
      expect(pubspec, contains('- $vokabIndexOrdner/'));
      expect(pubspec, isNot(contains('- $vokabIndexAltPfad')));
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
