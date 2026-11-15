// FILE: test/zurueckgestellt_test.dart
// PURPOSE: Wächter — die zurückgestellten Wörter haben EINE Quelle
//          (tool/daten/zurueckgestellt.json). docs/ZURUECKGESTELLT.md muss
//          genau das sein, was tool/zurueckgestellt.dart daraus erzeugt.
//          Rot ⇒ `dart tool/zurueckgestellt.dart` ausführen und committen.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/zurueckgestellt.dart';

void main() {
  test('docs/ZURUECKGESTELLT.md ist aus der JSON-Quelle erzeugt', () {
    final eintraege = ladeZurueckgestelltEintraege();
    expect(eintraege, isNotEmpty);
    expect(
      File(zurueckgestelltTabelle).readAsStringSync(),
      zurueckgestelltAlsTabelle(eintraege),
      reason: 'Tabelle veraltet — `dart tool/zurueckgestellt.dart` ausführen',
    );
  });

  test('erledigte Zeilen werden nicht mehr übersprungen', () {
    final eintraege = ladeZurueckgestelltEintraege();
    final erledigt = eintraege.where((e) => e['erledigt'] == true).length;
    expect(ladeZurueckgestellt().length, eintraege.length - erledigt);
  });

  group('Vier Fälle M6 — Runden aus Tabelle 2', () {
    List<Map<String, dynamic>> probe() => [
          {'tabelle': 1, 'nr': '1', 'wort': 'a', 'liste': 'L', 'datum': 'd', 'grund': 'g'},
          {'tabelle': 2, 'nr': '1', 'wort': 'Bank', 'liste': 'L', 'datum': 'd', 'grund': 'Fall 3'},
          {'tabelle': 2, 'nr': '2', 'wort': 'See', 'liste': 'L', 'datum': 'd', 'grund': 'Fall 2'},
          {'tabelle': 2, 'nr': '3', 'wort': 'Birne', 'liste': 'L', 'datum': 'd', 'grund': 'Fall 1'},
        ];

    test('nächste offene Wörter nur aus Tabelle 2, in Reihenfolge', () {
      expect([for (final e in vierFaelleOffen(probe(), 2)) e['wort']],
          ['Bank', 'See']);
    });

    test('erledigt markiert, Zeile bleibt, nächste Runde beginnt danach', () {
      final e = probe();
      expect(zurueckgestelltErledigen(e, ['Bank', 'See']), isEmpty);
      expect(e, hasLength(4));
      expect([for (final x in vierFaelleOffen(e, 5)) x['wort']], ['Birne']);
    });

    test('unbekanntes oder schon erledigtes Wort wird gemeldet', () {
      final e = probe();
      zurueckgestelltErledigen(e, ['Bank']);
      expect(zurueckgestelltErledigen(e, ['Bank', 'Gibtsnicht']),
          ['Bank', 'Gibtsnicht']);
    });
  });
}
