// FILE: lib/core/widgets/vox_progress.dart
// STATUS: [x] LIVE (B9 — 2026-07-04) — VoxQuizProgressBar + VoxStepDots
//          (VoxCompletionRing / VoxLeitnerBoxBar / VoxStreakCounter follow
//           when their screens are refactored)
// PURPOSE: Design System — progress indicators. Every quiz screen shows its
//          progress through VoxQuizProgressBar (AppBar title + bottom bar).
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// AppBar helper for quiz screens:
///   AppBar(
///     title : VoxQuizProgressBar.title(current: i + 1, total: n),
///     bottom: VoxQuizProgressBar.bar(current: i + 1, total: n),
///   )
abstract final class VoxQuizProgressBar {
  /// '۳ / ۱۰' title text (Persian digits, centralized).
  static Widget title({required int current, required int total}) =>
      Text(Formatters.outOf(current, total));

  /// 4px LinearProgressIndicator under the AppBar.
  static PreferredSizeWidget bar({required int current, required int total}) =>
      PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: total == 0 ? 0 : current / total,
        ),
      );
}

/// Row of page dots (Auswendiglernen card flow, multi-step screens).
class VoxStepDots extends StatelessWidget {
  const VoxStepDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.color,
  });

  final int    count;
  final int    activeIndex;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width : i == activeIndex ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == activeIndex
                  ? c
                  : c.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
