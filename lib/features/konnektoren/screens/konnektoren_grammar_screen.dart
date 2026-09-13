// FILE: lib/features/konnektoren/screens/konnektoren_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../controllers/konnektoren_controller.dart';
import '../models/konnektor.dart';
import '../widgets/connector_type_badge.dart';

class KonnektorenGrammarScreen extends ConsumerWidget {
  const KonnektorenGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(konnektorenGrammarProvider);
    final verbsAsync   = ref.watch(konnektorenProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'konnektor_grammar_title'))),
      body  : grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (g) {
          if (g.isEmpty) {
            return _PlaceholderContent(
              allAsync: verbsAsync,
            );
          }
          return _GrammarContent(g: g, allAsync: verbsAsync);
        },
      ),
    );
  }
}

// ─── when grammar JSON is empty (stub) ───────────────────────────────────────

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({required this.allAsync});
  final AsyncValue<List<Konnektor>> allAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding : const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        _Card(
          icon : Icons.info_outline_rounded,
          title: AppL10n.t(context, 'what_are_connectors'),
          child: Text(
            AppL10n.t(context, 'connectors_intro'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
          ),
        ),
        const SizedBox(height: 12),
        _TypesOverviewCard(),
        const SizedBox(height: 12),
        _WordOrderCard(),
      ],
    );
  }
}

// ─── when grammar JSON has content ───────────────────────────────────────────

class _GrammarContent extends StatelessWidget {
  const _GrammarContent({required this.g, required this.allAsync});
  final Map<String, dynamic>        g;
  final AsyncValue<List<Konnektor>> allAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding : const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        if (g['summary_fa'] != null)
          _Card(
            icon : Icons.menu_book_rounded,
            title: g['title_fa'] as String? ?? AppL10n.t(context, 'summary_label'),
            child: Text(AppL10n.loc(context, g, 'summary'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.8)),
          ),
        if (g['rule_explanation_fa'] != null) ...[
          const SizedBox(height: 12),
          _Card(
            icon : Icons.info_outline_rounded,
            title: AppL10n.t(context, 'full_explanation'),
            child: Text(AppL10n.loc(context, g, 'rule_explanation'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.8)),
          ),
        ],
        if (g['tips_fa'] != null) ...[
          const SizedBox(height: 12),
          _Card(
            icon : Icons.lightbulb_outline_rounded,
            title: AppL10n.t(context, 'key_tips'),
            child: Column(
              children: ((AppL10n.isFa(context) ? g['tips_fa'] : (g['tips_en'] ?? g['tips_fa'])) as List).map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                        child: Text(t as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.7))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _TypesOverviewCard(),
        const SizedBox(height: 12),
        _WordOrderCard(),
      ],
    );
  }
}

// ─── shared overview cards ────────────────────────────────────────────────────

class _TypesOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      icon : Icons.category_outlined,
      title: AppL10n.t(context, 'connector_types'),
      child: Column(
        children: ConnectorType.values.map((ct) {
          final color = Konnektor.colorFor(ct, context);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child  : Row(
              children: [
                ConnectorTypeBadge(ct),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    switch (ct) {
                      ConnectorType.nullposition    =>
                        AppL10n.t(context, 'ct_no_change'),
                      ConnectorType.nebensatz       =>
                        AppL10n.t(context, 'ct_verb_end'),
                      ConnectorType.adverbial       =>
                        AppL10n.t(context, 'ct_inversion'),
                      ConnectorType.doppelkonnektor =>
                        AppL10n.t(context, 'ct_two_part'),
                      ConnectorType.praeposition    =>
                        AppL10n.t(context, 'ct_prep'),
                      ConnectorType.relativsatz     =>
                        AppL10n.t(context, 'ct_relative'),
                    },
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: color.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WordOrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Card(
      icon : Icons.swap_horiz_rounded,
      title: AppL10n.t(context, 'effect_on_order'),
      child: Column(
        children: [
          _WORow('verb_end', AppL10n.t(context, 'wo_verb_end'), 'Nebensatz + Relativsatz', cs),
          _WORow('inversion', 'Inversion',
              AppL10n.meaning(context, fa: 'Adverbial در Pos1', en: 'Adverbial in Pos1'), cs),
          _WORow('no_change', AppL10n.t(context, 'wo_no_change'), 'Nullposition + Präposition', cs),
          _WORow('variable', AppL10n.t(context, 'wo_variable'), 'Doppelkonnektor', cs),
        ],
      ),
    );
  }
}

class _WORow extends StatelessWidget {
  const _WORow(this.key2, this.labelFa, this.note, this.cs);
  final String key2, labelFa, note;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child  : Row(
      children: [
        Container(
          width  : 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color       : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(labelFa,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(note,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ),
      ],
    ),
  );
}

// ─── reusable card ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String   title;
  final Widget   child;

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
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
