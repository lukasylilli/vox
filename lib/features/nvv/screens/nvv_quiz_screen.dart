// FILE: lib/features/nvv/screens/nvv_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/nvv_phrase.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class NvvQuizScreen extends ConsumerStatefulWidget {
  const NvvQuizScreen({super.key, required this.phrases});
  final List<NvvPhrase> phrases;

  @override
  ConsumerState<NvvQuizScreen> createState() => _NvvQuizScreenState();
}

class _NvvQuizScreenState extends ConsumerState<NvvQuizScreen> {
  final _rng       = Random();
  int  _current    = 0;
  int  _correct    = 0;
  int? _selected;
  bool _answered   = false;
  late List<NvvPhrase> _shuffled;
  late List<List<String>> _optionSets;

  @override
  void initState() {
    super.initState();
    _shuffled    = List.of(widget.phrases)..shuffle(_rng);
    _optionSets  = _shuffled.map((p) => _buildOptions(p)).toList();
  }

  // activeLang statt context — _buildOptions läuft in initState (kein
  // dependOnInheritedWidget erlaubt)
  String _m(NvvPhrase p) =>
      AppL10n.activeLang == 'fa' ? p.meaningFa : p.meaningEn;

  List<String> _buildOptions(NvvPhrase correct) {
    final others = widget.phrases
        .where((p) => p.id != correct.id)
        .toList()..shuffle(_rng);
    final opts = <String>[_m(correct)];
    for (final o in others) {
      if (opts.length >= 4) break;
      opts.add(_m(o));
    }
    opts.shuffle(_rng);
    return opts;
  }

  NvvPhrase get _phrase => _shuffled[_current];
  List<String> get _options => _optionSets[_current];

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (_options[i] == _m(_phrase)) _correct++;
    });
  }

  void _next() {
    if (_current < _shuffled.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    VoxDialog.quizResult(
      context,
      correct : _correct,
      total   : _shuffled.length,
      onBack  : () => Navigator.pop(context),
      onRepeat: () => setState(() {
                _shuffled   = List.of(widget.phrases)..shuffle(_rng);
                _optionSets = _shuffled.map((p) => _buildOptions(p)).toList();
                _current  = 0;
                _correct  = 0;
                _selected = null;
                _answered = false;
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p      = _phrase;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _current + 1, total: _shuffled.length),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _shuffled.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            // ── Phrase card ───────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    DeutschText(
                      p.phraseDe,
                      ganzeZeile: false, // zentrierte Karte
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    if (p.hasPreposition) ...[
                      const SizedBox(height: 6),
                      DeutschText(ganzeZeile: false, 
                        p.preposition!,
                        style: TextStyle(
                            color: scheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      AppL10n.t(context, 'meaning_question'),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Options ───────────────────────────────────────────
            ...List.generate(_options.length, (i) {
              final isCorrect = _options[i] == _m(p);
              return VoxOptionButton(
                label    : _options[i],
                state    : _answered
                    ? (isCorrect
                        ? VoxOptionState.correct
                        : _selected == i
                            ? VoxOptionState.wrong
                            : VoxOptionState.idle)
                    : (_selected == i
                        ? VoxOptionState.selected
                        : VoxOptionState.idle),
                onPressed: _answered ? null : () => _select(i),
              );
            }),

            const Spacer(),

            // ── Example (shown after answer) ──────────────────────
            if (_answered)
              Card(
                color: scheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    children: [
                      DeutschText(p.exampleDe, ganzeZeile: false, // zentriert
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(AppL10n.meaning(context, fa: p.exampleFa, en: p.exampleEn),
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSizes.sm),
            if (_answered)
              VoxButton.primary(
                label    : _current < _shuffled.length - 1
                    ? AppL10n.t(context, 'next')
                    : AppL10n.t(context, 'results'),
                icon     : Icons.arrow_forward_rounded,
                size     : VoxButtonSize.large,
                expand   : true,
                onPressed: _next,
              ),
          ],
        ),
      ),
    );
  }
}
