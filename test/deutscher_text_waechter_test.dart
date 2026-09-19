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

        final feld = deutscheFelder.where(l.contains).toList();
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
}
