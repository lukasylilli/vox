// FILE: tool/naechste_woerter.dart
// PURPOSE: Routine «ده کلمه جدید» (Lukas, 2026-09-23) — nennt die nächsten N
//          Wörter der Wortliste, für die es noch KEINE Karte gibt.
//
//   dart tool/naechste_woerter.dart                # 20 aus der aktuellen Liste
//   dart tool/naechste_woerter.dart 5              # 5
//   (Rundengröße 20 statt 10: Lukas 2026-10-31 — «Zeit verkürzen»)
//   dart tool/naechste_woerter.dart --abhaken      # ✓ vor jedes Wort mit Karte
//
// Regeln (siehe PLAN.md → «📚 روال ده کلمه جدید»):
//   · Reihenfolge = Reihenfolge der Datei (alphabetisch) — NIE umsortieren.
//   · Übersprungen wird ein Wort nur, wenn
//       (a) seine Karte schon existiert (assets/vocab/<wortart>/<id>.json —
//           das ist die Wahrheit, nicht das ✓ in der Liste), oder
//       (b) es in [zurueckgestellt] steht (Claude war unsicher ⇒ Lukas fragt).
//   · Listen-Reihenfolge: [listen] (Entscheidung Lukas 2026-09-23). Ist eine
//     Liste durch, geht es automatisch mit der nächsten weiter.
//   · Unsichere Wörter: nicht bauen, in [zurueckgestellt] eintragen, Lukas
//     melden (Lukas 2026-09-23: «genau so weitermachen»).
//   · Feste Regel (Lukas 2026-09-24): Jedes nicht gebaute Wort wird mit
//     Datum/Liste/Grund festgehalten. Seit 2026-11-11 an EINER Stelle:
//     tool/daten/zurueckgestellt.json; docs/ZURUECKGESTELLT.md wird daraus
//     erzeugt (`dart tool/zurueckgestellt.dart`). Geprüft und gebaut werden
//     sie erst ganz am Ende — nach Lukas' Entscheidung
//     (docs/zukunft/WOERTER_ENDSTUFEN.md).
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_schema.dart';

import 'zurueckgestellt.dart';

/// Wortlisten in der Reihenfolge der Abarbeitung — Entscheidung Lukas
/// (2026-09-23): erst Adjektive, dann unregelmäßige Verben, dann regelmäßige
/// Verben, dann Nomen. Innerhalb jeder Liste: Reihenfolge der Datei.
const listen = <(String, String)>[
  ('old files Lukasalmani/Wörter/Adjektive.txt', 'adjektiv'),
  ('old files Lukasalmani/Wörter/Verben_unregelmaeßig_Infinitiv.txt', 'verb'),
  ('old files Lukasalmani/Wörter/Verben_regelmaesig.txt', 'verb'),
  ('old files Lukasalmani/Wörter/substantiv_singular_alle.txt', 'nomen'),
  // ⛔ Vor dem ersten Nomen Lukas fragen: Nomen ohne Artikel (Städte …);
  //    Städtenamen = nur IPA + Bedeutung + Artikel (PLAN.md, 2026-09-24).
];

/// ⛔ Sperre vor den Verben — Entscheidung Lukas (2026-09-30): Bevor die
/// erste Verbkarte aus den Wortlisten gebaut wird, muss Claude Lukas fragen,
/// wie die Formensuche für Verben aussehen soll. Pflicht (schon entschieden):
/// JEDE Form eines Verbs muss in der Suche die Karte finden — gehe, ging,
/// gegangen, ausgehen, mitgegangen, … («gehen» im Archiv, «ging» gesucht ⇒
/// nie null Treffer). Offen (entscheidet Lukas): eigene Wortseite je Form
/// oder alle Formen auf der Seite des Infinitivs. Erst wenn Lukas
/// entschieden hat, wird dies auf `true` gesetzt (PLAN.md → «📚 روال …»).
const verbenFreigegeben = true; // Lukas 2026-10-11: Variante (b) — PLAN «✅ افعال»

/// Wörter, die Claude nicht sicher beschreiben konnte (Regel 14 des
/// Wort-Prompts: nie raten) oder die auf der Vier-Fälle-Liste stehen —
/// warten auf Lukas. Einzige Quelle seit 2026-11-11:
/// `tool/daten/zurueckgestellt.json` (siehe tool/zurueckgestellt.dart).
final Set<String> zurueckgestellt = ladeZurueckgestellt();

