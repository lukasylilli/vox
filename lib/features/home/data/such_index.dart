// FILE: lib/features/home/data/such_index.dart
// PHASE: G8 (2026-11-16) — globale Suche über die ganze App
// PURPOSE: EINE Quelle für «was findet die globale Suche außerhalb der
//          Wörter, und in welcher Reihenfolge?».
//
// Entscheidungen Lukas (2026-11-16):
//   · gesucht wird in allem außer den Lesetexten: Wörter, Grammatik
//     (Katalog mit 84 Lektionen) und alle Decks (Verben mit Präpositionen,
//     NVV, Konnektoren, Redemittel, unregelmäßige Verben …);
//   · Treffer stehen GRUPPIERT unter der Überschrift ihres Bereichs, je
//     Gruppe zuerst [suchVorschau] Treffer, der Rest über «alle zeigen»;
//   · Wörter erscheinen wie in «Alle Wörter» (Symbol, Ton, Leitner-Knopf) —
//     die kommen deshalb NICHT aus dieser Datei, sondern aus derselben
//     Quelle wie die Liste (wortschatz_filter.dart → wortschatzZeilen).
//
// Gesucht wird nur in dem, was der Eintrag IST: Titel, Bedeutung und feste
// Formen (Stammformen, Präposition). Beispielsätze zählen bewusst nicht —
// sonst fände «warten» jeden Satz, in dem das Wort vorkommt.
//
// Rein (ohne Flutter), damit test/such_index_test.dart es direkt prüft.

/// Bereiche der globalen Suche außer «Wörter» — Reihenfolge = Reihenfolge der
/// Gruppen in den Ergebnissen (Grammatik, dann die Decks wie in
/// Auswendiglernen).
enum SuchBereich {
  grammatik('Grammatik', ''),
  konnektoren('Satzkonnektoren', 'deck.konnektoren'),
  dativVerben('Dativ und Akkusativ Verben', 'deck.dativ_verben'),
  nvv('Nomen-Verb-Verbindungen', 'deck.nvv'),
  praepositionen(
      'Nomen · Verb · Adjektiv + Präposition', 'deck.praepositionen'),
  unregelmVerben('Unregelmäßige Verben', 'deck.unregelm_verben'),
  trennbarVerben('Trennbare und untrennbare Verben', 'deck.trennbar_verben'),
  reflexivVerben('Reflexivverben', 'deck.reflexiv_verben'),
  verbPraep('Verben mit Präpositionen', 'deck.verb_praep'),
  modalverben('Modalverben', 'deck.modalverben'),
  redemittelGoetheB2('Goethe B2 Redemittel', 'deck.goethe_b2'),
  redemittelOesdB2('ÖSD B2 Redemittel', 'deck.oesd_b2'),
  redemittelOesdC1('ÖSD C1 Redemittel', 'deck.oesd_c1'),
  redemittel1010('1010 Redemittel', 'deck.redemittel_1010'),
  auswendiglernen('Auswendiglernen', '');

  const SuchBereich(this.titel, this.flag);

  /// Überschrift der Gruppe — derselbe deutsche Name wie in der App.
  final String titel;

  /// Schlüssel in FeatureFlags; '' = immer da. Ein Deck, das nicht «live»
  /// ist, wird nicht durchsucht (sonst führte ein Treffer ins Leere).
  final String flag;
}

/// Wie viele Treffer eine Gruppe zeigt, bevor «alle zeigen» nötig ist.
const int suchVorschau = 5;

/// Ab so vielen Zeichen wird außerhalb der Wörter gesucht — ein einzelner
/// Buchstabe träfe fast jeden Eintrag.
const int suchMindestLaenge = 2;

/// Ein durchsuchbarer Eintrag (eine Lektion, ein Verb, ein Redemittel …).
class SuchEintrag {
  const SuchEintrag({
    required this.bereich,
    required this.titel,
    required this.fa,
    required this.en,
    required this.route,
    this.formen = const [],
    this.niveau = '',
  });

  final SuchBereich bereich;

  /// Deutscher Titel, wie die Zeile ihn zeigt («warten auf»).
  final String titel;

  /// Bedeutung — gezeigt wird nur die der aktiven Sprache, gesucht in beiden.
  final String fa;
  final String en;

  /// Seite, die ein Tippen öffnet.
  final String route;

