// FILE: lib/features/trennbar_verben/screens/trennbar_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/trennbar_controller.dart';
import '../models/trennbar_verb.dart';
import '../widgets/prefix_type_badge.dart';
import '../../../core/widgets/vox_button.dart';

class TrennbarListScreen extends ConsumerStatefulWidget {
  const TrennbarListScreen({super.key});

  @override
  ConsumerState<TrennbarListScreen> createState() => _TrennbarListScreenState();
}

class _TrennbarListScreenState extends ConsumerState<TrennbarListScreen> {
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
    FilterOption(value: 'C1', label: 'C1'),
  ];

  static final _typeOptions = PrefixType.values
      .map((t) => FilterOption(value: t.name, label: t.shortLabel))
      .toList();

  static const _topicOptions = [
    FilterOption(value: 'daily-life',    label: 'topic_daily_life'),
    FilterOption(value: 'relationships', label: 'topic_relationships'),
    FilterOption(value: 'work',          label: 'topic_work'),
    FilterOption(value: 'emotions',      label: 'topic_emotions'),
    FilterOption(value: 'school',        label: 'topic_school'),
    FilterOption(value: 'health',        label: 'topic_health'),
    FilterOption(value: 'travel',        label: 'topic_travel'),
    FilterOption(value: 'general',       label: 'topic_general'),
    FilterOption(value: 'economy',       label: 'topic_economy'),
    FilterOption(value: 'legal',         label: 'topic_legal'),
  ];

  Map<String, String> _activeFilters(TrennbarFilter f) {
    final m = <String, String>{};
    for (final lvl in f.cefrLevels) {
      m[lvl] = 'level:$lvl';
    }
    for (final t in f.prefixTypes) {
      m[t.shortLabel] = 'type:${t.name}';
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

  void _removeFilter(String encoded, TrennbarFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleCefr(encoded.substring(6));
    } else if (encoded.startsWith('type:')) {
      final t = PrefixType.values
          .firstWhere((c) => c.name == encoded.substring(5));
      n.toggleType(t);
    } else if (encoded.startsWith('topic:')) {
      n.toggleTopic(encoded.substring(6));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered  = ref.watch(filteredTrennbarVerbenProvider);
    final filter    = ref.watch(trennbarFilterProvider);
    final notifier  = ref.read(trennbarFilterProvider.notifier);
    final activeMap = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'trennbar_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.trennbarGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.trennbarQuiz),
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
              hint      : AppL10n.t(context, 'search_trennbar'),
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
                  onChanged: (v, _) => notifier.toggleCefr(v),
                ),
                FilterAccordion(
                  label   : 'Typ',
                  options : _typeOptions,
                  selected: filter.prefixTypes.map((t) => t.name).toSet(),
                  onChanged: (v, _) => notifier.toggleType(
                      PrefixType.values.firstWhere((t) => t.name == v)),
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
              onClearAll   : notifier.reset,
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
                            v.meaningFa.contains(_query) ||
                            v.prefix.toLowerCase().contains(_query))
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
  final TrennbarVerb verb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () => context.push(AppRoutes.trennbarDetail(verb.id)),
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
                        const SizedBox(width: 6),
                        _SmallChip(
                          '${verb.prefix}-',
                          const Color(0xFF0277BD),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppL10n.meaning(context,
                          fa: verb.meaningFa, en: verb.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrefixTypeBadge(verb.prefixType, small: true),
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
  Widget build(BuildContext context) => Container(
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
