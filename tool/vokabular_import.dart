// FILE: tool/vokabular_import.dart
// PURPOSE: Import-Pipeline فاز V Stufe ۵ — Konverter-Output (SUPER-PROMPT v3.0)
//          → 1 Datei pro Wort in assets/vocab/<wortart>/<id>.json.
//
//   dart run tool/vokabular_import.dart                  # alle import_inbox/*.json
//   dart run tool/vokabular_import.dart batch.json …     # bestimmte Dateien
//   Optionen: --out <dir>   Zielordner (Standard assets/vocab)
//             --update      vorhandene Wort-Dateien überschreiben
//             --dry-run     nur prüfen + Bericht, nichts schreiben
//
// Sicherheits-Regeln (für ۲۵٬۰۰۰ Wörter):
//   · Validierung/Normalisierung: lib/features/vokabular/data/vokab_schema.dart
//     (EINE Quelle mit der App — fatale Fehler schreiben NIE eine Datei)
//   · Duplikat-Schutz: existierende id → übersprungen (ohne --update)
//   · idempotent: denselben Batch zweimal importieren ist harmlos
//   · Fehlerbericht pro Karte + Summe; Exit-Code 1 bei Fehlern
import 'dart:convert';
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_schema.dart';

void main(List<String> args) async {
  var outDir = 'assets/vocab';
  var update = false;
  var dryRun = false;
  final dateien = <String>[];

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--out':
        outDir = args[++i];
      case '--update':
        update = true;
      case '--dry-run':
        dryRun = true;
      default:
        dateien.add(args[i]);
    }
  }
  if (dateien.isEmpty) {
    final inbox = Directory('import_inbox');
    if (inbox.existsSync()) {
      final gefunden = inbox
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .where((p) => p.endsWith('.json'))
          .toList()
        ..sort();
      dateien.addAll(gefunden);
    }
  }
  if (dateien.isEmpty) {
    stderr.writeln('Keine Eingabedateien (import_inbox/*.json leer?).');
    exit(2);
  }

  var neu = 0, aktualisiert = 0, uebersprungen = 0;
  final fehler = <String>[], warnungen = <String>[];
  const encoder = JsonEncoder.withIndent('  ');

  for (final pfad in dateien) {
    stdout.writeln('── $pfad');
    final List<Map<String, dynamic>> roh;
    try {
      roh = vokabParseBatch(await File(pfad).readAsString());
    } on Object catch (e) {
      fehler.add('[$pfad] JSON kaputt: $e');
      continue;
    }

    for (final r in roh) {
      final p = vokabPruefeKarte(r);
      warnungen.addAll(p.warnungen);
      if (!p.ok) {
        fehler.addAll(p.fehler);
        continue;
      }
      final karte = p.karte!;
      final id = karte['id'] as String;
      final wortart = karte['wortart'] as String;
      final ziel = File('$outDir/$wortart/$id.json');

      if (ziel.existsSync() && !update) {
        uebersprungen++;
        stdout.writeln('  ⏭  $id (existiert — Duplikat-Schutz)');
        continue;
      }
      final existierte = ziel.existsSync();
      if (!dryRun) {
        ziel.parent.createSync(recursive: true);
        await ziel.writeAsString('${encoder.convert(karte)}\n');
      }
      existierte ? aktualisiert++ : neu++;
      stdout.writeln(
          '  ${existierte ? '♻️ ' : '✅'} $id${dryRun ? ' (dry-run)' : ''}');
    }
  }

  // ── Bericht ──
  stdout.writeln('\n════ Import-Bericht ════');
  stdout.writeln('neu: $neu · aktualisiert: $aktualisiert · '
      'übersprungen: $uebersprungen · Fehler: ${fehler.length} · '
      'Warnungen: ${warnungen.length}${dryRun ? '  [DRY-RUN]' : ''}');
  if (warnungen.isNotEmpty) {
    stdout.writeln('\n⚠️  Warnungen (normalisiert/prüfen):');
    for (final w in warnungen) {
      stdout.writeln('  · $w');
    }
  }
  if (fehler.isNotEmpty) {
    stdout.writeln('\n❌ Fehler (NICHT geschrieben):');
    for (final f in fehler) {
      stdout.writeln('  · $f');
    }
    exit(1);
  }
}
