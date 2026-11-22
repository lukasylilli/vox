// FILE: lib/features/leitner/data/standard_decks.dart
// PHASE: X.4b (2026-11-17) — Deckهای پیش‌فرض (Entscheidung Lukas Nr. 16,
//        docs/zukunft/PHASE_X.md)
// PURPOSE: Welche Standard-Decks es gibt und welche Wörter darin liegen —
//          EINE Stelle, rein (ohne Flutter, ohne Datenbank).
//
// Entscheidung Nr. 16 (Lukas 2026-11-03):
//   · beim ersten Öffnen des Leitners hat der Nutzer OHNE eigenes Zutun
//     Decks nach den Filtern von «Alle Wörter» — alle außer «anstößig» und
//     «zeitlich»: Niveau (A1…C2) · VOX-Bücher (je Buch ein Subdeck) ·
//     Wortart · Berufe;
//   · alle beginnen als «nur Notizbuch» (kein Ansturm neuer Wörter);
//   · die Wörter werden AUS DENSELBEN DATEN wie der Filter berechnet, nicht
//     kopiert ⇒ trägt Lukas ein neues A1-Wort ein, wächst «A1» von selbst;
//     der Fortschritt hängt am Wort und geht nie verloren;
//   · ein gelöschtes Standard-Deck bleibt gelöscht (Ereignis `liste` in der
//     Sicherung) und kann über «Standard-Decks» zurückgeholt werden.
//
// Lektionen (Lukas 2026-11-22): ein Deck mit Wörtern (z. B. «A1») wird in
// Lektionen zu je [lektionGroesse] Wörtern geteilt, damit nicht alle Wörter
// auf einmal im Leitner sind — jede Lektion lässt sich einzeln lernen und
// wiederholen. Mehr als [lektionenJeTeil] Lektionen ⇒ zusätzlich «Teile» zu
// je 10 Lektionen. Die Lektionen sind FEST: Reihenfolge aus
// assets/leitner/reihenfolge.json (wort_reihenfolge.dart), die nur verlängert
// wird ⇒ ein neues Wort kommt in die letzte Lektion oder eine neue dahinter,
// frühere Lektionen ändern sich nie. Lektionen und Teile sind «virtuell»:
// sie stehen nicht in der Datenbank, solange der Nutzer an ihnen nichts
// ändert (sonst hätte jeder Nutzer ~2.500 Zeilen mehr in Ablage und
// Sicherung).
//
// Die Zugehörigkeit hier ist dieselbe Regel wie in wortschatz_filter.dart
// (Niveau aus `niveau`, Wortart über [altwortTypZuWortart], Berufe aus
// `berufe`, Bücher aus buecher.json) — test/standard_decks_test.dart prüft
// das gegen den Filter selbst.
import '../../../core/models/word_model.dart' show WordType;
import '../../vokabular/data/vokab_schema.dart' show vokabBerufe;
import '../../wortschatz/data/altwort_karte.dart' show altwortTypZuWortart;

/// Präfix aller Standard-Decks. Ein Nutzer-Deck hat es nie
/// (`eigen:#…`, `eigen:<Name>`, `kat_…`, `deck:leitner`).
const String standardDeckPraefix = 'std:';

bool istStandardDeck(String id) => id.startsWith(standardDeckPraefix);

/// Wörter je Lektion (Lukas 2026-11-22).
const int lektionGroesse = 20;

/// Lektionen je «Teil», wenn ein Deck mehr Lektionen hat (Lukas 2026-11-22).
const int lektionenJeTeil = 10;

final _virtuell = RegExp(r'^std:[^:]+:[^:]+:[lt]\d+$');

/// Lektion oder Teil eines Standard-Decks — ohne Zeile in der Datenbank,
/// solange der Nutzer nichts daran ändert.
bool istStandardLektion(String id) => _virtuell.hasMatch(id);

const _niveaus = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

/// Deutsche Namen der Berufe (wie in der Wortliste; Reihenfolge = vokabBerufe).
const standardBerufNamen = {
  'pflege_medizin': 'Medizin und Pflege',
  'it': 'IT',
  'technik': 'Elektro, Mechanik, Haustechnik',
  'bau': 'Bau',
  'gastro_hotel': 'Gastronomie und Hotel',
  'logistik': 'Transport und Lager',
  'kinder_bildung': 'Kita und Bildung',
  'reinigung': 'Reinigung',
  'buero': 'Büro',
};

