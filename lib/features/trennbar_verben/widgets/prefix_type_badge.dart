// FILE: lib/features/trennbar_verben/widgets/prefix_type_badge.dart
import 'package:flutter/material.dart';
import '../models/trennbar_verb.dart';

class PrefixTypeBadge extends StatelessWidget {
  const PrefixTypeBadge(this.type, {super.key, this.small = false});

  final PrefixType type;
  final bool       small;

  static Color _color(PrefixType t) => switch (t) {
        PrefixType.trennbar       => const Color(0xFF0277BD),
        PrefixType.untrennbar     => const Color(0xFF2E7D32),
        PrefixType.wechselpraefix => const Color(0xFFBF360C),
      };

  @override
  Widget build(BuildContext context) {
    final c  = _color(type);
    final fs = small ? 9.0 : 11.0;
    final px = small ? 5.0 : 8.0;
    final py = small ? 1.0 : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color       : c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border      : Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(
        type.shortLabel,
        style: TextStyle(
          fontSize  : fs,
          color     : c,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
