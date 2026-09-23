// FILE: lib/features/nvv/screens/nvv_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_loading_widget.dart';
import '../../../core/widgets/vox_error_widget.dart';
import '../controllers/nvv_controller.dart';
import '../models/nvv_phrase.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class NvvDetailScreen extends ConsumerWidget {
  const NvvDetailScreen({super.key, required this.phraseId});
  final int phraseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(nvvPhrasesProvider);

    return allAsync.when(
      loading: () => const Scaffold(body: VoxLoadingWidget()),
      error  : (e, _) => Scaffold(body: VoxErrorWidget(error: e)),
      data   : (all) {
        final phrase = all.firstWhere(
          (p) => p.id == phraseId,
          orElse: () => all.first,
        );
        final idx = all.indexOf(phrase);

        return Scaffold(
          appBar: AppBar(
            title: DeutschText(phrase.phraseDe, ganzeZeile: false),
          ),
          body: _NvvDetailBody(
            phrase : phrase,
            hasPrev: idx > 0,
            hasNext: idx < all.length - 1,
            onPrev : idx > 0
                ? () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => NvvDetailScreen(phraseId: all[idx - 1].id),
                      ),
                    )
                : null,
            onNext : idx < all.length - 1
                ? () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => NvvDetailScreen(phraseId: all[idx + 1].id),
                      ),
                    )
                : null,
          ),
        );
      },
    );
  }
}

class _NvvDetailBody extends StatefulWidget {
  const _NvvDetailBody({
    required this.phrase,
    required this.hasPrev,
    required this.hasNext,
    this.onPrev,
    this.onNext,
  });
  final NvvPhrase    phrase;
  final bool         hasPrev, hasNext;
  final VoidCallback? onPrev, onNext;

  @override
  State<_NvvDetailBody> createState() => _NvvDetailBodyState();
}

class _NvvDetailBodyState extends State<_NvvDetailBody> {

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p      = widget.phrase;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        // ── Header ───────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.phraseDe,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    _CefrBadge(level: p.cefrLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(label: p.nounPhrase, icon: Icons.article_rounded),
                    const SizedBox(width: 6),
                    _Chip(label: p.verbInfinitive, icon: Icons.play_arrow_rounded),
                    if (p.hasPreposition) ...[
                      const SizedBox(width: 6),
                      _Chip(
                        label: p.preposition!,
                        icon : Icons.link_rounded,
                        color: scheme.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // ── Meaning ──────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.t(context, 'meaning'),
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  AppL10n.meaning(context, fa: p.meaningFa, en: p.meaningEn),
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (p.synonymDe.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${AppL10n.t(context, 'synonym_label')}: ${p.synonymDe}',
                    style: TextStyle(
                      fontSize: 13,
                      color   : scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // ── Example ──────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.t(context, 'example'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _HighlightedExample(
                  sentence : p.exampleDe,
                  highlight: p.phraseDe.split(' ').take(2).join(' '),
                  color    : scheme.primary,
                ),
                const SizedBox(height: 6),
                // nur aktive Zweitsprache (فاز L)
                Text(
                    AppL10n.meaning(context,
                        fa: p.exampleFa, en: p.exampleEn),
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),

        // ── Note ─────────────────────────────────────────────────
        if (p.note.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          Card(
            color: scheme.secondaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: scheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  // aktive Sprache aus Settings (فاز L), EN-Fallback → FA
                  Expanded(
                      child: Text(AppL10n.meaning(context,
                          fa: p.note,
                          en: p.noteEn.isNotEmpty ? p.noteEn : p.note))),
                ],
              ),
            ),
          ),
        ],

        // ── Meta ─────────────────────────────────────────────────
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: 6,
          children: [
            _Chip(label: p.register,  icon: Icons.record_voice_over_rounded),
            _Chip(label: p.topic,     icon: Icons.label_rounded),
          ],
        ),

        // ── Navigation ───────────────────────────────────────────
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: VoxButton.secondary(
                label    : AppL10n.t(context, 'previous'),
                icon     : Icons.arrow_back_rounded,
                onPressed: widget.onPrev,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: VoxButton.secondary(
                label    : AppL10n.t(context, 'next'),
                icon     : Icons.arrow_forward_rounded,
                onPressed: widget.onNext,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _HighlightedExample extends StatelessWidget {
  const _HighlightedExample({
    required this.sentence,
    required this.highlight,
    required this.color,
  });
  final String sentence, highlight;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    final lower   = sentence.toLowerCase();
    final hLower  = highlight.toLowerCase();
    final start   = lower.indexOf(hLower);

    if (start == -1) {
      return Text(sentence,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500));
    }
    final end = start + highlight.length;
    return Text.rich(TextSpan(children: [
      if (start > 0) TextSpan(text: sentence.substring(0, start)),
      TextSpan(
        text : sentence.substring(start, end),
        style: TextStyle(
            color     : color,
            fontWeight: FontWeight.w700,
            fontSize  : 16),
      ),
      if (end < sentence.length)
        TextSpan(text: sentence.substring(end)),
    ], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});
  final String level;

  static Color _color(String level) => VoxColors.cefr(level);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding    : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration : BoxDecoration(
        color       : _color(level).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border      : Border.all(color: _color(level).withValues(alpha: 0.5)),
      ),
      child: Text(
        level,
        style: TextStyle(
            fontSize  : 12,
            fontWeight: FontWeight.w700,
            color     : _color(level)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, this.color});
  final String   label;
  final IconData icon;
  final Color?   color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color       : c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children    : [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: c)),
        ],
      ),
    );
  }
}
