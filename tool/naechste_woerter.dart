// FILE: tool/naechste_woerter.dart
// PURPOSE: Routine «ده کلمه جدید» (Lukas, 2026-09-23) — nennt die nächsten N
//          Wörter der Wortliste, für die es noch KEINE Karte gibt.
//
//   dart run tool/naechste_woerter.dart            # 10 aus der aktuellen Liste
//   dart run tool/naechste_woerter.dart 5          # 5
//   dart run tool/naechste_woerter.dart --abhaken  # ✓ vor jedes Wort mit Karte
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
//   · Feste Regel (Lukas 2026-09-24): Jedes nicht gebaute Wort steht AUCH in
//     PLAN.md → «🏁 مرحله‌ی آخر» (ganz unten, mit Datum/Liste/Grund). Geprüft
//     und gebaut werden sie erst ganz am Ende, wenn alle vier Listen durch
//     sind — nach Lukas' Entscheidung. [zurueckgestellt] und diese Tabelle
//     sind immer identisch.
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_schema.dart';

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

/// Wörter, die Claude nicht sicher beschreiben konnte (Regel 14 des
/// Wort-Prompts: nie raten) — warten auf Lukas. Mit Datum/Grund in PLAN.md.
const zurueckgestellt = <String>{
  'abatisch',
  'abdikativ',
  'afrikaans',
  'aldente', // Schreibung zweifelhaft (Duden: «al dente») 2026-09-24
  'aleppinisch', // Gebrauch als Adjektiv unsicher 2026-09-24
  'allenfallsig', // keine gesicherte Form (nur Adverb «allenfalls») 2026-09-24
  'altaltbacken', // Schreibung zweifelhaft (wohl «altbacken») 2026-09-24
  'Altdorfer', // Eigenname/Herkunftsbezeichnung, kein gewöhnliches Adjektiv 2026-09-24
  'altkrank', // Bedeutung/Gebrauch unsicher 2026-09-24
  'amaranten', // Bedeutung/Gebrauch unsicher (veraltet?) 2026-09-25
  'ambient', // als deutsches Adjektiv nicht gesichert (v. a. Nomen «Ambient») 2026-09-25
  'amethysten', // Bedeutung unsicher («aus Amethyst» oder «amethystfarben»?) 2026-09-25
  'amphibolisch', // Bedeutung unsicher (Logik «mehrdeutig» oder Mineral «Amphibol»?) 2026-09-25
  'anamorph', // Bedeutung fachabhängig unsicher (Optik/Biologie/Mykologie) 2026-09-25
  'anelliert', // keine gesicherte Bedeutung/Form gefunden 2026-09-25
  'anotherm', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'antichretisch', // Fachwort (Antichrese?), Bedeutung unsicher 2026-09-25
  'appendikuliert', // Bedeutung/Fachgebiet unsicher (Biologie?) 2026-09-25
  'aretologisch', // Bedeutung unsicher (Tugendlehre oder Wundererzählung?) 2026-09-25
  'arschig', // derb; Bedeutung/Gebrauch als Adjektiv nicht gesichert 2026-09-25
  'arschlos', // keine gesicherte Bedeutung/Form bekannt 2026-09-25
  'assi', // umgangssprachliche Kurzform; als Adjektiv nicht gesichert (Duden: «assig», «der Assi») 2026-09-25
  'athermisch', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'ausheimisch', // Bedeutung/Gebrauch unsicher (landschaftlich/veraltet?) 2026-09-25
  'austral', // Bedeutung/Gebrauch unsicher (Fachwort «südlich»?) 2026-09-25
  'averbal', // Bedeutung/Gebrauch unsicher (Fachwort?) 2026-09-25
  'azentrisch', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'azephal', // Bedeutung fachabhängig unsicher (Medizin «ohne Kopf» / Verslehre «ohne Auftakt»?) 2026-09-25
  'bananig', // Bedeutung/Gebrauch unsicher (umgangssprachlich?) 2026-09-25
  'bannig', // regional (norddeutsch «sehr»), eher Adverb — unsicher 2026-09-25
  'basalten', // Bedeutung unsicher («aus Basalt»?), nicht gesichert 2026-09-25
  'basiklin', // Fachwort (Botanik?), Bedeutung unsicher 2026-09-25
  'basten', // Bedeutung/Gebrauch unsicher («aus Bast»?) 2026-09-25
  'batisten', // Bedeutung/Gebrauch unsicher («aus Batist»?) 2026-09-25
  'bebuscht', // Bedeutung/Gebrauch unsicher 2026-09-25
  'bebust', // Bedeutung/Gebrauch unsicher (umgangssprachlich/derb?) 2026-09-25
  'bedonnert', // Bedeutung/Gebrauch unsicher (umgangssprachlich?) 2026-09-25
  'befotzt', // keine gesicherte Form/Bedeutung (derb, wohl Fehler) 2026-09-25
  'begeißelt', // Bedeutung/Fachgebiet unsicher (Biologie «mit Geißeln»?) 2026-09-25
  'begrannt', // Fachwort (Botanik «mit Grannen»?), unsicher 2026-09-25
  'behemdet', // Bedeutung/Gebrauch unsicher («mit Hemd»?) 2026-09-25
  'behost', // Bedeutung/Gebrauch unsicher («mit Hose»?) 2026-09-25
  'behuft', // Bedeutung/Gebrauch unsicher («mit Hufen»?) 2026-09-25
  'beinfarben', // Bedeutung unsicher («knochenfarben»?) 2026-09-25
  'bekrallt', // Bedeutung/Gebrauch unsicher («mit Krallen»?) 2026-09-25
  'bemähnt', // Bedeutung/Gebrauch unsicher («mit Mähne»?) 2026-09-25
  'bemützt', // Bedeutung/Gebrauch unsicher («mit Mütze»?) 2026-09-25
  'bepelzt', // Bedeutung/Gebrauch unsicher («mit Pelz»?) 2026-09-25
  'beredet', // Bedeutung/Form unsicher (wohl Nebenform/Verwechslung mit «beredt») 2026-09-25
  'berindet', // Bedeutung/Gebrauch unsicher («mit Rinde»?) 2026-09-25
  'bernsteinen', // Bedeutung unsicher («aus Bernstein»?) 2026-09-25
  'berstig', // keine gesicherte Form/Bedeutung 2026-09-25
  'berüscht', // Bedeutung/Gebrauch unsicher («mit Rüschen»?) 2026-09-25
  'beschilft', // Bedeutung/Gebrauch unsicher («mit Schilf»?) 2026-09-25
  'beschürzt', // Bedeutung/Gebrauch unsicher («mit Schürze»?) 2026-09-25
  'besoffenbesondere', // Listenfehler (zwei Wörter zusammengeschrieben) 2026-09-25
  'besonderes', // flektierte Form, keine Grundform (Lemma: «besonderer/besondere») 2026-09-25
  'besonderer', // flektierte Form, keine Grundform 2026-09-25
  'bestiefelt', // Bedeutung/Gebrauch unsicher («mit Stiefeln»?) 2026-09-25
  'bestrumpft', // Bedeutung/Gebrauch unsicher («mit Strümpfen»?) 2026-09-25
  'bestusst', // umgangssprachlich; Bedeutung/Gebrauch unsicher 2026-09-25
  'betresst', // Bedeutung/Gebrauch unsicher («mit Tressen»?) 2026-09-25
  'betrieben', // nur Partizip; als eigenständiges Adjektiv nicht gesichert (v. a. in Komposita wie «batteriebetrieben») 2026-09-25
  'bezastert', // keine gesicherte Form/Bedeutung 2026-09-25
  'bezopft', // Bedeutung/Gebrauch unsicher («mit Zopf»?) 2026-09-25
  'bibliophob', // Bedeutung/Gebrauch nicht gesichert 2026-09-25
  'biereifrig', // Bedeutung/Gebrauch unsicher (scherzhaft?) 2026-09-25
  'bimaxillär', // Fachwort (Medizin/Zahnmedizin), Bedeutung unsicher 2026-09-25
  'birken', // Bedeutung/Gebrauch unsicher («aus Birkenholz»?) 2026-09-25
  'bitchig', // umgangssprachlicher Anglizismus, Gebrauch nicht gesichert 2026-09-25
  'blakig', // Bedeutung/Gebrauch unsicher (rußend?) 2026-09-25
  'bland', // Fachwort (Medizin «mild, reizlos»?), unsicher 2026-09-25
  'blaustrümpfig', // Bedeutung/Gebrauch unsicher (abwertend für gebildete Frauen?) 2026-09-25
  'bonfortionös', // Schreibweise unsicher (Duden: «bomforzionös»?) 2026-09-26
  'botrytisiert', // Fachwort (Weinbau), Duden-Eintrag unsicher 2026-09-26
  'boustrophedon', // eher Adverb/Nomen (Bustrophedon), Wortart unsicher 2026-09-26
  'brennheiß', // Duden-Eintrag unsicher (eher «brennend heiß») 2026-09-26
  'brillanten', // Bedeutung/Gebrauch unsicher (aus Brillanten?) 2026-09-26
  'brokaten', // Bedeutung/Gebrauch unsicher (aus Brokat?) 2026-09-26
  'buchen', // Bedeutung/Gebrauch unsicher («aus Buchenholz»?) — wie birken 2026-09-26
  'bundrein', // Fachwort (Gitarrenbau?), Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'buntfarben', // Duden-Eintrag unsicher (gesichert: buntfarbig) 2026-09-26
  'busig', // Bedeutung/Gebrauch unsicher (umgangssprachlich «vollbusig»?) — wie bebust 2026-09-26
  'bustrophedon', // eher Nomen/Adverb (das Bustrophedon), Wortart unsicher — wie boustrophedon 2026-09-26
  'chemometrisch', // Fachwort (Chemometrie), Duden-Eintrag unsicher 2026-09-26
  'chilotisch', // Bedeutung unsicher (Chiloé? Chilote?) 2026-09-26
  'chionophil', // Fachwort (Biologie «schneeliebend»?), unsicher 2026-09-26
  'chochem', // im Duden nur als Nomen «der Chochem»; Adjektivgebrauch unsicher 2026-09-26
  'chondritisch', // zwei mögliche Bedeutungen (Chondrit-Meteorit / Chondritis), unsicher 2026-09-26
  'claviform', // Fachwort (Botanik «keulenförmig»?), Duden-Eintrag unsicher 2026-09-26
  'damasten', // Bedeutung/Gebrauch unsicher («aus Damast»?) — wie batisten 2026-09-26
  'dasig', // landschaftlich; Bedeutung unsicher («verwirrt»? «hiesig»?) 2026-09-26
  'debitorisch', // Fachwort (Buchhaltung «die Debitoren betreffend»?), Duden-Eintrag unsicher 2026-09-26
  'dekremental', // Fachwort, Bedeutung/Duden-Eintrag unsicher («abnehmend»?) 2026-09-26
  'delatorisch', // Bedeutung/Duden-Eintrag unsicher («denunzierend»? veraltet) 2026-09-26
  'demanten', // Bedeutung/Gebrauch unsicher (dichterisch «diamanten»?) — wie brillanten 2026-09-26
  'deprekativ', // Fachwort (Sprachwissenschaft/Religion «bittend»?), Duden-Eintrag unsicher 2026-09-26
  'depretiativ', // Bedeutung/Schreibweise unsicher (vielleicht «depreziativ» = abwertend?) 2026-09-26
  'desiderat', // im Duden als Nomen «das Desiderat»; Adjektivgebrauch unsicher 2026-09-26
  'designatus', // lateinisch, nur nachgestellt (Rektor designatus); kein gewöhnliches Adjektiv 2026-09-26
  'desmal', // keine gesicherte Form/Bedeutung (Druckfehler für «dezimal»? «diesmal»?) 2026-09-26
  'dextral', // Fachwort (Biologie/Medizin «rechtsseitig/rechtsgewunden»?), Duden-Eintrag unsicher 2026-09-26
  'dezisionistisch', // Fachwort (Philosophie/Staatsrecht), Duden-Eintrag und genaue Bedeutung unsicher 2026-09-26
  'diamanten', // Bedeutung/Gebrauch unsicher («aus Diamant»? gehoben) — wie brillanten 2026-09-26
  'diffusibel', // Fachwort (Physik/Chemie «diffusionsfähig»?), Duden-Eintrag unsicher 2026-09-26
  'dikasterial', // Fachwort (Kirchenrecht/Verwaltung, von «Dikasterium»?), Bedeutung unsicher 2026-09-26
  'dilemmatisch', // Duden-Eintrag und Gebrauch unsicher 2026-09-26
  'diptotisch', // Fachwort (Grammatik: «mit nur zwei Kasusformen»?), Duden-Eintrag unsicher 2026-09-26
  'dissidentisch', // Duden-Eintrag unsicher (gesichert: «dissident») 2026-09-26
  'dissipativ', // Fachwort (Physik: «Energie zerstreuend»), Duden-Eintrag unsicher 2026-09-26
  'distich', // Fachwort (Botanik «zweizeilig»?) oder Verwechslung mit «Distichon»; unsicher 2026-09-26
  'dolent', // Fachwort (Medizin «schmerzhaft»?), Duden-Eintrag unsicher 2026-09-26
  'doloros', // Schreibvariante unsicher (gesichert: «dolorös») 2026-09-26
  'dominicanisch', // Schreibweise unsicher (gesichert: «dominikanisch») 2026-09-26
  'doppelherzig', // veraltet, Duden-Eintrag und Bedeutung unsicher («heuchlerisch»?) 2026-09-26
  'drahten', // Bedeutung/Gebrauch unsicher («aus Draht»?) — wie birken 2026-09-26
  'drittelzahlig', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
};

