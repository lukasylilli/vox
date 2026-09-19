// FILE: lib/features/redemittel/screens/redemittel_1010_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../../../core/widgets/vox_chip.dart';
import '../../../core/widgets/vox_badge.dart';
import '../controllers/redemittel_controller.dart';
import '../models/redemittel_item.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class Redemittel1010ListScreen extends ConsumerStatefulWidget {
  const Redemittel1010ListScreen({super.key});

  @override
  ConsumerState<Redemittel1010ListScreen> createState() =>
      _Redemittel1010ListScreenState();
}

class _Redemittel1010ListScreenState
    extends ConsumerState<Redemittel1010ListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── filter option lists ────────────────────────────────────────────────────

  static const _cefrOpts = [
    FilterOption(value: 'B2', label: 'B2'),
    FilterOption(value: 'C1', label: 'C1'),
  ];

  static const _topicOpts = [
    FilterOption(value: 'diskussion',   label: 'Diskussion'),
    FilterOption(value: 'essay',        label: 'Essay'),
    FilterOption(value: 'brief_formell',label: 'Brief formell'),
    FilterOption(value: 'bewerbung',    label: 'Bewerbung'),
    FilterOption(value: 'telefon',      label: 'Telefon'),
    FilterOption(value: 'vortrag',      label: 'Vortrag'),
    FilterOption(value: 'grafik',       label: 'Grafik'),
    FilterOption(value: 'email',        label: 'E-Mail'),
    FilterOption(value: 'travel',       label: 'Reise'),
    FilterOption(value: 'general',      label: 'Allgemein'),
  ];

  static const _registerOpts = [
    FilterOption(value: 'formal',      label: 'Formell'),
    FilterOption(value: 'neutral',     label: 'Neutral'),
    FilterOption(value: 'colloquial',  label: 'Umgangssprachlich'),
  ];

  static const _grammarOpts = [
    FilterOption(value: 'dass_satz',              label: 'dass-Satz'),
    FilterOption(value: 'weil_satz',              label: 'weil-Satz'),
    FilterOption(value: 'wenn_satz',              label: 'wenn-Satz'),
    FilterOption(value: 'ob_satz',               label: 'ob-Satz'),
    FilterOption(value: 'infinitiv_zu',           label: 'Infinitiv mit zu'),
    FilterOption(value: 'hauptsatz_only',         label: 'Hauptsatz'),
    FilterOption(value: 'w_frage_satz',           label: 'W-Frage'),
    FilterOption(value: 'vollstaendiger_satz',    label: 'Vollständiger Satz'),
  ];

  // ─── active chip map ────────────────────────────────────────────────────────

  // Returns Map<label, tag> — label is shown, tag is passed to onRemove.
  Map<String, String> _activeChips(Redemittel1010Filter f) {
    final m = <String, String>{};
    for (final v in f.cefrLevels) { m[v] = 'cefr:$v'; }
    for (final v in f.topics) {
      final lbl = _topicOpts.firstWhere(
          (o) => o.value == v,
          orElse: () => FilterOption(value: v, label: v)).label;
      m[lbl] = 'topic:$v';
    }
    for (final v in f.registers) {
      final lbl = _registerOpts.firstWhere(
          (o) => o.value == v,
          orElse: () => FilterOption(value: v, label: v)).label;
      m[lbl] = 'reg:$v';
    }
    for (final v in f.grammarPats) {
      final lbl = _grammarOpts.firstWhere(
          (o) => o.value == v,
          orElse: () => FilterOption(value: v, label: v)).label;
      m[lbl] = 'gram:$v';
    }
    return m;
  }

  void _removeChip(String tag, Redemittel1010FilterNotifier notifier) {
    if (tag.startsWith('cefr:'))  { notifier.toggleCefr(tag.substring(5)); }
    else if (tag.startsWith('topic:'))  { notifier.toggleTopic(tag.substring(6)); }
    else if (tag.startsWith('reg:'))    { notifier.toggleRegister(tag.substring(4)); }
    else if (tag.startsWith('gram:'))   { notifier.toggleGrammar(tag.substring(5)); }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredRedemittel1010Provider);
    final filter        = ref.watch(redemittel1010FilterProvider);
    final notifier      = ref.read(redemittel1010FilterProvider.notifier);

    final chips = _activeChips(filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('1010 Redemittel'),
        actions: [
          VoxIconButton(
            icon: Icons.account_tree_rounded,
            tooltip : 'Grammatikmuster',
            onPressed: () => context.push(AppRoutes.redemittel1010Grammar),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, 0),
            child: VoxSearchField(
              controller: _searchCtrl,
              hint      : AppL10n.t(context, 'search_phrases_hint'),
              onChanged : (v) => notifier.setQuery(v),
              showClear : filter.query.isNotEmpty,
            ),
          ),

          // ── Filter accordions ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.xs, AppSizes.md, 0),
            child: Column(
              children: [
                FilterAccordion(
                  label   : AppL10n.t(context, 'cefr_level_label'),
                  options : _cefrOpts,
                  selected: filter.cefrLevels,
                  onChanged: (v, _) => notifier.toggleCefr(v),
                ),
                FilterAccordion(
                  label   : AppL10n.t(context, 'topic_label'),
                  options : _topicOpts,
                  selected: filter.topics,
                  onChanged: (v, _) => notifier.toggleTopic(v),
                ),
                FilterAccordion(
                  label   : AppL10n.t(context, 'register_label'),
                  options : _registerOpts,
                  selected: filter.registers,
                  onChanged: (v, _) => notifier.toggleRegister(v),
                ),
                FilterAccordion(
                  label   : AppL10n.t(context, 'grammar_pattern_label'),
                  options : _grammarOpts,
                  selected: filter.grammarPats,
                  onChanged: (v, _) => notifier.toggleGrammar(v),
                ),
              ],
            ),
          ),

          // ── Active filter chips ──────────────────────────────────────────────
          if (chips.isNotEmpty)
            FilterChipBar(
              activeFilters: chips,
              onRemove     : (tag) => _removeChip(tag, notifier),
              onClearAll   : () {
                notifier.clearAll();
                _searchCtrl.clear();
              },
            ),

          // ── Result list ──────────────────────────────────────────────────────
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
              data   : (items) {
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
                      titleDe: titleDe,
                      titleFa: AppL10n.meaning(context, fa: titleFa,
                          en: titleEn.isNotEmpty ? titleEn : titleFa),
                      phrases: phrases,
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
          filteredAsync.whenData((items) {
            if (items.isNotEmpty) {
              context.push(AppRoutes.redemittel1010Quiz, extra: items);
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
  });

  final String               titleDe;
  final String               titleFa;
  final List<RedemittelItem> phrases;

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
        // section header
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
          ...widget.phrases.map((p) => _PhraseCard(phrase: p)),

        const Divider(height: 16),
      ],
    );
  }
}

// ─── Phrase card ───────────────────────────────────────────────────────────────

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase});
  final RedemittelItem phrase;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final cs     = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      child : InkWell(
        onTap       : () => context.push(
            AppRoutes.redemittel1010Detail(phrase.id),
            extra: phrase),
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