/// Ein Standard-Deck: feste id, Name, Eltern-Deck, Platz unter Geschwistern.
class StandardDeck {
  const StandardDeck(this.id, this.name,
      {this.eltern, this.ordnung = 0, this.virtuell = false});

  final String id;
  final String name;
  final String? eltern;
  final int ordnung;

  /// Lektion oder Teil ([istStandardLektion]).
  final bool virtuell;
}

/// Ein Wort der alten Tabelle `Words` — nur was die Zuordnung braucht.
/// [ausApp] = mit der App geliefert (feste Menge) — steht in den Lektionen
/// vorn; eigene Wörter des Nutzers stehen hinten.
typedef StandardAltwort = ({
  String wortId,
  String? niveau,
  String wortart,
  bool ausApp,
});

/// Ein VOX-Buch mit allen seinen Wörtern (Karten und alte Wörter, Text-ids).
typedef StandardBuch = ({String id, String name, List<String> woerter});

/// Ergebnis: welche Standard-Decks es gibt und ihre Wörter.
class StandardDecks {
  const StandardDecks(this.decks, this.woerter, [this.gruppen = const {}]);

  /// In Baum-Reihenfolge: Gruppen («Niveau»), ihre Decks («A1»), darunter
  /// Teile und Lektionen (virtuell).
  final List<StandardDeck> decks;

  /// Lektion → ihre Wörter (Text-ids). Nur Lektionen haben Wörter; ein Deck
  /// darüber hat die seiner Lektionen.
  final Map<String, List<String>> woerter;

  /// Wort → Decks wie «A1», «Nomen», in denen es aus seinen Daten liegt
  /// (für den festen Haken in der Deck-Auswahl).
  final Map<String, Set<String>> gruppen;

  static const leer = StandardDecks([], {});
}

