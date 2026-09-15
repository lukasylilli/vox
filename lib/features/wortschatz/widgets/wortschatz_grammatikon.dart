// FILE: lib/features/wortschatz/widgets/wortschatz_grammatikon.dart
// PHASE: B-9 / Grammatikon in der Wortschatz-Liste (2026-09-15)
// PURPOSE: Übersetzt einen Eintrag der ALTEN Wortschatz-Tabelle (WordModel) in
//          die Kartenform, die GrammatikonResolver erwartet — damit Liste und
//          Wortseite dieselbe Formen-/Farbsprache sprechen.
//
// ⚠️ KERNREGEL: LIEBER KEIN SYMBOL ALS EIN FALSCHES.
//    Die alte Tabelle `Words` kennt nur german/article/plural/wordType/level/
//    Bedeutung/conjugationJson. Ihr fehlen genau die Felder, aus denen das
//    Grammatikon bei manchen Wortarten die Form ableitet:
//      · Verb        → `regelmaessig` / `trennbar` / `modalverb`
//                      (Kreis vs. Wellen-Blob vs. Zahnrad)
//      · Präposition → `kasus` (bestimmt die Innenform der Kapsel)
//      · Konnektor   → `untertyp` (U-Kurve vs. Welle vs. Kreis-mit-Linie)
//    Diese Felder zu erraten hieße, dem Lernenden falsche Grammatik zu zeigen.
//    Deshalb gibt es für diese Wortarten (vorerst) KEIN Symbol — bis die
//    Felder erfasst werden (PLAN.md → B-10).
import '../../../core/models/word_model.dart';

/// WordModel → Karte für GrammatikonResolver, oder null, wenn die Daten der
/// alten Tabelle für ein korrektes Symbol nicht ausreichen.
Map<String, dynamic>? grammatikonKarteAus(WordModel w) {
  switch (w.wordType) {
    case WordType.nomen:
      // Ohne Artikel kein Genus und damit keine Farbe → kein Symbol.
      final genus = w.article?.toLowerCase();
      if (genus != 'der' && genus != 'die' && genus != 'das') return null;
      return {
        'wortart': 'nomen',
        'details': {'genus': genus},
      };

    case WordType.adjektiv:
      // Grundform (prädikativ): Umriss, unabhängig von weiteren Feldern.
      return {'wortart': 'adjektiv', 'details': const {}};

    case WordType.pronomen:
      return {'wortart': 'pronomen', 'details': const {}};

    case WordType.zahl:
      return {'wortart': 'numerale', 'details': const {}};

    case WordType.modalpartikel:
      return {'wortart': 'partikel', 'details': const {}};

    // Fehlende Grammatikfelder — siehe Kernregel oben.
    case WordType.verb:
    case WordType.praepositon:
    case WordType.konnektor:
    case WordType.sonstige:
      return null;
  }
}
