// FILE: tool/wort_reihenfolge.dart
// PHASE: X.4b (2026-11-17) — feste Lektionen der Standard-Decks
// PURPOSE: Hängt jede Karte, die noch nicht in assets/leitner/reihenfolge.json
//          steht, ans Ende an (Regeln: lib/features/leitner/data/
//          wort_reihenfolge.dart). Läuft in jeder Wortrunde nach dem Index
//          (tool/wort_runde.sh). Das Ergebnis WIRD committet — es ist die
//          Grundlage der festen Lektionen für alle Nutzer.
// Aufruf:  dart tool/wort_reihenfolge.dart
import 'dart:io';

import 'package:vox/features/leitner/data/wort_reihenfolge.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';

void main() {
  final liste = File(vokabIndexStueckeDatei);
  if (!liste.existsSync()) {
    stderr.writeln('$vokabIndexStueckeDatei fehlt — vorher '
        '`dart tool/vokab_index.dart`.');
    exit(1);
  }
  final dateien = <String, String>{
    vokabIndexStueckeDatei: liste.readAsStringSync(),
    for (final p in vokabIndexStueckeLesen(liste.readAsStringSync()))
      p: File(p).readAsStringSync(),
  };
  final datei = File(wortReihenfolgeAsset);
  final bisherMap = datei.existsSync()
      ? wortReihenfolgeLesen(datei.readAsStringSync())
      : const <String, int>{};
  final bisher = (bisherMap.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value)))
      .map((e) => e.key)
      .toList();
  final neu = wortReihenfolgeVerlaengern(bisher, vokabIndexLesen(dateien));
  datei
    ..createSync(recursive: true)
    ..writeAsStringSync(wortReihenfolgeText(neu));
  stdout.writeln('Reihenfolge: ${neu.length} Karten '
      '(+${neu.length - bisher.length} neu) → $wortReihenfolgeAsset');
}
