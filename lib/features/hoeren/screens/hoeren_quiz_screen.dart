// FILE: lib/features/hoeren/screens/hoeren_quiz_screen.dart
// DEPS: hoeren_controller.dart, audio_service.dart, audio_player_controls.dart
// PURPOSE: Listening quiz — play audio clip, fill in the blanked words
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/hoeren_controller.dart';
import '../widgets/audio_player_controls.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class HoerenQuizScreen extends ConsumerStatefulWidget {
  const HoerenQuizScreen({super.key, required this.audioId});
  final int audioId;

  @override
  ConsumerState<HoerenQuizScreen> createState() => _HoerenQuizScreenState();
}

class _HoerenQuizScreenState extends ConsumerState<HoerenQuizScreen> {
  List<_QuizItem> _items      = [];
  int             _current    = 0;
  bool            _answered   = false;
  bool            _correct    = false;
  bool            _done       = false;
  int             _score      = 0;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final item  = await ref.read(audioByIdProvider(widget.audioId).future);
    final words = await ref.read(transcriptProvider(widget.audioId).future);
    if (item == null || !mounted) return;

    await ref.read(audioServiceProvider.notifier).load(item.audioPath);

    // Pick ~20% of content words as blanks
    final rng    = Random();
    final picked = <_QuizItem>[];
    for (var i = 2; i < words.length - 1; i++) {
      final w = words[i].word.replaceAll(RegExp(r'[.,!?;:]'), '');
      if (w.length >= 3 && rng.nextDouble() < 0.22) {
        // Context: 3 words before + blank + 3 words after
        final before = words
            .sublist(max(0, i - 3), i)
            .map((x) => x.word)
            .join(' ');
        final after = words
            .sublist(i + 1, min(words.length, i + 4))
            .map((x) => x.word)
            .join(' ');
        picked.add(_QuizItem(
          context : '$before ___ $after',
          answer  : w,
          startMs : words[max(0, i - 3)].startMs,
          endMs   : words[min(words.length - 1, i + 3)].endMs,
        ));
        if (picked.length >= 8) break;
      }
    }

    if (picked.isEmpty && words.isNotEmpty) {
      // Fallback: first content word
      final w = words[0].word;
      picked.add(_QuizItem(
        context : '___ ${words.skip(1).take(4).map((x) => x.word).join(' ')}',
        answer  : w,
        startMs : words[0].startMs,
        endMs   : words[min(words.length - 1, 4)].endMs,
      ));
    }

    setState(() => _items = picked);
  }

  void _check() {
    final correct =
        _controller.text.trim().toLowerCase() ==
        _items[_current].answer.toLowerCase();
    setState(() {
      _answered = true;
      _correct  = correct;
      if (correct) _score++;
    });
  }

  void _next() {
    _controller.clear();
    if (_current >= _items.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() {
        _current++;
        _answered = false;
        _correct  = false;
      });
    }
  }

  Future<void> _playContext() async {
    final item = _items[_current];
    final svc  = ref.read(audioServiceProvider.notifier);
    await svc.seek(Duration(milliseconds: item.startMs));
    await svc.play();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppL10n.t(context, 'listening_quiz_title')),
            bottom: const AudioPlayerControls()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_done) return _ResultScreen(score: _score, total: _items.length);

    final item = _items[_current];

    return Scaffold(
      appBar: AppBar(
        title : Text('${AppL10n.t(context, 'quiz')} — ${_current + 1}/${_items.length}'),
        bottom: const AudioPlayerControls(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / _items.length,
            ),
            const SizedBox(height: AppSizes.xl),

            // Play context button
            Center(
              child: VoxButton.primary(
                label    : AppL10n.t(context, 'play_piece'),
                icon     : Icons.play_circle_rounded,
                onPressed: _playContext,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Context sentence
            Container(
              width     : double.infinity,
              padding   : const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color       : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: DeutschText(
                item.context,
                style    : theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Text(AppL10n.t(context, 'listening_quiz_score'),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),

            TextField(
              controller  : _controller,
              enabled     : !_answered,
              autofocus   : true,
              decoration  : InputDecoration(
                hintText: AppL10n.t(context, 'type_here'),
                border  : const OutlineInputBorder(),
                filled  : true,
                fillColor: _answered
                    ? (_correct
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1))
                    : null,
              ),
              onSubmitted: (_) => _answered ? _next() : _check(),
            ),

            if (_answered) ...[
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Icon(
                    _correct
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _correct ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _correct ? AppL10n.t(context, 'correct_feedback') : '${AppL10n.t(context, 'answer_label')} ${item.answer}',
                    style: TextStyle(
                      color     : _correct ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            _answered
                ? VoxButton.primary(
                    label    : AppL10n.t(context,
                        _current < _items.length - 1 ? 'next' : 'results'),
                    expand   : true,
                    onPressed: _next,
                  )
                : VoxButton.primary(
                    label    : AppL10n.t(context, 'confirm'),
                    expand   : true,
                    onPressed: _controller.text.isEmpty ? null : _check,
                  ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _QuizItem {
  const _QuizItem({
    required this.context,
    required this.answer,
    required this.startMs,
    required this.endMs,
  });
  final String context;
  final String answer;
  final int    startMs;
  final int    endMs;
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({required this.score, required this.total});
  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct    = total == 0 ? 0 : (score * 100 ~/ total);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'quiz_result'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width : 120,
              height: 120,
              child : Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value    : pct / 100,
                    strokeWidth: 10,
                    color    : pct >= 70 ? Colors.green : scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  Text('$pct%',
                      style: const TextStyle(
                          fontSize  : 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(AppL10n.tf(context, 'x_of_y_correct', {'x': '$score', 'y': '$total'}),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),
            VoxButton.primary(
              label    : AppL10n.t(context, 'back'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
