// FILE: lib/features/konnektoren/widgets/connector_type_badge.dart
import 'package:flutter/material.dart';

import '../models/konnektor.dart';
import '../../../core/widgets/deutsch_text.dart';

class ConnectorTypeBadge extends StatelessWidget {
  const ConnectorTypeBadge(this.connectorType, {super.key, this.small = false});

  final ConnectorType connectorType;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color   = Konnektor.colorFor(connectorType, context);
    final fSize   = small ? 9.0 : 11.0;
    final padH    = small ? 5.0 : 8.0;
    final padV    = small ? 2.0 : 4.0;
    final radius  = small ? 4.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: DeutschText(
        connectorType.labelDe,
        ganzeZeile: false, // Abzeichen
        style: TextStyle(
          fontSize  : fSize,
          color     : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
