// FILE: lib/features/unregelm_verben/widgets/verb_class_badge.dart
import 'package:flutter/material.dart';

import '../models/unregelm_verb.dart';
import '../../../core/widgets/deutsch_text.dart';

class VerbClassBadge extends StatelessWidget {
  const VerbClassBadge(this.verbClass, {super.key, this.small = false});
  final VerbClass verbClass;
  final bool      small;

  static Color _color(VerbClass c) => switch (c) {
        VerbClass.stark     => const Color(0xFF1565C0),
        VerbClass.gemischt  => const Color(0xFFE65100),
        VerbClass.modal     => const Color(0xFF2E7D32),
        VerbClass.irregular => const Color(0xFF6A1B9A),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(verbClass);
    final fs    = small ? 9.0 : 10.0;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 5 : 7, vertical: small ? 1 : 3),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: DeutschText(
        verbClass.labelDe,
        ganzeZeile: false, // Abzeichen
        style: TextStyle(
          fontSize  : fs,
          color     : color,
          fontWeight: FontWeight.w700,
          height    : 1.2,
        ),
      ),
    );
  }
}

class AuxiliaryBadge extends StatelessWidget {
  const AuxiliaryBadge(this.aux, {super.key, this.small = false});
  final PerfektAuxiliary aux;
  final bool             small;

  static Color _color(PerfektAuxiliary a) => switch (a) {
        PerfektAuxiliary.haben => const Color(0xFF00695C),
        PerfektAuxiliary.sein  => const Color(0xFFC62828),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(aux);
    final fs    = small ? 9.0 : 10.0;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 5 : 7, vertical: small ? 1 : 3),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        aux.label,
        style: TextStyle(
          fontSize  : fs,
          color     : color,
          fontWeight: FontWeight.w700,
          height    : 1.2,
        ),
      ),
    );
  }
}
