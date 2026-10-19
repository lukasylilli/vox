// FILE: test/vokab_eigenname_homograph_test.dart
// PHASE: L.4 — Wortliste 4 (Nomen), Entscheidungen Lukas 2026-10-19:
//        (1) Eigennamen (Städte, Länder …) = KURZE Karte: IPA + Bedeutung +
//            Artikel/Genus (Prompt-Regel 18).
//        (2) Homographen (der See / die See) = zwei Karten mit eigener id;
//            Hauptbedeutung behält die normale id (Prompt-Regel 19).
//        Wächter: wird eins davon rot, wird keine Nomen-Karte gebaut.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

Map<String, dynamic> eigenname({
  String wort = 'Aachen',
  String genus = 'das',
  bool mitArtikel = false,
}) =>
    {
      'schema': '3.0',
      'id': vokabId('nomen', wort),
      'wort': wort,
      'homograph': null,
      'wortart': 'nomen',
      'uebersetzung': {
        'fa': ['آخن (شهری در آلمان)'],
        'en': ['Aachen (city in Germany)'],
      },
      'niveau': 'B1',
      'themen': ['Geografie'],
      'ipa': 'ˈaːxn̩',
      'anmerkung': null,
      'berufe': <String>[],
      'anstoessig': null,
      'zeitlich': null,
      'ersatz': null,
      'beispiele': <Map>[],
      'synonyme': <Map>[],
      'antonyme': <Map>[],
      'komposita': <Map>[],
      'etymologie': null,
      'details': {
        'eigenname': true,
        'genus': genus,
        'mit_artikel': mitArtikel,
      },
      'wortnetz': null,
      'box': 1,
      'nextReviewDate': null,
    };

void main() {
  group('Eigenname (Regel 18) — kurze Karte', () {
    test('ohne Beispiele/Wortnetz: ok und KEINE Warnung', () {
      final p = vokabPruefeKarte(eigenname());
      expect(p.ok, isTrue);
      expect(p.fehler, isEmpty);
      expect(p.warnungen, isEmpty);
      expect(p.karte!['id'], 'nomen_aachen');
    });

    test('mit Artikel: «die Schweiz» → nomen_schweiz, keine Warnung', () {
      final p = vokabPruefeKarte(
          eigenname(wort: 'die Schweiz', genus: 'die', mitArtikel: true));
      expect(p.warnungen, isEmpty);
      expect(p.karte!['id'], 'nomen_schweiz');
    });

    test('Lemma passt nicht zu mit_artikel → Warnung', () {
      final p = vokabPruefeKarte(eigenname(mitArtikel: true));
      expect(p.warnungen.join(), contains('mit_artikel'));
    });

    test('Eigenname ohne gültiges genus oder nicht als Nomen → fatal', () {
      final ohneGenus = eigenname();
      (ohneGenus['details'] as Map).remove('genus');
      expect(vokabPruefeKarte(ohneGenus).ok, isFalse);

      final alsAdjektiv = eigenname()..['wortart'] = 'adjektiv';
      expect(vokabPruefeKarte(alsAdjektiv).ok, isFalse);
    });

    test('normales Nomen ohne Beispiele bleibt eine Warnung', () {
      final normal = eigenname();
      normal['details'] = {
        'genus': 'das',
        'plural': null,
        'deklinationstyp': 'normal',
        'zaehlbar': false,
      };
      expect(vokabPruefeKarte(normal).warnungen.join(),
          allOf(contains('Beispiele'), contains('wortnetz')));
    });

    test('Suche: Genitiv nur «-s», nie «-es»; s/z-Endung ohne Form', () {
      final f = formenAusKarte(eigenname());
      expect(f, contains('aachens'));
      expect(f, isNot(contains('aachenes')));

      final graz = formenAusKarte(eigenname(wort: 'Graz'));
      expect(graz, isNot(contains('grazs')));
    });
  });

  group('Homographen (Regel 19) — eigene id je Bedeutung', () {
    test('vokabId: Hauptbedeutung normal, weitere mit Kennung', () {
      expect(vokabId('nomen', 'der See'), 'nomen_see');
      expect(vokabId('nomen', 'die See', homograph: 'die'), 'nomen_see_die');
      expect(vokabId('nomen', 'die Bank', homograph: '2'), 'nomen_bank_2');
      expect(vokabId('nomen', 'der See', homograph: null), 'nomen_see');
    });

    test('Karte mit homograph bekommt die richtige id', () {
      final see = eigenname(wort: 'die See', genus: 'die', mitArtikel: true)
        ..['homograph'] = 'die'
        ..['id'] = 'nomen_see';
      final p = vokabPruefeKarte(see);
      expect(p.ok, isTrue);
      expect(p.karte!['id'], 'nomen_see_die');
    });

    test('ungültige Kennung oder falsches Genus → fatal', () {
      expect(vokabPruefeKarte(eigenname()..['homograph'] = 'x').ok, isFalse);
      expect(vokabPruefeKarte(eigenname()..['homograph'] = '1').ok, isFalse);
      // Artikel-Kennung muss zum Genus passen (Aachen ist «das»).
      expect(vokabPruefeKarte(eigenname()..['homograph'] = 'die').ok, isFalse);
      expect(vokabPruefeKarte(eigenname()..['homograph'] = 'das').ok, isTrue);
    });

    test('Wortnetz-Verweis auf weitere Bedeutung: id_ref mit Kennung', () {
      final karte = eigenname();
      karte['wortnetz'] = {
        'grundwort': null,
        'woerter': [
          {
            'wort': 'die See',
            'wortart': 'nomen',
            'homograph': 'die',
            'id_ref': 'nomen_see',
          },
        ],
      };
      final p = vokabPruefeKarte(karte);
      final eintrag = ((p.karte!['wortnetz'] as Map)['woerter'] as List).first;
      expect(eintrag['id_ref'], 'nomen_see_die');
    });
  });
}
