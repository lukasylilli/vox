// FILE: lib/features/wortschatz/screens/word_detail_screen.dart
// DEPS: wordByIdProvider, WordModel, ArticleBadge, AudioPlayButton, ConjugationTable
// PURPOSE: Full word detail — all fields + action buttons (Leitner, Grammar, Quiz)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/article_badge.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/leitner_add_button.dart';
import '../../../core/widgets/quiz_launch_button.dart';
import '../../../features/categories/widgets/add_to_category_sheet.dart';
import '../controllers/word_controller.dart';
import '../widgets/conjugation_table.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({super.key, required this.wordId});

  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordByIdProvider(wordId));

    return wordAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error  : (e, _) => Scaffold(body: Center(child: Text('${AppL10n.t(context, 'error')}: $e'))),
      data   : (word) {
        if (word == null) {
          return Scaffold(body: Center(child: Text(AppL10n.t(context, 'not_found'))));
        }
        final model = word.toModel();
        return _WordDetailView(model: model);
      },
    );
  }
}

class _WordDetailView extends StatelessWidget {
  const _WordDetailView({required this.model});
  final WordModel model;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title  : DeutschText(model.german, ganzeZeile: false),
        actions: [
          AudioPlayButton(text: model.displayGerman),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── German word + article ───────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  model.german,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (model.article != null)
                ArticleBadge(article: model.article, large: true),
            ],
          ),

          // Plural
          if (model.plural != null) ...[
            const SizedBox(height: 4),
            Text('${AppL10n.t(context, 'plural_label')} ${model.plural}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              )),
          ],

          // Level chip
          if (model.level != null) ...[
            const SizedBox(height: 8),
            _Chip(label: model.level!.label, color: scheme.primary),
          ],

          const SizedBox(height: AppSizes.lg),
          const Divider(),
          const SizedBox(height: AppSizes.md),

          // ── Meanings ────────────────────────────────────────────────────
          _Section(
            title: AppL10n.t(context, 'meaning'),
            child: Text(
              AppL10n.meaning(context,
                  fa: model.meaningFa,
                  en: model.meaningEn ?? model.meaningFa),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ── Pronunciation ───────────────────────────────────────────────
          if (model.pronunciation != null)
            _Section(
              title: AppL10n.t(context, 'pronunciation'),
              child: Row(
                children: [
                  Text(model.pronunciation!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    )),
                  const SizedBox(width: 8),
                  AudioPlayButton(text: model.german, size: 20),
                ],
              ),
            ),

          // ── Conjugation ─────────────────────────────────────────────────
          if (model.conjugation != null)
            _Section(
              title: AppL10n.t(context, 'conjugation'),
              child: ConjugationTable(conjugation: model.conjugation!),
            ),

          // ── Examples ────────────────────────────────────────────────────
          if (model.examples.isNotEmpty)
            _Section(
              title: AppL10n.t(context, 'examples'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: model.examples.asMap().entries.map((e) =>
                  _ExampleRow(index: e.key + 1, text: e.value),
                ).toList(),
              ),
            ),

          // ── Etymology ───────────────────────────────────────────────────
          if (model.etymology != null)
            _Section(
              title: AppL10n.t(context, 'etymology'),
              child: Text(model.etymology!, style: theme.textTheme.bodyMedium),
            ),

          // ── Common errors ───────────────────────────────────────────────
          if (model.commonErrors != null)
            _Section(
              title: AppL10n.t(context, 'common_errors'),
              child: Container(
                padding    : const EdgeInsets.all(AppSizes.md),
                decoration : BoxDecoration(
                  color       : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border      : Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Text(model.commonErrors!, style: theme.textTheme.bodyMedium),
              ),
            ),

          // ── Grammar note ────────────────────────────────────────────────
          if (model.grammarNote != null)
            _Section(
              title: AppL10n.t(context, 'grammar_note'),
              child: Container(
                padding    : const EdgeInsets.all(AppSizes.md),
                decoration : BoxDecoration(
                  color       : scheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(model.grammarNote!, style: theme.textTheme.bodyMedium),
              ),
            ),

          const SizedBox(height: 100), // space for action bar
        ],
      ),

      // ── Action bar ───────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              LeitnerAddButton(wordId: model.id),
              const SizedBox(width: 8),
              Expanded(
                child: VoxButton.secondary(
                  label    : AppL10n.t(context, 'category_label'),
                  icon     : Icons.folder_rounded,
                  onPressed: () => showAddToCategorySheet(context, model.id),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: QuizLaunchButton()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
          const SizedBox(height: AppSizes.sm),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
    padding    : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration : BoxDecoration(
      color       : color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
  );
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.index, required this.text});
  final int    index;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$index. ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
        AudioPlayButton(text: text, size: 16),
      ],
    ),
  );
}
