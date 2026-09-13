// FILE: lib/features/dativ_verben/widgets/case_type_badge.dart
import 'package:flutter/material.dart';
import '../models/dativ_verb.dart';

class CaseTypeBadge extends StatelessWidget {
  const CaseTypeBadge(this.caseType, {super.key, this.small = false});

  final CaseType caseType;
  final bool     small;

  static Color colorFor(CaseType ct, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (ct) {
      CaseType.datumOnly                 => isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0),
      CaseType.dativAkkusativ            => isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A),
      CaseType.akkusativOnlyConfusable   => isDark ? const Color(0xFFFF8A65) : const Color(0xFFBF360C),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color   = colorFor(caseType, context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgAlpha = isDark ? 0.25 : 0.12;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6  : 8,
        vertical  : small ? 2  : 4,
      ),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(small ? 4 : 6),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        caseType.labelDe,
        style: TextStyle(
          color     : color,
          fontSize  : small ? 10 : 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
