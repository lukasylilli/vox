// FILE: lib/features/grammatik/screens/level_lessons_screen.dart
// DEPS: grammar_controller.dart, app_routes.dart
// PURPOSE: List of grammar lessons for a specific level (A1–C2)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/grammar_controller.dart';

class LevelLessonsScreen extends ConsumerWidget {
  const LevelLessonsScreen({super.key, required this.level});
  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsByLevelProvider(level));

    return Scaffold(
      appBar: AppBar(title: Text('Grammatik — ${level.toUpperCase()}')),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (lessons) => lessons.isEmpty
            ? _EmptyLevel(level: level)
            : ListView.builder(
                padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount  : lessons.length,
                itemBuilder: (_, i) {
                  final lesson = lessons[i];
                  return _LessonTile(lesson: lesson);
                },
              ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});
  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasEx  = lesson.exercises.isNotEmpty;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Text(
          '${lesson.sortOrder}',
          style: TextStyle(
            color     : scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize  : 13,
          ),
        ),
      ),
      title   : Text(lesson.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          )),
      subtitle: hasEx
          ? Text(Formatters.countLabel(lesson.exercises.length, AppL10n.t(context, 'practice')),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary,
              ))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap   : () => context.push(
        '${AppRoutes.grammatik}/lesson/${lesson.id}',
      ),
    );
  }
}

class _EmptyLevel extends StatelessWidget {
  const _EmptyLevel({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 72,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.lg),
            Text(AppL10n.tf(context, 'no_lessons_for', {'x': level.toUpperCase()}),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'content_from_phase12'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
