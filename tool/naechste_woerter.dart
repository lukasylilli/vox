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
//   · Die aktuelle Liste und ihre Wortart stehen in [liste]/[wortart]; ist sie
//     durch, meldet das Werkzeug das — welche Liste dann folgt, entscheidet
//     Lukas (in PLAN.md eintragen, dann hier).
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_schema.dart';

/// Aktuelle Wortliste (Reihenfolge der Abarbeitung: PLAN.md).
const liste = 'old files Lukasalmani/Wörter/Adjektive.txt';
const wortart = 'adjektiv';

/// Wörter, die Claude nicht sicher beschreiben konnte (Regel 14 des
/// Wort-Prompts: nie raten) — warten auf Lukas. Mit Datum/Grund in PLAN.md.
const zurueckgestellt = <String>{'abatisch'};

void main(List<String> args) {
  final anzahl = args.isNotEmpty ? int.parse(args.first) : 10;
  final datei = File(liste);
  if (!datei.existsSync()) {
    stderr.writeln('Liste fehlt: $liste — im Projektordner starten.');
    exit(1);
  }
  final woerter = datei
      .readAsLinesSync()
      .map((z) => z.replaceFirst(RegExp(r'^\s*✓\s*'), '').trim())
      .where((z) => z.isNotEmpty);

  final treffer = <String>[];
  var fertig = 0;
  for (final w in woerter) {
    final id = vokabId(wortart, w);
    if (File('assets/vocab/$wortart/$id.json').existsSync()) {
      fertig++;
      continue;
    }
    if (zurueckgestellt.contains(w)) continue;
    treffer.add(w);
    if (treffer.length == anzahl) break;
  }

  stdout.writeln('Liste: $liste ($wortart) · schon als Karte: $fertig');
  if (treffer.isEmpty) {
    stdout.writeln('Liste ist durch — nächste Liste in PLAN.md nachsehen / Lukas fragen.');
    return;
  }
  stdout.writeln('Nächste ${treffer.length}: ${treffer.join(' · ')}');
}
