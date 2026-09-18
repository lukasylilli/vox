// FILE: lib/features/grammatik/models/grammatik_uebung.dart
// PHASE: فاز G → G7a (2026-09-16) · فاز LAUNCH → L.2e
// PURPOSE: Die Übungen der Grammatik-Lektionen (`exercises` in
//          assets/data/grammatik/<thema>.json) als Modell + die EINE Stelle,
//          die entscheidet, ob eine Antwort richtig ist.
//
// Fünf Arten, genau wie in der Quelle: multipleChoice · fillBlank ·
// wordOrder · transform · matching.
//
// Befunde aus der Quelle (die Daten bleiben unverändert, die Regeln hier
// fangen sie auf — PLAN.md → G7a):
//   · fillBlank: `alternatives` sind immer FALSCHE Wahlmöglichkeiten
//     (82/82, keine ist gleich der Lösung) ⇒ fillBlank = Auswahl aus
//     Lösung + alternatives.
//   · wordOrder: vier Übungen haben ein überzähliges Kärtchen (z. B. „am" in
//     ex-interr-4) oder „Wir" großgeschrieben mitten im Satz ⇒ nicht benutzte
//     Kärtchen sind erlaubt; verglichen wird ohne Groß-/Kleinschreibung und
//     ohne Satzzeichen.
//   · matching: sieben Übungen haben dieselbe rechte Seite mehrfach
//     (z. B. „Dativ" ×4) ⇒ zu jedem linken Eintrag wird aus den
//     VERSCHIEDENEN rechten Werten gewählt; richtig ist der Wert, nicht die
//     Position.
//   · ids: `ex-komp-1…4` kommen in zwei Lektionen vor ⇒ eindeutig ist nur
//     [GrammatikUebung.schluessel] (Lektion + id).
//
// G7c (2026-09-16): Übungen aus den Beispielsätzen der Lektionen entstehen in
// beispiel_uebungen.dart und benutzen DIESES Modell ([ausBeispiel] = true),
// mit drei zusätzlichen Arten (bedeutung · satzWahl · richtigFalsch), die es
// in der Quelle nicht gibt.
import 'package:flutter/foundation.dart';

/// Art einer Übung. Die ersten fünf sind die `type`-Werte der Quelle; die
/// letzten drei gibt es nur bei Übungen aus Beispielsätzen (G7c).
enum UebungsArt {
  multipleChoice,
  fillBlank,
  wordOrder,
  transform,
  matching,

  /// Deutscher Satz → richtige Bedeutung wählen (Optionen übersetzt).
  bedeutung,

  /// Bedeutung → richtigen deutschen Satz wählen.
  satzWahl,

  /// Passt die gezeigte Bedeutung zum Satz? (Optionen: richtig/falsch)
  richtigFalsch,
}

/// Arten, die in der Quelle vorkommen dürfen.
const _quellArten = {
  UebungsArt.multipleChoice,
  UebungsArt.fillBlank,
  UebungsArt.wordOrder,
  UebungsArt.transform,
  UebungsArt.matching,
};

UebungsArt? _artAus(String? s) {
  for (final a in _quellArten) {
    if (a.name == s) return a;
  }
  return null;
}

/// Ein Paar einer Zuordnungsübung. [rechtsFa]/[rechtsEn]: übersetzte
/// Anzeige des rechten Werts (G7c: Satz ↔ Bedeutung); leer ⇒ [rechts] zeigen.
@immutable
class UebungsPaar {
  const UebungsPaar({
    required this.links,
    required this.rechts,
    this.rechtsFa = '',
    this.rechtsEn = '',
  });
  final String links, rechts, rechtsFa, rechtsEn;
  bool get rechtsUebersetzt => rechtsFa.isNotEmpty || rechtsEn.isNotEmpty;
}