/// Listeneinträge, die nur eine FORM einer anderen Karte sind (Lukas
/// 2026-10-19, Prompt-Regel 21: EINE Karte für «der/die Abgeordnete»; die
/// Liste führt zusätzlich die stark gebeugte Form «Abgeordneter»). Die Karte
/// heißt nach dem Ziel; die Suche findet die Form über vokab_formen.dart.
/// Mit Datum in PLAN.md.
const listenVerweis = <String, String>{
  'Abgeordneter': 'Abgeordnete', // Regel 21 (2026-10-19)
};

/// Wörter, deren Wortart in der Liste nicht stimmt (Duden-Wortart gilt,
/// Regel 14 des Wort-Prompts). Die Karte liegt dann unter der richtigen
/// Wortart; so erkennt das Tool sie trotzdem als fertig. Mit Datum in PLAN.md.
const wortartKorrektur = <String, String>{
  'aberhundert': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'abertausend': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'achte': 'numerale', // Ordinalzahl (2026-09-24)
  'sechste': 'numerale', // Ordinalzahl (2026-10-08)
  'sechzehnte': 'numerale', // Ordinalzahl (2026-10-08)
  'sechzigste': 'numerale', // Ordinalzahl (2026-10-08)
  'siebente': 'numerale', // Ordinalzahl (2026-10-08)
  'siebte': 'numerale', // Ordinalzahl (2026-10-08)
  'siebzehnte': 'numerale', // Ordinalzahl (2026-10-08)
  'siebzigste': 'numerale', // Ordinalzahl (2026-10-08)
  'tausendste': 'numerale', // Ordinalzahl (2026-10-09)
  'achtzehnte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzigste': 'numerale', // Ordinalzahl (2026-09-24)
  'andante': 'adverb', // Tempobezeichnung, Duden: Adverb (2026-09-25)
  'anderweit':
      'adverb', // Duden: Adverb; Adjektiv ist «anderweitig» (2026-09-25)
  'baldmöglichst': 'adverb', // Duden: Adverb (Amtssprache) (2026-09-25)
  'billiardste': 'numerale', // Ordinalzahl (2026-09-26)
  'billionste': 'numerale', // Ordinalzahl (2026-09-26)
  'demgemäß': 'adverb', // Duden: Adverb (2026-09-26)
  'dreihundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreißigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreiundzwanzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreizehnte': 'numerale', // Ordinalzahl (2026-09-26)
  'dritte': 'numerale', // Ordinalzahl (2026-09-26)
  'einhunderterste': 'numerale', // Ordinalzahl (2026-09-26)
  'einhundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'einunddreißigste': 'numerale', // Ordinalzahl (2026-09-26)
  'einundzwanzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'elfte': 'numerale', // Ordinalzahl (2026-09-26)
  'erste': 'numerale', // Ordinalzahl (2026-09-26)
  'forte': 'adverb', // Duden: Adverb (Musik) (2026-09-26)
  'fünfhundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'fünfte': 'numerale', // Ordinalzahl (2026-09-26)
  'fünftel': 'numerale', // Bruchzahl (2026-09-26)
  'fünfzehnte': 'numerale', // Ordinalzahl (2026-09-26)
  'fünfzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'fürbass': 'adverb', // Duden: Adverb (veraltet) (2026-09-26)
  'gell': 'partikel', // Duden: Partikel (landsch.) (2026-09-26)
  'gratis': 'adverb', // Duden: Adverb (2026-09-26)
  'hunderterste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertstel': 'numerale', // Duden: Numerale (2026-09-27)
  'hunderttausendste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertundzweite': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertzweite': 'numerale', // Duden: Numerale (2026-09-27)
  'milliardste': 'numerale', // Duden: Numerale (2026-09-27)
  'milliardstel': 'numerale', // Duden: Numerale (2026-09-27)
  'millionste': 'numerale', // Duden: Numerale (2026-09-27)
  'millionstel': 'numerale', // Duden: Numerale (2026-09-27)
  'neunte': 'numerale', // Duden: Numerale (2026-09-27)
  'neunzehnte': 'numerale', // Duden: Numerale (2026-09-27)
  'neunzigste': 'numerale', // Duden: Numerale (2026-09-27)
  'nullte': 'numerale', // Duden: Numerale (2026-09-27)
  'quadrillionste': 'numerale', // Duden: Numerale (2026-09-29)
  'viel': 'numerale', // Duden: unbestimmtes Zahlwort/Indefinitpronomen (2026-10-10)
  'vierte': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'viertel': 'numerale', // Duden: Bruchzahl (2026-10-10)
  'vierzehnte': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'vierzigste': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'vorbehältlich': 'praeposition', // Duden: Präposition mit Genitiv (österr./schweiz.) (2026-10-10)
  'vorbehaltlich': 'praeposition', // Duden: Präposition mit Genitiv (2026-10-10)
  'wahrlich': 'adverb', // Duden: Adverb (2026-10-10)
  'wenig': 'numerale', // Duden: unbestimmtes Zahlwort/Indefinitpronomen (2026-10-10)
  'zehntausendste': 'numerale', // Ordinalzahl (2026-10-11)
  'zehnte': 'numerale', // Ordinalzahl (2026-10-11)
  'zehntel': 'numerale', // Bruchzahl (2026-10-11)
  'zwanzigste': 'numerale', // Ordinalzahl (2026-10-11)
  'zweihundertste': 'numerale', // Ordinalzahl (2026-10-11)
  'zweite': 'numerale', // Ordinalzahl (2026-10-11)
  'zweiundzwanzigste': 'numerale', // Ordinalzahl (2026-10-11)
  'zwölfte': 'numerale', // Ordinalzahl (2026-10-11)
};

