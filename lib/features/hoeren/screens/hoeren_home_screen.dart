// FILE: lib/features/hoeren/screens/hoeren_home_screen.dart
// DEPS: hoeren_controller.dart, app_routes.dart
// PURPOSE: Hören home — 6 level cards with audio count
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/hoeren_controller.dart';

class HoerenHomeScreen extends ConsumerWidget {
  const HoerenHomeScreen({super.key});

  static const _levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
  static const _colors = [
    VoxColors.cefrA1,
    VoxColors.cefrA2,
    VoxColors.cefrB1,
    VoxColors.cefrB2,
    VoxColors.cefrC1,
    VoxColors.cefrC2,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(audioLevelCountsProvider);
    final theme       = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Hören')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── Info banner ──────────────────────────────────────────
          Container(
            padding   : const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color       : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.headphones_rounded,
                    color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    AppL10n.t(context, 'hoeren_tagline'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),
          Text(AppL10n.t(context, 'select_level'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),

          // ── Level grid ───────────────────────────────────────────
          countsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (counts) => GridView.builder(
              shrinkWrap  : true,
              physics     : const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount  : 2,
                mainAxisSpacing : AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 1.4,
              ),
              itemCount  : _levels.length,
              itemBuilder: (_, i) {
                final level = _levels[i];
                final count = counts[level] ?? 0;
                return _LevelCard(
                  level: level,
                  count: count,
                  color: _colors[i],
                  onTap: () => context.push('${AppRoutes.hoeren}/$level'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String level;
  final int    count;
  final Color  color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin : Alignment.topLeft,
            end   : Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.7 : 0.85),
              color.withValues(alpha: isDark ? 0.4 : 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment : MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.headphones_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(level.toUpperCase(),
                    style: const TextStyle(
                      color      : Colors.white,
                      fontSize   : 20,
                      fontWeight : FontWeight.w900,
                      letterSpacing: 2,
                    )),
              ],
            ),
            Text(
              count == 0 ? AppL10n.t(context, 'no_content') : AppL10n.tf(context, 'n_files', {'n': '$count'}),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
