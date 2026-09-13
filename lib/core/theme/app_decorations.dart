// FILE: lib/core/theme/app_decorations.dart
// PURPOSE: Design System — gemeinsame BoxDecoration-Patterns.
//          Screens dürfen KEINE eigenen Decoration-Styles definieren.
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

abstract final class AppDecorations {
  // ─── card ──────────────────────────────────────────────────────────────────

  static BoxDecoration card({
    required Color color,
    double         alpha  = 0.08,
    double         radius = AppSizes.radiusMd,
  }) => BoxDecoration(
        color       : color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration cardSolid({
    required Color color,
    double         radius = AppSizes.radiusMd,
    List<BoxShadow>? shadow,
  }) => BoxDecoration(
        color       : color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow   : shadow,
      );

  static BoxDecoration cardGradient({
    required Color  color,
    required bool   isDark,
    double          radius = AppSizes.radiusLg,
  }) => BoxDecoration(
        gradient: LinearGradient(
          begin : Alignment.topLeft,
          end   : Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.70 : 0.85),
            color.withValues(alpha: isDark ? 0.40 : 0.60),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color     : color.withValues(alpha: 0.28),
            blurRadius: 8,
            offset    : const Offset(0, 4),
          ),
        ],
      );

  // ─── chip / badge ──────────────────────────────────────────────────────────

  static BoxDecoration chip({
    required Color color,
    double         alpha  = 0.15,
    double         radius = 100,
  }) => BoxDecoration(
        color       : color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration chipOutline({
    required Color color,
    double         radius = 100,
  }) => BoxDecoration(
        border      : Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(radius),
      );

  // ─── header strip (4px color bar on the left side) ────────────────────────

  static BoxDecoration headerStrip({required Color color}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      );

  // ─── section header background ─────────────────────────────────────────────

  static BoxDecoration sectionHeader({required Color color}) =>
      BoxDecoration(color: color);

  // ─── icon circle ──────────────────────────────────────────────────────────

  static BoxDecoration iconCircle({
    required Color color,
    double         alpha = 0.15,
    double         size  = 40,
  }) => BoxDecoration(
        color       : color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(size / 2),
      );

  // ─── info banner ──────────────────────────────────────────────────────────

  static BoxDecoration infoBanner({required ColorScheme cs}) =>
      BoxDecoration(
        color       : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      );
}
