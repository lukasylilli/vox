// FILE: lib/features/wortschatz/widgets/wortschatz_grammatikon.dart
// PHASE: B-9 / Grammatikon in der Wortschatz-Liste (2026-09-15)
//        B-10 (2026-09-16): Verb/Präposition/Konnektor bekommen jetzt auch
//        ein Symbol, wenn die nötigen Felder vorhanden sind.
// PURPOSE: Übersetzt einen Eintrag der ALTEN Wortschatz-Tabelle (WordModel) in
//          die Kartenform, die GrammatikonResolver erwartet — damit Liste und
//          Wortseite dieselbe Formen-/Farbsprache sprechen.
//
// ⚠️ KERNREGEL: LIEBER KEIN SYMBOL ALS EIN FALSCHES.
//    Die Felder aus B-10 (`regelmaessig`, `trennbar`, `grammatikDetail`) sind
//    nullable — ältere Zeilen und die anderen Eingabeformate haben sie oft
//    nicht (siehe die Parser-Kommentare in core/parsers/). Wo ein Feld fehlt,
//    gibt es weiterhin KEIN Symbol statt eines geratenen.
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

    case WordType.verb:
      // regelmaessig ist das Feld, das GrammatikonResolver zwingend braucht
      // (kreis vs. blob_wellig) — ohne es bliebe nur raten. trennbar darf
      // fehlen: der Resolver behandelt null wie false (nicht trennbar), was
      // für ein unbekanntes Feld die vorsichtigere Annahme ist.
      if (w.regelmaessig == null) return null;
      return {
        'wortart': 'verb',
        'details': {
          'regelmaessig': w.regelmaessig,
          'trennbar': w.trennbar ?? false,
        },
      };

    case WordType.praepositon:
      // grammatikDetail trägt hier den Kasus (siehe word_parser.dart).
      if (w.grammatikDetail == null) return null;
      return {
        'wortart': 'praeposition',
        'details': {'kasus': w.grammatikDetail},
      };

    case WordType.konnektor:
      // grammatikDetail trägt hier den Untertyp (siehe connector_parser.dart).
      // Anders als bei Präposition ist der Wert hier nicht zwingend: der
      // Resolver hat für Konjunktion einen Standardfall (kurve_u), der auch
      // ohne Untertyp nicht falsch ist — nur weniger genau.
      return {
        'wortart': 'konjunktion',
        'details': {
          if (w.grammatikDetail != null) 'untertyp': w.grammatikDetail,
        },
      };

    case WordType.sonstige:
      return null;
  }
}
