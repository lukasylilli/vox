// FILE: test/wortschatz_grammatikon_test.dart
// PHASE: B-9 (2026-09-15)
// PURPOSE: Sichert die Regel „lieber kein Symbol als ein falsches" ab.
//          Verben, Präpositionen und Konnektoren dürfen aus der alten
//          Wortschatz-Tabelle KEIN Symbol bekommen, solange die Felder
//          regelmaessig/trennbar/kasus/untertyp dort fehlen — sonst zeigt die
//          App erfundene Grammatik.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/grammatikon_resolver.dart';
import 'package:vox/core/grammatikon/grammatikon_spec.dart';
import 'package:vox/core/models/word_model.dart';
import 'package:vox/features/wortschatz/widgets/wortschatz_grammatikon.dart';

WordModel wort(WordType typ,
        {String? artikel,
        bool? regelmaessig,
        bool? trennbar,
        String? grammatikDetail}) =>
    WordModel(
      id: 1,
      german: 'Test',
      article: artikel,
      wordType: typ,
      meaningFa: 'آزمایش',
      regelmaessig: regelmaessig,
      trennbar: trennbar,
      grammatikDetail: grammatikDetail,
    );

void main() {
  test('Nomen mit Artikel bekommt Genusfarbe', () {
    final karte = grammatikonKarteAus(wort(WordType.nomen, artikel: 'die'));
    expect(karte, isNotNull);
    final d = GrammatikonResolver.resolve(karte!);
    expect(d.color, GrammatikonSpec.feminin);
    expect(d.shape, 'quadrat'); // Nominativ
  });

  test('Nomen ohne Artikel bekommt KEIN Symbol', () {
    expect(grammatikonKarteAus(wort(WordType.nomen)), isNull);
  });

  test('Verb ohne regelmaessig-Feld bekommt KEIN Symbol '
      '(Feld fehlt in älteren Zeilen / manchen Eingabeformaten)', () {
    expect(grammatikonKarteAus(wort(WordType.verb)), isNull);
  });

  test('Präposition ohne Kasus bekommt KEIN Symbol '
      '(Innenform der Kapsel wäre sonst geraten)', () {
    expect(grammatikonKarteAus(wort(WordType.praepositon)), isNull);
  });

  test('Sonstige bekommt nie ein Symbol', () {
    expect(grammatikonKarteAus(wort(WordType.sonstige)), isNull);
  });

  test('B-10: Verb MIT regelmaessig bekommt das passende Symbol', () {
    final regelmaessig =
        grammatikonKarteAus(wort(WordType.verb, regelmaessig: true))!;
    expect(GrammatikonResolver.resolve(regelmaessig).shape, 'kreis');

    final unregelmaessig =
        grammatikonKarteAus(wort(WordType.verb, regelmaessig: false))!;
    expect(GrammatikonResolver.resolve(unregelmaessig).shape, 'blob_wellig');
  });

  test('B-10: trennbar fehlt → wie "nicht trennbar" behandelt (vorsichtiger '
      'als raten)', () {
    final ohneTrennbar =
        grammatikonKarteAus(wort(WordType.verb, regelmaessig: true))!;
    final mitTrennbarFalse = grammatikonKarteAus(
        wort(WordType.verb, regelmaessig: true, trennbar: false))!;
    expect(GrammatikonResolver.resolve(ohneTrennbar).shape,
        GrammatikonResolver.resolve(mitTrennbarFalse).shape);
  });

  test('B-10: Präposition MIT Kasus bekommt die passende Innenform', () {
    final karte = grammatikonKarteAus(
        wort(WordType.praepositon, grammatikDetail: 'dativ'))!;
    expect(GrammatikonResolver.resolve(karte).shape, 'kapsel');
  });

  test('B-10: Konnektor bekommt IMMER ein Symbol — mit Untertyp genauer, '
      'ohne Untertyp den Standardfall', () {
    final ohne = grammatikonKarteAus(wort(WordType.konnektor))!;
    expect(GrammatikonResolver.resolve(ohne).shape, 'kurve_u');

    final mit = grammatikonKarteAus(
        wort(WordType.konnektor, grammatikDetail: 'subordinierend'))!;
    expect(GrammatikonResolver.resolve(mit).shape, 'kurve_welle');
  });

  test('Adjektiv, Pronomen, Zahl, Modalpartikel bekommen ein Symbol', () {
    const erwartet = {
      WordType.adjektiv     : 'quadrat',
      WordType.pronomen     : 'quadrat',
      WordType.zahl         : 'quadrat',
      WordType.modalpartikel: 'stern',
    };
    erwartet.forEach((typ, shape) {
      final karte = grammatikonKarteAus(wort(typ));
      expect(karte, isNotNull, reason: '$typ sollte ein Symbol bekommen');
      expect(GrammatikonResolver.resolve(karte!).shape, shape);
    });
  });
}