/// Rechnet Standard-Decks und ihre Wörter aus.
///
/// [karten] = Einträge des Wortindex (`id`, `wortart`, `niveau`, `berufe`);
/// [altWoerter] = Wörter der Tabelle `Words`; [buecher] = VOX-Bücher.
/// Ein Subdeck ohne Wörter wird nicht angelegt — es entsteht von selbst,
/// sobald es Wörter hat. Ein Eltern-Deck gibt es, wenn es ein Subdeck gibt.
StandardDecks standardDecksBerechnen({
  required Iterable<Map<String, dynamic>> karten,
  required Iterable<StandardAltwort> altWoerter,
  required Iterable<StandardBuch> buecher,
  Map<String, int> reihenfolge = const {},
}) {
  final woerter = <String, List<String>>{};
  void dazu(String deck, String wort) => (woerter[deck] ??= []).add(wort);

  // Wortart der Karte ⇒ Wortart der Liste (dieselbe Tabelle wie der Filter).
  final kartenArtZuTyp = <String, List<String>>{};
  for (final e in altwortTypZuWortart.entries) {
    for (final a in e.value) {
      (kartenArtZuTyp[a] ??= []).add(e.key);
    }
  }

  for (final k in karten) {
    final id = k['id'] as String? ?? '';
    if (id.isEmpty) continue;
    final niveau = (k['niveau'] as String? ?? '').toLowerCase();
    if (_niveaus.contains(niveau))
      dazu('${standardDeckPraefix}niveau:$niveau', id);
    for (final t in kartenArtZuTyp[k['wortart']] ?? const <String>[]) {
      dazu('${standardDeckPraefix}wortart:$t', id);
    }
    final berufe = k['berufe'];
    if (berufe is List) {
      for (final b in berufe) {
        if (b is String && standardBerufNamen.containsKey(b)) {
          dazu('${standardDeckPraefix}beruf:$b', id);
        }
      }
    }
  }
  for (final w in altWoerter) {
    final niveau = (w.niveau ?? '').toLowerCase();
    if (_niveaus.contains(niveau))
      dazu('${standardDeckPraefix}niveau:$niveau', w.wortId);
    dazu('${standardDeckPraefix}wortart:${w.wortart}', w.wortId);
  }
  for (final b in buecher) {
    for (final w in b.woerter) {
      dazu('${standardDeckPraefix}buch:${b.id}', w);
    }
  }

  // Wörter je Deck nur einmal (eine Karte kann über zwei Wortarten passen).
  woerter.updateAll((_, l) => {...l}.toList());

  final decks = <StandardDeck>[];
  void gruppe(
    String schluessel,
    String name,
    int ordnung,
    List<(String, String)> kinder,
  ) {
    final vorhanden = [
      for (final (wert, kname) in kinder)
        if (woerter['$standardDeckPraefix$schluessel:$wert']?.isNotEmpty ??
            false)
          (wert, kname),
    ];
    if (vorhanden.isEmpty) return;
    final eltern = '$standardDeckPraefix$schluessel';
    decks.add(StandardDeck(eltern, name, ordnung: ordnung));
    var i = 0;
    for (final (wert, kname) in vorhanden) {
      decks.add(
        StandardDeck('$eltern:$wert', kname, eltern: eltern, ordnung: i++),
      );
    }
  }

  // Ordnung weit hinten (1000+): eigene Decks des Nutzers (Ordnung 0)
  // stehen immer oben.
  gruppe('niveau', 'Niveau', 1000, [
    for (final n in _niveaus) (n, n.toUpperCase()),
  ]);
  gruppe('buch', 'VOX-Bücher', 1001, [for (final b in buecher) (b.id, b.name)]);
  gruppe('wortart', 'Wortart', 1002, [
    for (final t in WordType.values) (t.name, t.label),
  ]);
  gruppe('beruf', 'Berufe', 1003, [
    for (final b in vokabBerufe) (b, standardBerufNamen[b] ?? b),
  ]);

  final ids = {for (final d in decks) d.id};
  woerter.removeWhere((k, _) => !ids.contains(k));

  // ── Lektionen ──────────────────────────────────────────────────────────
  // Feste Reihenfolge: mitgelieferte alte Wörter (feste Menge, alphabetisch)
  // · Karten nach reihenfolge.json (unbekannte — nur zwischen zwei Runden
  // denkbar — dahinter nach id) · eigene Wörter des Nutzers. Bücher behalten
  // die Reihenfolge ihrer Wortliste.
  final ausApp = {
    for (final w in altWoerter)
      if (w.ausApp) w.wortId,
  };
  int rang(String w) => w.startsWith('eigen:')
      ? (ausApp.contains(w) ? 0 : 3)
      : (reihenfolge.containsKey(w) ? 1 : 2);
  final buchIds = {for (final b in buecher) '${standardDeckPraefix}buch:${b.id}'};

  final gruppen = <String, Set<String>>{};
  final lektionWoerter = <String, List<String>>{};
  final mitLektionen = <StandardDeck>[];
  for (final d in decks) {
    mitLektionen.add(d);
    final liste = woerter[d.id];
    if (liste == null || liste.isEmpty) continue;
    for (final w in liste) {
      (gruppen[w] ??= {}).add(d.id);
    }
    final geordnet = buchIds.contains(d.id)
        ? liste
        : ([...liste]..sort((a, b) {
            final r = rang(a).compareTo(rang(b));
            if (r != 0) return r;
            final ra = reihenfolge[a], rb = reihenfolge[b];
            if (ra != null && rb != null) return ra.compareTo(rb);
            return a.compareTo(b);
          }));
    final anzahl = (geordnet.length + lektionGroesse - 1) ~/ lektionGroesse;
    final mitTeilen = anzahl > lektionenJeTeil;
    for (var l = 0; l < anzahl; l++) {
      String eltern = d.id;
      if (mitTeilen) {
        final t = l ~/ lektionenJeTeil;
        eltern = '${d.id}:t${t + 1}';
        if (l % lektionenJeTeil == 0) {
          final bis = (t + 1) * lektionenJeTeil > anzahl
              ? anzahl
              : (t + 1) * lektionenJeTeil;
          mitLektionen.add(StandardDeck(
              eltern, 'Teil ${t + 1} (Lektion ${l + 1}–$bis)',
              eltern: d.id, ordnung: t, virtuell: true));
        }
      }
      final id = '${d.id}:l${l + 1}';
      mitLektionen.add(StandardDeck(id, 'Lektion ${l + 1}',
          eltern: eltern, ordnung: l, virtuell: true));
      lektionWoerter[id] = geordnet.sublist(
          l * lektionGroesse,
          (l + 1) * lektionGroesse > geordnet.length
              ? geordnet.length
              : (l + 1) * lektionGroesse);
    }
  }
  return StandardDecks(mitLektionen, lektionWoerter, gruppen);
}
