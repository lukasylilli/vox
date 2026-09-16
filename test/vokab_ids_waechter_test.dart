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

  test('der eigene Index hat dieselbe Form wie der Wächter sie liest', () {
    final text = vokabIndexBauen({
      'assets/vocab/verb/verb_helfen.json': {
        'id': 'verb_helfen',
        'wort': 'helfen',
        'wortart': 'verb',
      },
    });
    expect(vokabIndexIds(text), {'verb_helfen'});
  });
}
