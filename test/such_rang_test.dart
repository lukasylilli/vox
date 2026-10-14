// FILE: test/such_rang_test.dart
// PHASE: فاز F.1 (Lukas, 2026-10-14): «ging» muss gehen GANZ OBEN zeigen,
//        nicht alphabetisch zwischen anderen Treffern.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/wortschatz/data/such_rang.dart';

void main() {
  List<String> geordnet(String q, List<String> woerter, Set<String> formen) =>
      [
        for (final t in suchTrefferOrdnen<String>(woerter,
            query: q, wort: (w) => w, istForm: formen.contains))
          t.wert,
      ];

  test('gebeugte Form: der Infinitiv steht vor allen anderen Treffern', () {
    // «ging» als Form von gehen; andere Treffer nur über Text/Übersetzung.
    final r = geordnet('ging', ['abgingen', 'aufgingen', 'gehen', 'Gingko'],
        {'gehen'});
    expect(r.first, 'gehen');
  });

  test('Rangfolge: genau ⇒ Form ⇒ Anfang ⇒ Mitte ⇒ Übersetzung', () {
    final r = geordnet(
      'haus',
      ['der Waschhausbesitzer', 'das Haus', 'hausen', 'das Hochhaus', 'warm'],
      {'hausen'},
    );
    expect(r, [
      'das Haus', // genau (Artikel zählt nicht)
      'hausen', // Form
      'das Hochhaus', // Mitte, kürzer
      'der Waschhausbesitzer', // Mitte, länger
      'warm', // nur Übersetzung
    ]);
  });

  test('Anfang vor Mitte, kürzer vor länger, dann Alphabet', () {
    final r = geordnet('geh', ['vergehen', 'gehen', 'gehorchen', 'gehalt'],
        const {});
    expect(r, ['gehen', 'gehalt', 'gehorchen', 'vergehen']);
  });

  test('Suche mit Artikel und Groß/Klein: trotzdem «genau»', () {
    expect(suchRang(wort: 'der Tisch', query: 'der tisch', istForm: false),
        SuchRang.genau);
    expect(suchRang(wort: 'Tisch', query: 'TISCH', istForm: false),
        SuchRang.genau);
  });

  test('genau schlägt Form (die Grundform ist selbst gesucht)', () {
    expect(suchRang(wort: 'gehen', query: 'gehen', istForm: true),
        SuchRang.genau);
  });
}
