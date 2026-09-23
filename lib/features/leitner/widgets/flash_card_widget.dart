// FILE: lib/features/leitner/widgets/flash_card_widget.dart
// DEPS: word_model.dart, article_badge.dart, audio_play_button.dart
// PURPOSE: 3D flip flash card — front=German, back=meaning+conjugation+examples
//          (App-Wörter; die Wende selbst steckt in wende_karte.dart — B-13)
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/article_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/article_badge.dart';
import '../../../core/widgets/audio_play_button.dart';
import 'wende_karte.dart';
import '../../../core/widgets/deutsch_text.dart';

class FlashCardWidget extends StatelessWidget {
  const FlashCardWidget({
    super.key,
    required this.model,
    this.onFlip,
  });
  final WordModel model;
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) => WendeKarte(
        // Neues Wort ⇒ neue Wende-Karte ⇒ wieder die Vorderseite.
        key: ObjectKey(model),
        vorne: _FrontFace(model: model),
        hinten: _BackFace(model: model),
        onFlip: onFlip,
      );
}

// ── Front face ────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.model});
  final WordModel model;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final scheme  = theme.colorScheme;
    final article = model.article;
    final color   = ArticleColors.forString(article);

    return Container(
      width      : double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding    : const EdgeInsets.all(AppSizes.xl),
      decoration : BoxDecoration(
        color       : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border      : Border.all(
          color: article != null ? color.withValues(alpha: 0.5) : scheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (article != null) ...[
            ArticleBadge(article: article, large: true),
            const SizedBox(height: AppSizes.sm),
          ],
          DeutschText(
            model.german,
            ganzeZeile: false, // Karte ist zentriert
            style    : theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: article != null ? color : scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (model.plural != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text('Pl. ${model.plural}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              )),
          ],
          const SizedBox(height: AppSizes.lg),
          AudioPlayButton(text: model.german),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(AppL10n.t(context, 'tap_to_reveal'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Back face ─────────────────────────────────────────────────────────────────

class _BackFace extends StatelessWidget {
  const _BackFace({required this.model});
  final WordModel model;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width      : double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding    : const EdgeInsets.all(AppSizes.lg),
      decoration : BoxDecoration(
        color       : scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border      : Border.all(color: scheme.primary.withValues(alpha: 0.4), width: 2),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meaning — nur aktive Zweitsprache (فاز L)
            Center(
              child: Text(
                AppL10n.meaning(context,
                    fa: model.meaningFa,
                    en: model.meaningEn ?? model.meaningFa),
                style    : theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Conjugation table (verbs)
            if (model.conjugation != null) ...[
              const SizedBox(height: AppSizes.md),
              const Divider(),
              _ConjRow('Infinitiv',  model.conjugation!.infinitiv),
              _ConjRow('Präsens',    model.conjugation!.praesens),
              _ConjRow('Präteritum', model.conjugation!.praeteritum),
              _ConjRow('Partizip II',model.conjugation!.partizip),
            ],

            // Examples
            if (model.examples.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              const Divider(),
              ...model.examples.take(3).map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child  : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 14, color: scheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(ex,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
            ],

            // Grammar note
            if (model.grammarNote != null) ...[
              const SizedBox(height: 8),
              Text(model.grammarNote!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontStyle: FontStyle.italic,
                )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConjRow extends StatelessWidget {
  const _ConjRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child  : Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          ),
          Expanded(
            child: Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
          ),
        ],
      ),
    );
  }
}
