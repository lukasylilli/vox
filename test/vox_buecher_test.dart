// FILE: test/vox_buecher_test.dart
// PHASE: فاز F.4 (Lukas, 2026-10-14): Bücher sind nur fertige VOX-Bücher aus
//        assets/buecher/buecher.json. Dieser Test schützt die Datei: Format,
//        feste ids, und JEDE Karten-id muss es in assets/vocab/ geben.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/wortschatz/data/vox_buecher.dart';

void main() {
  test('die echte buecher.json ist gültig, jede Karten-id existiert', () {
    final buecher = voxBuecherLesen(File(voxBuecherAsset).readAsStringSync());
    expect(buecher, isNotEmpty);
    final vorhanden = {
      for (final f in Directory('assets/vocab')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json')))
        f.uri.pathSegments.last.replaceAll('.json', ''),
    };
    for (final b in buecher) {
      for (final k in b.karten) {
        expect(vorhanden.contains(k), isTrue,
            reason: 'Buch «${b.id}»: Karte «$k» gibt es nicht');
      }
      expect(b.karten.toSet().length, b.karten.length,
          reason: 'Buch «${b.id}»: Karte doppelt');
    }
  });

  test('alt_buch zeigt nur auf mitgelieferte Decks (DataSeedService)', () {
    final seed =
        File('lib/core/services/data_seed_service.dart').readAsStringSync();
    for (final b in voxBuecherLesen(File(voxBuecherAsset).readAsStringSync())) {
      if (b.altBuch == null) continue;
      expect(seed.contains("_ensureBook('${b.altBuch}')"), isTrue,
          reason: 'Buch «${b.id}»: Deck «${b.altBuch}» unbekannt');
    }
  });

  test('Fehler werden laut (nie still in die App)', () {
    expect(() => voxBuecherLesen('{}'), throwsFormatException);
    expect(
        () => voxBuecherLesen(
            '{"buecher":[{"id":"a","name":"A"},{"id":"a","name":"B"}]}'),
        throwsFormatException);
    expect(() => voxBuecherLesen('{"buecher":[{"id":"A b","name":"x"}]}'),
        throwsFormatException);
    expect(() => voxBuecherLesen('{"buecher":[{"id":"a","name":" "}]}'),
        throwsFormatException);
    expect(
        () => voxBuecherLesen(
            '{"buecher":[{"id":"a","name":"A","karten":[1]}]}'),
        throwsFormatException);
    final ok = voxBuecherLesen(
        '{"buecher":[{"id":"a1_starten_wir","name":"A1 Starten wir","alt_buch":null,"karten":["verb_gehen"]}]}');
    expect(ok.single.karten, ['verb_gehen']);
  });
}
