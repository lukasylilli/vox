// FILE: lib/features/wortschatz/data/altwort_karte.dart
// PHASE: L.4b (Lukas, 2026-09-24) — «Wort, das schon in der App war»
// PURPOSE: EINZIGE Quelle für die Frage: «Welches alte App-Wort (drift-Tabelle
//          `Words`, `ausApp = true` — die mitgelieferten Wörter aus den Decks
//          Dativ/Akkusativ, Konnektoren, NVV, Präpositionen) gehört zu welcher
//          Prompt-Karte (assets/vocab/, SUPER-PROMPT 3.0)?»
//
// REGEL (Lukas): Vom alten Wort und seiner Seite wird NICHTS gelöscht. Die
//   alte Seite (word_detail_screen.dart) wird um die ganze Karte ERWEITERT und
//   bleibt die einzige Seite des Worts; die Liste zeigt nur die alte Zeile;
//   jeder Link auf die Karte führt zur alten Seite.
//
// PAARUNG — nie geraten (Projektregel 3: lieber kein Paar als ein falsches):
//   · nur App-Wörter (`ausApp`), nie eigene Wörter des Nutzers;
//   · Lemma exakt gleich (Artikel und Groß/Klein zählen nicht);
//   · Wortart verträglich laut [altwortTypZuWortart];
//   · eindeutig in BEIDE Richtungen — passt ein altes Wort auf zwei Karten
//     oder zwei alte Wörter auf eine Karte, entsteht kein Paar.
//   Beispiele: «helfen|verb» ↔ verb_helfen ✓ · «der|konnektor» ↔ artikel_der ✗
//   (andere Wortart) · «denken an|verb» ✗ (Lemma mit Präposition ≠ «denken»).
//
// Rein (ohne Flutter/DB), damit test/altwort_karte_test.dart es direkt prüft.

/// Alte `WordType`-Namen (drift) → Wortarten der Karten (Schema 3.0).
/// Auch der Wortart-Filter von «Alle Wörter» liest diese Tabelle.
const altwortTypZuWortart = <String, Set<String>>{
  'nomen': {'nomen'},
  'verb': {'verb'},
  'adjektiv': {'adjektiv'},
  'praepositon': {'praeposition'},
  'konnektor': {'konjunktion'},
  'modalpartikel': {'partikel'},
  'pronomen': {'pronomen'},
  'zahl': {'numerale'},
  'sonstige': {'artikel', 'adverb'},
};

/// Vergleichs-Lemma: Artikel (der/die/das) weg, klein, getrimmt.
/// Auch Sortierschlüssel von «Alle Wörter» (beide Quellen in EINER Liste).
String altwortLemma(String wort) {
  var w = wort.trim().toLowerCase();
  final teile = w.split(' ');
  if (teile.length > 1 && const {'der', 'die', 'das'}.contains(teile.first)) {
    w = teile.sublist(1).join(' ');
  }
  return w;
}

/// Die Felder eines alten Worts, die die Paarung braucht.
class AltwortEintrag {
  const AltwortEintrag({
    required this.id,
    required this.german,
    required this.wordType,
    required this.ausApp,
  });

  final int id;
  final String german;
  final String wordType;

  /// true = mitgeliefertes App-Wort; false/null = eigenes Wort des Nutzers.
  final bool ausApp;
}

/// Ergebnis der Paarung, in beiden Richtungen.
class AltwortZuordnung {
  const AltwortZuordnung({
    required this.karteZuWort,
    required this.wortZuKarte,
  });

  static const leer = AltwortZuordnung(karteZuWort: {}, wortZuKarte: {});

  /// Karten-id → id des alten Worts (drift).
  final Map<String, int> karteZuWort;

  /// id des alten Worts (drift) → Karten-id.
  final Map<int, String> wortZuKarte;
}

/// Paart alte App-Wörter mit Karten (Index-Einträge oder volle Karten —
/// gebraucht werden nur `id`, `wort`, `wortart`).
AltwortZuordnung altwortZuordnen(
  Iterable<AltwortEintrag> woerter,
  Iterable<Map<String, dynamic>> karten,
) {
  final kartenNachLemma = <String, List<Map<String, dynamic>>>{};
  for (final k in karten) {
    final lemma = altwortLemma(k['wort'] as String? ?? '');
    final id = k['id'] as String? ?? '';
    if (lemma.isEmpty || id.isEmpty) continue;
    kartenNachLemma.putIfAbsent(lemma, () => []).add(k);
  }

  final kandidat = <int, String>{};
  final wieOftKarte = <String, int>{};
  for (final w in woerter) {
    if (!w.ausApp) continue;
    final erlaubt = altwortTypZuWortart[w.wordType] ?? const <String>{};
    final treffer = (kartenNachLemma[altwortLemma(w.german)] ?? const [])
        .where((k) => erlaubt.contains(k['wortart']))
        .toList();
    if (treffer.length != 1) continue;
    final kartenId = treffer.single['id'] as String;
    kandidat[w.id] = kartenId;
    wieOftKarte[kartenId] = (wieOftKarte[kartenId] ?? 0) + 1;
  }

  final karteZuWort = <String, int>{};
  final wortZuKarte = <int, String>{};
  kandidat.forEach((wortId, kartenId) {
    if (wieOftKarte[kartenId] != 1) return;
    karteZuWort[kartenId] = wortId;
    wortZuKarte[wortId] = kartenId;
  });
  return AltwortZuordnung(karteZuWort: karteZuWort, wortZuKarte: wortZuKarte);
}
