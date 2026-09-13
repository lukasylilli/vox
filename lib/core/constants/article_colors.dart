// FILE: lib/core/constants/article_colors.dart
// PURPOSE: German article colors — der=blue, die=red, das=green
import 'package:flutter/material.dart';

enum GermanArticle { der, die, das, none }

class ArticleColors {
  ArticleColors._();

  static const der  = Color(0xFF1E6FDB); // blue
  static const die  = Color(0xFFDB1E1E); // red
  static const das  = Color(0xFF1EDB6F); // green
  static const none = Color(0xFF888899); // grey

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
