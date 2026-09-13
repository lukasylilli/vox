// FILE: lib/features/selbstlernen/screens/habit_stats_screen.dart
// DEPS: habit_dao.dart, selbstlernen_controller.dart, streak_chart_widget.dart
// PURPOSE: آمار یک عادت — streak chart + وضعیت امروز + تاریخچه
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/selbstlernen_controller.dart';
import '../widgets/streak_chart_widget.dart';
import '../../../core/widgets/vox_button.dart';

class HabitStatsScreen extends ConsumerWidget {
  const HabitStatsScreen({super.key, required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));
    final chartAsync = ref.watch(habitLast7DaysProvider(habitId));
    final todayAsync = ref.watch(habitCompletedTodayProvider(habitId));
    final scheme     = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'habit_stats_title'))),
      body  : habitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (habit) {
          if (habit == null) {
            return Center(child: Text(AppL10n.t(context, 'habit_not_found')));
          }

          final days = ref.read(habitActionsProvider).parseDays(habit);

          return ListView(
            padding : const EdgeInsets.all(AppSizes.md),
            children: [
              // Header card
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 40, color: scheme.primary),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(habit.name,
                                style: const TextStyle(
                                  fontSize  : 20,
                                  fontWeight: FontWeight.w800,
                                )),
                            Text('${days.length} ${AppL10n.t(context, 'days_per_week')}  •  streak: ${habit.streakCount}',
                                style: TextStyle(
                                    color: scheme.onPrimaryContainer)),
                          ],
                        ),
                      ),
                      todayAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error  : (_, _) => const SizedBox.shrink(),
                        data   : (done) => Column(
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: done ? Colors.green : scheme.outline,
                              size : 32,
                            ),
                            Text(done
                                ? AppL10n.t(context, 'done_today')
                                : AppL10n.t(context, 'today_label'),
                                style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Streak chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppL10n.t(context, 'last_7_days'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 16,
                          )),
                      const SizedBox(height: AppSizes.sm),
                      chartAsync.when(
                        loading: () => const SizedBox(
                            height: 120,
                            child : Center(child: CircularProgressIndicator())),
                        error  : (e, _) => Text('$e'),
                        data   : (map) => StreakChartWidget(last7Days: map),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              VoxButton.primary(
                label    : AppL10n.t(context, 'mark_today'),
                icon     : Icons.check_rounded,
                onPressed: () =>
                    ref.read(habitActionsProvider).toggleToday(habitId),
              ),
            ],
          );
        },
      ),
    );
  }
}
