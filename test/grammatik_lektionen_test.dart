// FILE: test/grammatik_lektionen_test.dart
// PHASE: فاز LAUNCH L.2c / فاز G G3–G6 (2026-09-16)
// PURPOSE: Alle 84 Kern-Lektionen sind da, erreichbar und darstellbar.
//
// Wächter:
//   · jede Datei in assets/data/grammatik/ wird geladen (grammatikContentFiles)
//   · jede Lektion hat einen Katalog-Eintrag — und jeder Katalog-Eintrag, der
//     auf /grammatik/lektion/<slug> zeigt, hat eine Lektion (kein Link ins Leere)
//   · jede Tabelle ist darstellbar (sonst stürzt DataTable ab)
//   · Titel, Erklärungen und Beispiele sind dreisprachig (فاز L3)
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/grammatik/controllers/grammatik_lektion_controller.dart';
import 'package:vox/features/grammatik/models/grammatik_lektion.dart';

Map<String, dynamic> lies(String pfad) =>
    jsonDecode(File(pfad).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final lektionen = <String, GrammatikLektion>{};
  final rohe = <Map<String, dynamic>>[];
  for (final pfad in grammatikContentFiles) {
    for (final l in (lies(pfad)['lessons'] as List)) {
      final roh = l as Map<String, dynamic>;
      rohe.add(roh);
      lektionen[roh['slug'] as String] = GrammatikLektion.fromJson(roh);
    }
  }
  final katalog = {
    for (final e in (lies('assets/data/grammatik_katalog.json')['eintraege']
        as List))
      (e as Map<String, dynamic>)['slug'] as String: e,
  };

  test('jede Content-Datei wird geladen', () {
    final dateien = Directory('assets/data/grammatik')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => f.path.replaceAll('\\', '/'))
        .toSet();
    expect(grammatikContentFiles.toSet(), dateien);
  });

  test('84 Kern-Lektionen, keine doppelt', () {
    expect(rohe.length, 84);
    expect(lektionen.length, 84);
  });

  test('Lektionen und Katalog passen zusammen', () {
    for (final slug in lektionen.keys) {
      expect(katalog.containsKey(slug), isTrue, reason: '$slug fehlt im Katalog');
      expect(katalog[slug]['route'], isNotNull, reason: '$slug ist nicht erreichbar');
    }
    for (final e in katalog.values) {
      final route = e['route'] as String?;
      if (route != null && route.startsWith('/grammatik/lektion/')) {
        final slug = route.substring('/grammatik/lektion/'.length);
        expect(lektionen.containsKey(slug), isTrue,
            reason: '${e['slug']} zeigt auf eine fehlende Lektion');
      }
    }
  });

  test('jede Tabelle ist darstellbar', () {
    for (final l in lektionen.values) {
      for (final t in l.tables) {
        expect(t.istStimmig, isTrue, reason: '${l.slug}: ${t.titleDe}');
      }
    }
  });

  test('zwei Schreibweisen der Spalten werden gleich dargestellt', () {
    final ohne = GrammatikTable.fromJson({
      'columns': ['Form'],
      'rows': [
        {'rowLabel': 'ich', 'cells': ['bin']},
      ],
    });
    expect(ohne.columns, ['', 'Form']);
    expect(ohne.istStimmig, isTrue);
    final mit = GrammatikTable.fromJson({
      'columns': ['Person', 'Endung'],
      'rows': [
        {'rowLabel': 'ich', 'cells': ['-e']},
      ],
    });
    expect(mit.columns, ['Person', 'Endung']);
    expect(mit.istStimmig, isTrue);
  });

  test('alles dreisprachig (DE/FA/EN)', () {
    for (final l in lektionen.values) {
      final felder = <String>[
        l.titleDe, l.titleFa, l.titleEn,
        for (final b in l.explanationBlocks) ...[b.bodyDe, b.bodyFa, b.bodyEn],
        for (final e in l.examples) ...[e.german, e.meaningFa, e.meaningEn],
        for (final t in l.tables) ...[t.titleDe, t.titleFa, t.titleEn],
      ];
      expect(felder.every((f) => f.trim().isNotEmpty), isTrue,
          reason: '${l.slug}: leeres Textfeld');
    }
  });
}
