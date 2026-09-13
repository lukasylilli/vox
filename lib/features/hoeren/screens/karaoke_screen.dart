// FILE: lib/features/hoeren/screens/karaoke_screen.dart
// DEPS: hoeren_controller.dart, audio_player_controls.dart, karaoke_text_display.dart
// PURPOSE: Full-screen karaoke — plays audio + highlights current word in transcript
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/hoeren_controller.dart';
import '../widgets/audio_player_controls.dart';
import '../widgets/karaoke_text_display.dart';
import '../../../core/widgets/vox_button.dart';

class KaraokeScreen extends ConsumerStatefulWidget {
  const KaraokeScreen({super.key, required this.audioId});
  final int audioId;

  @override
  ConsumerState<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends ConsumerState<KaraokeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAudio());
  }

  Future<void> _loadAudio() async {
    final item = await ref.read(audioByIdProvider(widget.audioId).future);
    if (item != null && mounted) {
      await ref.read(audioServiceProvider.notifier).load(item.audioPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync       = ref.watch(audioByIdProvider(widget.audioId));
    final transcriptAsync = ref.watch(transcriptProvider(widget.audioId));

    return Scaffold(
      appBar: AppBar(
        title: Text(itemAsync.value?.title ?? 'Karaoke'),
        bottom: const AudioPlayerControls(),
      ),
      body: transcriptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (words) => words.isEmpty
            ? _NoTranscript(audioId: widget.audioId)
            : KaraokeTextDisplay(words: words),
      ),
    );
  }
}

class _NoTranscript extends ConsumerWidget {
  const _NoTranscript({required this.audioId});
  final int audioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(audioServiceProvider);
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded,
              size: 80, color: scheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.lg),
          Text(AppL10n.t(context, 'no_text'),
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: AppSizes.sm),
          Text(AppL10n.t(context, 'audio_only')),
          const SizedBox(height: AppSizes.xl),
          VoxButton.primary(
            label    : state.playing
                ? AppL10n.t(context, 'pause')
                : AppL10n.t(context, 'play'),
            icon     : state.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onPressed: () => ref.read(audioServiceProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}
