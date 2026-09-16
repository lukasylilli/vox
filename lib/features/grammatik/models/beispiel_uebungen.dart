// FILE: lib/features/grammatik/models/beispiel_uebungen.dart
// PHASE: فاز G → G7c (2026-09-16) · فاز LAUNCH → L.2e
// PURPOSE: Übungen aus den Beispielsätzen einer Lektion (je Lektion 6).
//          Lukas: „die Übungsarten ganz vielfältig und zufällig".
//
// Jeder Beispielsatz ergibt GENAU EINE Übung; ihre Art wird zufällig aus den
// Arten gezogen, die für diesen Satz ohne Raten richtig sind:
//   · bedeutung      Satz → Bedeutung wählen (4 Optionen, alle aus derselben
//                    Lektion)                         braucht ≥ 4 Beispiele
//   · satzWahl       Bedeutung → Satz wählen (4 Optionen)   ≥ 4 Beispiele
//   · richtigFalsch  passt die gezeigte Bedeutung?          ≥ 2 Beispiele
//   · matching       3 Sätze ↔ 3 Bedeutungen                 ≥ 3 Beispiele
//   · wordOrder      Satz legen, Anfang vorgegeben, Bedeutung als Hilfe —
//                    nur „einfache" Sätze (ein Satz, 4–10 Wörter, keine
//                    Pfeile/Klammern/Formeln)
//
// Warum der Satzanfang vorgegeben ist: Im Deutschen lässt sich das erste
// Satzglied oft tauschen („Heute gehe ich …" / „Ich gehe heute …"). Mit
// festem Anfang bleibt fast immer genau eine richtige Reihenfolge. Ganz
// ausschließen lässt es sich nicht — deshalb kommt diese Art nicht in den
// Niveau-Test (GrammatikUebung.testTauglich).
//
// Ablenker stammen nur aus derselben Lektion und müssen sich in DE, FA und
// EN vom richtigen Satz unterscheiden; sonst wird die Art für diesen Satz
// nicht angeboten. Nichts wird erfunden: alle Texte stehen so in der Quelle.
import 'dart:math';

import 'grammatik_lektion.dart';
import 'grammatik_uebung.dart';

abstract final class BeispielUebungen {
  /// Deutsche Aufträge (die Übersetzung kommt aus AppL10n über aufgabeKey).
  static const _auftrag = {
    UebungsArt.bedeutung: ('Was bedeutet der Satz?', 'bsp_bedeutung'),
    UebungsArt.satzWahl: ('Welcher Satz hat diese Bedeutung?', 'bsp_satzwahl'),
    UebungsArt.richtigFalsch: ('Stimmt die Bedeutung?', 'bsp_richtigfalsch'),
    UebungsArt.matching: ('Ordne jeden Satz seiner Bedeutung zu.', 'bsp_zuordnung'),
    UebungsArt.wordOrder: ('Bilde den Satz.', 'bsp_satzbau'),
  };

  /// Schlüssel der beiden Optionen bei richtigFalsch.
  static const richtig = 'richtig';
  static const falsch = 'falsch';

  /// Wie viele Übungen [erzeuge] für [lek] liefert (unabhängig vom Zufall:
  /// der Zufall wählt nur die Art, nicht ob es eine Übung gibt).
  static int anzahl(GrammatikLektion lek) => [
        for (var i = 0; i < lek.examples.length; i++)
          if (_moeglich(lek.examples, i).arten.isNotEmpty) i,
      ].length;

  /// Eine Übung je Beispielsatz, Art zufällig.
  static List<GrammatikUebung> erzeuge(GrammatikLektion lek, Random zufall) {
    final alle = lek.examples;
    final out = <GrammatikUebung>[];
    for (var i = 0; i < alle.length; i++) {
      final (:arten, :andere) = _moeglich(alle, i);
      if (arten.isEmpty) continue;
      final art = arten[zufall.nextInt(arten.length)];
      out.add(_baue(lek.slug, i, alle[i], art, andere, zufall));
    }
    return out;
  }

  /// Welche Arten für Beispiel [i] ohne Raten richtig sind, und mit welchen
  /// anderen Beispielen der Lektion es sich verwechslungsfrei mischen lässt.
  static ({List<UebungsArt> arten, List<GrammatikExample> andere}) _moeglich(
      List<GrammatikExample> alle, int i) {
    final b = alle[i];
    final andere = [
      for (var k = 0; k < alle.length; k++)
        if (k != i && _unterscheidbar(b, alle[k])) alle[k],
    ];
    return (
      arten: [
        if (andere.isNotEmpty) UebungsArt.richtigFalsch,
        if (_paarweiseVerschieden(andere).length >= 3)
          ...[UebungsArt.bedeutung, UebungsArt.satzWahl],
        if (_paarweiseVerschieden(andere).length >= 2) UebungsArt.matching,
        if (_voll(b) && istEinfach(b.german)) UebungsArt.wordOrder,
      ],
      andere: andere,
    );
  }

  /// „Einfacher" Satz für den Satzbau: ein Satz, 4–10 Wörter, keine
  /// Pfeile, Formeln, Klammern, Doppelpunkte, Gedankenstriche oder Zitate.
  static bool istEinfach(String satz) {
    if (RegExp(r'[→+()\[\];:–—/"„“«»]').hasMatch(satz)) return false;
    if (RegExp(r'[.!?]\s+\S').hasMatch(satz.trim())) return false;
    if (RegExp(r'\s-\s').hasMatch(satz)) return false;
    final n = GrammatikUebung.satzWoerter(satz).length;
    return n >= 4 && n <= 10;
  }

  // ── intern ──────────────────────────────────────────────────────────────

