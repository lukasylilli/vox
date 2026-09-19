// FILE: lib/features/konnektoren/screens/konnektoren_quiz_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../controllers/konnektoren_controller.dart';
import '../models/konnektor.dart';
import '../models/konnektor_rich.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class KonnektorenQuizScreen extends ConsumerStatefulWidget {
  const KonnektorenQuizScreen({super.key, required this.richEntries});
  final List<KonnektorRich> richEntries;

  @override
  ConsumerState<KonnektorenQuizScreen> createState() =>
      _KonnektorenQuizScreenState();
}

class _KonnektorenQuizScreenState
    extends ConsumerState<KonnektorenQuizScreen> {
  late List<_QuizItem> _questions;
  int  _current  = 0;
  int  _correct  = 0;
  bool _answered = false;
  int? _selected;        // index of chosen option
  List<String> _wordOrder = []; // for word_order exercises

  @override
  void initState() {
    super.initState();
    _questions = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_questions.isEmpty) {
      _buildQuestions();
    }
  }

  void _buildQuestions() {
    final all = ref.read(konnektorenProvider).valueOrNull ?? [];
    final byId = {for (final k in all) k.id: k};
    final rng  = Random();

    final pool = <_QuizItem>[];
    for (final rich in widget.richEntries) {
      for (final ex in rich.exercisePool) {
        pool.add(_QuizItem(rich: rich, exercise: ex, byId: byId));
      }
    }
    pool.shuffle(rng);
    setState(() {
      _questions = pool.take(min(10, pool.length)).toList();
      if (_questions.isNotEmpty) {
        _initWordOrder();
      }
    });
  }

  void _initWordOrder() {
    final ex = _questions[_current].exercise;
    if (ex is WordOrderExercise) {
      _wordOrder = List<String>.from(ex.words)..shuffle();
    } else {
      _wordOrder = [];
    }
  }

  void _selectOption(int idx, String answer, bool isCorrect) {
    if (_answered) { return; }
    setState(() {
      _answered = true;
      _selected = idx;
      if (isCorrect) { _correct++; }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _answered = false;
        _selected = null;
        _initWordOrder();
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    VoxDialog.quizResult(
      context,
      correct : _correct,
      total   : _questions.length,
      onBack  : () {},
      onRepeat: () => setState(() {
                _current   = 0;
                _correct   = 0;
                _answered  = false;
                _selected  = null;
                _buildQuestions();
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppL10n.t(context, 'konnektor_quiz_title'))),
        body  : const Center(child: CircularProgressIndicator()),
      );
    }

    final q  = _questions[_current];
    final ex = q.exercise;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _current + 1, total: _questions.length),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _questions.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ConnectorLabel(q.rich.connector),
            const SizedBox(height: 20),
            Expanded(
              child: switch (ex) {
                FillBlankExercise()      => _FillBlankBody(
                    exercise : ex,
                    item     : q,
                    answered : _answered,
                    selected : _selected,
                    onSelect : _selectOption,
                  ),
                MultipleChoiceExercise() => _MCBody(
                    exercise : ex,
                    answered : _answered,
                    selected : _selected,
                    onSelect : _selectOption,
                  ),
                WordOrderExercise()      => _WordOrderBody(
                    exercise    : ex,
                    wordOrder   : _wordOrder,
                    answered    : _answered,
                    onWordTap   : (i) {
                      if (_answered) { return; }
                      setState(() => _wordOrder.removeAt(i));
                    },
                    onSubmit    : () {
                      final answer  = _wordOrder.join(' ');
                      final correct = answer.toLowerCase() ==
                          ex.correct.toLowerCase();
                      _selectOption(0, answer, correct);
                    },
                  ),
                TranslationExercise()    => _TranslationBody(
                    exercise: ex,
                    answered: _answered,
                    onReveal: () => _selectOption(0, ex.answerDe, true),
                  ),
              },
            ),
            if (_answered) ...[
              const SizedBox(height: 16),
              VoxButton.primary(
                label    : _current < _questions.length - 1
                    ? AppL10n.t(context, 'next')
                    : AppL10n.t(context, 'results'),
                onPressed: _next,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── data class ───────────────────────────────────────────────────────────────

class _QuizItem {
  const _QuizItem({
    required this.rich,
    required this.exercise,
    required this.byId,
  });
  final KonnektorRich      rich;
  final ExerciseItem       exercise;
  final Map<int, Konnektor> byId;
}

// ─── UI sub-widgets ───────────────────────────────────────────────────────────

class _ConnectorLabel extends StatelessWidget {
  const _ConnectorLabel(this.connector);
  final String connector;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color       : cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        connector,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FillBlankBody extends StatelessWidget {
  const _FillBlankBody({
    required this.exercise,
    required this.item,
    required this.answered,
    required this.selected,
    required this.onSelect,
  });
  final FillBlankExercise               exercise;
  final _QuizItem                       item;
  final bool                            answered;
  final int?                            selected;
  final void Function(int, String, bool) onSelect;

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();
    final prompt  = exercise.promptDe.replaceAll('___', '________');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prompt,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(height: 1.7)),
        const SizedBox(height: 20),
        ...List.generate(options.length, (i) {
          final opt       = options[i];
          final isCorrect = opt == exercise.answer;
          return VoxOptionButton(
            label    : opt,
            istDeutsch: true, // Konnektoren und Lueckensaetze sind deutsch
            state    : !answered
                ? VoxOptionState.idle
                : isCorrect
                    ? VoxOptionState.correct
                    : (selected == i
                        ? VoxOptionState.wrong
                        : VoxOptionState.idle),
            onPressed: answered ? null : () => onSelect(i, opt, isCorrect),
          );
        }),
      ],
    );
  }

  List<String> _buildOptions() {
    final opts = <String>[exercise.answer];
    for (final id in exercise.distractorIds) {
      final k = item.byId[id];
      if (k != null) { opts.add(k.connector); }
    }
    opts.shuffle();
    return opts.take(4).toList();
  }
}

