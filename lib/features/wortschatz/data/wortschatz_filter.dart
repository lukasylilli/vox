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
//          Bücher (nur fertige VOX-Bücher, assets/buecher/buecher.json) und
//          eigene Kategorien des Nutzers (F.4) sind Gruppen mit Mitgliedschaft
//          ([WortschatzZugehoerigkeit]). Neue Bereiche (Berufe, … — F.6)
//          kommen als weiterer [FilterBereich] hinzu; die Logik bleibt hier.
//
// Rein (ohne Flutter) — test/wortschatz_filter_test.dart.
import '../../../core/models/word_model.dart';
import '../../../core/wort/altwort_formen.dart';
import '../../../core/wort/wort_form.dart';
import '../../vokabular/data/vokab_schema.dart'
    show vokabAnstoessigStufen, vokabBerufe, vokabZeitlichWerte;
import 'altwort_karte.dart';
import 'such_rang.dart';

/// Die Drawer der Filterseite (Reihenfolge = Reihenfolge auf der Seite).
/// buch/kategorie haben Werte, die erst zur Laufzeit feststehen
/// ([WortschatzZugehoerigkeit]); niveau/wortart sind fest.
/// beruf/anstoessig/zeitlich (F.6) lesen die Einordnung der Karte (Prompt-
/// Regel 17, vokab_schema.dart) — alte Wörter haben keine und fallen dort
/// heraus.
enum FilterBereich { buch, wortart, niveau, beruf, anstoessig, zeitlich, kategorie }

/// Schlüssel im gespeicherten JSON je Bereich.
const _jsonSchluessel = {
  FilterBereich.buch: 'buecher',
  FilterBereich.wortart: 'wortarten',
  FilterBereich.niveau: 'niveaus',
  FilterBereich.beruf: 'berufe',
  FilterBereich.anstoessig: 'anstoessig',
  FilterBereich.zeitlich: 'zeitlich',
  FilterBereich.kategorie: 'kategorien',
};

/// Bereiche aus der Einordnung der Karte (F.6).
const _einordnungsBereiche = {
  FilterBereich.beruf,
  FilterBereich.anstoessig,
  FilterBereich.zeitlich,
};

/// Gültige Niveau-Werte (klein, wie `GermanLevel.name`).
const wortschatzNiveaus = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

/// Eine Gruppe mit fester Mitgliedschaft — ein VOX-Buch oder eine eigene
/// Kategorie des Nutzers. [altWoerter] = ids alter Wörter (drift),
/// [karten] = ids der Karten (assets/vocab/).
class FilterGruppe {
  const FilterGruppe({
    required this.id,
    required this.name,
    this.altWoerter = const {},
    this.karten = const {},
  });
  final String id;
  final String name;
  final Set<int> altWoerter;
  final Set<String> karten;
}

/// Bücher und eigene Kategorien, wie sie gerade sind (F.4).
class WortschatzZugehoerigkeit {
  const WortschatzZugehoerigkeit({
    this.buecher = const [],
    this.kategorien = const [],
  });
  final List<FilterGruppe> buecher;
  final List<FilterGruppe> kategorien;

  static const leer = WortschatzZugehoerigkeit();

  List<FilterGruppe> gruppen(FilterBereich b) => switch (b) {
        FilterBereich.buch => buecher,
        FilterBereich.kategorie => kategorien,
        _ => const [],
      };

  FilterGruppe? gruppe(FilterBereich b, String id) {
    for (final g in gruppen(b)) {
      if (g.id == id) return g;
    }
    return null;
  }
}

/// Bereiche mit Gruppen (Mitgliedschaft statt Eigenschaft des Worts).
const _gruppenBereiche = {FilterBereich.buch, FilterBereich.kategorie};

class WortschatzFilter {
  const WortschatzFilter._(this._werte);

  WortschatzFilter({
    Set<String> niveaus = const {},
    Set<String> wortarten = const {},
    Set<String> buecher = const {},
    Set<String> kategorien = const {},
    Set<String> berufe = const {},
    Set<String> anstoessig = const {},
    Set<String> zeitlich = const {},
  }) : _werte = {
          for (final e in {
            FilterBereich.buch: buecher,
            FilterBereich.wortart: wortarten,
            FilterBereich.niveau: niveaus,
            FilterBereich.beruf: berufe,
            FilterBereich.anstoessig: anstoessig,
            FilterBereich.zeitlich: zeitlich,
            FilterBereich.kategorie: kategorien,
          }.entries)
            if (e.value.isNotEmpty) e.key: Set.unmodifiable(e.value),
        };

  /// Nur nicht-leere Bereiche stehen drin.
  final Map<FilterBereich, Set<String>> _werte;

  static const leer = WortschatzFilter._({});

