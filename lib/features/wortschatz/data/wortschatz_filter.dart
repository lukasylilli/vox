// FILE: lib/features/wortschatz/data/wortschatz_filter.dart
// PHASE: فاز F.2 (Lukas, 2026-10-14) — eigene Filterseite für «Alle Wörter»
// PURPOSE: EINE Quelle für Filter + Zeilen von «Alle Wörter» — die Liste UND
//          die Filterseite (Zähler «N Wörter anzeigen», Zahl je Knopf) rechnen
//          mit denselben Funktionen, damit die Zahl auf dem Knopf immer genau
//          der Liste entspricht.
//            · [WortschatzFilter] — gewählte Werte je Bereich (Drawer).
//              Innerhalb eines Bereichs «oder», zwischen Bereichen «und».
//            · [WortschatzBasis] — beide Quellen NACH der Suche (alte Wörter
//              aus drift + Karten aus assets/vocab/), einmal berechnet.
//            · [wortschatzZeilen] — gefiltert + geordnet (such_rang.dart).
//            · [wortschatzAnzahl] / [wortschatzAnzahlMit] — nur zählen.
//          Neue Bereiche (Bücher, Berufe, … — F.4/F.6) kommen als weiteres
//          Feld + [FilterBereich] hinzu; die Logik bleibt hier.
//
// Rein (ohne Flutter) — test/wortschatz_filter_test.dart.
import '../../../core/models/word_model.dart';
import '../../../core/wort/altwort_formen.dart';
import '../../../core/wort/wort_form.dart';
import 'altwort_karte.dart';
import 'such_rang.dart';

/// Die Drawer der Filterseite.
enum FilterBereich { niveau, wortart }

/// Gültige Niveau-Werte (klein, wie `GermanLevel.name`).
const wortschatzNiveaus = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

class WortschatzFilter {
  const WortschatzFilter({
    this.niveaus = const {},
    this.wortarten = const {},
  });

  /// 'a1' … 'c2'.
  final Set<String> niveaus;

  /// Namen von [WordType] (z. B. 'nomen', 'praepositon').
  final Set<String> wortarten;

  static const leer = WortschatzFilter();

  bool get istLeer => niveaus.isEmpty && wortarten.isEmpty;
  int get anzahlAktiv => niveaus.length + wortarten.length;

  Set<String> werte(FilterBereich b) => switch (b) {
        FilterBereich.niveau => niveaus,
        FilterBereich.wortart => wortarten,
      };

  /// Kopie, in der Bereich [b] genau [neu] enthält.
  WortschatzFilter mitBereich(FilterBereich b, Set<String> neu) => switch (b) {
        FilterBereich.niveau =>
          WortschatzFilter(niveaus: Set.unmodifiable(neu), wortarten: wortarten),
        FilterBereich.wortart =>
          WortschatzFilter(niveaus: niveaus, wortarten: Set.unmodifiable(neu)),
      };

  /// Wert [wert] in Bereich [b] an/aus.
  WortschatzFilter umschalten(FilterBereich b, String wert) {
    final s = {...werte(b)};
    s.contains(wert) ? s.remove(wert) : s.add(wert);
    return mitBereich(b, s);
  }

  Map<String, dynamic> toJson() => {
        'niveaus': niveaus.toList()..sort(),
        'wortarten': wortarten.toList()..sort(),
      };

  /// Unbekannte Werte (z. B. aus einer älteren App-Version) fallen weg.
  factory WortschatzFilter.fromJson(Map<String, dynamic> json) {
    Set<String> lies(String k, Set<String> erlaubt) => {
          for (final v in (json[k] as List?) ?? const [])
            if (v is String && erlaubt.contains(v)) v,
        };
    return WortschatzFilter(
      niveaus: lies('niveaus', wortschatzNiveaus.toSet()),
      wortarten: lies('wortarten', {for (final t in WordType.values) t.name}),
    );
  }

  // ── Passt ein Eintrag? ───────────────────────────────────────────────────

  /// Altes Wort (drift).
  bool wortPasst(WordModel w) =>
      (niveaus.isEmpty || (w.level != null && niveaus.contains(w.level!.name))) &&
      (wortarten.isEmpty || wortarten.contains(w.wordType.name));

  /// Karte bzw. Index-Eintrag (assets/vocab/). Wortart über dieselbe Tabelle
  /// wie die Paarung (altwortTypZuWortart).
  bool kartePasst(Map<String, dynamic> k) => kartenPruefer()(k);