class _MCBody extends StatelessWidget {
  const _MCBody({
    required this.exercise,
    required this.answered,
    required this.selected,
    required this.onSelect,
  });
  final MultipleChoiceExercise          exercise;
  final bool                            answered;
  final int?                            selected;
  final void Function(int, String, bool) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeutschText(exercise.promptDe,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(height: 1.7)),
        const SizedBox(height: 20),
        ...List.generate(exercise.options.length, (i) {
          final opt       = exercise.options[i];
          final isCorrect = i == exercise.answerIndex;
          return VoxOptionButton(
            label    : opt,
            istDeutsch: true, // Konnektoren und Lueckensaetze sind deutsch
            state    : !answered
                ? VoxOptionState.idle
                : isCorrect
                    ? VoxOptionState.correct
                    : (selected == i
                        ? VoxOptionState.wrong
                        : VoxOptionState.idle),
            onPressed: answered ? null : () => onSelect(i, opt, isCorrect),
          );
        }),
      ],
    );
  }
}

class _WordOrderBody extends StatelessWidget {
  const _WordOrderBody({
    required this.exercise,
    required this.wordOrder,
    required this.answered,
    required this.onWordTap,
    required this.onSubmit,
  });
  final WordOrderExercise exercise;
  final List<String>      wordOrder;
  final bool              answered;
  final void Function(int) onWordTap;
  final VoidCallback       onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = wordOrder.join(' ');
    final isRight = current.toLowerCase() == exercise.correct.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.context.isNotEmpty)
          Text(exercise.context,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        Container(
          width      : double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding    : const EdgeInsets.all(12),
          decoration : BoxDecoration(
            color       : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border      : answered
                ? Border.all(
                    color: isRight ? Colors.green : cs.error,
                    width: 2)
                : null,
          ),
          child: Text(
            current.isEmpty ? '...' : current,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing   : 8,
          runSpacing: 8,
          children  : List.generate(wordOrder.length, (i) => GestureDetector(
            onTap : () => onWordTap(i),
            child : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color       : cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(wordOrder[i]),
            ),
          )),
        ),
        const SizedBox(height: 16),
        if (!answered)
          VoxButton.secondary(
            label    : AppL10n.t(context, 'confirm'),
            onPressed: onSubmit,
          ),
        if (answered)
          Text(
            isRight ? AppL10n.t(context, 'correct_check') : '${AppL10n.t(context, 'answer_wrong_prefix')} ${exercise.correct}',
            style: TextStyle(
              color     : isRight ? Colors.green : cs.error,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _TranslationBody extends StatelessWidget {
  const _TranslationBody({
    required this.exercise,
    required this.answered,
    required this.onReveal,
  });
  final TranslationExercise exercise;
  final bool                answered;
  final VoidCallback        onReveal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppL10n.t(context, 'translate'),
            style: TextStyle(
                fontSize: 12, color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color       : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(AppL10n.meaning(context, fa: exercise.promptFa, en: exercise.promptEn),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(height: 1.6)),
        ),
        const SizedBox(height: 20),
        if (!answered)
          VoxButton.secondary(
            label    : AppL10n.t(context, 'show_answer'),
            onPressed: onReveal,
          ),
        if (answered)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color       : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border      : Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Text(exercise.answerDe,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600, height: 1.6)),
          ),
      ],
    );
  }
}
