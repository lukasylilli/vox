// FILE: test/deutscher_text_waechter_test.dart
// PURPOSE: Wächter — deutscher Inhalt darf nicht mit einem nackten `Text(`
//          gezeigt werden, sondern nur mit `DeutschText` (oder, bei
//          Quiz-Optionen, `VoxOptionButton(istDeutsch: true)`).
//
// WARUM (Fehlerbericht Lukas, 2026-09-18):
//   Steht die Oberfläche auf Persisch, ist die Directionality der ganzen App
//   RTL. Ein nacktes `Text('… Österreich.')` erbt das: die Zeile klebt rechts
//   und der Schlusspunkt landet links — optisch am Satzanfang.
//
//   Der Fehler wurde zweimal gemeldet, weil beim ersten Durchgang genau EIN
//   Absatz (`b.bodyDe` in der Grammatik-Lektion) übersehen wurde. Ein Blick
//   über die Dateien reicht offensichtlich nicht — darum dieser Wächter,
//   nach dem Vorbild von `puzzling_buttons_test.dart` (B.5).
//
// WIE ER ARBEITET:
//   Er sucht in `lib/features/` nach `Text(`-Aufrufen, deren Inhalt eines der
//   bekannten deutschen Felder nennt (`.german`, `.exampleDe`, `.phraseDe` …).
//   Findet er einen, wird CI rot und nennt Datei, Zeile und Feld.
//
// WENN DER TEST ANSCHLÄGT:
//   Entweder `Text(` → `DeutschText(` tauschen (Import:
//   `core/widgets/deutsch_text.dart`), oder — falls die Stelle wirklich keine
//   deutsche Anzeige ist (z. B. ein Feldname in einer Meldung) — die Zeile in
//   `erlaubteAusnahmen` unten mit Begründung eintragen.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Felder, die immer deutschen Text enthalten.
const deutscheFelder = <String>[
  '.german',
  '.exampleDe',
  '.phraseDe',
  '.titleDe',
  '.bodyDe',
  '.headingDe',
  '.promptDe',
  '.sectionTitleDe',
  '.connector',
  '.labelDe',
  // Nachtrag 2026-09-23: Beispielsätze in den Grammatik-Seiten der Decks
  "['de']",
  "['example_de']",
  // Nachtrag 2026-09-23 (Bund 3 der Vor-Launch-Liste): alle deutschen Felder
  // der Deck-Modelle (Auswendiglernen) und der Grammatik-JSONs.
  '.baseVerb',
  '.beispielDe',
  '.erklaerungDe',
  '.anweisungDe',
  '.aufgabeDe',
  '.futur',
  '.infinitiv',
  '.konjunktiv',
  '.lemma',
  '.memberLemma',
  '.memberPreposition',
  '.noteDe',
  '.nounPhrase',
  '.partizip',
  '.perfekt',
  '.plural',
  '.plusquamperfekt',
  '.praesens',
  '.praeteritum',
  '.prefix',
  '.preposition',
  '.satz',
  '.synonymDe',
  '.verbInfinitive',
  '.clozePrefix',
  '.clozeSuffix',
  '.clozeAnswer',
  '.woCompound',
  '.displayVerb',
  '.loesung',
  '.vorgabe',
  '.structureAfter',
  "['infinitiv']",
  "['base']",
  "['wrong']",
  "['correct']",
  "['formula']",
  "['change']",
];

/// Stellen, die absichtlich ein nacktes `Text(` behalten — mit Begründung.
/// Schlüssel: `<Pfad ab lib/>:<Zeilennummer>`.
const erlaubteAusnahmen = <String, String>{
  // Hier steht das deutsche Wort in einem übersetzten Satz ("«X» gelöscht"),
  // der als Ganzes der Oberflächensprache folgen soll.
  'lib/features/categories/screens/category_detail_screen.dart':
      'AppL10n.tf-Meldung: deutsches Wort eingebettet in einen FA/EN-Satz',
  'lib/features/wortschatz/screens/add_word_screen.dart':
      'AppL10n.tf-Meldung (saved_quoted): deutsches Wort in einem FA/EN-Satz',
};

