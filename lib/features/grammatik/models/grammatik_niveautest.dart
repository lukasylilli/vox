// FILE: lib/features/grammatik/models/grammatik_niveautest.dart
// PHASE: فاز G → G7b (2026-09-16) · فاز LAUNCH → L.2e
// PURPOSE: Kombinierter Niveau-Test A1–C2 — Einstellungen + Auswahl der
//          Fragen. Einstellungen aus assets/data/grammatik_niveautest.json
//          (unverändert aus `old files Lukasalmani/1/Grammatik`, das dort als
//          „einzige Quelle der Einstellungen für den Niveau-Test" bezeichnete
//          Dokument): 10 Fragen je Niveau, bestanden ab 70 %.
//
// Fragen: zufällig aus den Übungen aller Lektionen, deren `levels` das
// Niveau enthalten. Bewusst OHNE `transform`: Dort wird frei getippt und
// streng verglichen — eine andere richtige Formulierung würde als falsch
// zählen. Im Üben ist das tragbar (Lösung wird gezeigt), in einem Test mit
// Bestehensgrenze nicht.
// Hat ein Niveau weniger Übungen als 10 (C2: nur 3), besteht der Test aus
// allen vorhandenen — nichts wird aufgefüllt oder erfunden.
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'grammatik_lektion.dart';
import 'grammatik_uebung.dart';

@immutable
class GrammatikNiveauTest {
  const GrammatikNiveauTest({
    required this.fragenProNiveau,
    required this.bestehensQuote,
    required this.niveaus,
  });

  /// Liest `{"config": {...}}`. Unbrauchbare Einstellungen ⇒ `null`
  /// (dann gibt es keinen Test statt eines falschen).
  static GrammatikNiveauTest? ausJson(Map<String, dynamic> j) {
    final c = j['config'];
    if (c is! Map<String, dynamic>) return null;
    final n = c['questionsPerLevel'];
    final q = c['passThreshold'];
    final l = c['levels'];
    if (n is! int || n < 1) return null;
    if (q is! num || q <= 0 || q > 1) return null;
    if (l is! List || l.isEmpty || l.any((x) => x is! String)) return null;
    return GrammatikNiveauTest(
      fragenProNiveau: n,
      bestehensQuote: q.toDouble(),
      niveaus: [for (final x in l.cast<String>()) x.toUpperCase()],
    );
  }

  final int fragenProNiveau;
  final double bestehensQuote;

  /// Großgeschrieben, z. B. `A1`.
  final List<String> niveaus;

  /// Übungsarten, die im Test vorkommen (siehe Kopf: ohne transform).
  static const testArten = {
    UebungsArt.multipleChoice,
    UebungsArt.fillBlank,
    UebungsArt.wordOrder,
    UebungsArt.matching,
  };

  bool kennt(String niveau) => niveaus.contains(niveau.toUpperCase());

  /// Bestehensgrenze in ganzen Prozent (für die Anzeige).
  int get quoteProzent => (bestehensQuote * 100).round();

  /// Alle Übungen, aus denen für [niveau] gezogen wird — in fester
  /// Reihenfolge (Lektion nach slug, darin Quell-Reihenfolge).
  List<GrammatikUebung> vorrat(
    String niveau,
    Map<String, GrammatikLektion> lektionen,
    Map<String, List<GrammatikUebung>> uebungen,
  ) {
    final n = niveau.toUpperCase();
    if (!kennt(n)) return const [];
    final slugs = [
      for (final l in lektionen.values)
        if (l.levels.map((x) => x.toUpperCase()).contains(n)) l.slug,
    ]..sort();
    return [
      for (final s in slugs)
        for (final u in uebungen[s] ?? const <GrammatikUebung>[])
          if (testArten.contains(u.art)) u,
    ];
  }

  /// Fragen eines Durchgangs aus [vorrat]: höchstens [fragenProNiveau],
  /// jede nur einmal, zufällig.
  List<GrammatikUebung> ziehe(List<GrammatikUebung> vorrat, Random zufall) {
    final alle = List<GrammatikUebung>.of(vorrat)..shuffle(zufall);
    return alle.take(fragenProNiveau).toList();
  }
}