  Set<String> werte(FilterBereich b) => _werte[b] ?? const {};
  Set<String> get niveaus => werte(FilterBereich.niveau);
  Set<String> get wortarten => werte(FilterBereich.wortart);
  Set<String> get buecher => werte(FilterBereich.buch);
  Set<String> get kategorien => werte(FilterBereich.kategorie);
  Set<String> get berufe => werte(FilterBereich.beruf);
  Set<String> get anstoessig => werte(FilterBereich.anstoessig);
  Set<String> get zeitlich => werte(FilterBereich.zeitlich);

  bool get istLeer => _werte.isEmpty;
  int get anzahlAktiv =>
      _werte.values.fold(0, (summe, s) => summe + s.length);

  /// Kopie, in der Bereich [b] genau [neu] enthält.
  WortschatzFilter mitBereich(FilterBereich b, Set<String> neu) {
    final m = {..._werte};
    if (neu.isEmpty) {
      m.remove(b);
    } else {
      m[b] = Set.unmodifiable(neu);
    }
    return WortschatzFilter._(m);
  }

  /// Wert [wert] in Bereich [b] an/aus.
  WortschatzFilter umschalten(FilterBereich b, String wert) {
    final s = {...werte(b)};
    s.contains(wert) ? s.remove(wert) : s.add(wert);
    return mitBereich(b, s);
  }

  /// Ohne Buch-/Kategorie-Werte, die es (nicht mehr) gibt — z. B. eine
  /// gelöschte Kategorie. Gespeichert bleibt der Wert; er wirkt nur nicht
  /// und erscheint nicht als Chip.
  WortschatzFilter bereinigt(WortschatzZugehoerigkeit z) {
    var f = this;
    for (final b in _gruppenBereiche) {
      final bekannt = {for (final g in z.gruppen(b)) g.id};
      final w = werte(b);
      if (w.any((x) => !bekannt.contains(x))) {
        f = f.mitBereich(b, w.where(bekannt.contains).toSet());
      }
    }
    return f;
  }

  Map<String, dynamic> toJson() => {
        for (final b in FilterBereich.values)
          _jsonSchluessel[b]!: werte(b).toList()..sort(),
      };

  /// Unbekannte Niveaus/Wortarten (z. B. aus einer älteren App-Version)
  /// fallen weg; Bücher/Kategorien prüft erst [bereinigt].
  factory WortschatzFilter.fromJson(Map<String, dynamic> json) {
    Set<String> lies(String k, [Set<String>? erlaubt]) => {
          for (final v in (json[k] as List?) ?? const [])
            if (v is String && v.isNotEmpty && (erlaubt?.contains(v) ?? true))
              v,
        };
    return WortschatzFilter(
      niveaus: lies('niveaus', wortschatzNiveaus.toSet()),
      wortarten: lies('wortarten', {for (final t in WordType.values) t.name}),
      buecher: lies('buecher'),
      kategorien: lies('kategorien'),
      berufe: lies('berufe', vokabBerufe.toSet()),
      anstoessig: lies('anstoessig', vokabAnstoessigStufen.toSet()),
      zeitlich: lies('zeitlich', vokabZeitlichWerte.toSet()),
    );
  }

  // ── Passt ein Eintrag? ─── (Filter vorher mit [bereinigt] säubern) ───────

  /// Gruppen eines Bereichs, in denen ein Eintrag sein muss (eine genügt).
  List<FilterGruppe> _gewaehlteGruppen(
          FilterBereich b, WortschatzZugehoerigkeit z) =>
      [
        for (final id in werte(b)) ?z.gruppe(b, id),
      ];

  /// Prüffunktion für alte Wörter (drift).
  bool Function(WordModel) wortPruefer(WortschatzZugehoerigkeit z) {
    final buecherG = _gewaehlteGruppen(FilterBereich.buch, z);
    final katG = _gewaehlteGruppen(FilterBereich.kategorie, z);
    final niv = niveaus, art = wortarten;
    // Alte Wörter haben keine Einordnung (Regel 17) ⇒ bei einem dieser
    // Filter nie dabei.
    final mitEinordnung = _einordnungsBereiche.any((b) => werte(b).isNotEmpty);
    return (w) =>
        !mitEinordnung &&
        (niv.isEmpty || (w.level != null && niv.contains(w.level!.name))) &&
        (art.isEmpty || art.contains(w.wordType.name)) &&
        (buecherG.isEmpty || buecherG.any((g) => g.altWoerter.contains(w.id))) &&
        (katG.isEmpty || katG.any((g) => g.altWoerter.contains(w.id)));
  }

