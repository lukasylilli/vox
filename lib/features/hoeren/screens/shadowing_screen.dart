// FILE: lib/features/hoeren/screens/shadowing_screen.dart
// DEPS: hoeren_controller.dart, audio_service.dart, audio_player_controls.dart
// PURPOSE: Shadowing practice — plays one sentence at a time, pauses for user to repeat
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/hoeren_controller.dart';
import '../widgets/audio_player_controls.dart';
import '../../../core/widgets/vox_button.dart';

class ShadowingScreen extends ConsumerStatefulWidget {
  const ShadowingScreen({super.key, required this.audioId});
  final int audioId;

  @override
  ConsumerState<ShadowingScreen> createState() => _ShadowingScreenState();
}

class _ShadowingScreenState extends ConsumerState<ShadowingScreen> {
  List<List<TranscriptWord>> _sentences = [];
  int   _currentSentence = 0;
  bool  _waitingForUser  = false;
  bool  _loaded          = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final item   = await ref.read(audioByIdProvider(widget.audioId).future);
    final words  = await ref.read(transcriptProvider(widget.audioId).future);
    if (item != null && mounted) {
      await ref.read(audioServiceProvider.notifier).load(item.audioPath);
      setState(() {
        _sentences = _splitIntoSentences(words);
        _loaded    = true;
      });
    }
  }

  // Split word list into sentence groups on punctuation
  List<List<TranscriptWord>> _splitIntoSentences(List<TranscriptWord> words) {
    final sentences = <List<TranscriptWord>>[];
    var current     = <TranscriptWord>[];
    for (final w in words) {
      current.add(w);
      if (w.word.endsWith('.') ||
          w.word.endsWith('?') ||
          w.word.endsWith('!')) {
        if (current.isNotEmpty) sentences.add(current);
        current = [];
      }
    }
    if (current.isNotEmpty) sentences.add(current);
    return sentences;
  }

  Future<void> _playCurrent() async {
    if (_sentences.isEmpty) return;
    final s      = _sentences[_currentSentence];
    final start  = Duration(milliseconds: s.first.startMs);
    final end    = Duration(milliseconds: s.last.endMs);
    final svc    = ref.read(audioServiceProvider.notifier);
    await svc.seek(start);
    await svc.play();
    // Wait until position passes sentence end
    setState(() => _waitingForUser = false);
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      final pos = ref.read(audioServiceProvider).position;
      if (pos >= end) {
        await svc.pause();
        if (mounted) setState(() => _waitingForUser = true);
        return false;
      }
      return true;
    });
  }

  void _next() {
    if (_currentSentence < _sentences.length - 1) {
      setState(() {
        _currentSentence++;
        _waitingForUser = false;
      });
      _playCurrent();
    }
  }

  void _prev() {
    if (_currentSentence > 0) {
      setState(() {
        _currentSentence--;
        _waitingForUser = false;
      });
      _playCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'shadowing_title')),
        bottom: const AudioPlayerControls(),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _sentences.isEmpty
              ? Center(child: Text(AppL10n.t(context, 'no_text')))
              : Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    children: [
                      // Progress
                      LinearProgressIndicator(
                        value: (_currentSentence + 1) / _sentences.length,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        '${_currentSentence + 1} / ${_sentences.length}',
                        style: theme.textTheme.labelMedium,
                      ),

                      const SizedBox(height: AppSizes.xl),

                      // Current sentence
                      Container(
                        width     : double.infinity,
                        padding   : const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          color       : scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          border      : _waitingForUser
                              ? Border.all(color: scheme.primary, width: 2)
                              : null,
                        ),
                        child: Text(
                          _sentences[_currentSentence]
                              .map((w) => w.word)
                              .join(' '),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      if (_waitingForUser)
                        Container(
                          padding   : const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color       : scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic_rounded,
                                  color: scheme.onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text(AppL10n.t(context, 'now_repeat'),
                                  style: TextStyle(
                                    color     : scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          VoxButton.secondary(
                            label    : AppL10n.t(context, 'previous'),
                            icon     : Icons.skip_previous_rounded,
                            onPressed: _currentSentence > 0 ? _prev : null,
                          ),
                          VoxButton.primary(
                            label    : AppL10n.t(context, 'play'),
                            icon     : Icons.play_arrow_rounded,
                            onPressed: _playCurrent,
                          ),
                          VoxButton.primary(
                            label    : AppL10n.t(context, 'next'),
                            icon     : Icons.skip_next_rounded,
                            onPressed:
                                _currentSentence < _sentences.length - 1
                                    ? _next
                                    : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                    ],
                  ),
                ),
    );
  }
}
