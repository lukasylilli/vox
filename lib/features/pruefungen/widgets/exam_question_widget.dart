// FILE: lib/features/pruefungen/widgets/exam_question_widget.dart
// DEPS: lesson_model.dart, lueckentext_widget.dart, wortstellung_widget.dart
// PURPOSE: یک سوال آزمون — fill-in یا word-order با شماره و hint
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/models/lesson_model.dart';
import '../../grammatik/widgets/lueckentext_widget.dart';
import '../../grammatik/widgets/wortstellung_widget.dart';

class ExamQuestionWidget extends StatelessWidget {
  const ExamQuestionWidget({
    super.key,
    required this.index,
    required this.exercise,
    required this.onAnswer,
    this.showResult = false,
    this.userAnswer,
  });

  final int             index;
  final GrammarExercise exercise;
  // onAnswer(isCorrect, userAnswer)
  final void Function(bool isCorrect, String userAnswer) onAnswer;
  final bool            showResult;
  final String?         userAnswer;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding   : const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color       : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border      : Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + hint
          Row(
            children: [
              CircleAvatar(
                radius         : 14,
                backgroundColor: scheme.primaryContainer,
                child          : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize  : 12,
                    fontWeight: FontWeight.w700,
                    color     : scheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (exercise.hint != null && exercise.hint!.isNotEmpty) ...[
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    exercise.hint!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Exercise widget
          switch (exercise.type) {
            ExerciseType.lueckentext => LueckentextWidget(
                exercise     : exercise.template ?? '',
                correctAnswer: exercise.answer   ?? '',
                showResult   : showResult,
                userAnswer   : userAnswer,
                onAnswer     : (ans) {
                  final correct = ans.trim().toLowerCase() ==
                      (exercise.answer ?? '').trim().toLowerCase();
                  onAnswer(correct, ans);
                },
              ),
            ExerciseType.wortstellung => WortstellungWidget(
                shuffledWords: _shuffle(exercise.words ?? []),
                solution     : exercise.solution ?? '',
                showResult   : showResult,
                onAnswer     : (isCorrect, ans) => onAnswer(isCorrect, ans),
              ),
          },
        ],
      ),
    );
  }

  // Deterministic shuffle keyed by index so rebuild doesn't re-shuffle
  List<String> _shuffle(List<String> words) {
    final copy = List<String>.from(words);
    final rng  = Random(index);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final t = copy[i]; copy[i] = copy[j]; copy[j] = t;
    }
    return copy;
  }
}
