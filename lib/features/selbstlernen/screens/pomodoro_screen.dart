// FILE: lib/features/selbstlernen/screens/pomodoro_screen.dart
// DEPS: selbstlernen_controller.dart, pomodoro_timer_widget.dart
// PURPOSE: صفحه پومودورو — تایمر + کنترل‌ها + بنر «فاز تمام شد» + سه سوییچ
//          (روشن ماندن صفحه، شروع خودکار فاز بعدی، صدا) — 2026-10-05
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
              // Phase finished (also while the screen was locked)
              if (pState.beendetePhase != null) ...[
                const SizedBox(height: AppSizes.md),
                _EndeBanner(
                  text: AppL10n.t(context, pState.beendetePhase!.endeKey),
                ),
              ],
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

              // Session count
              if (pState.sessionCount > 0)
                Text(
                  AppL10n.tf(context, 'n_sessions_done', {'n': '${pState.sessionCount}'}),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              const SizedBox(height: AppSizes.lg),

              // Settings
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  margin: EdgeInsets.zero,
                  child : Column(
                    children: [
                      SwitchListTile(
                        key      : const Key('pomo_switch_keep_awake'),
                        value    : pState.wachHalten,
                        onChanged: notifier.setzeWachHalten,
                        title    : Text(AppL10n.t(context, 'pomo_keep_awake')),
                        subtitle : Text(AppL10n.t(context, 'pomo_keep_awake_sub')),
                      ),
                      SwitchListTile(
                        key      : const Key('pomo_switch_auto_next'),
                        value    : pState.autoWeiter,
                        onChanged: notifier.setzeAutoWeiter,
                        title    : Text(AppL10n.t(context, 'pomo_auto_next')),
                        subtitle : Text(AppL10n.t(context, 'pomo_auto_next_sub')),
                      ),
                      SwitchListTile(
                        key      : const Key('pomo_switch_sound'),
                        value    : pState.klang,
                        onChanged: notifier.setzeKlang,
                        title    : Text(AppL10n.t(context, 'pomo_sound')),
                        subtitle : Text(AppL10n.t(context, 'pomo_sound_sub')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// „Phase X ist zu Ende" — bleibt stehen, bis der Nutzer etwas bedient
/// (im Auto-Modus verschwindet es nach 30 Sekunden, siehe PomodoroNotifier).
class _EndeBanner extends StatelessWidget {
  const _EndeBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key       : const Key('pomo_ende_banner'),
      padding   : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color       : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize  : 13,
                fontWeight: FontWeight.w700,
                color     : scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