  /// Prüffunktion für Karten bzw. Index-Einträge (assets/vocab/). Wortart
  /// über dieselbe Tabelle wie die Paarung (altwortTypZuWortart). Mengen
  /// werden nur EINMAL gebaut (Zählen über ~26.000 Karten).
  bool Function(Map<String, dynamic>) kartenPruefer(
      [WortschatzZugehoerigkeit z = WortschatzZugehoerigkeit.leer]) {
    final erlaubt = {
      for (final t in wortarten) ...?altwortTypZuWortart[t],
    };
    final buchKarten = {
      for (final g in _gewaehlteGruppen(FilterBereich.buch, z)) ...g.karten,
    };
    final katKarten = {
      for (final g in _gewaehlteGruppen(FilterBereich.kategorie, z))
        ...g.karten,
    };
    final mitBuch = buecher.isNotEmpty, mitKat = kategorien.isNotEmpty;
    final niv = niveaus, mitArt = wortarten.isNotEmpty;
    final ber = berufe, ans = anstoessig, zeit = zeitlich;
    return (k) {
      if (niv.isNotEmpty &&
          !niv.contains((k['niveau'] as String? ?? '').toLowerCase())) {
        return false;
      }
      if (mitArt && !erlaubt.contains(k['wortart'])) return false;
      final id = k['id'] as String? ?? '';
      if (mitBuch && !buchKarten.contains(id)) return false;
      if (mitKat && !katKarten.contains(id)) return false;
      if (ber.isNotEmpty) {
        final kb = k['berufe'];
        if (kb is! List || !kb.any(ber.contains)) return false;
      }
      if (ans.isNotEmpty) {
        final a = k['anstoessig'];
        if (a is! Map || !ans.contains(a['stufe'])) return false;
      }
      if (zeit.isNotEmpty && !zeit.contains(k['zeitlich'])) return false;
      return true;
    };
  }

  bool wortPasst(WordModel w,
          [WortschatzZugehoerigkeit z = WortschatzZugehoerigkeit.leer]) =>
      wortPruefer(z)(w);

  bool kartePasst(Map<String, dynamic> k,
          [WortschatzZugehoerigkeit z = WortschatzZugehoerigkeit.leer]) =>
      kartenPruefer(z)(k);
}

/// Beide Quellen nach der Suche — einmal berechnen, oft filtern/zählen.
class WortschatzBasis {
  WortschatzBasis._(
      this.woerter, this.karten, this._altForm, this.query, this.zugehoerigkeit);

  /// Alte Wörter, die zur Suche passen (alle, wenn keine Suche).
  final List<WordModel> woerter;

  /// Karten, die zur Suche passen (vom Aufrufer, z. B. vokabSucheProvider).
  final List<Map<String, dynamic>> karten;

  /// Ids alter Wörter, deren gebeugte Form gesucht wurde.
  final Set<int> _altForm;

  /// Suche (klein, getrimmt; leer = keine).
  final String query;

  /// Bücher und eigene Kategorien (für die Drawer buch/kategorie).
  final WortschatzZugehoerigkeit zugehoerigkeit;

  bool altIstForm(WordModel w) => _altForm.contains(w.id);
}

/// [alleWoerter] = alle alten Wörter; [kartenTreffer] = Karten, die schon zur
/// Suche passen (ohne Suche: alle). Alte Wörter werden hier gesucht — über
/// Wort, FA/EN und gebeugte Formen («empfahl» ⇒ empfehlen, 2026-09-30).
WortschatzBasis wortschatzBasis({
  required List<WordModel> alleWoerter,
  required List<Map<String, dynamic>> kartenTreffer,
  required String query,
  WortschatzZugehoerigkeit zugehoerigkeit = WortschatzZugehoerigkeit.leer,
}) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) {
    return WortschatzBasis._(
        alleWoerter, kartenTreffer, const {}, '', zugehoerigkeit);
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
  return WortschatzBasis._(woerter, kartenTreffer, altForm, q, zugehoerigkeit);
}

/// Zeilen von «Alle Wörter»: gefiltert; ohne Suche alphabetisch (Artikel
/// zählt nicht), mit Suche nach Nähe (such_rang.dart, F.1). [formIds] = ids
/// der Karten, deren gebeugte Form gesucht wurde.
List<SuchTreffer<Object>> wortschatzZeilen(
  WortschatzBasis basis,
  WortschatzFilter filter, {
  Set<String> formIds = const {},
}) {
  final z = basis.zugehoerigkeit;
  final f = filter.bereinigt(z);
  final passt = f.kartenPruefer(z);
  final wortOk = f.wortPruefer(z);
  final eintraege = <Object>[
    for (final w in basis.woerter)
      if (wortOk(w)) w,
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
  final z = basis.zugehoerigkeit;
  final f = filter.bereinigt(z);
  final wortOk = f.wortPruefer(z);
  final passt = f.kartenPruefer(z);
  var n = 0;
  for (final w in basis.woerter) {
    if (wortOk(w)) n++;
  }
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
