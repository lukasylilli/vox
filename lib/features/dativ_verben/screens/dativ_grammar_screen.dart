// FILE: lib/features/dativ_verben/screens/dativ_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../controllers/dativ_verben_controller.dart';
import '../models/dativ_verb.dart';
import '../widgets/case_type_badge.dart';
import '../../../core/widgets/deutsch_text.dart';

class DativGrammarScreen extends ConsumerWidget {
  const DativGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(dativGrammarProvider);
    final verbsAsync   = ref.watch(dativVerbenProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'dativ_grammar_title'))),
      body  : grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (g) => ListView(
          padding : const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // ── summary ──
            _Card(
              icon : Icons.menu_book_rounded,
              title: AppL10n.loc(context, g, 'title'),
              child: Text(
                AppL10n.loc(context, g, 'summary'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
            const SizedBox(height: 12),

            // ── full rule ──
            _Card(
              icon : Icons.info_outline_rounded,
              title: AppL10n.t(context, 'full_explanation'),
              child: Text(
                AppL10n.loc(context, g, 'rule_explanation'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
            const SizedBox(height: 12),

            // ── word order ──
            _Card(
              icon : Icons.swap_horiz_rounded,
              title: AppL10n.t(context, 'object_order_title'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppL10n.loc(context, g, 'word_order_rule'),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.8),
                  ),
                  const SizedBox(height: 10),
                  ...(g['word_order_examples'] as List).map((e) {
                    final ex = e as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DeutschText(ex['de'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(AppL10n.meaning(context, fa: ex['fa'] as String,
                                en: ex['en'] as String? ?? ex['fa'] as String),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(height: 1.5)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── tips ──
            _Card(
              icon : Icons.lightbulb_outline_rounded,
              title: AppL10n.t(context, 'key_tips'),
              child: Column(
                children: ((AppL10n.isFa(context) ? g['tips_fa'] : (g['tips_en'] ?? g['tips_fa'])) as List).map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                      Expanded(child: Text(t as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.7))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── common verbs by case_type ──
            verbsAsync.when(
              loading: () => const SizedBox.shrink(),
              error  : (_, _) => const SizedBox.shrink(),
              data   : (verbs) {
                final byId = {for (final v in verbs) v.id: v};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CommonVerbsSection(
                      title   : AppL10n.t(context, 'common_dativ_verbs'),
                      caseType: CaseType.datumOnly,
                      ids     : (g['common_dativ_only_verb_ids'] as List).cast<int>(),
                      byId    : byId,
                    ),
                    const SizedBox(height: 12),
                    _CommonVerbsSection(
                      title   : AppL10n.t(context, 'common_dativ_akk_verbs'),
                      caseType: CaseType.dativAkkusativ,
                      ids     : (g['common_dativ_akkusativ_verb_ids'] as List).cast<int>(),
                      byId    : byId,
                    ),
                    const SizedBox(height: 12),
                    _CommonVerbsSection(
                      title   : AppL10n.t(context, 'akk_verbs_mistake'),
                      caseType: CaseType.akkusativOnlyConfusable,
                      ids     : (g['confusable_akkusativ_verb_ids'] as List).cast<int>(),
                      byId    : byId,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── reusable card ──

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700)),
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

// ── common verbs mini-list ──

class _CommonVerbsSection extends StatelessWidget {
  const _CommonVerbsSection({
    required this.title,
    required this.caseType,
    required this.ids,
    required this.byId,
  });

  final String              title;
  final CaseType            caseType;
  final List<int>           ids;
  final Map<int, DativVerb> byId;

  @override
  Widget build(BuildContext context) {
    final verbs = ids.map((id) => byId[id]).whereType<DativVerb>().toList();

    return _Card(
      icon : Icons.list_rounded,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseTypeBadge(caseType),
          const SizedBox(height: 10),
          Wrap(
            spacing   : 8,
            runSpacing: 8,
            children  : verbs.map((v) => _VerbChip(v)).toList(),
          ),
        ],
      ),
    );
  }
}

class _VerbChip extends StatelessWidget {
  const _VerbChip(this.verb);
  final DativVerb verb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(color: cs.outlineVariant),
      ),
      child: Text(verb.verbInfinitive,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
