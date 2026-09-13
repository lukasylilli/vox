// FILE: lib/features/selbstlernen/screens/pomodoro_screen.dart
// DEPS: selbstlernen_controller.dart, pomodoro_timer_widget.dart
// PURPOSE: صفحه پومودورو — تایمر + کنترل‌ها + انتخاب عادت مرتبط
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/selbstlernen_controller.dart';
import '../widgets/pomodoro_timer_widget.dart';
import '../../../core/widgets/vox_button.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pState     = ref.watch(pomodoroProvider);
    final notifier   = ref.read(pomodoroProvider.notifier);
    final habitsAsync = ref.watch(activeHabitsProvider);
    final scheme     = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body  : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child  : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase label
              Container(
                padding   : const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color       : scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  AppL10n.t(context, pState.phase.labelFa),
                  style: TextStyle(
                    fontSize  : 14,
                    fontWeight: FontWeight.w700,
                    color     : scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Timer circle
              PomodoroTimerWidget(state: pState),
              const SizedBox(height: AppSizes.xl),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VoxIconButton.outlined(
                    icon     : Icons.replay_rounded,
                    iconSize : 28,
                    onPressed: notifier.reset,
                  ),
                  const SizedBox(width: AppSizes.md),
                  VoxIconButton.filled(
                    icon     : pState.running
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    iconSize : 36,
                    padding  : const EdgeInsets.all(18),
                    onPressed: pState.running ? notifier.pause : notifier.start,
                  ),
                  const SizedBox(width: AppSizes.md),
                  VoxIconButton.outlined(
                    icon     : Icons.skip_next_rounded,
                    iconSize : 28,
                    onPressed: notifier.skipPhase,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Linked habit selector
              habitsAsync.when(
                loading: () => const SizedBox.shrink(),
                error  : (_, _) => const SizedBox.shrink(),
                data   : (habits) {
                  if (habits.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppL10n.t(context, 'related_habit'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color     : scheme.onSurfaceVariant,
                          )),
                      const SizedBox(height: 8),
                      DropdownButton<int?>(
                        value    : pState.linkedHabitId,
                        isExpanded: true,
                        hint     : Text(AppL10n.t(context, 'no_habit')),
                        items    : [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(AppL10n.t(context, 'no_habit')),
                          ),
                          ...habits.map((h) => DropdownMenuItem<int?>(
                                value: h.id,
                                child: Text(h.name),
                              )),
                        ],
                        onChanged: (v) => notifier.setLinkedHabit(v),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSizes.md),

              // Session count
              if (pState.sessionCount > 0)
                Text(
                  AppL10n.tf(context, 'n_sessions_done', {'n': '${pState.sessionCount}'}),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
