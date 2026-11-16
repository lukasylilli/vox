// FILE: test/vokab_ids_waechter_test.dart
// PHASE: فاز LAUNCH, Schritt L.1a (2026-09-16)
// PURPOSE: Der Wächter „eine veröffentlichte Wort-id bleibt für immer".
//          Der eigentliche Vergleich mit der Live-Seite läuft im Workflow
//          (tool/vokab_ids_pruefen.dart); hier die Regeln dahinter.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';

String index(List<String> ids, {int version = vokabIndexVersion}) =>
    '{"version":$version,"karten":[${ids.map((i) => '{"id":"$i"}').join(',')}]}';

void main() {
  test('gelöschte oder umbenannte id wird gemeldet, neue ids sind erlaubt', () {
    final alt = vokabIndexIds(index(['verb_helfen', 'adjektiv_stolz']));
    final neu = vokabIndexIds(index(['verb_helfen', 'adjektiv_stolzz', 'nomen_tisch']));
    expect(vokabVerloreneIds(alt, neu), ['adjektiv_stolz']);
    expect(vokabVerloreneIds(alt, {...alt, 'nomen_tisch'}), isEmpty);
  });

  test('ein veröffentlichter Index älterer Fassung wird trotzdem gelesen', () {
    expect(vokabIndexIds(index(['verb_helfen'], version: 0)), {'verb_helfen'});
  });

  test('Unlesbares ist ein Fehler, nie „nichts veröffentlicht"', () {
    expect(() => vokabIndexIds('<html>404</html>'), throwsFormatException);
    expect(() => vokabIndexIds('{"version":1}'), throwsFormatException);
    expect(() => vokabIndexIds('{"karten":[{"wort":"x"}]}'),
        throwsFormatException);
  });

  test('der eigene Index hat dieselbe Form wie der Wächter sie liest', () async {
    final dateien = vokabIndexBauen({
      'assets/vocab/verb/verb_helfen.json': {
        'id': 'verb_helfen',
        'wort': 'helfen',
        'wortart': 'verb',
      },
      'assets/vocab/nomen/nomen_tisch.json': {
        'id': 'nomen_tisch',
        'wort': 'der Tisch',
        'wortart': 'nomen',
      },
    });
    expect(await vokabIndexIdsHolen((p) async => dateien[p]),
        {'verb_helfen', 'nomen_tisch'});
  });

  group('Live-Seite: in Stücken ODER ältere Ablage in einer Datei', () {
    test('ältere Ablage (eine Datei) wird gelesen, wenn es keine Stücke gibt',
        () async {
      final live = {vokabIndexAltPfad: index(['verb_helfen', 'adjektiv_stolz'], version: 5)};
      expect(await vokabIndexIdsHolen((p) async => live[p]),
          {'verb_helfen', 'adjektiv_stolz'});
    });

    test('Stücke haben Vorrang; eine ältere Fassung der Liste wird gelesen',
        () async {
      final live = {
        vokabIndexStueckeDatei:
            '{"version":0,"stuecke":["assets/vocab_index/h.json","assets/vocab_index/s.json"]}',
        'assets/vocab_index/h.json': index(['verb_helfen'], version: 0),
        'assets/vocab_index/s.json': index(['adjektiv_stolz'], version: 0),
        vokabIndexAltPfad: index(['nomen_uralt']),
      };
      expect(await vokabIndexIdsHolen((p) async => live[p]),
          {'verb_helfen', 'adjektiv_stolz'});
    });

    test('nichts da oder ein Stück fehlt ⇒ Fehler, nie „nichts veröffentlicht"',
        () async {
      await expectLater(
          vokabIndexIdsHolen((p) async => null), throwsFormatException);
      final live = {
        vokabIndexStueckeDatei:
            '{"version":6,"stuecke":["assets/vocab_index/h.json","assets/vocab_index/s.json"]}',
        'assets/vocab_index/h.json': index(['verb_helfen']),
      };
      await expectLater(vokabIndexIdsHolen((p) async => live[p]),
          throwsFormatException);
      await expectLater(
          vokabIndexIdsHolen(
              (p) async => p == vokabIndexStueckeDatei ? '<html>' : null),
          throwsFormatException);
    });
  });
}
