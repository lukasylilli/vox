// FILE: lib/features/grammatik/screens/grammar_quiz_screen.dart
// DEPS: grammar_controller.dart, lesson_model.dart, wortstellung_widget.dart, quiz_result_widget.dart
// PURPOSE: Quiz session — one exercise at a time, multiple-choice for Lückentext, score at end
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/widgets/vox_progress.dart';
import '../controllers/grammar_controller.dart';
import '../widgets/quiz_result_widget.dart';
import '../widgets/wortstellung_widget.dart';
import '../../../core/widgets/vox_button.dart';

class GrammarQuizScreen extends ConsumerWidget {
  const GrammarQuizScreen({super.key, required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));
    return lessonAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error  : (e, _) =>
          Scaffold(body: Center(child: Text('${AppL10n.t(context, 'error')}: $e'))),
      data   : (lesson) {
        if (lesson == null || lesson.exercises.isEmpty) {
          return Scaffold(
              body: Center(child: Text(AppL10n.t(context, 'no_exercise'))));
        }
        return _QuizSession(lesson: lesson);
      },
    );
  }
}

class _QuizSession extends StatefulWidget {
  const _QuizSession({required this.lesson});
  final LessonModel lesson;

  @override
  State<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<_QuizSession> {
  int           _index   = 0;
  int           _correct = 0;
  bool          _answered = false;
  String?       _selected;
  final List<WrongItem> _wrongs = [];

  GrammarExercise get _current => widget.lesson.exercises[_index];
  bool get _done => _index >= widget.lesson.exercises.length;

  void _pickOption(String option) {
    if (_answered) return;
    final isRight = option == _current.answer;
    setState(() {
      _selected  = option;
      _answered  = true;
      if (isRight) {
        _correct++;
      } else {
        _wrongs.add(WrongItem(
          question  : _current.template ?? '',
          correct   : _current.answer ?? '',
          userAnswer: option,
        ));
      }
    });
  }

  void _onWortstellungAnswer(bool isCorrect, String userAnswer) {
    if (_answered) return;
    setState(() {
      _answered = true;
      if (isCorrect) {
        _correct++;
      } else {
        _wrongs.add(WrongItem(
          question  : (_current.words ?? []).join(' '),
          correct   : _current.solution ?? '',
          userAnswer: userAnswer,
        ));
      }
    });
  }

  void _next() {
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
  }

  void _restart() => setState(() {
    _index   = 0;
    _correct = 0;
    _answered = false;
    _selected = null;
    _wrongs.clear();
  });

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text(AppL10n.t(context, 'quiz_result'))),
        body  : QuizResultWidget(
          correct     : _correct,
          total       : widget.lesson.exercises.length,
          wrongAnswers: _wrongs,
          onRetry     : _restart,
          onDone      : () => Navigator.of(context).pop(),
        ),
      );
    }

    final ex       = _current;
    final total    = widget.lesson.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _index + 1, total: total),
        bottom: VoxQuizProgressBar.bar(current: _index + 1, total: total),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ex.hint != null)
              Text(ex.hint!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: AppSizes.lg),

            // ── Lueckentext: multiple choice ─────────────────────────
            if (ex.type == ExerciseType.lueckentext) ...[
              if (ex.template != null)
                Text(
                  ex.template!.replaceAll('___', '______'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: AppSizes.lg),
              if (ex.options != null)
                ...ex.options!.map((opt) => VoxOptionButton(
                  label    : opt,
                  state    : !_answered
                      ? VoxOptionState.idle
                      : opt == (ex.answer ?? '')
                          ? VoxOptionState.correct
                          : (opt == _selected
                              ? VoxOptionState.wrong
                              : VoxOptionState.idle),
                  onPressed: _answered ? null : () => _pickOption(opt),
                )),
              if (ex.options == null || ex.options!.isEmpty)
                Text(AppL10n.t(context, 'undefined_option'),
                  style: Theme.of(context).textTheme.bodySmall),
            ],

            // ── Wortstellung: same word-building UI ──────────────────
            if (ex.type == ExerciseType.wortstellung &&
                ex.words != null &&
                ex.solution != null)
              Expanded(
                child: WortstellungWidget(
                  shuffledWords: ex.words!,
                  solution     : ex.solution!,
                  showResult   : _answered,
                  onAnswer     : _onWortstellungAnswer,
                ),
              ),

            const Spacer(),

            if (_answered)
              VoxButton.primary(
                label    : _index + 1 < total
                    ? AppL10n.t(context, 'next')
                    : AppL10n.t(context, 'result'),
                onPressed: _next,
              ),
          ],
        ),
      ),
    );
  }
}
