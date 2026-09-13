// FILE: lib/features/pruefungen/screens/exam_simulation_screen.dart
// DEPS: pruefungen_controller.dart, exam_question_widget.dart, exam_score_widget.dart
// PURPOSE: شبیه‌سازی آزمون — تایمر + سوال به سوال + نتیجه
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/widgets/vox_progress.dart';
import '../controllers/pruefungen_controller.dart';
import '../widgets/exam_question_widget.dart';
import '../widgets/exam_score_widget.dart';
import '../../../core/widgets/vox_button.dart';

class ExamSimulationScreen extends ConsumerStatefulWidget {
  const ExamSimulationScreen({
    super.key,
    required this.orgKey,
    required this.level,
  });

  final String orgKey;
  final String level;

  @override
  ConsumerState<ExamSimulationScreen> createState() =>
      _ExamSimulationScreenState();
}

class _ExamSimulationScreenState extends ConsumerState<ExamSimulationScreen> {
  List<GrammarExercise> _exercises = [];
  int     _current       = 0;
  bool    _loaded        = false;
  bool    _done          = false;
  int     _correct       = 0;
  int     _elapsedSec    = 0;
  int     _limitSec      = 3600;
  Timer?  _timer;

  // Track user answers per index
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final org  = ExamOrg.values.firstWhere(
      (e) => e.key == widget.orgKey, orElse: () => ExamOrg.goethe);
    _limitSec  = org.timeLimitMinutes(widget.level) * 60;

    final exercises = await ref.read(
      examExercisesProvider((org: widget.orgKey, level: widget.level)).future,
    );

    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _loaded    = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSec++);
      if (_elapsedSec >= _limitSec) _finish();
    });
  }

  void _onAnswer(bool isCorrect, String userAnswer) {
    _userAnswers[_current] = userAnswer;
    if (isCorrect) setState(() => _correct++);
  }

  void _next() {
    if (_current >= _exercises.length - 1) {
      _finish();
    } else {
      setState(() => _current++);
    }
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _done = true);
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _current      = 0;
      _correct      = 0;
      _elapsedSec   = 0;
      _done         = false;
      _userAnswers.clear();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSec++);
      if (_elapsedSec >= _limitSec) _finish();
    });
  }

  String get _timeLeft {
    final remaining = (_limitSec - _elapsedSec).clamp(0, _limitSec);
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _timerColor(BuildContext context) {
    final remaining = _limitSec - _elapsedSec;
    if (remaining < 300) return Theme.of(context).colorScheme.error;
    if (remaining < 600) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final org   = ExamOrg.values.firstWhere(
      (e) => e.key == widget.orgKey, orElse: () => ExamOrg.goethe);
    final title = '${org.shortName} ${widget.level.toUpperCase()}';

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body  : const Center(child: CircularProgressIndicator()),
      );
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body  : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_rounded, size: 64),
              const SizedBox(height: AppSizes.md),
              Text(AppL10n.t(context, 'no_questions')),
              const SizedBox(height: 8),
              Text(AppL10n.t(context, 'content_from_phase12')),
              const SizedBox(height: AppSizes.lg),
              VoxButton.primary(
                label    : AppL10n.t(context, 'back'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body  : ExamScoreWidget(
          correct       : _correct,
          total         : _exercises.length,
          elapsedSeconds: _elapsedSec,
          timeLimitSeconds: _limitSec,
          examTitle     : title,
          onRetry       : _restart,
          onDone        : () => Navigator.pop(context),
        ),
      );
    }

    final exercise = _exercises[_current];

    return Scaffold(
      appBar: AppBar(
        title : Text(title),
        actions: [
          // Timer
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: Center(
              child: Text(
                _timeLeft,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize  : 16,
                  color     : _timerColor(context),
                ),
              ),
            ),
          ),
        ],
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _exercises.length),
      ),
      body: Column(
        children: [
          // Question counter
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${AppL10n.t(context, 'question_progress')} ${_current + 1} / ${_exercises.length}',
                    style: Theme.of(context).textTheme.labelMedium),
                Text('${AppL10n.t(context, 'correct_count')} $_correct',
                    style: TextStyle(
                      color     : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize  : 13,
                    )),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: ExamQuestionWidget(
                key       : ValueKey(_current),
                index     : _current,
                exercise  : exercise,
                onAnswer  : _onAnswer,
                userAnswer: _userAnswers[_current],
              ),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: VoxButton.primary(
              label    : _current < _exercises.length - 1
                  ? AppL10n.t(context, 'next')
                  : AppL10n.t(context, 'finish'),
              expand   : true,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}
