// FILE: lib/features/verb_praep/screens/verb_praep_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/verb_praep_controller.dart';
import '../models/verb_praep.dart';
import '../widgets/prep_case_badge.dart';
import '../../../core/widgets/vox_button.dart';

class VerbPraepListScreen extends ConsumerStatefulWidget {
  const VerbPraepListScreen({super.key});

  @override
  ConsumerState<VerbPraepListScreen> createState() =>
      _VerbPraepListScreenState();
}

class _VerbPraepListScreenState extends ConsumerState<VerbPraepListScreen> {
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

  static const _cefrOptions = [
    FilterOption(value: 'A1', label: 'A1'),
    FilterOption(value: 'A2', label: 'A2'),
    FilterOption(value: 'B1', label: 'B1'),
    FilterOption(value: 'B2', label: 'B2'),
  ];

  static const _caseOptions = [
    FilterOption(value: 'akkusativ', label: 'Akkusativ'),
    FilterOption(value: 'dativ',     label: 'Dativ'),
  ];

  static const _topicOptions = [
    FilterOption(value: 'daily-life',    label: 'topic_daily_life'),
    FilterOption(value: 'economy',       label: 'topic_economy'),
    FilterOption(value: 'emotions',      label: 'topic_emotions'),
    FilterOption(value: 'general',       label: 'topic_general'),
    FilterOption(value: 'health',        label: 'topic_health'),
    FilterOption(value: 'politics',      label: 'topic_politics'),
    FilterOption(value: 'relationships', label: 'topic_relationships'),
    FilterOption(value: 'school',        label: 'topic_school'),
    FilterOption(value: 'work',          label: 'topic_work'),
  ];

  Map<String, String> _activeFilters(VerbPraepFilter f) {
    final m = <String, String>{};
    for (final l in f.cefrLevels) {
      m[l] = 'level:$l';
    }
    for (final c in f.prepCases) {
      m[c.labelFa] = 'case:${c.name}';
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

  void _removeFilter(String encoded, VerbPraepFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleLevel(encoded.substring(6));
    } else if (encoded.startsWith('case:')) {
      final c = PrepositionCase.values
          .firstWhere((v) => v.name == encoded.substring(5));
      n.toggleCase(c);
    } else if (encoded.startsWith('topic:')) {
      n.toggleTopic(encoded.substring(6));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredVerbPraepProvider);
    final filter   = ref.watch(verbPraepFilterProvider);
    final notifier = ref.read(verbPraepFilterProvider.notifier);
    final activeMap = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'verb_praep_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip  : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.verbPraepGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.verbPraepQuiz),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: VoxSearchField(
              controller: _searchCtrl,
              hint      : AppL10n.t(context, 'search_verb_praep'),
              showClear : _query.isNotEmpty,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                FilterAccordion(
                  label   : 'Niveau',
                  options : _cefrOptions,
                  selected: filter.cefrLevels,
                  onChanged: (v, _) => notifier.toggleLevel(v),
                ),
                FilterAccordion(
                  label   : 'Kasus',
                  options : _caseOptions,
                  selected: filter.prepCases.map((c) => c.name).toSet(),
                  onChanged: (v, _) => notifier.toggleCase(
                      PrepositionCase.values.firstWhere((c) => c.name == v)),
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

          if (activeMap.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilterChipBar(
              activeFilters: activeMap,
              onRemove     : (v) => _removeFilter(v, notifier),
              onClearAll   : notifier.clearAll,
            ),
          ],

          const Divider(height: 12),

          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('$e')),
              data   : (verbs) {
                final list = _query.isEmpty
                    ? verbs
                    : verbs
                        .where((v) =>
                            v.verbInfinitive.toLowerCase().contains(_query) ||
                            v.preposition.toLowerCase().contains(_query) ||
                            v.meaningFa.contains(_query))
                        .toList();

                if (list.isEmpty) {
                  return Center(
                      child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.separated(
                  padding         : const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount       : list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder     : (_, i) => _VerbTile(list[i]),
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
  const _VerbTile(this.verb);
  final VerbPraep verb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () => context.push(AppRoutes.verbPraepDetail(verb.id)),
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
                            verb.displayVerb,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _PrepChip(verb.preposition),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppL10n.meaning(context,
                          fa: verb.meaningFa, en: verb.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrepCaseBadge(verb.prepositionCase),
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

class _PrepChip extends StatelessWidget {
  const _PrepChip(this.prep);
  final String prep;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color       : const Color(0xFF6A1B9A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border      : Border.all(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.4)),
        ),
        child: Text(
          prep,
          style: const TextStyle(
            fontSize  : 9,
            color     : Color(0xFF6A1B9A),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
