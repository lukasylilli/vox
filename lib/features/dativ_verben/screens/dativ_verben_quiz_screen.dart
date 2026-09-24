// FILE: lib/features/dativ_verben/screens/dativ_verben_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/dativ_verb.dart';
import '../widgets/case_type_badge.dart';
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

  final _QuizType     type;
  final DativVerb     verb;
  final List<String>  options;
  final int           correctIndex;
  final List<String>  shuffledWords;
  final String        clozePrefix;
  final String        clozeSuffix;
  final String        clozeAnswer;
}

class DativVerbenQuizScreen extends StatefulWidget {
  const DativVerbenQuizScreen({super.key, required this.verbs});

  final List<DativVerb> verbs;

  @override
  State<DativVerbenQuizScreen> createState() => _DativVerbenQuizScreenState();
}

class _DativVerbenQuizScreenState extends State<DativVerbenQuizScreen> {
  final _rng       = Random();
  late List<_Question> _questions;
  int  _current    = 0;
  int  _correct    = 0;
  int? _selected;            // for MC/match
  List<String> _arranged = []; // for word-order
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
    final pool    = [...widget.verbs]..shuffle(_rng);
    final count   = min(_questionCount, pool.length);
    final types   = _QuizType.values;
    final result  = <_Question>[];

    for (var i = 0; i < count; i++) {
      final verb  = pool[i];
      final type  = types[_rng.nextInt(types.length)];
      result.add(_makeQuestion(type, verb));
    }
    return result;
  }

  _Question _makeQuestion(_QuizType type, DativVerb verb) {
    switch (type) {
      case _QuizType.multiChoice:
        return _makeCaseTypeQ(verb);
      case _QuizType.matchMeaning:
        return _makeMeaningQ(verb);
      case _QuizType.wordOrder:
        return _makeWordOrderQ(verb);
      case _QuizType.cloze:
        return _makeClozeQ(verb);
    }
  }

  _Question _makeCaseTypeQ(DativVerb verb) {
    final all     = CaseType.values.toList();
    final correct = all.indexOf(verb.caseType);
    final opts    = all.map((c) => c.labelDe).toList();
    return _Question(type: _QuizType.multiChoice, verb: verb,
        options: opts, correctIndex: correct);
  }

  String _m(DativVerb v) =>
      AppL10n.activeLang == 'fa' ? v.meaningFa : v.meaningEn;

  _Question _makeMeaningQ(DativVerb verb) {
    final distractors = widget.verbs
        .where((v) => v.id != verb.id)
        .toList()
      ..shuffle(_rng);
    final wrongMeanings = distractors.take(3).map(_m).toList();
    final opts = [_m(verb), ...wrongMeanings]..shuffle(_rng);
    return _Question(
      type        : _QuizType.matchMeaning,
      verb        : verb,
      options     : opts,
      correctIndex: opts.indexOf(_m(verb)),
    );
  }

  _Question _makeWordOrderQ(DativVerb verb) {
    final words    = verb.exampleDe.split(' ');
    final shuffled = [...words]..shuffle(_rng);
    return _Question(
      type         : _QuizType.wordOrder,
      verb         : verb,
      options      : [],
      correctIndex : -1,
      shuffledWords: shuffled,
    );
  }

  _Question _makeClozeQ(DativVerb verb) {
    final words   = verb.exampleDe.split(' ');
    // pick a content word to blank (not the first/last, skip articles)
    final skip    = {'der','die','das','ein','eine','ich','du','er','sie','es',
                     'wir','ihr','Sie','mir','dir','ihm','uns','mich','dich',
                     'ihn','nicht','bitte','heute'};
    final indices = <int>[];
    for (var i = 1; i < words.length - 1; i++) {
      if (!skip.contains(words[i].toLowerCase().replaceAll(RegExp(r'[?.!,]'), ''))) {
        indices.add(i);
      }
    }
    if (indices.isEmpty) indices.add(1);
    final blankIdx  = indices[_rng.nextInt(indices.length)];
    final answer    = words[blankIdx];
    final cleanAns  = answer.replaceAll(RegExp(r'[?.!,]'), '');
    return _Question(
      type        : _QuizType.cloze,
      verb        : verb,
      options     : [],
      correctIndex: -1,
      clozePrefix : words.sublist(0, blankIdx).join(' '),
      clozeSuffix : words.sublist(blankIdx + 1).join(' '),
      clozeAnswer : cleanAns,
    );
  }

  // ── answer logic ──────────────────────────────────────────────────────────

  void _answerMC(int idx) {
    if (_answered) return;
    final q = _questions[_current];
    if (q.type == _QuizType.multiChoice || q.type == _QuizType.matchMeaning) {
      final correct = idx == q.correctIndex;
      setState(() {
        _selected = idx;
        _answered = true;
        if (correct) _correct++;
      });
    }
  }

  void _submitWordOrder() {
    if (_answered) return;
    final q       = _questions[_current];
    final attempt = _arranged.join(' ');
    final correct = attempt == q.verb.exampleDe;
    setState(() {
      _answered = true;
      if (correct) _correct++;
    });
  }

  void _submitCloze() {
    if (_answered) return;
    final q       = _questions[_current];
    final attempt = _clozeCtrl.text.trim();
    final correct = attempt.toLowerCase() == q.clozeAnswer.toLowerCase();
    setState(() {
      _answered = true;
      if (correct) _correct++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected  = null;
        _answered  = false;
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
      onBack  : () {},
      onRepeat: () => setState(() {
                _questions = _buildQuestions();
                _current   = 0;
                _correct   = 0;
                _selected  = null;
                _answered  = false;
                _arranged  = [];
                _clozeCtrl.clear();
              }),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppL10n.t(context, 'quiz_of')} (${_current + 1}/${_questions.length})'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child  : Text('$_correct ✓', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_current + 1) / _questions.length,
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child  : switch (q.type) {
                _QuizType.multiChoice  => _MCBody(q, _selected, _answered, _answerMC),
                _QuizType.matchMeaning => _MCBody(q, _selected, _answered, _answerMC,
                    prompt: AppL10n.tf(context, 'meaning_of_which', {'x': q.verb.verbInfinitive})),
                _QuizType.wordOrder    => _WordOrderBody(
                    q       : q,
                    arranged: _arranged,
                    answered: _answered,
                    onArrange: (w) => setState(() => _arranged = w),
                    onSubmit : _submitWordOrder,
                  ),
                _QuizType.cloze        => _ClozeBody(
                    q       : q,
                    ctrl    : _clozeCtrl,
                    answered: _answered,
                    onSubmit: _submitCloze,
                  ),
              },
            ),
          ),
          if (_answered)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child  : VoxButton.primary(
                  label    : _current < _questions.length - 1 ? AppL10n.t(context, 'next') : AppL10n.t(context, 'result'),
                  icon     : Icons.arrow_forward_rounded,
                  size     : VoxButtonSize.large,
                  expand   : true,
                  onPressed: _next,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── multiple-choice body ─────────────────────────────────────────────────────

class _MCBody extends StatelessWidget {
  const _MCBody(this.q, this.selected, this.answered, this.onTap, {this.prompt});

  final _Question q;
  final int?      selected;
  final bool      answered;
  final String?   prompt;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaseTypeBadge(q.verb.caseType, small: true),
        const SizedBox(height: 12),
        Text(
          prompt ?? AppL10n.t(context, 'which_case_question'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        DeutschText(ganzeZeile: false, 
          q.verb.verbInfinitive,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        DeutschText(q.verb.exampleDe, ganzeZeile: false, // zentrierte Spalte
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          return VoxOptionButton(
            label    : q.options[i],
            // matchMeaning zeigt die Übersetzung, alles andere deutsche Formen
            istDeutsch: q.type != _QuizType.matchMeaning,
            state    : answered
                ? (i == q.correctIndex
                    ? VoxOptionState.correct
                    : i == selected
                        ? VoxOptionState.wrong
                        : VoxOptionState.idle)
                : (i == selected
                    ? VoxOptionState.selected
                    : VoxOptionState.idle),
            onPressed: answered ? null : () => onTap(i),
          );
        }),
        // Feedback-Notiz — aktive Sprache aus Settings (فاز L), EN-Fallback → FA
        if (answered && q.verb.note.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FeedbackNote(AppL10n.meaning(context,
              fa: q.verb.note,
              en: q.verb.noteEn.isNotEmpty ? q.verb.noteEn : q.verb.note)),
        ],
      ],
    );
  }
}