  /// Weitere feste Formen, über die man den Eintrag findet (Stammformen
  /// «ging», «gegangen»; Präposition; Glieder eines Clusters). Nicht gezeigt.
  final List<String> formen;

  /// «A1» … «C2» oder leer.
  final String niveau;
}

/// Rang eines Treffers — kleinerer Index steht weiter oben.
enum SuchEintragRang { genau, anfang, wortAnfang, mitte, form, bedeutung }

final RegExp _leerraum = RegExp(r'\s+');
// Arabische Kurzvokale/Tanwin und Tatweel — beim Tippen meist weggelassen.
final RegExp _faZeichen = RegExp('[ً-ْٰـ]');
final RegExp _wortGrenze = RegExp(r'[\s·/,;:()«»„“"\-]+');

/// Vergleichsform für Suche und Eintrag: klein, Leerraum einfach, und die
/// persischen Schreibvarianten vereinheitlicht (arabisches ي/ك ⇒ ی/ک,
/// Halbabstand ⇒ nichts, Kurzvokale weg) — «میروم» findet «می‌روم».
String suchNormal(String text) => text
    .toLowerCase()
    .replaceAll('ي', 'ی') // ي → ی
    .replaceAll('ك', 'ک') // ك → ک
    .replaceAll('‌', '') // Halbabstand (ZWNJ)
    .replaceAll(_faZeichen, '')
    .replaceAll(_leerraum, ' ')
    .trim();

// Wörter, die in fast jeder Stammform stehen («hat geholfen», «ich kann»,
// «freut sich») — über sie allein wird keine Form gefunden.
const _hilfswoerter = {
  'hat', 'ist', 'sich', 'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr', //
};

/// Rang von [e] für die Suche [query], oder `null`, wenn [e] nicht passt.
/// Eine Form ([SuchEintrag.formen]) trifft nur als GANZES Wort («gegangen»,
/// nicht «gang») — lieber kein Treffer als ein zufälliger.
/// [query] muss schon [suchNormal] sein.
SuchEintragRang? suchEintragRang(SuchEintrag e, String query) {
  if (query.length < suchMindestLaenge) return null;
  final t = suchNormal(e.titel);
  if (t == query) return SuchEintragRang.genau;
  if (t.startsWith(query)) return SuchEintragRang.anfang;
  if (t.contains(query)) {
    return t.split(_wortGrenze).any((w) => w.startsWith(query))
        ? SuchEintragRang.wortAnfang
        : SuchEintragRang.mitte;
  }
  for (final f in e.formen) {
    final form = suchNormal(f);
    if (form.isEmpty) continue;
    if (form == query) return SuchEintragRang.form;
    if (!_hilfswoerter.contains(query) &&
        form.split(_wortGrenze).contains(query)) {
      return SuchEintragRang.form;
    }
  }
  if (suchNormal(e.fa).contains(query) || suchNormal(e.en).contains(query)) {
    return SuchEintragRang.bedeutung;
  }
  return null;
}

/// Treffer von [query] in [eintraege], nach Bereich gruppiert. Die Karte ist
/// in der Reihenfolge von [SuchBereich] geordnet und enthält nur Bereiche mit
/// Treffern. In einer Gruppe: Rang, dann kürzerer Titel, dann Alphabet; bei
/// völligem Gleichstand bleibt die Reihenfolge der Daten.
Map<SuchBereich, List<SuchEintrag>> suchGruppen(
    Iterable<SuchEintrag> eintraege, String query) {
  final q = suchNormal(query);
  if (q.length < suchMindestLaenge) return const {};
  final roh = <SuchBereich, List<(SuchEintragRang, int, SuchEintrag)>>{};
  var nr = 0;
  for (final e in eintraege) {
    final rang = suchEintragRang(e, q);
    if (rang != null) (roh[e.bereich] ??= []).add((rang, nr++, e));
  }
  return {
    for (final b in SuchBereich.values)
      if (roh[b] != null)
        b: [
          for (final t in roh[b]!
            ..sort((a, b) {
              final r = a.$1.index.compareTo(b.$1.index);
              if (r != 0) return r;
              final l = a.$3.titel.length.compareTo(b.$3.titel.length);
              if (l != 0) return l;
              final c = suchNormal(a.$3.titel).compareTo(suchNormal(b.$3.titel));
              return c != 0 ? c : a.$2.compareTo(b.$2);
            }))
            t.$3,
        ],
  };
}
