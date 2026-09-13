// FILE: lib/features/lesen/screens/level_texts_screen.dart
// DEPS: lesen_controller.dart, app_routes.dart
// PURPOSE: List of reading texts for a given level
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/lesen_controller.dart';

class LevelTextsScreen extends ConsumerWidget {
  const LevelTextsScreen({super.key, required this.level});
  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textsAsync = ref.watch(textsByLevelProvider(level));

    return Scaffold(
      appBar: AppBar(title: Text('Lesen — ${level.toUpperCase()}')),
      body: textsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (texts) => texts.isEmpty
            ? _EmptyLevel(level: level)
            : ListView.builder(
                padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount  : texts.length,
                itemBuilder: (_, i) => _TextTile(text: texts[i]),
              ),
      ),
    );
  }
}

class _TextTile extends StatelessWidget {
  const _TextTile({required this.text});
  final ReadingText text;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    final preview = text.content.length > 100
        ? '${text.content.substring(0, 100)}…'
        : text.content;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.article_rounded,
            color: scheme.onPrimaryContainer, size: 20),
      ),
      title   : Text(text.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          )),
      subtitle: Text(preview,
          maxLines : 2,
          overflow : TextOverflow.ellipsis,
          style    : theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          )),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap   : () => context.push('/lesen/text/${text.id}'),
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
            Icon(Icons.article_rounded, size: 72,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.lg),
            Text(AppL10n.tf(context, 'no_texts_for', {'x': level.toUpperCase()}),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'content_from_phase12'),
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
