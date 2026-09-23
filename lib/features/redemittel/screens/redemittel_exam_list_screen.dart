// FILE: lib/features/redemittel/screens/redemittel_exam_list_screen.dart
// PURPOSE: Generic list screen for exam Redemittel decks (Goethe B2, ÖSD B2,
//          ÖSD C1). Groups phrases by section, local search, quiz FAB.
//          Reuses Redemittel1010QuizScreen + Redemittel1010DetailScreen via
//          the deck's own routes (phrase passed as `extra`).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../../../core/widgets/vox_chip.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/deutsch_text.dart';
import '../controllers/redemittel_controller.dart';
import '../models/redemittel_item.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';

class RedemittelExamListScreen extends ConsumerStatefulWidget {
  const RedemittelExamListScreen({
    super.key,
    required this.title,
    required this.provider,
    required this.basePath,
  });

  final String title;
  final FutureProvider<List<RedemittelItem>> provider;

  /// Route prefix of this deck, e.g. '/redemittel-goethe-b2'.
  /// Quiz route  = `$basePath/quiz`
  /// Detail route = `$basePath/{phraseId}`
  final String basePath;

  @override
  ConsumerState<RedemittelExamListScreen> createState() =>
      _RedemittelExamListScreenState();
}

class _RedemittelExamListScreenState
    extends ConsumerState<RedemittelExamListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RedemittelItem> _filter(List<RedemittelItem> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((p) =>
        p.phraseDe.toLowerCase().contains(q) ||
        p.phraseFa.contains(q) ||
        p.phraseEn.toLowerCase().contains(q) ||
        p.sectionTitleDe.toLowerCase().contains(q) ||
        p.sectionTitleFa.contains(q) ||
        p.sectionTitleEn.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(widget.provider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, 0),
            child: VoxSearchField(
              controller: _searchCtrl,
              hint      : AppL10n.t(context, 'search_phrases_hint'),
              onChanged : (v) => setState(() => _query = v.trim()),
              showClear : _query.isNotEmpty,
            ),
          ),

          // ── Result list ─────────────────────────────────────────────────
          Expanded(
            child: allAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
              data   : (all) {
                final items = _filter(all);
                if (items.isEmpty) {
                  return VoxEmptyState.noResults(message: AppL10n.t(context, 'no_phrases_found'));
                }

                final sections = groupBySectionTitle(items);

                return ListView.builder(
                  padding    : const EdgeInsets.fromLTRB(
                      AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
                  itemCount  : sections.length,
                  itemBuilder: (_, si) {
                    final (titleDe, titleFa, titleEn, phrases) = sections[si];
                    return _SectionGroup(
                      titleDe : titleDe,
                      titleFa : AppL10n.meaning(context, fa: titleFa,
                          en: titleEn.isNotEmpty ? titleEn : titleFa),
                      phrases : phrases,
                      basePath: widget.basePath,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: VoxFab.extended(
        icon     : Icons.quiz_rounded,
        label    : AppL10n.t(context, 'quiz_of'),
        onPressed: () {
          allAsync.whenData((all) {
            final items = _filter(all);
            if (items.isNotEmpty) {
              context.push('${widget.basePath}/quiz', extra: items);
            }
          });
        },
      ),
    );
  }
}

// ─── Section group ─────────────────────────────────────────────────────────────

class _SectionGroup extends StatefulWidget {
  const _SectionGroup({
    required this.titleDe,
    required this.titleFa,
    required this.phrases,
    required this.basePath,
  });

  final String               titleDe;
  final String               titleFa;
  final List<RedemittelItem> phrases;
  final String               basePath;

  @override
  State<_SectionGroup> createState() => _SectionGroupState();
}

class _SectionGroupState extends State<_SectionGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap       : () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeutschText(
                        widget.titleDe,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color     : cs.primary,
                        ),
                      ),
                      Text(
                        widget.titleFa,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                VoxCountPill(count: widget.phrases.length),
              ],
            ),
          ),
        ),

        if (_expanded)
          ...widget.phrases.map((p) =>
              _PhraseCard(phrase: p, basePath: widget.basePath)),

        const Divider(height: 16),
      ],
    );
  }
}

// ─── Phrase card ───────────────────────────────────────────────────────────────

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase, required this.basePath});
  final RedemittelItem phrase;
  final String         basePath;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final cs     = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      child : InkWell(
        onTap       : () =>
            context.push('$basePath/${phrase.id}', extra: phrase),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeutschText(
                      phrase.phraseDe,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    // aktive Sprache aus Settings (فاز L), EN-Fallback → FA
                    Text(
                      AppL10n.meaning(context,
                          fa: phrase.phraseFa,
                          en: phrase.phraseEn.isNotEmpty
                              ? phrase.phraseEn
                              : phrase.phraseFa),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VoxBadge.level(phrase.cefrLevel, small: true),
                  const SizedBox(height: 4),
                  VoxRegisterDot(register: phrase.register),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
