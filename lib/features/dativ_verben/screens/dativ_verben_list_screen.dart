// FILE: lib/features/dativ_verben/screens/dativ_verben_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/dativ_verben_controller.dart';
import '../models/dativ_verb.dart';
import '../widgets/case_type_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../vokabular/controllers/vokabular_controller.dart';

class DativVerbenListScreen extends ConsumerStatefulWidget {
  const DativVerbenListScreen({super.key});

  @override
  ConsumerState<DativVerbenListScreen> createState() =>
      _DativVerbenListScreenState();
}

class _DativVerbenListScreenState
    extends ConsumerState<DativVerbenListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase().trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── filter option lists ──────────────────────────────────────────────────

  static const _cefrOptions = [
    FilterOption(value: 'A1', label: 'A1'),
    FilterOption(value: 'A2', label: 'A2'),
    FilterOption(value: 'B1', label: 'B1'),
    FilterOption(value: 'B2', label: 'B2'),
    FilterOption(value: 'C1', label: 'C1'),
    FilterOption(value: 'C2', label: 'C2'),
  ];

  static final _caseOptions = CaseType.values
      .map((ct) => FilterOption(value: ct.name, label: ct.labelDe))
      .toList();

  static const _topicOptions = [
    FilterOption(value: 'daily-life',    label: 'topic_daily_life'),
    FilterOption(value: 'relationships', label: 'topic_relationships'),
    FilterOption(value: 'work',          label: 'topic_work'),
    FilterOption(value: 'emotions',      label: 'topic_emotions'),
    FilterOption(value: 'school',        label: 'topic_school'),
    FilterOption(value: 'legal',         label: 'topic_legal'),
    FilterOption(value: 'economy',       label: 'topic_economy'),
    FilterOption(value: 'health',        label: 'topic_health'),
    FilterOption(value: 'politics',      label: 'topic_political'),
    FilterOption(value: 'media-news',    label: 'topic_media'),
    FilterOption(value: 'travel',        label: 'topic_travel'),
  ];

  // ─── active filter chip map ───────────────────────────────────────────────

  Map<String, String> _activeFilters(DativFilter f) {
    final m = <String, String>{};
    for (final lvl in f.cefrLevels) {
      m[lvl] = 'level:$lvl';
    }
    for (final ct in f.caseTypes) {
      m[ct.labelDe] = 'case:${ct.name}';
    }
    for (final t in f.topics) {
      final label = _topicOptions
          .firstWhere((o) => o.value == t,
              orElse: () => FilterOption(value: t, label: t))
          .label;
      m[label] = 'topic:$t';
    }
    return m;
  }

  void _removeFilter(String encoded, DativFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleCefr(encoded.substring(6));
    } else if (encoded.startsWith('case:')) {
      final ct = CaseType.values
          .firstWhere((c) => c.name == encoded.substring(5));
      n.toggleCaseType(ct);
    } else if (encoded.startsWith('topic:')) {
      n.toggleTopic(encoded.substring(6));
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered  = ref.watch(filteredDativVerbenProvider);
    final filter    = ref.watch(dativFilterProvider);
    final notifier  = ref.read(dativFilterProvider.notifier);
    final activeMap = _activeFilters(filter);

    // Bereits nach assets/vocab migrierte Verben → Detail öffnet die
    // einheitliche Vokabelseite; noch nicht migrierte → alte Detailseite.
    final vocabIds = ref.watch(vokabularByIdProvider).asData?.value.keys.toSet()
        ?? const <String>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'dativ_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.dativVerbenGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.dativVerbenQuiz),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: VoxSearchField(
              controller: _searchCtrl,
              hint      : AppL10n.t(context, 'search_dativ'),
              showClear : _query.isNotEmpty,
            ),
          ),

          // ── filter accordions ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                FilterAccordion(
                  label   : 'Niveau',
                  options : _cefrOptions,
                  selected: filter.cefrLevels,
                  onChanged: (v, _) => notifier.toggleCefr(v),
                ),
                FilterAccordion(
                  label   : 'Kasus',
                  options : _caseOptions,
                  selected: filter.caseTypes.map((c) => c.name).toSet(),
                  onChanged: (v, _) => notifier.toggleCaseType(
                      CaseType.values.firstWhere((c) => c.name == v)),
                ),
                FilterAccordion(
                  label   : 'Thema',
                  options : _topicOptions,
                  selected: filter.topics,
                  onChanged: (v, _) => notifier.toggleTopic(v),
                ),
              ],
            ),
          ),

          // ── active filter bar ─────────────────────────────────────────────
          if (activeMap.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilterChipBar(
              activeFilters: activeMap,
              onRemove     : (v) => _removeFilter(v, notifier),
              onClearAll   : notifier.reset,
            ),
          ],

          const Divider(height: 12),

          // ── results ───────────────────────────────────────────────────────
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('$e')),
              data   : (verbs) {
                final list = _query.isEmpty
                    ? verbs
                    : verbs.where((v) =>
                        v.verbInfinitive.toLowerCase().contains(_query) ||
                        v.meaningFa.contains(_query)).toList();

                if (list.isEmpty) {
                  return Center(
                      child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.separated(
                  padding         : const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount       : list.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 6),
                  itemBuilder     : (_, i) => _VerbTile(list[i], vocabIds),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── verb tile ────────────────────────────────────────────────────────────────

class _VerbTile extends StatelessWidget {
  const _VerbTile(this.verb, this.vocabIds);
  final DativVerb      verb;
  final Set<String>    vocabIds;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vocabId = vokabId('verb', verb.verbInfinitive);
    final hasVocab = vocabIds.contains(vocabId);

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () => hasVocab
            ? context.push(AppRoutes.vokabularWort(vocabId))
            : context.push(AppRoutes.dativVerbenDetail(verb.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            verb.verbInfinitive,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (verb.separable) ...[
                          const SizedBox(width: 6),
                          _SmallChip('trennbar', Colors.teal),
                        ],
                        if (verb.reflexive) ...[
                          const SizedBox(width: 4),
                          _SmallChip('reflexiv', Colors.deepPurple),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                        AppL10n.meaning(context,
                            fa: verb.meaningFa, en: verb.meaningEn),
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CaseTypeBadge(verb.caseType, small: true),
                  const SizedBox(height: 4),
                  VoxBadge.level(verb.cefrLevel, small: true),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