  static GrammatikUebung _baue(
    String slug,
    int index,
    GrammatikExample b,
    UebungsArt art,
    List<GrammatikExample> andere,
    Random zufall,
  ) {
    final (de, key) = _auftrag[art]!;
    GrammatikUebung mit({
      String satz = '',
      List<String> optionen = const [],
      List<String> optionenFa = const [],
      List<String> optionenEn = const [],
      String loesung = '',
      List<String> woerter = const [],
      String vorgabe = '',
      String bedeutungFa = '',
      String bedeutungEn = '',
      List<UebungsPaar> paare = const [],
      List<String> rechteReihenfolge = const [],
    }) =>
        GrammatikUebung(
          id: 'bsp-${index + 1}-${art.name}',
          lektionSlug: slug,
          art: art,
          aufgabeDe: de,
          aufgabeFa: '',
          aufgabeEn: '',
          aufgabeKey: key,
          erklaerungDe: b.noteDe ?? '',
          erklaerungFa: b.noteFa ?? '',
          erklaerungEn: b.noteEn ?? '',
          ausBeispiel: true,
          beispielDe: b.german,
          beispielFa: b.meaningFa,
          beispielEn: b.meaningEn,
          satz: satz,
          optionen: optionen,
          optionenFa: optionenFa,
          optionenEn: optionenEn,
          loesung: loesung,
          woerter: woerter,
          vorgabe: vorgabe,
          bedeutungFa: bedeutungFa,
          bedeutungEn: bedeutungEn,
          paare: paare,
          rechteReihenfolge: rechteReihenfolge,
        );

    List<GrammatikExample> ziehe(List<GrammatikExample> aus, int n) =>
        (List<GrammatikExample>.of(aus)..shuffle(zufall)).take(n).toList();

    switch (art) {
      case UebungsArt.bedeutung:
      case UebungsArt.satzWahl:
        final optionen = [b, ...ziehe(_paarweiseVerschieden(andere), 3)]
          ..shuffle(zufall);
        return mit(
          satz: b.german,
          optionen: [for (final o in optionen) o.german],
          optionenFa: art == UebungsArt.bedeutung
              ? [for (final o in optionen) o.meaningFa]
              : const [],
          optionenEn: art == UebungsArt.bedeutung
              ? [for (final o in optionen) o.meaningEn]
              : const [],
          loesung: b.german,
        );
      case UebungsArt.richtigFalsch:
        final stimmt = zufall.nextBool();
        final gezeigt = stimmt ? b : ziehe(andere, 1).first;
        return mit(
          satz: b.german,
          optionen: const [richtig, falsch],
          loesung: stimmt ? richtig : falsch,
          bedeutungFa: gezeigt.meaningFa,
          bedeutungEn: gezeigt.meaningEn,
        );
      case UebungsArt.matching:
        final drei = [b, ...ziehe(_paarweiseVerschieden(andere), 2)]
          ..shuffle(zufall);
        final paare = [
          for (final x in drei)
            UebungsPaar(
              links: x.german,
              rechts: x.german,
              rechtsFa: x.meaningFa,
              rechtsEn: x.meaningEn,
            ),
        ];
        // Rechte Seite in eigener Reihenfolge — nie dieselbe wie links.
        var rechts = [for (final p in paare) p.rechts];
        for (var v = 0; v < 10 && _gleich(rechts, paare); v++) {
          rechts = List.of(rechts)..shuffle(zufall);
        }
        if (_gleich(rechts, paare)) rechts = [...rechts.skip(1), rechts.first];
        return mit(paare: paare, rechteReihenfolge: rechts);
      case UebungsArt.wordOrder:
        final woerter = GrammatikUebung.satzWoerter(b.german);
        final vorgabe = woerter.first;
        final rest = woerter.sublist(1);
        var gemischt = List.of(rest);
        for (var v = 0; v < 10 && _gleicheListe(gemischt, rest); v++) {
          gemischt = List.of(rest)..shuffle(zufall);
        }
        if (_gleicheListe(gemischt, rest)) {
          gemischt = [...rest.skip(1), rest.first];
        }
        return mit(
          loesung: b.german,
          vorgabe: vorgabe,
          woerter: gemischt,
        );
      case UebungsArt.multipleChoice:
      case UebungsArt.fillBlank:
      case UebungsArt.transform:
        throw ArgumentError('keine Beispiel-Übung: $art');
    }
  }

  static bool _gleich(List<String> rechts, List<UebungsPaar> paare) {
    for (var i = 0; i < paare.length; i++) {
      if (rechts[i] != paare[i].rechts) return false;
    }
    return true;
  }

  static bool _gleicheListe(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].toLowerCase() != b[i].toLowerCase()) return false;
    }
    return true;
  }

  /// Zwei Beispiele sind unterscheidbar, wenn sie sich in DE, FA UND EN
  /// unterscheiden und alle drei Texte haben.
  static bool _unterscheidbar(GrammatikExample a, GrammatikExample b) =>
      _voll(a) &&
      _voll(b) &&
      a.german.trim() != b.german.trim() &&
      a.meaningFa.trim() != b.meaningFa.trim() &&
      a.meaningEn.trim() != b.meaningEn.trim();

  static bool _voll(GrammatikExample e) =>
      e.german.trim().isNotEmpty &&
      e.meaningFa.trim().isNotEmpty &&
      e.meaningEn.trim().isNotEmpty;

  /// Beispiele, die untereinander paarweise unterscheidbar sind (gierig).
  static List<GrammatikExample> _paarweiseVerschieden(
      List<GrammatikExample> liste) {
    final out = <GrammatikExample>[];
    for (final e in liste) {
      if (out.every((o) => _unterscheidbar(o, e))) out.add(e);
    }
    return out;
  }
}
