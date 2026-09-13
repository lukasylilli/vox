// FILE: lib/features/grammatik/screens/grammar_exercise_screen.dart
// DEPS: grammar_controller.dart, lesson_model.dart, lueckentext_widget.dart, wortstellung_widget.dart
// PURPOSE: Open-ended exercise session — all exercises scrollable, check each individually
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/lesson_model.dart';
import '../controllers/grammar_controller.dart';
import '../widgets/lueckentext_widget.dart';
import '../widgets/wortstellung_widget.dart';

class GrammarExerciseScreen extends ConsumerWidget {
  const GrammarExerciseScreen({super.key, required this.lessonId});
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
        return _ExerciseBody(lesson: lesson);
      },
    );
  }
}

class _ExerciseBody extends StatelessWidget {
  const _ExerciseBody({required this.lesson});
  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.tf(context, 'practice_dash', {'x': lesson.title})),
      ),
      body: ListView.separated(
        padding   : const EdgeInsets.all(AppSizes.md),
        itemCount : lesson.exercises.length,
        separatorBuilder: (_, _) => const Divider(height: AppSizes.xl * 2),
        itemBuilder: (_, i) {
          final ex = lesson.exercises[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise number + hint
              Row(
                children: [
                  CircleAvatar(
                    radius         : 13,
                    backgroundColor: scheme.primaryContainer,
                    child: Text('${i + 1}',
                      style: TextStyle(
                        fontSize  : 11,
                        fontWeight: FontWeight.w700,
                        color     : scheme.onPrimaryContainer,
                      )),
                  ),
                  const SizedBox(width: 8),
                  if (ex.hint != null)
                    Expanded(
                      child: Text(ex.hint!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        )),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              // Exercise widget
              if (ex.type == ExerciseType.lueckentext &&
                  ex.template != null &&
                  ex.answer != null)
                LueckentextWidget(
                  exercise     : ex.template!,
                  correctAnswer: ex.answer!,
                  onAnswer     : (_) {},
                )
              else if (ex.type == ExerciseType.wortstellung &&
                  ex.words != null &&
                  ex.solution != null)
                WortstellungWidget(
                  shuffledWords: ex.words!,
                  solution     : ex.solution!,
                  onAnswer     : (_, _) {},
                )
              else
                Text(AppL10n.t(context, 'unknown_exercise'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  )),
            ],
          );
        },
      ),
    );
  }
}