/// `--abhaken` (Schritt 6 der Routine): setzt in ALLEN Listen «✓ » vor jedes
/// Wort, das eine Karte hat (Referenz: assets/vocab/, wie oben). Vorhandene
/// Zeilen ohne Karte bleiben unverändert; eine Datei wird nur geschrieben,
/// wenn sich etwas ändert.
void abhaken() {
  for (final (liste, wortart) in listen) {
    final datei = File(liste);
    if (!datei.existsSync()) continue;
    final alt = datei.readAsStringSync();
    final zeilen = alt.split('\n');
    var neu = 0;
    for (var i = 0; i < zeilen.length; i++) {
      final roh = zeilen[i];
      if (roh.trimLeft().startsWith('✓')) continue;
      final eintrag = roh.trim();
      if (eintrag.isEmpty) continue;
      final w = listenLemma(eintrag);
      final art = wortartKorrektur[w] ?? wortart;
      final ziel = listenVerweis[w] ?? w;
      if (File('assets/vocab/$art/${vokabId(art, ziel)}.json').existsSync()) {
        zeilen[i] = '✓ $eintrag';
        neu++;
      }
    }
    if (neu > 0) datei.writeAsStringSync(zeilen.join('\n'));
    stdout.writeln('$liste: $neu neu abgehakt');
  }
}

/// Lemma eines Listeneintrags: alles vor dem ersten Komma bzw. vor der ersten
/// Klammer. Einträge der Verbliste tragen Zusätze («anbacken, kleben» =
/// Bedeutung, «sein, war, gewesen» = Stammformen, 2026-10-11; «miauen
/// (Partizip II: miaut)» = Hinweis, 2026-10-16) — die Karte heißt nach dem Lemma.
String listenLemma(String eintrag) =>
    eintrag.split(',').first.split('(').first.trim();

void main(List<String> args) {
  if (args.contains('--abhaken')) {
    abhaken();
    return;
  }
  final anzahl = args.isNotEmpty ? int.parse(args.first) : 20;
  final treffer = <(String, String)>[]; // (Wort, Wortart)

  for (final (liste, wortart) in listen) {
    if (wortart == 'verb' && !verbenFreigegeben) {
      stdout.writeln(
        '⛔ Verben gesperrt: vor der ersten Verbkarte Lukas fragen '
        '(Formensuche gehe/ging/gegangen/ausgehen …, eine Seite oder je '
        'Form eine Seite) — danach `verbenFreigegeben = true`.',
      );
      break;
    }
    final datei = File(liste);
    if (!datei.existsSync()) {
      stderr.writeln('Liste fehlt: $liste — im Projektordner starten.');
      exit(1);
    }
    var fertig = 0;
    var offen = 0;
    for (final roh in datei.readAsLinesSync()) {
      final w = listenLemma(roh.replaceFirst(RegExp(r'^\s*✓\s*'), '').trim());
      if (w.isEmpty) continue;
      final art = wortartKorrektur[w] ?? wortart;
      final ziel = listenVerweis[w] ?? w;
      if (File('assets/vocab/$art/${vokabId(art, ziel)}.json').existsSync()) {
        fertig++;
        continue;
      }
      if (zurueckgestellt.contains(w)) continue;
      offen++;
      if (treffer.length < anzahl) treffer.add((w, art));
    }
    stdout.writeln('$liste ($wortart): $fertig als Karte · $offen offen');
    if (treffer.length >= anzahl) break;
  }

  if (treffer.isEmpty) {
    stdout.writeln('Alle Listen sind durch.');
    return;
  }
  stdout.writeln(
    'Nächste ${treffer.length}: '
    '${treffer.map((t) => '${t.$1} (${t.$2})').join(' · ')}',
  );
}
