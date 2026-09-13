// FILE: lib/features/selbstlernen/widgets/habit_day_selector_widget.dart
// DEPS: selbstlernen_controller.dart
// PURPOSE: ۷ دکمه روز هفته — toggle selection (Mo-So = 1-7)
import 'package:flutter/material.dart';

import '../controllers/selbstlernen_controller.dart';

class HabitDaySelectorWidget extends StatelessWidget {
  const HabitDaySelectorWidget({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  // selectedDays: list of weekday ints (1=Mo ... 7=So)
  final List<int>           selectedDays;
  final void Function(List<int>) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day      = i + 1;
        final selected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            final updated = List<int>.from(selectedDays);
            if (selected) {
              updated.remove(day);
            } else {
              updated.add(day);
              updated.sort();
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width   : 38,
            height  : 38,
            decoration: BoxDecoration(
              color       : selected ? scheme.primary : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
              border      : Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Center(
              child: Text(
                dayNames[i],
                style: TextStyle(
                  fontSize  : 12,
                  fontWeight: FontWeight.w700,
                  color     : selected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