@immutable
class GrammatikUebung {
  const GrammatikUebung({
    required this.id,
    required this.lektionSlug,
    required this.art,
    required this.aufgabeDe,
    required this.aufgabeFa,
    required this.aufgabeEn,
    required this.erklaerungDe,
    required this.erklaerungFa,
    required this.erklaerungEn,
    this.satz = '',
    this.optionen = const [],
    this.loesung = '',
    this.woerter = const [],
    this.anweisungDe = '',
    this.anweisungFa = '',
    this.anweisungEn = '',
    this.paare = const [],
    this.ausBeispiel = false,
    this.aufgabeKey,
    this.vorgabe = '',
    this.optionenFa = const [],
    this.optionenEn = const [],
    this.bedeutungFa = '',
    this.bedeutungEn = '',
    this.beispielDe = '',
    this.beispielFa = '',
    this.beispielEn = '',
    this.rechteReihenfolge = const [],
  });

  /// Liest eine Übung der Quelle. Unvollständige oder unbekannte Übungen
  /// ergeben `null` — sie werden nie halb gezeigt (lieber keine Übung als
  /// eine falsche). test/grammatik_uebungen_test.dart stellt sicher, dass
  /// das bei den echten Daten für KEINE Übung passiert.
  static GrammatikUebung? ausJson(Map<String, dynamic> j) {
    final p = j['payload'];
    if (p is! Map<String, dynamic>) return null;
    final art = _artAus(j['type'] as String?);
    final id = j['id'] as String? ?? '';
    final slug = j['lessonSlug'] as String? ?? '';
    if (art == null || id.isEmpty || slug.isEmpty) return null;
    if (p['type'] != j['type']) return null;

    List<String> texte(Object? o) =>
        o is List ? o.whereType<String>().toList() : const <String>[];
    String text(Object? o) => o is String ? o : '';

    final basis = GrammatikUebung(
      id: id,
      lektionSlug: slug,
      art: art,
      aufgabeDe: text(j['promptDE']),
      aufgabeFa: text(j['promptFA']),
      aufgabeEn: text(j['promptEN']),
      erklaerungDe: text(j['explanationAfterAnswerDE']),
      erklaerungFa: text(j['explanationAfterAnswerFA']),
      erklaerungEn: text(j['explanationAfterAnswerEN']),
    );

    switch (art) {
      case UebungsArt.multipleChoice:
        final optionen = texte(p['options']);
        final i = p['correctIndex'];
        if (optionen.length < 2 ||
            i is! int ||
            i < 0 ||
            i >= optionen.length ||
            optionen.toSet().length != optionen.length) {
          return null;
        }
        // Frage steht in der Quelle in promptDE (z. B. „Sie ___ jeden Tag").
        return basis._mit(
            satz: basis.aufgabeDe, optionen: optionen, loesung: optionen[i]);
      case UebungsArt.fillBlank:
        final satz = text(p['sentenceWithBlank']);
        final loesung = text(p['correctAnswer']);
        final falsche = texte(p['alternatives']);
        final optionen = [loesung, ...falsche];
        if (!satz.contains('___') ||
            loesung.isEmpty ||
            falsche.isEmpty ||
            optionen.toSet().length != optionen.length) {
          return null;
        }
        return basis._mit(satz: satz, optionen: optionen, loesung: loesung);
      case UebungsArt.wordOrder:
        final woerter = texte(p['shuffledWords']);
        final loesung = text(p['correctSentence']);
        if (woerter.length < 2 || loesung.isEmpty) return null;
        // Jedes Wort der Lösung muss als Kärtchen vorhanden sein — sonst
        // wäre die Übung unlösbar.
        if (!_reichtFuer(woerter, satzWoerter(loesung))) return null;
        return basis._mit(woerter: woerter, loesung: loesung);
      case UebungsArt.transform:
        final satz = text(p['sourceSentence']);
        final loesung = text(p['correctAnswer']);
        if (satz.isEmpty || loesung.isEmpty) return null;
        return basis._mit(
          satz: satz,
          loesung: loesung,
          anweisungDe: text(p['instructionDE']),
          anweisungFa: text(p['instructionFA']),
          anweisungEn: text(p['instructionEN']),
        );
      case UebungsArt.matching:
        final roh = p['pairs'];
        if (roh is! List) return null;
        final paare = <UebungsPaar>[];
        for (final e in roh) {
          if (e is! Map) return null;
          final l = e['left'], r = e['right'];
          if (l is! String || r is! String || l.isEmpty || r.isEmpty) {
            return null;
          }
          paare.add(UebungsPaar(links: l, rechts: r));
        }
        if (paare.length < 2 ||
            paare.map((x) => x.links).toSet().length != paare.length) {
          return null;
        }
        return basis._mit(paare: paare);
      // Nur aus Beispielsätzen (beispiel_uebungen.dart), nie aus der Quelle.
      case UebungsArt.bedeutung:
      case UebungsArt.satzWahl:
      case UebungsArt.richtigFalsch:
        return null;
    }
  }

