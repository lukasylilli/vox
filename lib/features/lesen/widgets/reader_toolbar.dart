// FILE: lib/features/lesen/widgets/reader_toolbar.dart
// DEPS: tts_service.dart, readerFontSizeProvider
// PURPOSE: AppBar bottom toolbar — TTS play/stop, font size +/-, TTS speed
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/tts_service.dart';
import '../controllers/lesen_controller.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';

class ReaderToolbar extends ConsumerWidget implements PreferredSizeWidget {
  const ReaderToolbar({super.key, required this.fullText});
  final String fullText;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts      = ref.watch(ttsServiceProvider);
    final fontSize = ref.watch(readerFontSizeProvider);
    final scheme   = Theme.of(context).colorScheme;
    final playing  = tts.isPlayingText(fullText);

    return Container(
      height    : 48,
      decoration: BoxDecoration(
        color : scheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // TTS play/stop
          VoxIconButton(
            tooltip  : playing ? AppL10n.t(context, 'pause') : AppL10n.t(context, 'play_text'),
            icon     : playing ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
            color    : playing ? scheme.error : scheme.primary,
            onPressed: () => ref
                .read(ttsServiceProvider.notifier)
                .toggle(fullText),
          ),

          // Speed control
          _SpeedButton(ref: ref, tts: tts),

          const Spacer(),

          // Font size controls
          VoxIconButton(
            tooltip  : AppL10n.t(context, 'smaller'),
            icon: Icons.text_decrease_rounded,
            onPressed: fontSize <= 12
                ? null
                : () => ref
                    .read(readerFontSizeProvider.notifier)
                    .state = fontSize - 2,
          ),
          Text(
            '${fontSize.round()}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          VoxIconButton(
            tooltip  : AppL10n.t(context, 'larger'),
            icon: Icons.text_increase_rounded,
            onPressed: fontSize >= 28
                ? null
                : () => ref
                    .read(readerFontSizeProvider.notifier)
                    .state = fontSize + 2,
          ),
        ],
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.ref, required this.tts});
  final WidgetRef    ref;
  final TtsPlayState tts;

  static const _speeds = [0.5, 0.75, 0.85, 1.0, 1.25];

  @override
  Widget build(BuildContext context) {
    final current = tts.rate;
    final label   = current == 1.0 ? '1×' : '$current×';
    return VoxButton.text(
      label    : label,
      size     : VoxButtonSize.small,
      onPressed: () {
        final idx  = _speeds.indexOf(current);
        final next = _speeds[(idx + 1) % _speeds.length];
        ref.read(ttsServiceProvider.notifier).setRate(next);
      },
    );
  }
}
