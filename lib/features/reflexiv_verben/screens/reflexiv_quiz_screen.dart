// FILE: lib/features/reflexiv_verben/screens/reflexiv_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/reflexiv_verb.dart';
import '../widgets/reflexivity_type_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

enum _QuizType { multiChoice, matchMeaning, wordOrder, cloze }

class _Question {
  _Question({
    required this.type,
    required this.verb,
    required this.options,
    required this.correctIndex,
    this.shuffledWords = const [],
    this.clozePrefix   = '',
    this.clozeSuffix   = '',
    this.clozeAnswer   = '',
  });

  final _QuizType    type;
  final ReflexivVerb verb;
  final List<String> options;
  final int          correctIndex;
  final List<String> shuffledWords;
  final String       clozePrefix;
  final String       clozeSuffix;
  final String       clozeAnswer;
}

class ReflexivQuizScreen extends StatefulWidget {
  const ReflexivQuizScreen({super.key, required this.verbs});

  final List<ReflexivVerb> verbs;

  @override
  State<ReflexivQuizScreen> createState() => _ReflexivQuizScreenState();
}

class _ReflexivQuizScreenState extends State<ReflexivQuizScreen> {
  final _rng       = Random();
  late List<_Question> _questions;
  int  _current    = 0;
  int  _correct    = 0;
  int? _selected;
  List<String> _arranged = [];
  final _clozeCtrl = TextEditingController();
  bool _answered   = false;

  static const _questionCount = 10;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  @override
  void dispose() {
    _clozeCtrl.dispose();
    super.dispose();
  }

  // ── question generation ───────────────────────────────────────────────────

  List<_Question> _buildQuestions() {
    final pool  = [...widget.verbs]..shuffle(_rng);
    final count = min(_questionCount, pool.length);
    final types = _QuizType.values;
    final result = <_Question>[];

    for (var i = 0; i < count; i++) {
      final verb = pool[i];
      final type = types[_rng.nextInt(types.length)];
      result.add(_makeQuestion(type, verb));
    }
    return result;
  }

  _Question _makeQuestion(_QuizType type, ReflexivVerb verb) {
    switch (type) {
      case _QuizType.multiChoice:
        final distractors = widget.verbs
            .where((v) => v.id != verb.id)
            .toList()
          ..shuffle(_rng);
        final opts = [verb.verbInfinitive,
          ...distractors.take(3).map((v) => v.verbInfinitive)]
          ..shuffle(_rng);
        return _Question(
          type        : type,
          verb        : verb,
          options     : opts,
          correctIndex: opts.indexOf(verb.verbInfinitive),
        );

      case _QuizType.matchMeaning:
        final distractors = widget.verbs
            .where((v) => v.id != verb.id)
            .toList()
          ..shuffle(_rng);
        final opts = [verb.meaningFa,
          ...distractors.take(3).map((v) => v.meaningFa)]
          ..shuffle(_rng);
        return _Question(
          type        : type,
          verb        : verb,
          options     : opts,
          correctIndex: opts.indexOf(verb.meaningFa),
        );

      case _QuizType.wordOrder:
        final words = verb.exampleDe.split(' ')..shuffle(_rng);
        return _Question(
          type         : type,
          verb         : verb,
          options      : const [],
          correctIndex : -1,
          shuffledWords: words,
        );

      case _QuizType.cloze:
        final words = verb.exampleDe.split(' ');
        // pick the infinitive stem as the target
        final stem = verb.verbInfinitive.replaceFirst('sich ', '');
        final ti   = words.indexWhere(
            (w) => w.toLowerCase().contains(stem.toLowerCase().split(' ').first));
        if (ti == -1) {
          // fallback to multiChoice
          return _makeQuestion(_QuizType.multiChoice, verb);
        }
        return _Question(
          type       : _QuizType.cloze,
          verb       : verb,
          options    : const [],
          correctIndex: -1,
          clozePrefix: words.sublist(0, ti).join(' '),
          clozeSuffix: words.sublist(ti + 1).join(' '),
          clozeAnswer: words[ti],
        );
    }
  }

  // ── answer handling ───────────────────────────────────────────────────────