  /// Prüffunktion für viele Karten — die Wortart-Menge wird nur EINMAL
  /// gebaut (Zählen über ~26.000 Karten auf der Filterseite).
  bool Function(Map<String, dynamic>) kartenPruefer() {
    final erlaubt = {
      for (final t in wortarten) ...?altwortTypZuWortart[t],
    };
    return (k) {
      if (niveaus.isNotEmpty &&
          !niveaus.contains((k['niveau'] as String? ?? '').toLowerCase())) {
        return false;
      }
      if (wortarten.isNotEmpty && !erlaubt.contains(k['wortart'])) {
        return false;
      }
      return true;
    };
  }
}

/// Beide Quellen nach der Suche — einmal berechnen, oft filtern/zählen.
class WortschatzBasis {
  WortschatzBasis._(this.woerter, this.karten, this._altForm, this.query);

  /// Alte Wörter, die zur Suche passen (alle, wenn keine Suche).
  final List<WordModel> woerter;

  /// Karten, die zur Suche passen (vom Aufrufer, z. B. vokabSucheProvider).
  final List<Map<String, dynamic>> karten;

  /// Ids alter Wörter, deren gebeugte Form gesucht wurde.
  final Set<int> _altForm;

  /// Suche (klein, getrimmt; leer = keine).
  final String query;

  bool altIstForm(WordModel w) => _altForm.contains(w.id);
}

/// [alleWoerter] = alle alten Wörter; [kartenTreffer] = Karten, die schon zur
/// Suche passen (ohne Suche: alle). Alte Wörter werden hier gesucht — über
/// Wort, FA/EN und gebeugte Formen («empfahl» ⇒ empfehlen, 2026-09-30).
WortschatzBasis wortschatzBasis({
  required List<WordModel> alleWoerter,
  required List<Map<String, dynamic>> kartenTreffer,
  required String query,
}) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) {
    return WortschatzBasis._(alleWoerter, kartenTreffer, const {}, '');
  }
  final formSchluessel = wortSchluessel(q);
  final altForm = <int>{};
  final woerter = <WordModel>[];
  for (final w in alleWoerter) {
    final istForm = formSchluessel.isNotEmpty &&
        altwortFormen(
          wortart: w.wordType.name,
          german: w.german,
          plural: w.plural,
          conjugationJson: w.conjugationJson,
        ).contains(formSchluessel);
    if (istForm) altForm.add(w.id);
    if (istForm ||
        w.german.toLowerCase().contains(q) ||
        w.meaningFa.contains(q) ||
        (w.meaningEn?.toLowerCase().contains(q) ?? false)) {
      woerter.add(w);
    }
  }
  return WortschatzBasis._(woerter, kartenTreffer, altForm, q);
}

/// Zeilen von «Alle Wörter»: gefiltert; ohne Suche alphabetisch (Artikel
/// zählt nicht), mit Suche nach Nähe (such_rang.dart, F.1). [formIds] = ids
/// der Karten, deren gebeugte Form gesucht wurde.
List<SuchTreffer<Object>> wortschatzZeilen(
  WortschatzBasis basis,
  WortschatzFilter filter, {
  Set<String> formIds = const {},
}) {
  final passt = filter.kartenPruefer();
  final eintraege = <Object>[
    for (final w in basis.woerter)
      if (filter.wortPasst(w)) w,
    for (final k in basis.karten)
      if (passt(k)) k,
  ];
  if (basis.query.isEmpty) {
    return [
      for (final e in eintraege)
        SuchTreffer<Object>(
          wert: e,
          lemma: altwortLemma(_wortVon(e)),
          rang: SuchRang.genau,
        ),
    ]..sort((a, b) => a.lemma.compareTo(b.lemma));
  }
  return suchTrefferOrdnen<Object>(
    eintraege,
    query: basis.query,
    wort: _wortVon,
    istForm: (e) => e is WordModel
        ? basis.altIstForm(e)
        : formIds.contains((e as Map<String, dynamic>)['id'] as String? ?? ''),
  );
}

/// Anzahl der Zeilen mit [filter] (ohne Ordnen).
int wortschatzAnzahl(WortschatzBasis basis, WortschatzFilter filter) {
  var n = 0;
  for (final w in basis.woerter) {
    if (filter.wortPasst(w)) n++;
  }
  final passt = filter.kartenPruefer();
  for (final k in basis.karten) {
    if (passt(k)) n++;
  }
  return n;
}

/// Zahl je Knopf (F.2b): wie viele Zeilen es gäbe, wenn in Bereich [b] NUR
/// [wert] gewählt wäre — die anderen Bereiche bleiben, wie sie sind.
int wortschatzAnzahlMit(WortschatzBasis basis, WortschatzFilter filter,
        FilterBereich b, String wert) =>
    wortschatzAnzahl(basis, filter.mitBereich(b, {wert}));

String _wortVon(Object e) => e is WordModel
    ? e.german
    : ((e as Map<String, dynamic>)['wort'] as String? ?? '');
