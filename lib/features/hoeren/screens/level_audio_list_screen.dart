// FILE: lib/features/hoeren/screens/level_audio_list_screen.dart
// DEPS: hoeren_controller.dart
// PURPOSE: List of audio items for a given level — tap → karaoke screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/hoeren_controller.dart';
import '../../../core/widgets/vox_button.dart';

class LevelAudioListScreen extends ConsumerWidget {
  const LevelAudioListScreen({super.key, required this.level});
  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(audioByLevelProvider(level));

    return Scaffold(
      appBar: AppBar(title: Text('Hören — ${level.toUpperCase()}')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (items) => items.isEmpty
            ? _EmptyLevel(level: level)
            : ListView.separated(
                padding        : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount      : items.length,
                separatorBuilder: (_, i) => const Divider(height: 1),
                itemBuilder    : (_, i) => _AudioTile(item: items[i]),
              ),
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({required this.item});
  final AudioItem item;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasTranscript = item.transcript != null && item.transcript!.isNotEmpty;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.headphones_rounded,
            color: scheme.onPrimaryContainer, size: 20),
      ),
      title: Text(item.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          )),
      subtitle: Text(
        hasTranscript
            ? AppL10n.t(context, 'with_transcript')
            : AppL10n.t(context, 'audio_only_short'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTranscript) ...[
            VoxIconButton(
              icon: Icons.lyrics_rounded, iconSize: 20,
              tooltip: AppL10n.t(context, 'karaoke'),
              onPressed: () =>
                  context.push('/hoeren/karaoke/${item.id}'),
            ),
            VoxIconButton(
              icon: Icons.record_voice_over_rounded, iconSize: 20,
              tooltip: AppL10n.t(context, 'shadowing_title'),
              onPressed: () =>
                  context.push('/hoeren/shadowing/${item.id}'),
            ),
          ],
          VoxIconButton(
            icon: Icons.quiz_rounded, iconSize: 20,
            tooltip: AppL10n.t(context, 'quiz'),
            onPressed: () =>
                context.push('/hoeren/quiz/${item.id}'),
          ),
        ],
      ),
      onTap: () => context.push('/hoeren/karaoke/${item.id}'),
    );
  }
}

class _EmptyLevel extends StatelessWidget {
  const _EmptyLevel({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headphones_rounded,
                size: 72,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.lg),
            Text(AppL10n.t(context, 'no_audio_for_level'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'content_from_phase12'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
