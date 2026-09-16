// FILE: tool/vokab_ids_pruefen.dart
// PHASE: فاز LAUNCH, Schritt L.1a (2026-09-16)
// PURPOSE: Wächter — keine veröffentlichte Wort-id darf verschwinden.
//
//   dart run tool/vokab_ids_pruefen.dart <veroeffentlichter_index.json>
//
// Vergleicht den Index der LIVE-Seite (vom Workflow vorher heruntergeladen)
// mit dem gerade gebauten assets/vocab_index.json. Fehlt eine id, die Nutzer
// schon haben konnten, endet der Lauf mit Exit-Code 1 — der Bau bleibt rot,
// nichts wird veröffentlicht.
//
// WARUM gegen die Live-Seite und nicht gegen den vorigen Commit: Ein roter
// Lauf veröffentlicht nichts. Verglichen mit „dem vorigen Commit" würde der
// NÄCHSTE Push die Löschung schon als Ausgangslage sehen und durchlassen.
// Die Live-Seite ist genau das, was Nutzer wirklich haben.
//
// ⚠️ Ausnahmen gibt es bewusst nicht. Muss eine Karte je wirklich weg, braucht
// es vorher eine Umzugsregel für den Leitner-Stand der Nutzer — das ist eine
// Entscheidung mit Lukas, kein Handgriff (PLAN.md → L.1a).
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_index.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln(
        'Aufruf: dart run tool/vokab_ids_pruefen.dart <veroeffentlicht.json>');
    exit(2);
  }
  final alt = File(args.single);
  final neu = File(vokabIndexPfad);
  if (!neu.existsSync()) {
    stderr.writeln('$vokabIndexPfad fehlt — vorher `dart run tool/vokab_index.dart`.');
    exit(1);
  }
  if (!alt.existsSync()) {
    stderr.writeln('${args.single} fehlt — der veröffentlichte Index wurde nicht geladen.');
    exit(1);
  }

  final Set<String> veroeffentlicht;
  final Set<String> jetzt;
  try {
    veroeffentlicht = vokabIndexIds(alt.readAsStringSync());
    jetzt = vokabIndexIds(neu.readAsStringSync());
  } on FormatException catch (e) {
    stderr.writeln('Index nicht lesbar: ${e.message}');
    exit(1);
  }

  final verloren = vokabVerloreneIds(veroeffentlicht, jetzt);
  if (verloren.isNotEmpty) {
    stderr.writeln('⛔ ${verloren.length} veröffentlichte Wort-id(s) fehlen '
        '(gelöscht oder umbenannt):');
    for (final id in verloren) {
      stderr.writeln('  · $id');
    }
    stderr.writeln('Nutzer können diese Wörter im Leitner, in Listen oder '
        'Notizen haben. Karte(n) wiederherstellen — siehe PLAN.md → L.1a.');
    exit(1);
  }
  stdout.writeln('Wort-ids: ${veroeffentlicht.length} veröffentlicht, '
      'alle noch da; ${jetzt.length - veroeffentlicht.length} neu.');
}
