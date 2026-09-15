// FILE: lib/core/constants/article_colors.dart
// PURPOSE: Artikelfarben — EINE Quelle: GrammatikonSpec.
//
// ⚠️ B-9, entschieden 2026-09-15: Bis dahin gab es zwei widersprüchliche
//    Farbsysteme. Hier war der=blau, die=rot, das=grün; im Grammatikon
//    maskulin=grün, feminin=orange, neutral=lila, plural=rot. Grün bedeutete
//    in der einen Ansicht „das", in der anderen „der"; Rot einmal „die",
//    einmal Plural. Für Lernende, die sich Farben einprägen, sind das zwei
//    einander widersprechende Systeme.
//    Gewonnen hat das Grammatikon-System, weil es zusätzlich Form = Kasus
//    trägt und eine eigene Pluralfarbe kennt. Diese Datei hält nur noch die
//    Zuordnung Artikel → Genus und reicht die Farbe durch (Puzzling: keine
//    zweite Farbtabelle). Farbe ändern = ausschließlich grammatikon_spec.dart.
import 'package:flutter/material.dart';

import '../grammatikon/grammatikon_spec.dart';

enum GermanArticle { der, die, das, none }

class ArticleColors {
  ArticleColors._();

  static const der  = GrammatikonSpec.maskulin; // grün
  static const die  = GrammatikonSpec.feminin;  // orange
  static const das  = GrammatikonSpec.neutral;  // lila
  static const none = GrammatikonSpec.verb;     // grau

  /// Plural hat im Grammatikon eine eigene Farbe — hier mitgeführt, damit
  /// Listen sie nutzen können, ohne GrammatikonSpec direkt zu importieren.
  static const plural = GrammatikonSpec.plural; // rot

  static Color forArticle(GermanArticle article) => switch (article) {
    GermanArticle.der  => der,
    GermanArticle.die  => die,
    GermanArticle.das  => das,
    GermanArticle.none => none,
  };

  static Color forString(String? article) => switch (article?.toLowerCase()) {
    'der' => der,
    'die' => die,
    'das' => das,
    _     => none,
  };

  static GermanArticle fromString(String? article) => switch (article?.toLowerCase()) {
    'der' => GermanArticle.der,
    'die' => GermanArticle.die,
    'das' => GermanArticle.das,
    _     => GermanArticle.none,
  };
}
