// FILE: lib/features/leitner/widgets/box_progress_widget.dart
// DEPS: leitner_controller.dart, boxLabels, boxIntervals
// PURPOSE: 5-box overview widget showing card counts and day intervals
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../controllers/leitner_controller.dart';

class BoxProgressWidget extends ConsumerWidget {
  const BoxProgressWidget({super.key, this.onBoxTap});
  final void Function(int box)? onBoxTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(boxCountsProvider);

    return countsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error  : (_, _) => const SizedBox.shrink(),
      data   : (counts) => Row(
        children: List.generate(5, (i) {
          final box   = i + 1;
          final count = counts[box] ?? 0;
          return Expanded(
            child: GestureDetector(
              onTap: () => onBoxTap?.call(box),
              child: _BoxCard(box: box, count: count, label: boxLabels[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _BoxCard extends StatelessWidget {
  const _BoxCard({required this.box, required this.count, required this.label});
  final int    box, count;
  final String label;

  static const _boxColors = [
    Color(0xFFEF5350), // box 1 — red (new/hard)
    Color(0xFFFF9800), // box 2 — orange
    Color(0xFFFFEB3B), // box 3 — yellow
    Color(0xFF66BB6A), // box 4 — green
    Color(0xFF42A5F5), // box 5 — blue (mastered)
  ];

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final color  = _boxColors[box - 1];
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin     : const EdgeInsets.symmetric(horizontal: 3),
      padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: 4),
      decoration : BoxDecoration(
        color       : color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border      : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color     : color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$box',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines : 2,
            overflow : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
