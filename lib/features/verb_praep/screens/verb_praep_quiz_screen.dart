// FILE: lib/features/verb_praep/screens/verb_praep_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/verb_praep.dart';
import '../widgets/prep_case_badge.dart';
import '../../../core/widgets/vox_button.dart';

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
  final VerbPraep    verb;
  final List<String> options;
  final int          correctIndex;
  final List<String> shuffledWords;
  final String       clozePrefix;
  final String       clozeSuffix;
  final String       clozeAnswer;
}

class VerbPraepQuizScreen extends StatefulWidget {
  const VerbPraepQuizScreen({super.key, required this.verbs});
  final List<VerbPraep> verbs;

  @override
  State<VerbPraepQuizScreen> createState() => _VerbPraepQuizScreenState();
}

class _VerbPraepQuizScreenState extends State<VerbPraepQuizScreen> {
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

  _Question _makeQuestion(_QuizType type, VerbPraep verb) {
    switch (type) {
      case _QuizType.multiChoice:
        final distractors = widget.verbs
            .where((v) => v.id != verb.id)
            .toList()
          ..shuffle(_rng);
        final opts = ['${verb.verbInfinitive} + ${verb.preposition}',
          ...distractors.take(3).map(
              (v) => '${v.verbInfinitive} + ${v.preposition}')]
          ..shuffle(_rng);
        final answer = '${verb.verbInfinitive} + ${verb.preposition}';
        return _Question(
          type        : type,
          verb        : verb,
          options     : opts,
          correctIndex: opts.indexOf(answer),
        );

      case _QuizType.matchMeaning:
        final distractors = widget.verbs
            .where((v) => v.id != verb.id)
            .toList()
          ..shuffle(_rng);
        String m(VerbPraep v) =>
            AppL10n.activeLang == 'fa' ? v.meaningFa : v.meaningEn;
        final opts = [m(verb),
          ...distractors.take(3).map(m)]
          ..shuffle(_rng);
        return _Question(
          type        : type,
          verb        : verb,
          options     : opts,
          correctIndex: opts.indexOf(m(verb)),
        );

      case _QuizType.wordOrder:
        if (verb.exampleDe.isEmpty) {
          return _makeQuestion(_QuizType.multiChoice, verb);
        }
        final words = verb.exampleDe.split(' ')..shuffle(_rng);
        return _Question(
          type         : type,
          verb         : verb,
          options      : const [],
          correctIndex : -1,
          shuffledWords: words,
        );

      case _QuizType.cloze:
        if (verb.exampleDe.isEmpty) {
          return _makeQuestion(_QuizType.multiChoice, verb);
        }
        final words = verb.exampleDe.split(' ');
        // find the first preposition word in the example
        final prep = verb.preposition.split(' / ').first.toLowerCase();
        final ti = words.indexWhere(
            (w) => w.toLowerCase().replaceAll(RegExp(r'[,.]'), '') == prep);
        if (ti == -1) {
          return _makeQuestion(_QuizType.matchMeaning, verb);
        }
        return _Question(
          type        : _QuizType.cloze,
          verb        : verb,
          options     : const [],
          correctIndex: -1,
          clozePrefix : words.sublist(0, ti).join(' '),
          clozeSuffix : words.sublist(ti + 1).join(' '),
          clozeAnswer : words[ti],
        );
    }
  }

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

  String _prompt(_Question q) => switch (q.type) {
        _QuizType.multiChoice  => AppL10n.meaning(context, fa: q.verb.meaningFa, en: q.verb.meaningEn),
        _QuizType.matchMeaning => '${q.verb.displayVerb} + ${q.verb.preposition}',
        _QuizType.wordOrder    => AppL10n.t(context, 'sort_prompt'),
        _QuizType.cloze        => AppL10n.t(context, 'enter_preposition'),
      };

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
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    PrepCaseBadge(q.verb.prepositionCase),
                    const SizedBox(height: 8),
                    Text(
                      _prompt(q),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody(q, cs)),
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

  Widget _buildBody(_Question q, ColorScheme cs) {
    switch (q.type) {
      case _QuizType.multiChoice:
      case _QuizType.matchMeaning:
        return Column(
          children: List.generate(q.options.length, (i) {
            return VoxOptionButton(
              label    : q.options[i],
              state    : _answered
                  ? (i == q.correctIndex
                      ? VoxOptionState.correct
                      : i == _selected
                          ? VoxOptionState.wrong
                          : VoxOptionState.idle)
                  : (_selected == i
                      ? VoxOptionState.selected
                      : VoxOptionState.idle),
              onPressed: _answered
                  ? null
                  : () => setState(() => _selected = i),
            );
          }),
        );

      case _QuizType.wordOrder:
        final remaining =
            q.shuffledWords.where((w) => !_arranged.contains(w)).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _arranged
                  .map((w) => ActionChip(
                        label    : Text(w),
                        onPressed: _answered
                            ? null
                            : () => setState(() => _arranged.remove(w)),
                      ))
                  .toList(),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: remaining
                  .map((w) => ActionChip(
                        label    : Text(w),
                        onPressed: _answered
                            ? null
                            : () => setState(() => _arranged.add(w)),
                      ))
                  .toList(),
            ),
            if (_answered) ...[
              const SizedBox(height: 12),
              Text('✓ ${q.verb.exampleDe}',
                  style: const TextStyle(color: Colors.green)),
              Text(AppL10n.meaning(context, fa: q.verb.exampleFa,
                  en: q.verb.exampleEn.isNotEmpty ? q.verb.exampleEn : q.verb.exampleFa),
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ],
        );

      case _QuizType.cloze:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: '${q.clozePrefix} '),
                const TextSpan(
                  text : '[___] ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color     : Color(0xFF6A1B9A),
                  ),
                ),
                TextSpan(text: q.clozeSuffix),
              ]),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller     : _clozeCtrl,
              enabled        : !_answered,
              textInputAction: TextInputAction.done,
              onSubmitted    : (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Präposition...',
                border  : OutlineInputBorder(),
                isDense : true,
              ),
            ),
            if (_answered) ...[
              const SizedBox(height: 8),
              Text('✓ ${q.clozeAnswer}',
                  style: const TextStyle(color: Colors.green)),
              Text(AppL10n.meaning(context, fa: q.verb.exampleFa,
                  en: q.verb.exampleEn.isNotEmpty ? q.verb.exampleEn : q.verb.exampleFa),
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ],
        );
    }
  }
}
