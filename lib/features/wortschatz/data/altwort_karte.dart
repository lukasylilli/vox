// FILE: lib/features/wortschatz/data/altwort_karte.dart
// PHASE: L.4b (Lukas, 2026-09-24) — «Wort, das schon in der App war»
// PURPOSE: EINZIGE Quelle für die Frage: «Welches alte App-Wort (drift-Tabelle
//          `Words`, `ausApp = true` — die mitgelieferten Wörter aus den Decks
//          Dativ/Akkusativ, Konnektoren, NVV, Präpositionen) gehört zu welcher
//          Prompt-Karte (assets/vocab/, SUPER-PROMPT 3.0)?»
//
// GRUNDREGEL (Lukas, 2026-09-24 — ersetzt die früheren Regeln L.4b/L.4b-2/
//   L.4c «alte Seite statt neuer Seite»): Jedes Wort der Wortlisten bekommt
//   IMMER eine eigene Karte mit eigener Seite und eigener Zeile — egal ob es
//   das Wort schon gab (allein, mit Präposition, mit «sich», als Ausdruck).
//   Nichts wird gelöscht, nichts umgeleitet, nichts ausgeblendet. Doppelte
//   sucht Claude erst ganz am Ende (PLAN.md → L.4d); Lukas entscheidet.
//   Diese Paarung bestimmt NUR noch, unter welcher alten Seite die Karte
//   ZUSÄTZLICH angezeigt wird (word_detail_screen.dart, eine weitere Tür;
//   nichts wird dort gelöscht) — und liefert L.4d die bekannten Paare.
//
// PAARUNG — nie geraten (Projektregel 3: lieber kein Paar als ein falsches):
//   · nur App-Wörter (`ausApp`), nie eigene Wörter des Nutzers;
//   · Lemma exakt gleich (Artikel und Groß/Klein zählen nicht); bei Einträgen
//     «Wort + feste Präposition» aus dem Präpositionen-Deck («warten auf»,
//     grammarNote «auf + Akk») zählt das Wort ohne Präposition — aber NUR,
//     wenn die Präposition genau so in grammarNote steht (L.4b-2, Lukas
//     2026-09-24);
//   · Wortart verträglich laut [altwortTypZuWortart];
//   · je altem Wort genau EINE passende Karte, sonst kein Paar;
//   · eine Karte darf zu MEHREREN alten Seiten gehören (L.4b-2: «vertrauen»,
//     «vertrauen auf», «vertrauen in») — sie erscheint dann unter JEDER davon
//     (eine Karte, mehrere Türen). Nur zwei alte Einträge OHNE Präposition für
//     dieselbe Karte gelten als unklar ⇒ die Karte wird gar nicht gepaart.
//   · Ausdrücke (NVV/Redemittel) werden nie gepaart («Lemma exakt gleich»).
//   Beispiele: «helfen|verb» ↔ verb_helfen ✓ · «warten auf|verb» ↔ verb_warten ✓
//   · «der|konnektor» ↔ artikel_der ✗ (andere Wortart) · «sich bedanken bei» ✗
//   (Lemma mit «sich» ≠ Karten-Lemma ⇒ kein Paar; die Karte hat trotzdem
//   ihre eigene Seite — Grundregel).
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
    this.grammarNote,
  });

  final int id;
  final String german;
  final String wordType;

  /// Präpositionen-Deck: «`präp` + `Kasus`» (siehe DataSeedService).
  final String? grammarNote;

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

  /// Karten-id → erste alte Seite (ohne Präposition zuerst) — nur Übersicht
  /// für L.4d und Tests; Links auf die Karte führen IMMER zur Karten-Seite.
  /// Enthält jede gepaarte Karte genau einmal.
  final Map<String, int> karteZuWort;

  /// id des alten Worts (drift) → Karten-id. Mehrere alte Wörter können
  /// dieselbe Karte haben (L.4b-2).
  final Map<int, String> wortZuKarte;
}

/// Lemma eines alten Eintrags für die Paarung: «warten auf» mit grammarNote
/// «auf + Akk» ⇒ «warten». Ohne passende grammarNote bleibt alles, wie es ist
/// (Ausdrücke wie «eine Entscheidung treffen» werden so nie gekürzt).
String altwortPaarLemma(String german, String? grammarNote) {
  final lemma = altwortLemma(german);
  final note = grammarNote?.trim() ?? '';
  if (!note.contains('+')) return lemma;
  final praep = note.split('+').first.trim().toLowerCase();
  final teile = lemma.split(' ');
  if (praep.isEmpty || teile.length < 2 || teile.last != praep) return lemma;
  return teile.sublist(0, teile.length - 1).join(' ');
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

  // Karte → alte Einträge (mit/ohne Präposition getrennt).
  final ohnePraep = <String, List<AltwortEintrag>>{};
  final mitPraep = <String, List<AltwortEintrag>>{};
  for (final w in woerter) {
    if (!w.ausApp) continue;
    final erlaubt = altwortTypZuWortart[w.wordType] ?? const <String>{};
    final lemma = altwortPaarLemma(w.german, w.grammarNote);
    final treffer = (kartenNachLemma[lemma] ?? const [])
        .where((k) => erlaubt.contains(k['wortart']))
        .toList();
    if (treffer.length != 1) continue;
    final kartenId = treffer.single['id'] as String;
    final ziel = lemma == altwortLemma(w.german) ? ohnePraep : mitPraep;
    ziel.putIfAbsent(kartenId, () => []).add(w);
  }

  final karteZuWort = <String, int>{};
  final wortZuKarte = <int, String>{};
  for (final kartenId in {...ohnePraep.keys, ...mitPraep.keys}) {
    final ohne = ohnePraep[kartenId] ?? const <AltwortEintrag>[];
    if (ohne.length > 1) continue; // unklar ⇒ kein Paar
    final mit = [
      ...?mitPraep[kartenId],
    ]..sort((a, b) => a.german.toLowerCase().compareTo(b.german.toLowerCase()));
    final alle = [...ohne, ...mit];
    karteZuWort[kartenId] = alle.first.id; // ohne Präposition zuerst
    for (final w in alle) {
      wortZuKarte[w.id] = kartenId;
    }
  }
  return AltwortZuordnung(karteZuWort: karteZuWort, wortZuKarte: wortZuKarte);
}