/// Wörter, deren Wortart in der Liste nicht stimmt (Duden-Wortart gilt,
/// Regel 14 des Wort-Prompts). Die Karte liegt dann unter der richtigen
/// Wortart; so erkennt das Tool sie trotzdem als fertig. Mit Datum in PLAN.md.
const wortartKorrektur = <String, String>{
  'aberhundert': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'abertausend': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'achte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzehnte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzigste': 'numerale', // Ordinalzahl (2026-09-24)
  'andante': 'adverb', // Tempobezeichnung, Duden: Adverb (2026-09-25)
  'anderweit': 'adverb', // Duden: Adverb; Adjektiv ist «anderweitig» (2026-09-25)
  'baldmöglichst': 'adverb', // Duden: Adverb (Amtssprache) (2026-09-25)
  'billiardste': 'numerale', // Ordinalzahl (2026-09-26)
  'billionste': 'numerale', // Ordinalzahl (2026-09-26)
  'demgemäß': 'adverb', // Duden: Adverb (2026-09-26)
  'dreihundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreißigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreiundzwanzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreizehnte': 'numerale', // Ordinalzahl (2026-09-26)
  'dritte': 'numerale', // Ordinalzahl (2026-09-26)
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
      final w = roh.trim();
      if (w.isEmpty) continue;
      final art = wortartKorrektur[w] ?? wortart;
      if (File('assets/vocab/$art/${vokabId(art, w)}.json').existsSync()) {
        zeilen[i] = '✓ $w';
        neu++;
      }
    }
    if (neu > 0) datei.writeAsStringSync(zeilen.join('\n'));
    stdout.writeln('$liste: $neu neu abgehakt');
  }
}

void main(List<String> args) {
  if (args.contains('--abhaken')) {
    abhaken();
    return;
  }
  final anzahl = args.isNotEmpty ? int.parse(args.first) : 10;
  final treffer = <(String, String)>[]; // (Wort, Wortart)

  for (final (liste, wortart) in listen) {
    final datei = File(liste);
    if (!datei.existsSync()) {
      stderr.writeln('Liste fehlt: $liste — im Projektordner starten.');
      exit(1);
    }
    var fertig = 0;
    var offen = 0;
    for (final roh in datei.readAsLinesSync()) {
      final w = roh.replaceFirst(RegExp(r'^\s*✓\s*'), '').trim();
      if (w.isEmpty) continue;
      final art = wortartKorrektur[w] ?? wortart;
      if (File('assets/vocab/$art/${vokabId(art, w)}.json').existsSync()) {
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
