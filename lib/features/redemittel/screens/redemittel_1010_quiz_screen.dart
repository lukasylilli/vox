// FILE: lib/features/redemittel/screens/redemittel_1010_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/redemittel_item.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

enum _QuizType { multiChoice, matchMeaning, fillBlank, wordOrder }

class _Question {
  _Question({
    required this.type,
    required this.phrase,
    required this.options,
    required this.correctIndex,
    this.shuffledWords = const [],
    this.fillPrefix    = '',
    this.fillSuffix    = '',
    this.fillAnswer    = '',
  });

  final _QuizType        type;
  final RedemittelItem   phrase;
  final List<String>     options;
  final int              correctIndex;
  final List<String>     shuffledWords;
  final String           fillPrefix;
  final String           fillSuffix;
  final String           fillAnswer;
}

class Redemittel1010QuizScreen extends StatefulWidget {
  const Redemittel1010QuizScreen({
    super.key,
    required this.phrases,
  });

  final List<RedemittelItem> phrases;

  @override
  State<Redemittel1010QuizScreen> createState() =>
      _Redemittel1010QuizScreenState();
}

class _Redemittel1010QuizScreenState
    extends State<Redemittel1010QuizScreen> {
  final _rng       = Random();
  late List<_Question> _questions;
  int  _current    = 0;
  int  _correct    = 0;
  int? _selected;
  List<String> _arranged = [];
  final _fillCtrl  = TextEditingController();
  bool _answered   = false;

  static const _questionCount = 10;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    super.dispose();
  }

  // ─── question builder ───────────────────────────────────────────────────────

  /// Bedeutung in der aktiven Sprache (فاز L) — initState-sicher über
  /// AppL10n.activeLang (kein context nötig); EN-Fallback → FA.
  String _meaning(RedemittelItem p) => AppL10n.activeLang == 'fa'
      ? p.phraseFa
      : (p.phraseEn.isNotEmpty ? p.phraseEn : p.phraseFa);

  List<_Question> _buildQuestions() {
    final pool  = [...widget.phrases]..shuffle(_rng);
    final count = min(_questionCount, pool.length);
    final types = _QuizType.values;
    final result = <_Question>[];
    for (var i = 0; i < count; i++) {
      final phrase = pool[i];
      final type   = types[_rng.nextInt(types.length)];
      result.add(_makeQuestion(type, phrase));
    }
    return result;
  }

  _Question _makeQuestion(_QuizType type, RedemittelItem phrase) {
    switch (type) {
      // ── Multiple choice: show German, pick meaning (aktive Sprache) ────────
      // phrase.distractors sind DEUTSCHE Lückentext-Bausteine (fillBlank) —
      // hier NICHT verwenden, sonst mischen sich Sprachen in den Optionen.
      case _QuizType.multiChoice: {
        final korrekt = _meaning(phrase);
        final andere = (widget.phrases
                .where((p) => p.id != phrase.id)
                .toList()
              ..shuffle(_rng))
            .map(_meaning)
            .where((m) => m != korrekt)
            .take(3)
            .toList();
        final opts = [korrekt, ...andere]..shuffle(_rng);
        return _Question(
          type        : type,
          phrase      : phrase,
          options     : opts,
          correctIndex: opts.indexOf(korrekt),
        );
      }

      // ── Match meaning: show Persian, pick German ───────────────────────────
      case _QuizType.matchMeaning: {
        final others = widget.phrases
            .where((p) => p.id != phrase.id)
            .toList()
          ..shuffle(_rng);
        final opts = [phrase.phraseDe, ...others.take(3).map((p) => p.phraseDe)]
          ..shuffle(_rng);
        return _Question(
          type        : type,
          phrase      : phrase,
          options     : opts,
          correctIndex: opts.indexOf(phrase.phraseDe),
        );
      }

      // ── Fill-in-the-blank using fill_blank_target ──────────────────────────
      case _QuizType.fillBlank: {
        if (phrase.fillBlankTarget.isEmpty) {
          return _makeQuestion(_QuizType.multiChoice, phrase);
        }
        // Build options from phrase.distractors + correct answer
        final distractors = phrase.distractors.isNotEmpty
            ? phrase.distractors.take(3).toList()
            : widget.phrases
                .where((p) => p.id != phrase.id && p.fillBlankTarget.isNotEmpty)
                .map((p) => p.fillBlankTarget)
                .take(3)
                .toList();
        final opts = [phrase.fillBlankTarget, ...distractors]..shuffle(_rng);
        return _Question(
          type        : type,
          phrase      : phrase,
          options     : opts,
          correctIndex: opts.indexOf(phrase.fillBlankTarget),
          fillPrefix  : '',
          fillSuffix  : _meaning(phrase),
          fillAnswer  : phrase.fillBlankTarget,
        );
      }

      // ── Word order: rearrange example sentence ─────────────────────────────
      case _QuizType.wordOrder: {
        final example = phrase.exampleDe;
        if (example.isEmpty) {
          return _makeQuestion(_QuizType.multiChoice, phrase);
        }
        final words = example.split(' ')..shuffle(_rng);
        return _Question(
          type         : type,
          phrase       : phrase,
          options      : const [],
          correctIndex : -1,
          shuffledWords: words,
        );
      }
    }
  }

  // ─── answer checking ────────────────────────────────────────────────────────

  bool _isCorrect() {
    final q = _questions[_current];
    switch (q.type) {
      case _QuizType.multiChoice:
      case _QuizType.matchMeaning:
      case _QuizType.fillBlank:
        return _selected == q.correctIndex;
      case _QuizType.wordOrder:
        return _arranged.join(' ') == q.phrase.exampleDe;
    }
  }

  void _submit() {
    if (_answered) return;
    final q = _questions[_current];
    // word order: require at least one word arranged
    if (q.type == _QuizType.wordOrder && _arranged.isEmpty) return;
    // choice questions: require a selection
    if ((q.type == _QuizType.multiChoice ||
            q.type == _QuizType.matchMeaning ||
            q.type == _QuizType.fillBlank) &&
        _selected == null) { return; }
    final ok = _isCorrect();
    setState(() {
      _answered = true;
      if (ok) {
        _correct++;
      }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _answered = false;
        _selected = null;
        _arranged = [];
        _fillCtrl.clear();
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
                _fillCtrl.clear();
              }),
    );
  }

  // ─── prompt text ────────────────────────────────────────────────────────────

  String _prompt(_Question q) => switch (q.type) {
        _QuizType.multiChoice  => AppL10n.t(context, 'meaning_which'),
        _QuizType.matchMeaning => AppL10n.t(context, 'german_phrase_which'),
        _QuizType.fillBlank    => AppL10n.t(context, 'starter_phrase_which'),
        _QuizType.wordOrder    => AppL10n.t(context, 'arrange_sentence'),
      };

  // ─── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppL10n.t(context, 'quiz_of'))),
        body  : Center(child: Text(AppL10n.t(context, 'no_phrases_quiz'))),
      );
    }

    final q  = _questions[_current];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _current + 1, total: _questions.length),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _questions.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Question card ──────────────────────────────────────────────
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    // type label + section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QuizTypeBadge(q.type),
                        const SizedBox(width: 8),
                        Flexible(
                          child: DeutschText(
                            q.phrase.sectionTitleDe,
                            ganzeZeile: false, // zentrierte Kopfzeile
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // phrase prompt
                    // Deutsch bleibt LTR; die Übersetzung folgt der Oberfläche.
                    switch (q.type) {
                      _QuizType.multiChoice || _QuizType.wordOrder =>
                        DeutschText(
                          q.phrase.phraseDe,
                          textAlign: TextAlign.center,
                          style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, height: 1.5),
                        ),
                      _QuizType.matchMeaning => Text(
                          _meaning(q.phrase),
                          textAlign: TextAlign.center,
                          style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, height: 1.5),
                        ),
                      _QuizType.fillBlank => Text(
                          '___  ${_meaning(q.phrase)}',
                          textAlign: TextAlign.center,
                          style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, height: 1.5),
                        ),
                    },
                    const SizedBox(height: 8),
                    Text(
                      _prompt(q),
                      style: tt.labelMedium
                          ?.copyWith(color: cs.primary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Answer area ────────────────────────────────────────────────
            Expanded(child: _buildBody(q, cs, tt)),
            const SizedBox(height: AppSizes.sm),

            // ── Action button ──────────────────────────────────────────────
            VoxButton.primary(
              label    : _answered
                  ? (_current < _questions.length - 1 ? AppL10n.t(context, 'next') : AppL10n.t(context, 'finish'))
                  : AppL10n.t(context, 'check'),
              onPressed: _answered ? _next : _submit,
            ),
          ],
        ),
      ),
    );
  }

  // ─── answer body per type ───────────────────────────────────────────────────

  Widget _buildBody(_Question q, ColorScheme cs, TextTheme tt) {
    switch (q.type) {
      case _QuizType.multiChoice:
      case _QuizType.matchMeaning:
      case _QuizType.fillBlank:
        return ListView(
          children: List.generate(q.options.length, (i) {
            return VoxOptionButton(
              label    : q.options[i],
              // matchMeaning zeigt Uebersetzungen, multiChoice/fillBlank deutsche Phrasen
              istDeutsch: q.type != _QuizType.matchMeaning,
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

      case _QuizType.wordOrder: {
        final remaining = q.shuffledWords
            .where((w) => !_arranged.contains(w))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // arranged words (tap to remove)
            Container(
              width     : double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              padding   : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color       : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border      : Border.all(color: cs.outlineVariant),
              ),
              child: _arranged.isEmpty
                  ? Text(AppL10n.t(context, 'build_phrase_here'),
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant))
                  : Wrap(
                      spacing: 6, runSpacing: 6,
                      children: _arranged.map((w) => ActionChip(
                            label    : DeutschText(w, ganzeZeile: false),
                            onPressed: _answered
                                ? null
                                : () => setState(
                                    () => _arranged.remove(w)),
                          )).toList(),
                    ),
            ),
            const SizedBox(height: 12),
            // remaining words (tap to add)
            Wrap(
              spacing: 6, runSpacing: 6,
              children: remaining.map((w) => ActionChip(
                    label    : DeutschText(w, ganzeZeile: false),
                    onPressed: _answered
                        ? null
                        : () => setState(() => _arranged.add(w)),
                  )).toList(),
            ),
            if (_answered) ...[
              const SizedBox(height: 12),
              DeutschText(
                '✓ ${q.phrase.exampleDe}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // aktive Sprache aus Settings (فاز L), EN-Fallback → FA
              Text(
                AppL10n.meaning(context,
                    fa: q.phrase.exampleFa,
                    en: q.phrase.exampleEn.isNotEmpty
                        ? q.phrase.exampleEn
                        : q.phrase.exampleFa),
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        );
      }
    }
  }
}

// ─── quiz type badge ───────────────────────────────────────────────────────────

class _QuizTypeBadge extends StatelessWidget {
  const _QuizTypeBadge(this.type);
  final _QuizType type;

  static (String, Color) _meta(_QuizType t) => switch (t) {
        _QuizType.multiChoice  => ('Multiple Choice', Color(0xFF1565C0)),
        _QuizType.matchMeaning => ('Match', Color(0xFF2E7D32)),
        _QuizType.fillBlank    => ('Fill Blank', Color(0xFF6A1B9A)),
        _QuizType.wordOrder    => ('Word Order', Color(0xFFBF360C)),
      };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _meta(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