void main() {
  test('kein deutsches Feld in einem nackten Text( in lib/features/', () {
    final wurzel = Directory('lib/features');
    expect(wurzel.existsSync(), isTrue,
        reason: 'Test muss aus dem Projektstamm laufen');

    final treffer = <String>[];

    for (final eintrag in wurzel.listSync(recursive: true)) {
      if (eintrag is! File || !eintrag.path.endsWith('.dart')) continue;

      final pfad  = eintrag.path.replaceAll(r'\', '/');
      final zeile = eintrag.readAsLinesSync();

      for (var i = 0; i < zeile.length; i++) {
        final l = zeile[i];

        // Nur nackte Text(-Aufrufe; DeutschText( ist genau das Richtige.
        if (!l.contains('Text(')) continue;
        if (RegExp(r'\bDeutschText\(').hasMatch(l) &&
            !RegExp(r'(?<!Deutsch)\bText\(').hasMatch(l)) {
          continue;
        }
        if (!RegExp(r'(?<!Deutsch)(?<!Rich)(?<!Selectable)\bText\(')
            .hasMatch(l)) {
          continue;
        }

        // Auch `Text(` am Zeilenende mit dem Inhalt in der nächsten Zeile
        // (Nachtrag 2026-09-23: so rutschten `verb.exampleDe` & Co. durch).
        final inhalt = l.trimRight().endsWith('Text(') && i + 1 < zeile.length
            ? '$l ${zeile[i + 1]}'
            : l;
        final feld = deutscheFelder.where(inhalt.contains).toList();
        if (feld.isEmpty) continue;

        if (erlaubteAusnahmen.containsKey(pfad)) continue;

        treffer.add('$pfad:${i + 1}  →  ${feld.join(", ")}\n      ${l.trim()}');
      }
    }

    expect(
      treffer,
      isEmpty,
      reason: 'Deutscher Inhalt in einem nackten Text( gefunden.\n'
          'In einer persischen (RTL) Oberfläche rutscht die Zeile nach rechts\n'
          'und der Schlusspunkt nach links. Bitte DeutschText( benutzen\n'
          "(import 'core/widgets/deutsch_text.dart') — oder, wenn die Stelle\n"
          'wirklich keine deutsche Anzeige ist, oben in erlaubteAusnahmen\n'
          'mit Begründung eintragen.\n\n${treffer.join("\n")}',
    );
  });

  // Nachtrag 2026-09-23 (Fund Lukas, Auswendiglernen): hervorgehobene
  // Beispielsätze liefen über nacktes `Text.rich(` / `RichText(` und standen in
  // der persischen Oberfläche rechts, mit dem Punkt am Satzanfang. Deutscher
  // Text mit mehreren Stilen ⇒ `DeutschRichText` (core/widgets/deutsch_text.dart).
  test('kein nacktes Text.rich( / RichText( in lib/features/', () {
    // Stellen ohne (reinen) deutschen Inhalt — mit Begründung.
    const ausnahmen = <String, String>{
      'lib/features/vokabular/widgets/wort_notiz.dart':
          'freie Notiz des Nutzers — Sprache offen, folgt der Oberfläche',
      'lib/features/home/screens/search_results_screen.dart':
          'Treffer der Suche: Deutsch ODER Übersetzung gemischt',
      'lib/features/vokabular/screens/wort_seite_screen.dart':
          'Kopf der Wortseite: schon LTR; steht bewusst direkt neben dem '
              'Symbol (Kopfzeile folgt der Oberfläche)',
    };
    final treffer = <String>[];
    for (final e in Directory('lib/features').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      final pfad = e.path.replaceAll(r'\', '/');
      if (ausnahmen.containsKey(pfad)) continue;
      final zeilen = e.readAsLinesSync();
      for (var i = 0; i < zeilen.length; i++) {
        if (RegExp(r'(?<![A-Za-z])(Text\.rich|RichText)\(').hasMatch(zeilen[i])) {
          treffer.add('$pfad:${i + 1}: ${zeilen[i].trim()}');
        }
      }
    }
    expect(treffer, isEmpty,
        reason: 'Deutscher Text mit Hervorhebung ⇒ DeutschRichText; '
            'sonst Ausnahme mit Begründung eintragen:\n${treffer.join('\n')}');
  });
}
