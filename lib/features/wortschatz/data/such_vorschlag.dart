// FILE: lib/features/wortschatz/data/such_vorschlag.dart
// PHASE: فاز F.1c (Lukas, 2026-10-14) — «منظورت این بود؟» / «Did you mean?»
// PURPOSE: Findet die Suche NICHTS, schlägt «Alle Wörter» die nächsten
//          Wörter mit kleinem Tippfehler vor («gehn» ⇒ gehen, «Strasse» ⇒
//          Straße, «Hasu» ⇒ Haus). Nur kleine Abstände — lieber kein
//          Vorschlag als ein falscher (wie Projektregel 3):
//            · Suche (gefaltet) unter 3 Zeichen ⇒ nie ein Vorschlag;
//            · bis 5 Zeichen höchstens 1 Änderung, länger höchstens 2;
//            · ß/ss und ä/ae, ö/oe, ü/ue zählen als gleich (Tastatur ohne
//              Umlaute), Groß/Klein und Artikel zählen nicht.
//          Abstand = Damerau-Levenshtein (OSA): einfügen, löschen, ersetzen,
//          zwei Nachbarbuchstaben vertauschen = je 1.
//
// Rein (ohne Flutter), damit test/such_vorschlag_test.dart es direkt prüft.
import '../../../core/wort/wort_form.dart' show ohneNomenArtikel;
import 'altwort_karte.dart' show altwortLemma;

/// Vergleichsform: Artikel weg, klein, ß→ss, Umlaute ausgeschrieben.
String suchGefaltet(String wort) => altwortLemma(wort)
    .replaceAll('ß', 'ss')
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue');

/// Höchster erlaubter Abstand für eine Suche der (gefalteten) Länge [n];
/// 0 ⇒ kein Vorschlag.
int suchVorschlagGrenze(int n) => n < 3 ? 0 : (n <= 5 ? 1 : 2);

/// Abstand von [a] und [b]; sobald er sicher über [grenze] liegt, kommt
/// `grenze + 1` zurück (schneller bei ~26.000 Wörtern).
int suchAbstand(String a, String b, int grenze) {
  if ((a.length - b.length).abs() > grenze) return grenze + 1;
  final n = a.length, m = b.length;
  var vorvorher = List<int>.filled(m + 1, 0);
  var vorher = List<int>.generate(m + 1, (j) => j);
  for (var i = 1; i <= n; i++) {
    final jetzt = List<int>.filled(m + 1, 0)..[0] = i;
    var zeilenMin = jetzt[0];
    for (var j = 1; j <= m; j++) {
      final kosten = a[i - 1] == b[j - 1] ? 0 : 1;
      var d = vorher[j] + 1; // löschen
      if (jetzt[j - 1] + 1 < d) d = jetzt[j - 1] + 1; // einfügen
      if (vorher[j - 1] + kosten < d) d = vorher[j - 1] + kosten; // ersetzen
      if (i > 1 &&
          j > 1 &&
          a[i - 1] == b[j - 2] &&
          a[i - 2] == b[j - 1] &&
          vorvorher[j - 2] + 1 < d) {
        d = vorvorher[j - 2] + 1; // vertauschen
      }
      jetzt[j] = d;
      if (d < zeilenMin) zeilenMin = d;
    }
    if (zeilenMin > grenze) return grenze + 1;
    vorvorher = vorher;
    vorher = jetzt;
  }
  return vorher[m];
}

/// Bis zu [max] Vorschläge für [query] aus [woerter] (Lemmata, Nomen gern
/// mit Artikel). Zurück kommt das Wort OHNE Artikel, in seiner Schreibung
/// («Straße») — so kann der Screen es direkt in die Suche setzen.
/// Reihenfolge: kleinster Abstand, dann Länge näher an der Suche, dann
/// alphabetisch; jedes Wort nur einmal.
List<String> suchVorschlaege(String query, Iterable<String> woerter,
    {int max = 3}) {
  final q = suchGefaltet(query);
  final grenze = suchVorschlagGrenze(q.length);
  if (grenze == 0) return const [];
  final besteNachForm = <String, ({String wort, int abstand})>{};
  for (final w in woerter) {
    final f = suchGefaltet(w);
    if (f.isEmpty) continue;
    final d = suchAbstand(q, f, grenze);
    if (d > grenze) continue;
    final alt = besteNachForm[f];
    if (alt == null || d < alt.abstand) {
      besteNachForm[f] = (wort: _ohneArtikel(w), abstand: d);
    }
  }
  final liste = besteNachForm.entries.toList()
    ..sort((a, b) {
      final d = a.value.abstand.compareTo(b.value.abstand);
      if (d != 0) return d;
      final l = (a.key.length - q.length)
          .abs()
          .compareTo((b.key.length - q.length).abs());
      if (l != 0) return l;
      return a.key.compareTo(b.key);
    });
  return [for (final e in liste.take(max)) e.value.wort];
}

String _ohneArtikel(String wort) {
  return ohneNomenArtikel(wort);
}
