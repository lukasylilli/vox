// FILE: lib/features/selbstlernen/screens/habit_maker_screen.dart
// DEPS: habit_dao.dart, selbstlernen_controller.dart, habit_day_selector_widget.dart
// PURPOSE: لیست عادت‌ها + دیالوگ ایجاد/ویرایش + حذف
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/selbstlernen_controller.dart';
import '../widgets/habit_day_selector_widget.dart';
import '../../../core/widgets/vox_button.dart';

class HabitMakerScreen extends ConsumerWidget {
  const HabitMakerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Maker')),
      floatingActionButton: VoxFab(
        icon     : Icons.add,
        onPressed: () => _showDialog(context, ref),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 64, color: Colors.orange),
                  const SizedBox(height: AppSizes.md),
                  Text(AppL10n.t(context, 'habit_empty'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(AppL10n.t(context, 'habit_add_prompt'),
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding         : const EdgeInsets.all(AppSizes.md),
            itemCount       : habits.length,
            separatorBuilder: (_, i) => const SizedBox(height: AppSizes.sm),
            itemBuilder     : (_, i) {
              final h    = habits[i];
              final days = ref.read(habitActionsProvider).parseDays(h);
              return _HabitTile(
                habit    : h,
                dayCount : days.length,
                onTap    : () => context.push(
                  AppRoutes.habitStats.replaceAll(':habitId', '${h.id}'),
                ),
                onEdit   : () => _showDialog(context, ref, existing: h),
                onDelete : () =>
                    ref.read(habitActionsProvider).deleteHabit(h.id),
                onToggle : () =>
                    ref.read(habitActionsProvider).toggleToday(h.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    WidgetRef ref, {
    Habit? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _HabitDialog(existing: existing, ref: ref),
    );
  }
}

// ─────────────────────────────────────────────
class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.dayCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final Habit      habit;
  final int        dayCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  static const _shiftIcons = {
    'morning'  : Icons.wb_sunny_rounded,
    'afternoon': Icons.wb_cloudy_rounded,
    'evening'  : Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap   : onTap,
        leading : CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            _shiftIcons[habit.shift] ?? Icons.star_rounded,
            color: scheme.primary,
          ),
        ),
        title   : Text(habit.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          AppL10n.tf(context, 'n_days_per_week', {'n': '$dayCount'}),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VoxIconButton(
              icon: Icons.edit_rounded, iconSize: 18,
              onPressed: onEdit,
            ),
            VoxIconButton(
              icon: Icons.delete_rounded, iconSize: 18,
              color    : scheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _HabitDialog extends StatefulWidget {
  const _HabitDialog({this.existing, required this.ref});

  final Habit?    existing;
  final WidgetRef ref;

  @override
  State<_HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<_HabitDialog> {
  final _nameCtrl   = TextEditingController();
  List<int> _days   = [1, 2, 3, 4, 5];
  String    _shift  = 'morning';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final h  = widget.existing!;
      _nameCtrl.text = h.name;
      _shift         = h.shift;
      _days          = widget.ref.read(habitActionsProvider).parseDays(h);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title  : Text(AppL10n.t(context, widget.existing == null ? 'new_habit' : 'edit_habit')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize      : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller : _nameCtrl,
              decoration : InputDecoration(
                labelText: AppL10n.t(context, 'habit_name'),
                border   : const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(AppL10n.t(context, 'weekdays'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            HabitDaySelectorWidget(
              selectedDays: _days,
              onChanged   : (d) => setState(() => _days = d),
            ),
            const SizedBox(height: AppSizes.md),
            Text(AppL10n.t(context, 'time_of_day'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'morning',   label: Text(AppL10n.t(context, 'morning'))),
                ButtonSegment(value: 'afternoon', label: Text(AppL10n.t(context, 'afternoon'))),
                ButtonSegment(value: 'evening',   label: Text(AppL10n.t(context, 'evening'))),
              ],
              selected : {_shift},
              onSelectionChanged: (s) =>
                  setState(() => _shift = s.first),
            ),
          ],
        ),
      ),
      actions: [
        VoxButton.text(
          label    : AppL10n.t(context, 'cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        VoxButton.primary(
          label    : AppL10n.t(context, 'save'),
          onPressed: _save,
        ),
      ],
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final actions = widget.ref.read(habitActionsProvider);
    if (widget.existing == null) {
      actions.createHabit(
        name         : name,
        scheduledDays: _days,
        shift        : _shift,
      );
    } else {
      actions.updateHabit(
        id           : widget.existing!.id,
        name         : name,
        scheduledDays: _days,
        shift        : _shift,
      );
    }
    Navigator.pop(context);
  }
}
