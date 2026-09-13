// FILE: lib/features/grammatik/screens/lesson_detail_screen.dart
// DEPS: grammar_controller.dart, lesson_model.dart, app_routes.dart
// PURPOSE: Full lesson — body text + exercise count + two action buttons
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/grammar_controller.dart';
import '../../../core/widgets/vox_button.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({super.key, required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));

    return lessonAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error  : (e, _) => Scaffold(
          body: Center(child: Text('${AppL10n.t(context, 'error')}: $e'))),
      data   : (lesson) {
        if (lesson == null) {
          return Scaffold(body: Center(child: Text(AppL10n.t(context, 'lesson_not_found'))));
        }
        final hasExercises = lesson.exercises.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // ── Level chip ─────────────────────────────────────────
              Container(
                padding   : const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color       : Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(lesson.level.toUpperCase(),
                  style: TextStyle(
                    color     : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize  : 12,
                  )),
              ),

              const SizedBox(height: AppSizes.lg),
              const Divider(),
              const SizedBox(height: AppSizes.md),

              // ── Lesson body ────────────────────────────────────────
              SelectableText(
                lesson.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),

              if (hasExercises) ...[
                const SizedBox(height: AppSizes.xl),
                const Divider(),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(AppL10n.tf(context, 'n_exercises_avail', {'n': Formatters.faDigits(lesson.exercises.length)}),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ],
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),

          // ── Bottom action bar ────────────────────────────────────────
          bottomNavigationBar: hasExercises
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: VoxButton.secondary(
                            label    : AppL10n.t(context, 'practice'),
                            icon     : Icons.edit_rounded,
                            onPressed: () => context.push(
                              '${AppRoutes.grammatik}/lesson/$lessonId/exercise',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: VoxButton.primary(
                            label    : AppL10n.t(context, 'quiz'),
                            icon     : Icons.quiz_rounded,
                            onPressed: () => context.push(
                              '${AppRoutes.grammatik}/lesson/$lessonId/quiz',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
