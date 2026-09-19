// FILE: lib/features/konnektoren/screens/konnektor_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../controllers/konnektoren_controller.dart';
import '../models/konnektor.dart';
import '../models/konnektor_rich.dart';
import '../widgets/connector_type_badge.dart';
import '../widgets/highlighted_example_text.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class KonnektorDetailScreen extends ConsumerStatefulWidget {
  const KonnektorDetailScreen({super.key, required this.konnektorId});
  final int konnektorId;

  @override
  ConsumerState<KonnektorDetailScreen> createState() =>
      _KonnektorDetailScreenState();
}

class _KonnektorDetailScreenState
    extends ConsumerState<KonnektorDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final allAsync  = ref.watch(konnektorenProvider);
    final richAsync = ref.watch(konnektorenRichProvider);

    return allAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (all) {
        final idx = all.indexWhere((k) => k.id == widget.konnektorId);
        if (idx == -1) {
          return Scaffold(body: Center(child: Text(AppL10n.t(context, 'not_found'))));
        }
        final k    = all[idx];
        final rich = richAsync.valueOrNull?[k.id];

        return Scaffold(
          appBar: AppBar(
            title: DeutschText(k.connector),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              // badges
              Wrap(
                spacing: 8, runSpacing: 6,
                children: [
                  ConnectorTypeBadge(k.connectorType),
                  _LevelBadge(k.cefrLevel),
                  _RegisterBadge(k.register),
                  _SmallBadge(AppL10n.t(context, k.wordOrderEffect.labelFa),
                      Theme.of(context).colorScheme.secondary),
                  _SmallBadge(AppL10n.t(context, k.semanticRole.labelFa),
                      Theme.of(context).colorScheme.tertiary),
                ],
              ),
              const SizedBox(height: 14),

              // meaning
              _Section(
                title: AppL10n.t(context, 'meaning'),
                child: Text(
                  AppL10n.meaning(context, fa: k.meaningFa, en: k.meaningEn),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, height: 1.6),
                ),
              ),
              const SizedBox(height: 12),

              // grammar (rich layer)
              if (rich != null) ...[
                _GrammarCard(rich.grammarSummary),
                const SizedBox(height: 12),
              ],

              // examples
              _Section(
                title: AppL10n.t(context, 'examples'),
                child: rich != null
                    ? _RichExamples(
                        examples: rich.examples, showFa: AppL10n.isFa(context))
                    : _BasicExample(k: k, showFa: AppL10n.isFa(context)),
              ),
              const SizedBox(height: 12),

              // confusable contrast (rich layer)
              if (rich != null && rich.confusableContrast.isNotEmpty) ...[
                _ConfusableSection(rich.confusableContrast),
                const SizedBox(height: 12),
              ],

              // note — aktive Sprache aus Settings (فاز L), EN-Fallback → FA
              if (k.note.isNotEmpty) ...[
                _NoteCard(AppL10n.meaning(context,
                    fa: k.note,
                    en: k.noteEn.isNotEmpty ? k.noteEn : k.note)),
                const SizedBox(height: 12),
              ],

              // navigation
              _NavRow(all: all, currentIdx: idx),
            ],
          ),
        );
      },
    );
  }
}

// ─── sub-widgets ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize    : 11,
              fontWeight  : FontWeight.w700,
              color       : cs.onSurfaceVariant,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge(this.level);
  final String level;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color       : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(level,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class _RegisterBadge extends StatelessWidget {
  const _RegisterBadge(this.register);
  final String register;

  static const _label = {
    'neutral'   : 'register_neutral',
    'formal'    : 'register_formal',
    'colloquial': 'register_colloquial',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(AppL10n.t(context, _label[register] ?? register),
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border      : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      );
}

class _GrammarCard extends StatelessWidget {
  const _GrammarCard(this.gs);
  final GrammarSummary gs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child : Padding(
        padding: const EdgeInsets.all(14),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.schema_outlined, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(AppL10n.t(context, 'grammar_label'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            _InfoRow(AppL10n.t(context, 'structure_label'),
                AppL10n.meaning(context, fa: gs.structureFa, en: gs.structureEn)),
            const SizedBox(height: 6),
            _InfoRow(AppL10n.t(context, 'position_label'),
                AppL10n.meaning(context, fa: gs.positionNoteFa, en: gs.positionNoteEn)),
            if (gs.commonMistakeFa.isNotEmpty) ...[
              const SizedBox(height: 6),
              _MistakeRow(AppL10n.meaning(context, fa: gs.commonMistakeFa, en: gs.commonMistakeEn)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant)),
        Expanded(
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.6)),
        ),
      ],
    );
  }
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color       : cs.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _RichExamples extends StatelessWidget {
  const _RichExamples({required this.examples, required this.showFa});
  final List<RichExample> examples;
  final bool showFa;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: examples.map((ex) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child  : Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color       : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HighlightedExampleText(
                sentence : ex.de,
                highlight: ex.highlight,
                style    : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, height: 1.6),
              ),
              const SizedBox(height: 4),
              Text(
                showFa ? ex.fa : ex.en,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color : cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _BasicExample extends StatelessWidget {
  const _BasicExample({required this.k, required this.showFa});
  final Konnektor k;
  final bool showFa;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeutschText(k.exampleDe,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.6)),
          const SizedBox(height: 4),
          Text(showFa ? k.exampleFa : k.exampleEn,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }
}

class _ConfusableSection extends StatelessWidget {
  const _ConfusableSection(this.contrasts);
  final List<ConfusableContrast> contrasts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child : Padding(
        padding: const EdgeInsets.all(14),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.compare_arrows_rounded, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(AppL10n.t(context, 'compare_similar'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            ...contrasts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color       : cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DeutschText(c.connector,
                        style: const TextStyle(
                            fontSize   : 12,
                            fontWeight : FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppL10n.meaning(context, fa: c.differenceFa, en: c.differenceEn),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(height: 1.6)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(this.note);
  final String note;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : cs.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(note,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.7)),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.all, required this.currentIdx});
  final List<Konnektor> all;
  final int             currentIdx;

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentIdx > 0;
    final hasNext = currentIdx < all.length - 1;

    return Row(
      children: [
        Expanded(
          child: hasPrev
              ? VoxButton.secondary(
                  label    : all[currentIdx - 1].connector,
                  icon     : Icons.arrow_back_rounded,
                  onPressed: () => _go(context, all[currentIdx - 1].id),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hasNext
              ? VoxButton.primary(
                  label    : all[currentIdx + 1].connector,
                  icon     : Icons.arrow_forward_rounded,
                  onPressed: () => _go(context, all[currentIdx + 1].id),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _go(BuildContext context, int id) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => KonnektorDetailScreen(konnektorId: id),
      ),
    );
  }
}