  bool _isCorrect() {
    final q = _questions[_current];
    switch (q.type) {
      case _QuizType.multiChoice:
      case _QuizType.matchMeaning:
        return _selected == q.correctIndex;
      case _QuizType.wordOrder:
        return _arranged.join(' ') == q.verb.exampleDe;
      case _QuizType.cloze:
        return _clozeCtrl.text.trim().toLowerCase() ==
            q.clozeAnswer.toLowerCase();
    }
  }

  void _submit() {
    if (_answered) return;
    final ok = _isCorrect();
    setState(() {
      _answered = true;
      if (ok) _correct++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _answered  = false;
        _selected  = null;
        _arranged  = [];
        _clozeCtrl.clear();
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
      onBack  : () => Navigator.pop(context),
      onRepeat: () => setState(() {
                _questions = _buildQuestions();
                _current   = 0;
                _correct   = 0;
                _answered  = false;
                _selected  = null;
                _arranged  = [];
                _clozeCtrl.clear();
              }),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final q  = _questions[_current];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _current + 1, total: _questions.length),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _questions.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── verb card ─────────────────────────────────────────────────
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ReflexivityTypeBadge(q.verb.reflexivityType),
                    const SizedBox(height: 8),
                    Text(
                      _prompt(q),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (q.type == _QuizType.matchMeaning ||
                        q.type == _QuizType.cloze) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppL10n.t(context, 'meaning'),
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── question body ─────────────────────────────────────────────
            Expanded(child: _buildBody(q, cs)),

            // ── action button ─────────────────────────────────────────────
            const SizedBox(height: 12),
            VoxButton.primary(
              label    : _answered
                  ? (_current < _questions.length - 1
                      ? AppL10n.t(context, 'next')
                      : AppL10n.t(context, 'finish'))
                  : AppL10n.t(context, 'check'),
              onPressed: _answered ? _next : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _prompt(_Question q) => switch (q.type) {
        _QuizType.multiChoice  => AppL10n.meaning(context,
            fa: q.verb.meaningFa, en: q.verb.meaningEn),
        _QuizType.matchMeaning => q.verb.verbInfinitive,
        _QuizType.wordOrder    => AppL10n.t(context, 'arrange_words'),
        _QuizType.cloze        => q.verb.verbInfinitive,
      };

  Widget _buildBody(_Question q, ColorScheme cs) {
    switch (q.type) {
      case _QuizType.multiChoice:
      case _QuizType.matchMeaning:
        return ListView.separated(
          itemCount       : q.options.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder     : (_, i) {
            final state = _answered
                ? (i == q.correctIndex
                    ? VoxOptionState.correct
                    : i == _selected
                        ? VoxOptionState.wrong
                        : VoxOptionState.idle)
                : (_selected == i
                    ? VoxOptionState.selected
                    : VoxOptionState.idle);
            return VoxOptionButton(
              label    : q.options[i],
              // matchMeaning zeigt die Übersetzung, alles andere deutsche Formen
              istDeutsch: q.type != _QuizType.matchMeaning,
              state    : state,
              onPressed:
                  _answered ? null : () => setState(() => _selected = i),
            );
          },
        );

      case _QuizType.wordOrder:
        final placed = _arranged.toSet();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // arranged area
            Container(
              padding   : const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border      : Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _arranged
                    .map((w) => ActionChip(
                          label    : Text(w),
                          onPressed: _answered
                              ? null
                              : () => setState(
                                  () => _arranged.remove(w)),
                        ))
                    .toList(),
              ),
            ),
            if (_answered) ...[
              const SizedBox(height: 8),
              DeutschText(
                q.verb.exampleDe,
                style: TextStyle(
                    color     : _isCorrect() ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 12),
            // word bank
            Wrap(
              spacing  : 6,
              runSpacing: 6,
              children : q.shuffledWords
                  .where((w) => !placed.contains(w))
                  .map((w) => ActionChip(
                        label    : Text(w),
                        onPressed: _answered
                            ? null
                            : () => setState(() => _arranged.add(w)),
                      ))
                  .toList(),
            ),
          ],
        );

      case _QuizType.cloze:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${q.clozePrefix} ___ ${q.clozeSuffix}',
                style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 16),
            TextField(
              controller     : _clozeCtrl,
              enabled        : !_answered,
              textInputAction: TextInputAction.done,
              onSubmitted    : (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Antwort eingeben...',
                border  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (_answered) ...[
              const SizedBox(height: 8),
              Text(
                q.clozeAnswer,
                style: TextStyle(
                    color     : _isCorrect() ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ],
        );
    }
  }
}
