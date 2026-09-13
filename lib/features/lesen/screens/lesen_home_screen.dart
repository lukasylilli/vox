// FILE: lib/features/lesen/screens/lesen_home_screen.dart
// DEPS: lesen_controller.dart, app_routes.dart
// PURPOSE: Lesen section home — 6 level cards + News button
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/lesen_controller.dart';

class LesenHomeScreen extends ConsumerWidget {
  const LesenHomeScreen({super.key});

  static const _levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
  static const _levelColors = [
    VoxColors.cefrA1,
    VoxColors.cefrA2,
    VoxColors.cefrB1,
    VoxColors.cefrB2,
    VoxColors.cefrC1,
    VoxColors.cefrC2,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(textLevelCountsProvider);
    final theme       = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lesen')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── News / RSS card ─────────────────────────────────────────
          _NewsCard(onTap: () => context.push(AppRoutes.lesenNews)),

          const SizedBox(height: AppSizes.lg),
          Text(AppL10n.t(context, 'graded_texts'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),

          // ── Level grid ──────────────────────────────────────────────
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
                childAspectRatio: 1.5,
              ),
              itemCount  : _levels.length,
              itemBuilder: (_, i) {
                final level = _levels[i];
                final count = counts[level] ?? 0;
                return _LevelCard(
                  level: level,
                  count: count,
                  color: _levelColors[i],
                  onTap: () => context.push(
                    '${AppRoutes.lesen}/$level',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding   : const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.8),
              scheme.secondary.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(Icons.newspaper_rounded, color: Colors.white, size: 36),
            const SizedBox(width: AppSizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.t(context, 'news_title'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
                Text(AppL10n.t(context, 'rss_description'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level, required this.count,
    required this.color, required this.onTap,
  });
  final String level;
  final int    count;
  final Color  color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            Text(level.toUpperCase(),
              style: const TextStyle(
                color: Colors.white, fontSize: 24,
                fontWeight: FontWeight.w900, letterSpacing: 2,
              )),
            Text(count == 0 ? AppL10n.t(context, 'no_texts') : AppL10n.tf(context, 'n_texts', {'n': '$count'}),
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