  GrammatikUebung _mit({
    String satz = '',
    List<String> optionen = const [],
    String loesung = '',
    List<String> woerter = const [],
    String anweisungDe = '',
    String anweisungFa = '',
    String anweisungEn = '',
    List<UebungsPaar> paare = const [],
  }) =>
      GrammatikUebung(
        id: id,
        lektionSlug: lektionSlug,
        art: art,
        aufgabeDe: aufgabeDe,
        aufgabeFa: aufgabeFa,
        aufgabeEn: aufgabeEn,
        erklaerungDe: erklaerungDe,
        erklaerungFa: erklaerungFa,
        erklaerungEn: erklaerungEn,
        satz: satz,
        optionen: optionen,
        loesung: loesung,
        woerter: woerter,
        anweisungDe: anweisungDe,
        anweisungFa: anweisungFa,
        anweisungEn: anweisungEn,
        paare: paare,
      );

  final String id, lektionSlug;
  final UebungsArt art;

  /// Eindeutig über ALLE Lektionen. Die `id` allein ist es nicht: Die Quelle
  /// vergibt `ex-komp-1…4` zweimal (adjektive.json → komparativ-superlativ
  /// und nomen.json → komposita). Die Daten bleiben unverändert; eindeutig
  /// ist erst Lektion + id.
  String get schluessel => '$lektionSlug/$id';

  /// Arbeitsauftrag (bei multipleChoice zugleich der Satz mit Lücke).
  final String aufgabeDe, aufgabeFa, aufgabeEn;

  /// Erklärung, die nach dem Prüfen gezeigt wird.
  final String erklaerungDe, erklaerungFa, erklaerungEn;

  /// multipleChoice/fillBlank: Satz mit `___` · transform: Ausgangssatz.
  final String satz;

  /// multipleChoice/fillBlank: Wahlmöglichkeiten in QUELL-Reihenfolge
  /// (fillBlank: Lösung zuerst — die Anzeige mischt sie).
  final List<String> optionen;

  /// Die richtige Antwort (Option, Satz oder umgeformter Satz).
  final String loesung;

  /// wordOrder: Kärtchen.
  final List<String> woerter;

  /// transform: was umgeformt werden soll.
  final String anweisungDe, anweisungFa, anweisungEn;

  /// matching: Paare in Quell-Reihenfolge.
  final List<UebungsPaar> paare;

  // ── G7c: Übungen aus Beispielsätzen ─────────────────────────────────────

  /// Aus einem Beispielsatz erzeugt (nicht aus der Quell-Übungsliste).
  final bool ausBeispiel;

  /// AppL10n-Schlüssel des Auftrags (statt [aufgabeFa]/[aufgabeEn]).
  final String? aufgabeKey;

  /// wordOrder: fest vorgegebener Satzanfang (nicht verschiebbar).
  final String vorgabe;

  /// bedeutung: übersetzte Anzeige zu [optionen] (gleiche Länge).
  final List<String> optionenFa, optionenEn;

  /// richtigFalsch: die gezeigte (evtl. falsche) Bedeutung.
  final String bedeutungFa, bedeutungEn;

