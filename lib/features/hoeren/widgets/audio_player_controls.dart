// FILE: lib/features/hoeren/widgets/audio_player_controls.dart
// DEPS: audio_service.dart, hoeren_controller.dart
// PURPOSE: Persistent audio controls — play/pause, seek bar, ±10s, speed
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/hoeren_controller.dart';
import '../../../core/widgets/vox_button.dart';

class AudioPlayerControls extends ConsumerWidget implements PreferredSizeWidget {
  const AudioPlayerControls({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(audioServiceProvider);
    final svc    = ref.read(audioServiceProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height    : 96,
      padding   : const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color : scheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Seek bar ────────────────────────────────────────────
          Row(
            children: [
              Text(_fmt(state.position),
                  style: Theme.of(context).textTheme.labelSmall),
              Expanded(
                child: Slider(
                  value: state.progress.clamp(0.0, 1.0),
                  onChanged: state.isLoaded
                      ? (v) => svc.seek(
                            Duration(
                              milliseconds:
                                  (v * state.duration.inMilliseconds).round(),
                            ),
                          )
                      : null,
                ),
              ),
              Text(_fmt(state.duration),
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),

          // ── Playback buttons ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed
              _SpeedButton(state: state, svc: svc),

              // -10s
              VoxIconButton(
                icon     : Icons.replay_10_rounded,
                onPressed: state.isLoaded
                    ? () => svc.seekBy(const Duration(seconds: -10))
                    : null,
              ),

              // Play / Pause
              VoxIconButton.filled(
                icon     : state.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                iconSize : 28,
                onPressed: state.isLoaded ? svc.toggle : null,
              ),

              // +10s
              VoxIconButton(
                icon     : Icons.forward_10_rounded,
                onPressed: state.isLoaded
                    ? () => svc.seekBy(const Duration(seconds: 10))
                    : null,
              ),

              // Stop
              VoxIconButton(
                icon     : Icons.stop_rounded,
                onPressed: state.isLoaded ? svc.stop : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.state, required this.svc});
  final AudioPlayState state;
  final AudioService   svc;

  @override
  Widget build(BuildContext context) {
    final current = state.speed;
    final label   = current == 1.0 ? '1×' : '$current×';
    return VoxButton.text(
      label    : label,
      size     : VoxButtonSize.small,
      onPressed: () {
        final idx  = audioSpeedSteps.indexOf(current);
        final next = audioSpeedSteps[(idx + 1) % audioSpeedSteps.length];
        svc.setSpeed(next);
      },
    );
  }
}
