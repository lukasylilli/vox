// FILE: lib/features/wortschatz/data/such_rang.dart
// PHASE: فاز F.1 (Lukas, 2026-10-14) — Reihenfolge der Suchtreffer
// PURPOSE: EINZIGE Quelle für die Frage «Welcher Treffer steht oben?».
//          Vorher sortierte «Alle Wörter» jede Suche alphabetisch — wer «ging»
//          suchte, fand gehen irgendwo zwischen anderen Treffern. Jetzt:
//            1. genau  — das gesuchte Wort selbst («gehen» ⇒ gehen)
//            2. form   — die Suche ist eine gebeugte Form der Karte
//                        («ging» ⇒ gehen, «Häuser» ⇒ das Haus)
//            3. anfang — das Wort beginnt mit der Suche
//            4. mitte  — die Suche steht irgendwo im Wort
//            5. uebersetzung — nur die FA/EN-Übersetzung passt
//          Innerhalb eines Rangs: kürzeres Wort zuerst (näher an der Suche),
//          dann alphabetisch. Ohne Suche bleibt die Liste alphabetisch
//          (das entscheidet der Screen, nicht diese Datei).
//          Vergleich über [altwortLemma] (Artikel weg, klein) — dieselbe
//          Normalisierung wie der Sortierschlüssel der Liste.
//
// Rein (ohne Flutter), damit test/such_rang_test.dart es direkt prüft.
import 'altwort_karte.dart' show altwortLemma;

/// Rang eines Treffers — kleinerer Index steht weiter oben.
enum SuchRang { genau, form, anfang, mitte, uebersetzung }

/// Rang von [wort] für die Suche [query]. [istForm] = die Suche ist eine
/// gebeugte Form genau dieses Worts (Formen-Tabelle bzw. altwortFormen).
SuchRang suchRang({
  required String wort,
  required String query,
  required bool istForm,
}) {
  final l = altwortLemma(wort);
  final q = altwortLemma(query);
  if (q.isEmpty || l == q) return SuchRang.genau;
  if (istForm) return SuchRang.form;
  if (l.startsWith(q)) return SuchRang.anfang;
  if (l.contains(q)) return SuchRang.mitte;
  return SuchRang.uebersetzung;
}

/// Ein einsortierter Treffer: [wert] ist die Zeile (Karte oder altes Wort).
class SuchTreffer<T> {
  const SuchTreffer({
    required this.wert,
    required this.lemma,
    required this.rang,
  });

  final T wert;

  /// Vergleichs-Lemma ([altwortLemma]).
  final String lemma;
  final SuchRang rang;
}

/// Ordnet [treffer] nach Rang, dann Länge, dann Alphabet.
List<SuchTreffer<T>> suchTrefferOrdnen<T>(
  Iterable<T> treffer, {
  required String query,
  required String Function(T) wort,
  required bool Function(T) istForm,
}) {
  final liste = [
    for (final t in treffer)
      SuchTreffer<T>(
        wert: t,
        lemma: altwortLemma(wort(t)),
        rang: suchRang(wort: wort(t), query: query, istForm: istForm(t)),
      ),
  ];
  liste.sort((a, b) {
    final r = a.rang.index.compareTo(b.rang.index);
    if (r != 0) return r;
    final l = a.lemma.length.compareTo(b.lemma.length);
    if (l != 0) return l;
    return a.lemma.compareTo(b.lemma);
  });
  return liste;
}
