// FILE: lib/core/widgets/vox_chip.dart
// STATUS: [x] LIVE (B9 — 2026-07-04)
// PURPOSE: Design System — small semantic chips/dots used inside list cards.
//          CEFR badges themselves are VoxBadge.level (vox_badge.dart) — this
//          file adds the pieces VoxBadge doesn't cover.
import 'package:flutter/material.dart';

import '../constants/vox_colors.dart';

/// 8px register indicator dot (formal=blue, colloquial=green, informal=orange,
/// neutral=grey) — used in phrase/verb list cards.
class VoxRegisterDot extends StatelessWidget {
  const VoxRegisterDot({super.key, required this.register, this.size = 8});

  final String register;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width : size,
        height: size,
        decoration: BoxDecoration(
          color: VoxColors.register(register),
          shape: BoxShape.circle,
        ),
      );
}

/// Small rounded count pill (e.g. section phrase count in list headers).
class VoxCountPill extends StatelessWidget {
  const VoxCountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color       : cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize  : 11,
          fontWeight: FontWeight.w700,
          color     : cs.onPrimaryContainer,
        ),
      ),
    );
  }
}
