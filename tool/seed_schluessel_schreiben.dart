// FILE: tool/seed_schluessel_schreiben.dart
// PHASE: فاز LAUNCH, Schritt L.1e (2026-09-18)
// PURPOSE: Schreibt die Liste der geschützten App-Wort-Schlüssel neu.
//
//   dart run tool/seed_schluessel_schreiben.dart
//
// WANN AUSFÜHREN: nachdem NEUE Wörter in eine der vier Datendateien
// gekommen sind — damit auch sie ab sofort geschützt sind.
//
// ⚠️ NICHT ausführen, um einen roten Wächter „wegzumachen".
//   Ist der Test rot, fehlt ein Schlüssel, den Nutzer schon haben können.
//   Dann gehört der deutsche Text bzw. die Wortart zurückgesetzt — oder es
//   braucht vorher eine Umzugsregel alt→neu für den Leitner-Stand. Das ist
//   eine Entscheidung mit Lukas, kein Handgriff (PLAN.md → L.1e).
//
//   Dieses Werkzeug schreibt die Datei deshalb NUR, wenn kein bisher
//   geschützter Schlüssel verloren geht. Sonst bricht es ab.
import 'dart:io';

import 'package:vox/core/services/seed_wortschluessel.dart';

const _pfad = 'test/daten/seed_schluessel_veroeffentlicht.txt';

void main() {
  for (final q in seedQuellen) {
    if (!File(q).existsSync()) {
      stderr.writeln('⛔ Quelldatei fehlt: $q — im Projektstamm ausführen.');
      exit(1);
    }
  }

  final jetzt = seedWortschluessel((p) => File(p).readAsStringSync());

  final datei = File(_pfad);
  if (!datei.existsSync()) {
    stderr.writeln('⛔ $_pfad fehlt.');
    exit(1);
  }

  final alteZeilen = datei.readAsLinesSync();
  final kopf = alteZeilen.where((l) => l.startsWith('#')).toList();
  final bisher = alteZeilen
      .where((l) => !l.startsWith('#') && l.trim().isNotEmpty)
      .toSet();

  final verloren = seedVerloreneSchluessel(bisher, jetzt);
  if (verloren.isNotEmpty) {
    stderr.writeln('⛔ ${verloren.length} geschützte(r) Schlüssel würde(n) '
        'verschwinden — die Datei wird NICHT geschrieben:');
    for (final s in verloren.take(20)) {
      stderr.writeln('  · $s');
    }
    if (verloren.length > 20) {
      stderr.writeln('  … und ${verloren.length - 20} weitere');
    }
    stderr.writeln('Nutzer können diese Wörter im Leitner haben. '
        'Text/Wortart zurücksetzen — siehe PLAN.md → L.1e.');
    exit(1);
  }

  final neu = jetzt.toList()..sort();
  datei.writeAsStringSync('${kopf.join('\n')}\n${neu.join('\n')}\n');
  stdout.writeln('$_pfad geschrieben: ${neu.length} Schlüssel '
      '(${neu.length - bisher.length} neu).');
}