// ─── word-order body ──────────────────────────────────────────────────────────

class _WordOrderBody extends StatelessWidget {
  const _WordOrderBody({
    required this.q,
    required this.arranged,
    required this.answered,
    required this.onArrange,
    required this.onSubmit,
  });

  final _Question      q;
  final List<String>   arranged;
  final bool           answered;
  final void Function(List<String>) onArrange;
  final VoidCallback   onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final correct = arranged.join(' ') == q.verb.exampleDe;
    final remaining = q.shuffledWords
        .where((w) => !arranged.contains(w) ||
            arranged.where((a) => a == w).length <
                q.shuffledWords.where((s) => s == w).length)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppL10n.t(context, 'sort_sentence'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('(${AppL10n.meaning(context, fa: q.verb.exampleFa, en: q.verb.exampleEn)})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),
        // arranged zone
        Container(
          width : double.infinity,
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color       : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border      : Border.all(
              color: answered
                  ? (correct ? Colors.green : Colors.red)
                  : cs.outlineVariant,
            ),
          ),
          child: Wrap(
            textDirection: TextDirection.ltr, // deutsche Wortbausteine: Lesereihenfolge
            spacing   : 8,
            runSpacing: 8,
            children  : arranged.map((w) => _WordChip(
              word   : w,
              color  : cs.primaryContainer,
              onTap  : answered ? null : () {
                final copy = [...arranged]..remove(w);
                onArrange(copy);
              },
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // available words
        Wrap(
          textDirection: TextDirection.ltr, // deutsche Wortbausteine: Lesereihenfolge
          spacing   : 8,
          runSpacing: 8,
          children  : remaining.map((w) => _WordChip(
            word  : w,
            color : cs.surfaceContainerHighest,
            onTap : answered ? null : () => onArrange([...arranged, w]),
          )).toList(),
        ),
        const SizedBox(height: 20),
        if (!answered)
          VoxButton.primary(
            label    : AppL10n.t(context, 'check'),
            onPressed: arranged.isNotEmpty ? onSubmit : null,
          ),
        // Meldung folgt der Oberfläche, der deutsche Satz steht getrennt
        // darunter — links, Punkt am Ende (Nachtrag 2026-09-23).
        if (answered)
          Text(
            correct ? AppL10n.t(context, 'correct_check') : AppL10n.t(context, 'answer_wrong_prefix'),
            style: TextStyle(
              color     : correct ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (answered && !correct)
          DeutschText(
            q.verb.exampleDe,
            style: const TextStyle(
              color     : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.color, this.onTap});

  final String     word;
  final Color      color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color       : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DeutschText(ganzeZeile: false, word, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      );
}

// ─── cloze body ───────────────────────────────────────────────────────────────

class _ClozeBody extends StatelessWidget {
  const _ClozeBody({
    required this.q,
    required this.ctrl,
    required this.answered,
    required this.onSubmit,
  });

  final _Question          q;
  final TextEditingController ctrl;
  final bool               answered;
  final VoidCallback        onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final correct = ctrl.text.trim().toLowerCase() == q.clozeAnswer.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppL10n.t(context, 'fill_blank'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('(${AppL10n.meaning(context, fa: q.verb.exampleFa, en: q.verb.exampleEn)})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),
        // sentence with blank
        DeutschRichText(
          TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
            children: [
              if (q.clozePrefix.isNotEmpty)
                TextSpan(text: '${q.clozePrefix} '),
              WidgetSpan(
                child: SizedBox(
                  width : 120,
                  child : TextField(
                    controller  : ctrl,
                    enabled     : !answered,
                    decoration  : InputDecoration(
                      isDense : true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border  : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onSubmitted : (_) => onSubmit(),
                  ),
                ),
              ),
              if (q.clozeSuffix.isNotEmpty)
                TextSpan(text: ' ${q.clozeSuffix}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!answered)
          VoxButton.primary(
            label    : AppL10n.t(context, 'check'),
            onPressed: onSubmit,
          ),
        if (answered)
          // Meldung folgt der Oberfläche, die richtige Antwort ist Deutsch (LTR, 2026-09-23).
          DeutschMitEtikett(
            etikett: correct ? AppL10n.t(context, 'correct_check') : AppL10n.t(context, 'answer_wrong_prefix'),
            wert   : correct ? '' : q.clozeAnswer,
            style: TextStyle(
              color     : correct ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

// ─── feedback note ────────────────────────────────────────────────────────────

class _FeedbackNote extends StatelessWidget {
  const _FeedbackNote(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color       : cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 14, color: cs.tertiary),
          const SizedBox(width: 6),
          Expanded(child: Text(note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6))),
        ],
      ),
    );
  }
}
