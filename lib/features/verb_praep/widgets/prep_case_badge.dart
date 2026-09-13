// FILE: lib/features/verb_praep/widgets/prep_case_badge.dart
// PURPOSE: Small chip badge showing preposition case (Akkusativ/Dativ)
import 'package:flutter/material.dart';

import '../models/verb_praep.dart';
import '../../../core/l10n/app_l10n.dart';

class PrepCaseBadge extends StatelessWidget {
  const PrepCaseBadge(this.prepCase, {super.key});
  final PrepositionCase prepCase;

  static Color _color(PrepositionCase c) => switch (c) {
        PrepositionCase.akkusativ => const Color(0xFF1565C0),
        PrepositionCase.dativ     => const Color(0xFF2E7D32),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(prepCase);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        AppL10n.t(context, prepCase.labelFa),
        style: TextStyle(
          fontSize  : 11,
          fontWeight: FontWeight.w700,
          color     : color,
        ),
      ),
    );
  }
}
