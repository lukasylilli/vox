// FILE: lib/core/constants/vox_colors.dart
// STATUS: [x] LIVE (B1 — 2026-07-04)
// PURPOSE: Unified color tokens — the single import point for every semantic
//          color in the app. Brand/section colors delegate to AppColors,
//          article colors to ArticleColors (no divergence). Screens use ONLY
//          VoxColors.* — never inline Color(0x...) switches.
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'article_colors.dart';

abstract final class VoxColors {
  // ── Brand / status (delegates — one source of truth) ──────────────────────
  static const primary     = AppColors.primary;
  static const primaryDark = AppColors.primaryDark;
  static const secondary   = AppColors.secondary;
  static const success     = AppColors.success;
  static const error       = AppColors.error;
  static const warning     = AppColors.warning;

  // ── CEFR level colors ──────────────────────────────────────────────────────
  static const cefrA1       = Color(0xFF1565C0); // blue
  static const cefrA2       = Color(0xFF0277BD); // light blue
  static const cefrB1       = Color(0xFF2E7D32); // green
  static const cefrB2       = Color(0xFF558B2F); // light green
  static const cefrC1       = Color(0xFF6A1B9A); // purple
  static const cefrC2       = Color(0xFF880E4F); // dark pink
  static const cefrFallback = Color(0xFF546E7A); // blue-grey

  static Color cefr(String level) => switch (level.toLowerCase()) {
        'a1' => cefrA1,
        'a2' => cefrA2,
        'b1' => cefrB1,
        'b2' => cefrB2,
        'c1' => cefrC1,
        'c2' => cefrC2,
        _    => cefrFallback,
      };

  // ── Article colors (delegates) ─────────────────────────────────────────────
  static const der = ArticleColors.der;
  static const die = ArticleColors.die;
  static const das = ArticleColors.das;

  static Color article(String? a) => ArticleColors.forString(a);

  // ── Register colors (formal / neutral / colloquial / informal) ────────────
  static const registerFormal     = Color(0xFF1565C0); // blue
  static const registerNeutral    = Color(0xFF455A64); // blue-grey
  static const registerColloquial = Color(0xFF2E7D32); // green
  static const registerInformal   = Color(0xFFE65100); // orange

  static Color register(String r) => switch (r.toLowerCase()) {
        'formal'     => registerFormal,
        'colloquial' => registerColloquial,
        'informal'   => registerInformal,
        _            => registerNeutral,
      };

  // ── Word type colors ───────────────────────────────────────────────────────
  static const typeNomen     = Color(0xFF1565C0);
  static const typeVerb      = Color(0xFF2E7D32);
  static const typeAdjektiv  = Color(0xFF6A1B9A);
  static const typeAdverb    = Color(0xFF00838F);
  static const typeKonnektor = Color(0xFFAD1457);
  static const typeFallback  = Color(0xFF455A64);

  static Color wordType(String t) => switch (t.toLowerCase()) {
        'nomen' || 'noun'          => typeNomen,
        'verb'                     => typeVerb,
        'adjektiv' || 'adjective'  => typeAdjektiv,
        'adverb'                   => typeAdverb,
        'konnektor' || 'connector' => typeKonnektor,
        _                          => typeFallback,
      };

  // ── Quiz feedback colors ───────────────────────────────────────────────────
  static const quizCorrect  = AppColors.success;
  static const quizWrong    = AppColors.error;
  static const quizSelected = AppColors.primary;
  static const quizNeutral  = Color(0xFF78909C);
}
