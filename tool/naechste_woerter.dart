// FILE: tool/naechste_woerter.dart
// PURPOSE: Routine «ده کلمه جدید» (Lukas, 2026-09-23) — nennt die nächsten N
//          Wörter der Wortliste, für die es noch KEINE Karte gibt.
//
//   dart run tool/naechste_woerter.dart            # 10 aus der aktuellen Liste
//   dart run tool/naechste_woerter.dart 5          # 5
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
const zurueckgestellt = <String>{'abatisch', 'abdikativ'};

/// Wörter, deren Wortart in der Liste nicht stimmt (Duden-Wortart gilt,
/// Regel 14 des Wort-Prompts). Die Karte liegt dann unter der richtigen
/// Wortart; so erkennt das Tool sie trotzdem als fertig. Mit Datum in PLAN.md.
const wortartKorrektur = <String, String>{
  'aberhundert': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'abertausend': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'achte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzehnte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzigste': 'numerale', // Ordinalzahl (2026-09-24)
};

void main(List<String> args) {
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
  stdout.writeln('Nächste ${treffer.length}: '
      '${treffer.map((t) => '${t.$1} (${t.$2})').join(' · ')}');
}
