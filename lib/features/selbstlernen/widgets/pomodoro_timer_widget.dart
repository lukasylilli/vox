// FILE: lib/features/selbstlernen/widgets/pomodoro_timer_widget.dart
// DEPS: selbstlernen_controller.dart
// PURPOSE: دایره‌ای تایمر پومودورو — CircularProgressIndicator با ثانیه‌شمار
import 'package:flutter/material.dart';

import '../controllers/selbstlernen_controller.dart';
import '../../../core/l10n/app_l10n.dart';

class PomodoroTimerWidget extends StatelessWidget {
  const PomodoroTimerWidget({
    super.key,
    required this.state,
    this.size = 220,
  });

  final PomodoroState state;
  final double        size;

  @override
  Widget build(BuildContext context) {
    final scheme    = Theme.of(context).colorScheme;
    final minutes   = state.secondsLeft ~/ 60;
    final seconds   = state.secondsLeft % 60;
    final timeLabel =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final color = switch (state.phase) {
      PomodoroPhase.work       => scheme.primary,
      PomodoroPhase.shortBreak => Colors.green,
      PomodoroPhase.longBreak  => Colors.teal,
    };

    return SizedBox(
      width : size,
      height: size,
      child : Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width : size,
            height: size,
            child : CircularProgressIndicator(
              value          : state.progress.clamp(0.0, 1.0),
              strokeWidth    : 10,
              color          : color,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize  : size * 0.2,
                  fontWeight: FontWeight.w900,
                  color     : color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppL10n.t(context, state.phase.labelFa),
                style: TextStyle(
                  fontSize: size * 0.07,
                  color   : scheme.onSurfaceVariant,
                ),
              ),
              if (state.sessionCount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    state.sessionCount.clamp(0, 8),
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child  : Icon(Icons.circle, size: 8, color: color),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
