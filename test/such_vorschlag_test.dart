// FILE: test/such_vorschlag_test.dart
// PHASE: فاز F.1c (Lukas, 2026-10-14): kleiner Tippfehler ⇒ «Did you mean?»
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/wortschatz/data/such_vorschlag.dart';

void main() {
  const woerter = [
    'gehen',
    'die Straße',
    'das Haus',
    'der Tisch',
    'abholen',
    'verstehen',
  ];

  test('fehlender Buchstabe: gehn ⇒ gehen', () {
    expect(suchVorschlaege('gehn', woerter).first, 'gehen');
  });

  test('ss/ß und Groß/Klein zählen nicht: strasse ⇒ Straße', () {
    expect(suchVorschlaege('strasse', woerter), ['Straße']);
  });

  test('vertauschte Buchstaben: Hasu ⇒ Haus (Artikel fällt weg)', () {
    expect(suchVorschlaege('hasu', woerter), ['Haus']);
  });

  test('Umlaut ohne Tastatur: ae/oe/ue gilt wie ä/ö/ü', () {
    expect(suchVorschlaege('fuer', ['für']), ['für']);
  });

  test('zu kurz oder zu weit weg ⇒ kein Vorschlag (lieber keiner als falsch)',
      () {
    expect(suchVorschlaege('ge', woerter), isEmpty);
    expect(suchVorschlaege('xyzq', woerter), isEmpty);
    // 5 Zeichen ⇒ höchstens 1 Änderung: «tsich» (vertauscht) ja, «tusck» nein.
    expect(suchVorschlaege('tsich', woerter), ['Tisch']);
    expect(suchVorschlaege('tusck', woerter), isEmpty);
  });

  test('längere Suche erlaubt 2 Änderungen: verstehn ⇒ verstehen', () {
    expect(suchVorschlaege('verstehn', woerter), ['verstehen']);
    expect(suchVorschlaege('verstn', woerter), isEmpty); // 3 Änderungen
  });

  test('höchstens 3 Vorschläge, jedes Wort einmal', () {
    final r = suchVorschlaege(
        'haus', ['das Haus', 'das Haus', 'hausen', 'Maus', 'raus', 'laus']);
    expect(r.length, lessThanOrEqualTo(3));
    expect(r.toSet().length, r.length);
    expect(r.first, 'Haus');
  });

  test('Abstand bricht früh ab, Ergebnis bleibt richtig', () {
    expect(suchAbstand('kitten', 'sitting', 5), 3);
    expect(suchAbstand('kitten', 'sitting', 1), 2); // = grenze + 1
    expect(suchAbstand('ab', 'ba', 1), 1);
  });
}