  /// Der Beispielsatz, aus dem die Übung stammt, mit seiner Bedeutung —
  /// wird nach dem Prüfen gezeigt.
  final String beispielDe, beispielFa, beispielEn;

  /// matching: Anzeige-Reihenfolge der rechten Werte (leer ⇒ sortiert).
  final List<String> rechteReihenfolge;

  /// matching: die verschiedenen rechten Werte (Anzeige-Auswahl).
  List<String> get rechteWerte => rechteReihenfolge.isNotEmpty
      ? rechteReihenfolge
      : (paare.map((p) => p.rechts).toSet().toList()..sort());

  /// Darf in den Niveau-Test (G7b): nur Arten ohne jede Chance, eine richtige
  /// Antwort als falsch zu werten — also ohne frei getippte Umformung und
  /// ohne Satzbau aus Beispielsätzen (dort kann es eine zweite richtige
  /// Wortstellung geben; die Quell-Übungen sind dafür gebaut).
  bool get testTauglich =>
      art != UebungsArt.transform &&
      !(ausBeispiel && art == UebungsArt.wordOrder);

  bool get hatErklaerung => erklaerungDe.trim().isNotEmpty;

  // ── Prüfen ──────────────────────────────────────────────────────────────

  /// multipleChoice / fillBlank: gewählte Option.
  bool pruefeWahl(String gewaehlt) => gewaehlt == loesung;

  /// wordOrder: gelegte Kärtchen in Reihenfolge (ohne [vorgabe]).
  bool pruefeReihenfolge(List<String> gelegt) =>
      _gleicheWorte([...satzWoerter(vorgabe), ...gelegt], satzWoerter(loesung));

  /// transform: frei getippter Satz. Streng bis auf Leerzeichen, typografische
  /// Anführungszeichen/Apostrophe und das Satzzeichen am Ende — Groß- und
  /// Kleinschreibung zählt (im Deutschen bedeutungstragend).
  bool pruefeUmformung(String getippt) =>
      normalisiereSatz(getippt) == normalisiereSatz(loesung);

  /// matching: gewählter rechter Wert je linkem Eintrag.
  bool pruefeZuordnung(Map<String, String> gewaehlt) => paare.every(
      (p) => gewaehlt[p.links] == p.rechts);

  // ── Hilfen (öffentlich für Tests) ───────────────────────────────────────

  /// Wörter eines Satzes ohne Satzzeichen.
  static List<String> satzWoerter(String satz) => satz
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(_satzzeichen, ''))
      .where((w) => w.isNotEmpty)
      .toList();

  static final _satzzeichen = RegExp(r'[.,!?;:„“”"«»()]');

  static String normalisiereSatz(String s) {
    var t = s
        .replaceAll(RegExp('[„“”«»]'), '"')
        .replaceAll(RegExp('[‘’‚]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    t = t.replaceAllMapped(RegExp(r'\s+([.,!?;:])'), (m) => m[1]!);
    return t.replaceAll(RegExp(r'[.!?]+$'), '').trim();
  }

  static bool _gleicheWorte(List<String> a, List<String> b) {
    final x = a
        .map((w) => w.replaceAll(_satzzeichen, '').toLowerCase())
        .where((w) => w.isNotEmpty)
        .toList();
    final y = b.map((w) => w.toLowerCase()).toList();
    return listEquals(x, y);
  }

  /// Sind in [vorrat] (ohne Groß-/Kleinschreibung) alle [benoetigt] enthalten?
  static bool _reichtFuer(List<String> vorrat, List<String> benoetigt) {
    final rest = <String, int>{};
    for (final w in vorrat) {
      final k = w.replaceAll(_satzzeichen, '').toLowerCase();
      rest[k] = (rest[k] ?? 0) + 1;
    }
    for (final w in benoetigt) {
      final k = w.toLowerCase();
      final n = rest[k] ?? 0;
      if (n == 0) return false;
      rest[k] = n - 1;
    }
    return true;
  }
}
