// FILE: lib/features/leitner/screens/leitner_stats_screen.dart
// DEPS: leitner_controller.dart, box_progress_widget.dart
// PURPOSE: Leitner statistics — total cards, box distribution, upcoming reviews
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/leitner_controller.dart';
import '../widgets/box_progress_widget.dart';

class LeitnerStatsScreen extends ConsumerWidget {
  const LeitnerStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme       = Theme.of(context);
    final scheme      = theme.colorScheme;
    final countsAsync = ref.watch(boxCountsProvider);
    final allAsync    = ref.watch(allLeitnerCardsProvider);
    final dueAsync    = ref.watch(dueCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'leitner_stats_title'))),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [

          // ── Summary chips ─────────────────────────────────────────────
          Row(
            children: [
              _StatChip(
                label  : AppL10n.t(context, 'total_cards'),
                valueAsync: allAsync.when(
                  data   : (l) => '${l.length}',
                  loading: () => '...',
                  error  : (_, _) => '-',
                ),
                icon : Icons.style_rounded,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.sm),
              _StatChip(
                label  : AppL10n.t(context, 'due_today'),
                valueAsync: dueAsync.when(
                  data   : (n) => '$n',
                  loading: () => '...',
                  error  : (_, _) => '-',
                ),
                icon : Icons.today_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: AppSizes.sm),
              _StatChip(
                label  : AppL10n.t(context, 'box_five'),
                valueAsync: countsAsync.when(
                  data   : (m) => '${m[5] ?? 0}',
                  loading: () => '...',
                  error  : (_, _) => '-',
                ),
                icon : Icons.star_rounded,
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // ── Box progress ──────────────────────────────────────────────
          Text(AppL10n.t(context, 'leitner_boxes'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          const BoxProgressWidget(),

          const SizedBox(height: AppSizes.lg),

          // ── Box breakdown ─────────────────────────────────────────────
          Text(AppL10n.t(context, 'details_label'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          countsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (counts) {
              final total = counts.values.fold(0, (a, b) => a + b);
              return Column(
                children: List.generate(5, (i) {
                  final box      = i + 1;
                  final count    = counts[box] ?? 0;
                  final fraction = total == 0 ? 0.0 : count / total;
                  final interval = boxIntervals[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${AppL10n.t(context, 'box_label')} $box',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              )),
                            const Spacer(),
                            Text(AppL10n.tf(context, 'n_cards_every_x', {'n': '$count', 'x': '$interval'}),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value          : fraction,
                            minHeight      : 8,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: AppSizes.lg),

          // ── Upcoming reviews ──────────────────────────────────────────
          Text(AppL10n.t(context, 'upcoming_reviews'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          allAsync.when(
            loading: () => const SizedBox.shrink(),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (cards) {
              final now = DateTime.now();
              final upcoming = cards
                  .where((c) => c.nextReview.isAfter(now))
                  .toList()
                ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
              if (upcoming.isEmpty) {
                return Text(AppL10n.t(context, 'no_future_cards'));
              }
              final grouped = <String, int>{};
              for (final card in upcoming) {
                final diff = card.nextReview.difference(now).inDays + 1;
                final key  = diff == 1 ? AppL10n.t(context, 'tomorrow') : AppL10n.tf(context, 'in_x_days', {'n': '$diff'});
                grouped[key] = (grouped[key] ?? 0) + 1;
              }
              return Column(
                children: grouped.entries.take(7).map((e) => ListTile(
                  leading : Icon(Icons.calendar_today_rounded,
                      color: scheme.primary, size: 18),
                  title   : Text(e.key),
                  trailing: Text(Formatters.countLabel(e.value, AppL10n.t(context, 'card_unit')),
                    style: TextStyle(color: scheme.primary,
                        fontWeight: FontWeight.w600)),
                  contentPadding: EdgeInsets.zero,
                  dense  : true,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label, required this.valueAsync,
    required this.icon, required this.color,
  });
  final String label, valueAsync;
  final IconData icon;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding   : const EdgeInsets.symmetric(
            vertical: AppSizes.md, horizontal: AppSizes.sm),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border      : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(valueAsync,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color, fontWeight: FontWeight.w800,
              )),
            Text(label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
