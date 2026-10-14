// FILE: test/filter_raster_test.dart
// PHASE: فاز F.3 (Lukas, 2026-10-14): In jedem Filter-Drawer haben ALLE
//        Zeilen gleich viele, gleich breite Knöpfe — bündig auf jedem Gerät.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/widgets/filter_accordion.dart';

void main() {
  group('filterSpalten', () {
    test('kurze Knöpfe: alle 6 Niveaus in EINER Zeile, wenn sie passen', () {
      expect(filterSpalten(breiten: List.filled(6, 44), verfuegbar: 340), 6);
    });

    test('volle Zeilen bevorzugt: 6 Knöpfe, 4 passen ⇒ 3 + 3 (nie 4 + 2)', () {
      expect(filterSpalten(breiten: List.filled(6, 70), verfuegbar: 340), 3);
    });

    test('mittlere Knöpfe ⇒ 2 pro Zeile', () {
      expect(filterSpalten(breiten: List.filled(8, 140), verfuegbar: 340), 2);
    });

    test('lange Beschriftung (z. B. Buchtitel) ⇒ 1 pro Zeile', () {
      expect(filterSpalten(breiten: [250, 120, 90, 200], verfuegbar: 340), 1);
    });

    test('der BREITESTE Knopf entscheidet für den ganzen Drawer', () {
      expect(filterSpalten(breiten: [40, 40, 40, 200], verfuegbar: 340), 1);
    });

    test('Primzahl (7) ⇒ so viele wie passen, letzte Zeile kürzer', () {
      expect(filterSpalten(breiten: List.filled(7, 70), verfuegbar: 340), 4);
    });

    test('Randfälle: 0/1 Knopf ⇒ 1', () {
      expect(filterSpalten(breiten: const [], verfuegbar: 340), 1);
      expect(filterSpalten(breiten: const [50], verfuegbar: 340), 1);
    });
  });

  testWidgets('Drawer: alle Knöpfe gleich breit und spaltenbündig',
      (tester) async {
    const optionen = [
      FilterOption(value: 'a', label: 'Nomen'),
      FilterOption(value: 'b', label: 'Verb'),
      FilterOption(value: 'c', label: 'Adjektiv'),
      FilterOption(value: 'd', label: 'Präposition'),
      FilterOption(value: 'e', label: 'Konjunktion'),
      FilterOption(value: 'f', label: 'Adverb'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: FilterAccordion(
            label: 'Wortart',
            options: optionen,
            selected: const {'b'},
            onChanged: (_, _) {},
            initiallyExpanded: true,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Knopf-Rechtecke = InkWell um den Text.
    final knoepfe = [
      for (final o in optionen)
        tester.getRect(find
            .ancestor(of: find.text(o.label), matching: find.byType(InkWell))
            .first),
    ];
    expect(knoepfe.length, 6);
    final breite = knoepfe.first.width;
    for (final k in knoepfe) {
      expect(k.width, moreOrLessEquals(breite, epsilon: 0.5));
    }
    // Spalten bündig: jede linke Kante ist eine der Spaltenkanten der 1. Zeile.
    final ersteZeile = knoepfe
        .where((k) => (k.top - knoepfe.first.top).abs() < 0.5)
        .map((k) => k.left)
        .toList();
    expect(6 % ersteZeile.length, 0, reason: 'nur volle Zeilen');
    for (final k in knoepfe) {
      expect(ersteZeile.any((l) => (l - k.left).abs() < 0.5), isTrue);
    }
  });
}
