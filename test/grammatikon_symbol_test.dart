// Smoke-Test فاز V Stufe ۱: jede Wortart durch Resolver + Painter schicken.
// CustomPainter kann erst zur Paint-Zeit werfen — dieser Test rendert real.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/grammatikon_painter.dart';
import 'package:vox/core/grammatikon/grammatikon_resolver.dart';

void main() {
  // Minimale Karten je Wortart (SUPER-PROMPT Schema 2.0, nur was der Resolver liest).
  final karten = <String, Map<String, dynamic>>{
    'nomen': {'wortart': 'nomen', 'details': {'genus': 'der'}},
    'nomen_die': {'wortart': 'nomen', 'details': {'genus': 'die'}},
    'nomen_das': {'wortart': 'nomen', 'details': {'genus': 'das'}},
    'artikel': {'wortart': 'artikel', 'details': {'typ': 'bestimmt'}},
    'artikel_unbestimmt': {'wortart': 'artikel', 'details': {'typ': 'unbestimmt'}},
    'pronomen': {'wortart': 'pronomen', 'details': <String, dynamic>{}},
    'adjektiv': {'wortart': 'adjektiv', 'details': <String, dynamic>{}},
    'verb_regelm': {'wortart': 'verb', 'details': {'regelmaessig': true}},
    'verb_unregelm': {'wortart': 'verb', 'details': {'regelmaessig': false}},
    'verb_trennbar': {'wortart': 'verb', 'details': {'regelmaessig': true, 'trennbar': true}},
    'verb_modal': {'wortart': 'verb', 'details': {'modalverb': true}},
    'praep_akk': {'wortart': 'praeposition', 'details': {'kasus': 'akkusativ'}},
    'praep_wechsel': {'wortart': 'praeposition', 'details': {'kasus': 'wechsel'}},
    'konjunktion': {'wortart': 'konjunktion', 'details': {'untertyp': 'subordinierend'}},
    'adverb': {'wortart': 'adverb', 'details': <String, dynamic>{}},
    'numerale': {'wortart': 'numerale', 'details': <String, dynamic>{}},
    'partikel': {'wortart': 'partikel', 'details': <String, dynamic>{}},
    'unbekannt': {'wortart': 'xyz', 'details': <String, dynamic>{}},
  };

  testWidgets('WortSymbol rendert jede Wortart ohne Exception', (tester) async {
    for (final entry in karten.entries) {
      await tester.pumpWidget(MaterialApp(
        home: Center(child: WortSymbol(card: entry.value, size: 36)),
      ));
      expect(tester.takeException(), isNull, reason: 'Wortart ${entry.key} warf beim Rendern');
    }
  });

  testWidgets('flektierte Kontexte (Kasus/Form) rendern ohne Exception', (tester) async {
    const kasusListe = ['nominativ', 'akkusativ', 'dativ', 'genitiv'];
    const formen = ['partizip1', 'partizip2', 'imperativ'];
    for (final k in kasusListe) {
      await tester.pumpWidget(MaterialApp(
        home: WortSymbol(card: karten['nomen']!, kasus: k, size: 24),
      ));
      expect(tester.takeException(), isNull, reason: 'Nomen Kasus $k');
    }
    for (final f in formen) {
      await tester.pumpWidget(MaterialApp(
        home: WortSymbol(card: karten['verb_unregelm']!, form: f, size: 24),
      ));
      expect(tester.takeException(), isNull, reason: 'Verb Form $f');
    }
  });

  test('Resolver: Genus → Farbe, Kasus → Form', () {
    final der = GrammatikonResolver.resolve(karten['nomen']!);
    final die = GrammatikonResolver.resolve(karten['nomen_die']!);
    expect(der.color, isNot(die.color)); // verschiedene Genus-Farben
    expect(der.shape, 'quadrat'); // Nominativ

    final akk = GrammatikonResolver.resolve(
        karten['nomen']!, const GrammatikonContext(kasus: 'akkusativ'));
    expect(akk.shape, 'raute'); // Akkusativ = gedrehtes Quadrat

    final plural = GrammatikonResolver.resolve(
        karten['nomen']!, const GrammatikonContext(numerus: 'plural'));
    expect(plural.color, isNot(der.color)); // Plural = rote Farbe
  });
}
