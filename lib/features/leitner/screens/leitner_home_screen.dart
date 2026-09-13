// FILE: lib/features/leitner/screens/leitner_home_screen.dart
// DEPS: leitner_controller.dart, box_progress_widget.dart, app_routes.dart
// PURPOSE: Leitner overview — due count banner, 5-box grid, Start Review button
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/leitner_controller.dart';
import '../widgets/box_progress_widget.dart';
import '../../../core/widgets/vox_button.dart';

class LeitnerHomeScreen extends ConsumerWidget {
  const LeitnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final scheme     = theme.colorScheme;
    final dueAsync   = ref.watch(dueCountProvider);
    final countsAsync= ref.watch(boxCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitner'),
        actions: [
          VoxIconButton(
            icon: Icons.bar_chart_rounded,
            tooltip  : AppL10n.t(context, 'stats_label'),
            onPressed: () => context.push(AppRoutes.leitnerStats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [

          // ── Due cards banner ────────────────────────────────────────────
          dueAsync.when(
            loading: () => const _DueBanner(count: 0, loading: true),
            error  : (_, _) => const _DueBanner(count: 0),
            data   : (n) => _DueBanner(count: n),
          ),

          const SizedBox(height: AppSizes.lg),

          // ── Box progress ────────────────────────────────────────────────
          Text(AppL10n.t(context, 'box_distribution'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          const BoxProgressWidget(),

          const SizedBox(height: AppSizes.lg),

          // ── Box detail list ─────────────────────────────────────────────
          countsAsync.when(
            loading: () => const SizedBox.shrink(),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (counts) => Column(
              children: List.generate(5, (i) {
                final box   = i + 1;
                final count = counts[box] ?? 0;
                final interval = boxIntervals[i];
                return ListTile(
                  leading     : CircleAvatar(
                    radius   : 16,
                    backgroundColor: scheme.primaryContainer,
                    child    : Text('$box',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                        fontSize: 12,
                      )),
                  ),
                  title       : Text('${AppL10n.t(context, 'box_label')} $box'),
                  subtitle    : Text(AppL10n.tf(context, 'every_x_days', {'n': '$interval'})),
                  trailing    : Text(Formatters.countLabel(count, AppL10n.t(context, 'card_unit')),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ),
          ),

          const SizedBox(height: AppSizes.xl),
        ],
      ),

      // ── Start Review FAB ─────────────────────────────────────────────────
      floatingActionButton: dueAsync.when(
        loading: () => null,
        error  : (_, _) => null,
        data   : (n) => n == 0
            ? null
            : VoxFab.extended(
                icon     : Icons.play_arrow_rounded,
                label    : AppL10n.tf(context, 'start_review_n', {'n': '$n'}),
                onPressed: () => context.push(AppRoutes.leitnerReview),
              ),
      ),
    );
  }
}

// ── Due count banner ──────────────────────────────────────────────────────────

class _DueBanner extends StatelessWidget {
  const _DueBanner({required this.count, this.loading = false});
  final int  count;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final hasCards = count > 0;

    return Container(
      padding   : const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCards
              ? [Colors.orange.withValues(alpha: 0.8), Colors.deepOrange.withValues(alpha: 0.8)]
              : [Colors.green.withValues(alpha: 0.6), Colors.teal.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        children: [
          Icon(
            hasCards ? Icons.notification_important_rounded : Icons.check_circle_rounded,
            color: Colors.white, size: 40,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loading ? '...' : AppL10n.tf(context, 'n_cards_due', {'n': '$count'}),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  hasCards ? AppL10n.t(context, 'ready_for_review_today') : AppL10n.t(context, 'all_cards_up_to_date'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
