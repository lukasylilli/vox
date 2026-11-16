// FILE: test/such_index_test.dart
// PHASE: G8 (2026-11-16) — Regeln der globalen Suche außerhalb der Wörter
//        (lib/features/home/data/such_index.dart): Vergleichsform, Rang,
//        Gruppen. Die echten Daten prüft test/globale_suche_test.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/home/data/such_index.dart';

SuchEintrag e(
  String titel, {
  SuchBereich bereich = SuchBereich.verbPraep,
  String fa = '',
  String en = '',
  List<String> formen = const [],
}) =>
    SuchEintrag(
      bereich: bereich,
      titel: titel,
      fa: fa,
      en: en,
      route: '/x/$titel',
      formen: formen,
    );

void main() {
  group('suchNormal', () {
    test('klein, Leerraum einfach', () {
      expect(suchNormal('  Warten   AUF '), 'warten auf');
    });

    test('persische Schreibvarianten fallen zusammen', () {
      // arabisches ي/ك, Halbabstand, Kurzvokale
      expect(suchNormal('مي‌روم'), suchNormal('میروم'));
      expect(suchNormal('كتاب'), suchNormal('کتاب'));
      expect(suchNormal('مَدرسه'), suchNormal('مدرسه'));
    });
  });

  group('suchEintragRang', () {
    test('Reihenfolge: genau, Anfang, Wortanfang, Mitte, Form, Bedeutung', () {
      expect(suchEintragRang(e('warten'), 'warten'), SuchEintragRang.genau);
      expect(suchEintragRang(e('warten auf'), 'warten'), SuchEintragRang.anfang);
      expect(suchEintragRang(e('sich freuen auf'), 'freuen'),
          SuchEintragRang.wortAnfang);
      expect(suchEintragRang(e('abwarten'), 'warten'), SuchEintragRang.mitte);
      expect(suchEintragRang(e('gehen', formen: ['ging', 'ist gegangen']), 'ging'),
          SuchEintragRang.form);
      expect(suchEintragRang(e('gehen', fa: 'رفتن', en: 'to go'), 'to go'),
          SuchEintragRang.bedeutung);
      expect(suchEintragRang(e('gehen', fa: 'رفتن'), 'رفتن'),
          SuchEintragRang.bedeutung);
      expect(suchEintragRang(e('gehen'), 'kommen'), isNull);
    });

    test('eine Form trifft nur als ganzes Wort, nie über ein Hilfswort', () {
      final gehen = e('gehen', formen: ['geht', 'ging', 'ist gegangen']);
      expect(suchEintragRang(gehen, 'gegangen'), SuchEintragRang.form);
      expect(suchEintragRang(gehen, 'ist gegangen'), SuchEintragRang.form);
      expect(suchEintragRang(gehen, 'gang'), isNull,
          reason: 'Teil einer Form ist kein Treffer');
      expect(suchEintragRang(gehen, 'ist'), isNull,
          reason: '«ist» steht in fast jeder Stammform');
    });

    test('ein einzelner Buchstabe sucht nicht', () {
      expect(suchEintragRang(e('an'), 'a'), isNull);
      expect(suchGruppen([e('an')], 'a'), isEmpty);
      expect(suchGruppen([e('an')], '  '), isEmpty);
    });

    test('Beispielsätze gibt es im Eintrag nicht — nur Titel, Formen, Bedeutung',
        () {
      // Wächter gegen ein späteres «suchen wir doch auch in den Beispielen»:
      // dafür müsste SuchEintrag ein Feld bekommen, und dieser Test erinnert
      // an die Entscheidung in such_index.dart.
      expect(suchEintragRang(e('helfen', fa: 'کمک کردن'), 'ich warte'), isNull);
    });
  });

  group('suchGruppen', () {
    test('Gruppen in der Reihenfolge von SuchBereich, nur mit Treffern', () {
      final g = suchGruppen([
        e('warten auf'),
        e('Wartezeit', bereich: SuchBereich.grammatik),
        e('obwohl', bereich: SuchBereich.konnektoren),
        e('abwarten', bereich: SuchBereich.trennbarVerben),
      ], 'Wart');
      expect(g.keys.toList(), [
        SuchBereich.grammatik,
        SuchBereich.trennbarVerben,
        SuchBereich.verbPraep,
      ]);
    });

    test('in der Gruppe: Rang, dann kürzer, dann Alphabet', () {
      final g = suchGruppen([
        e('abwarten'),
        e('warten auf', fa: 'x'),
        e('erwarten'),
        e('warten'),
        e('hoffen', fa: 'warten (alt)'),
        e('warten an'),
      ], 'warten');
      expect(g[SuchBereich.verbPraep]!.map((x) => x.titel).toList(), [
        'warten', // genau
        'warten an', // Anfang, kürzer
        'warten auf', // Anfang
        'abwarten', // Mitte, gleich lang wie erwarten ⇒ Alphabet
        'erwarten',
        'hoffen', // nur Bedeutung
      ]);
    });

    test('die Suche darf groß, mit Leerraum oder persisch getippt sein', () {
      final liste = [e('obwohl', fa: 'با وجود این‌که')];
      expect(suchGruppen(liste, ' OBWOHL '), isNotEmpty);
      expect(suchGruppen(liste, 'اينكه'), isNotEmpty,
          reason: 'arabische Tastatur + ohne Halbabstand');
    });
  });
}
