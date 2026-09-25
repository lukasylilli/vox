// Tests فاز V Stufe ۵: vokabParseBatch (Fences/Einzelobjekt/kaputt) und
// vokabPruefeKarte (fatal vs. normalisiert+Warnung) — die eine Quelle,
// die auch tool/vokabular_import.dart benutzt.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

Map<String, dynamic> gueltigesVerb() => {
      'schema': '3.0',
      'id': 'verb_lernen',
      'wort': 'lernen',
      'wortart': 'verb',
      'uebersetzung': {
        'fa': ['یاد گرفتن'],
        'en': ['to learn'],
      },
      'niveau': 'A1',
      'beispiele': [
        {'niveau': 'A1', 'satz': 'Ich lerne Deutsch.'},
        {'niveau': 'B1', 'satz': 'Er lernt jeden Tag.'},
      ],
      'details': {
        'trennbar': false,
        'regelmaessig': true,
        'hilfsverb': 'haben',
        'reflexiv': 'nein',
        'stammformen': {'infinitiv': 'lernen'},
        'konjugation': {'praesens': {}},
      },
      'wortnetz': {
        'grundwort': 'lernen',
        'woerter': [
          for (final w in ['üben', 'lehren', 'kennen', 'wissen', 'merken'])
            {'wort': w, 'wortart': 'verb', 'id_ref': 'verb_${w == 'üben' ? 'ueben' : w}'},
        ],
      },
      'box': 1,
      'nextReviewDate': null,
    };

void main() {
  group('vokabParseBatch', () {
    test('Array, Einzelobjekt und Code-Fences', () {
      expect(vokabParseBatch('[{"a":1},{"b":2}]').length, 2);
      expect(vokabParseBatch('{"a":1}').length, 1); // Einzelobjekt → Liste
      expect(
          vokabParseBatch('```json\n[{"a":1}]\n```').single['a'], 1); // Fences
    });
    test('kaputtes JSON → FormatException', () {
      expect(() => vokabParseBatch('[{'), throwsFormatException);
    });
  });

  group('vokabPruefeKarte', () {
    test('gültige Karte → ok, keine Fehler', () {
      final p = vokabPruefeKarte(gueltigesVerb());
      expect(p.ok, isTrue);
      expect(p.fehler, isEmpty);
    });

    test('fatal: wortart/niveau/uebersetzung fehlerhaft → keine Karte', () {
      expect(vokabPruefeKarte(gueltigesVerb()..['wortart'] = 'quatsch').ok,
          isFalse);
      expect(
          vokabPruefeKarte(gueltigesVerb()..['niveau'] = 'Z9').ok, isFalse);
      expect(
          vokabPruefeKarte(gueltigesVerb()..['uebersetzung'] = {'fa': []}).ok,
          isFalse);
    });

    test('id-Typo wird korrigiert (Regel 5) + Warnung', () {
      final p = vokabPruefeKarte(gueltigesVerb()..['id'] = 'verb_Lernen!');
      expect(p.ok, isTrue);
      expect(p.karte!['id'], 'verb_lernen');
      expect(p.warnungen.join(), contains('korrigiert'));
    });

    test('gespeichertes Perfekt wird entfernt (Regel 7)', () {
      final roh = gueltigesVerb();
      (roh['details'] as Map)['konjugation']['perfekt'] = {'ich': 'habe gelernt'};
      final p = vokabPruefeKarte(roh);
      expect(
          ((p.karte!['details'] as Map)['konjugation'] as Map)
              .containsKey('perfekt'),
          isFalse);
      expect(p.warnungen.join(), contains('perfekt'));
    });

    test('box/nextReviewDate werden normalisiert', () {
      final p = vokabPruefeKarte(gueltigesVerb()
        ..['box'] = 4
        ..['nextReviewDate'] = '2026-01-01');
      expect(p.karte!['box'], 1);
      expect(p.karte!['nextReviewDate'], isNull);
    });

    test('Regel 9: Zielwort fehlt im Beispielsatz → Warnung', () {
      final roh = gueltigesVerb();
      (roh['beispiele'] as List)[0] = {'niveau': 'A1', 'satz': 'Das ist gut.'};
      final p = vokabPruefeKarte(roh);
      expect(p.warnungen.join(), contains('Lückentext'));
    });

    test('Regel 9: mehr als 2 Beispiele erlaubt (nur erweitern), weniger → Warnung',
        () {
      final mehr = gueltigesVerb();
      (mehr['beispiele'] as List)
          .add({'niveau': 'C1', 'satz': 'Wir lernen gemeinsam.'});
      expect(vokabPruefeKarte(mehr).warnungen, isEmpty);

      final weniger = gueltigesVerb();
      (weniger['beispiele'] as List).removeLast();
      expect(vokabPruefeKarte(weniger).warnungen.join(),
          contains('1 Beispiele statt 2'));
    });

    test('Regel 12: etymologie muss {fa, en} sein — String/kaputt → Warnung',
        () {
      // zweisprachig → ok
      final ok = vokabPruefeKarte(gueltigesVerb()
        ..['etymologie'] = {'fa': 'lern- (ریشه)', 'en': 'lern- (stem)'});
      expect(ok.warnungen.join(), isNot(contains('etymologie')));

      // altes Format (String mit FA-Glossen) → Warnung
      final legacy = vokabPruefeKarte(
          gueltigesVerb()..['etymologie'] = 'lern- (ریشه) + -en');
      expect(legacy.warnungen.join(), contains('etymologie einsprachig'));

      // kaputt (en fehlt) → Warnung; null → keine Warnung
      final kaputt = vokabPruefeKarte(
          gueltigesVerb()..['etymologie'] = {'fa': 'nur fa'});
      expect(kaputt.warnungen.join(), contains('etymologie ungültig'));
      final ohne = vokabPruefeKarte(gueltigesVerb()..['etymologie'] = null);
      expect(ohne.warnungen.join(), isNot(contains('etymologie')));
    });

    test('wortnetz: falsches id_ref korrigiert; null nur bei partikel ok', () {
      final roh = gueltigesVerb();
      ((roh['wortnetz'] as Map)['woerter'] as List)[0]['id_ref'] = 'FALSCH';
      final p = vokabPruefeKarte(roh);
      expect(((p.karte!['wortnetz'] as Map)['woerter'] as List)[0]['id_ref'],
          'verb_ueben');

      final ohneNetz = vokabPruefeKarte(gueltigesVerb()..['wortnetz'] = null);
      expect(ohneNetz.warnungen.join(), contains('wortnetz'));

      final partikel = gueltigesVerb()
        ..['wortart'] = 'partikel'
        ..['wortnetz'] = null
        ..['details'] = {'untertyp': 'modalpartikel', 'funktion': 'x', 'register': 'neutral'};
      expect(vokabPruefeKarte(partikel).warnungen.join(),
          isNot(contains('wortnetz')));
    });
  });
}
