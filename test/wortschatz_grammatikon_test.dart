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

WordModel wort(WordType typ, {String? artikel}) => WordModel(
      id: 1,
      german: 'Test',
      article: artikel,
      wordType: typ,
      meaningFa: 'آزمایش',
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

  test('Verb, Präposition, Konnektor bekommen KEIN Symbol '
      '(Felder fehlen in der alten Tabelle)', () {
    for (final typ in [
      WordType.verb,
      WordType.praepositon,
      WordType.konnektor,
      WordType.sonstige,
    ]) {
      expect(grammatikonKarteAus(wort(typ)), isNull,
          reason: '$typ dürfte nur mit vollständigen Daten ein Symbol haben');
    }
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
