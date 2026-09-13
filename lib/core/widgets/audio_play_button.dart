// FILE: lib/core/widgets/audio_play_button.dart
// DEPS: tts_service.dart
// PURPOSE: TTS play/stop button — delegates to singleton TtsService to avoid multiple FlutterTts instances
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tts_service.dart';
import '../../core/l10n/app_l10n.dart';

class AudioPlayButton extends ConsumerWidget {
  const AudioPlayButton({
    super.key,
    required this.text,
    this.size  = 22.0,
    this.color,
  });

  final String text;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts     = ref.watch(ttsServiceProvider);
    final playing = tts.isPlayingText(text);
    final iconColor = color ?? Theme.of(context).colorScheme.primary;

    return IconButton(
      icon: Icon(
        playing ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
        size : size,
        color: iconColor,
      ),
      tooltip  : playing ? AppL10n.t(context, 'pause') : AppL10n.t(context, 'play_audio'),
      onPressed: () => ref.read(ttsServiceProvider.notifier).toggle(text),
      padding  : EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
