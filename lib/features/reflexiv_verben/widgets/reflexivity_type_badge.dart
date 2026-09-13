// FILE: lib/features/reflexiv_verben/widgets/reflexivity_type_badge.dart
import 'package:flutter/material.dart';
import '../models/reflexiv_verb.dart';

class ReflexivityTypeBadge extends StatelessWidget {
  const ReflexivityTypeBadge(this.type, {super.key, this.small = false});

  final ReflexivityType type;
  final bool            small;

  static Color _color(ReflexivityType t) => switch (t) {
        ReflexivityType.echte          => const Color(0xFF558B2F),
        ReflexivityType.unechte        => const Color(0xFF1565C0),
        ReflexivityType.dativReflexive => const Color(0xFF6A1B9A),
      };

  @override
  Widget build(BuildContext context) {
    final c    = _color(type);
    final fs   = small ? 9.0 : 11.0;
    final px   = small ? 5.0 : 8.0;
    final py   = small ? 1.0 : 3.0;

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
