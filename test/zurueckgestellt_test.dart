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
}
