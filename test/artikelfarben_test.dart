// FILE: test/artikelfarben_test.dart
// PHASE: B-9 (2026-09-15)
// PURPOSE: Hält fest, dass es nur EIN Artikel-Farbsystem gibt. Bis 2026-09-15
//          liefen zwei nebeneinander (der=blau in der Wortschatz-Liste,
//          der=grün im Grammatikon). Fällt das je wieder auseinander, soll es
//          hier auffallen und nicht erst beim Lernenden.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/constants/article_colors.dart';
import 'package:vox/core/grammatikon/grammatikon_spec.dart';

void main() {
  test('Artikelfarben kommen aus GrammatikonSpec — keine zweite Tabelle', () {
    expect(ArticleColors.der, GrammatikonSpec.maskulin);
    expect(ArticleColors.die, GrammatikonSpec.feminin);
    expect(ArticleColors.das, GrammatikonSpec.neutral);
    expect(ArticleColors.plural, GrammatikonSpec.plural);
  });

  test('forString bildet auf dieselben Farben ab', () {
    expect(ArticleColors.forString('der'), GrammatikonSpec.maskulin);
    expect(ArticleColors.forString('DIE'), GrammatikonSpec.feminin);
    expect(ArticleColors.forString('das'), GrammatikonSpec.neutral);
    expect(ArticleColors.forString(null), GrammatikonSpec.verb);
    expect(ArticleColors.forString('Wort'), GrammatikonSpec.verb);
  });

  test('die vier Genusfarben sind paarweise verschieden', () {
    final farben = {
      GrammatikonSpec.maskulin,
      GrammatikonSpec.feminin,
      GrammatikonSpec.neutral,
      GrammatikonSpec.plural,
    };
    expect(farben.length, 4);
  });
}
