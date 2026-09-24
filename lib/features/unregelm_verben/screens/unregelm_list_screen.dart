// FILE: lib/features/unregelm_verben/screens/unregelm_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/unregelm_controller.dart';
import '../models/unregelm_verb.dart';
import '../widgets/verb_class_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class UnregelmListScreen extends ConsumerStatefulWidget {
  const UnregelmListScreen({super.key});

  @override
  ConsumerState<UnregelmListScreen> createState() =>
      _UnregelmListScreenState();
}

class _UnregelmListScreenState extends ConsumerState<UnregelmListScreen> {
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

  static const _classOptions = [
    FilterOption(value: 'stark',     label: 'stark'),
    FilterOption(value: 'gemischt',  label: 'gemischt'),
    FilterOption(value: 'modal',     label: 'modal'),
    FilterOption(value: 'irregular', label: 'irregulär'),
  ];

  static const _topicOptions = [
    FilterOption(value: 'daily-life',    label: 'topic_daily_life'),
    FilterOption(value: 'economy',       label: 'topic_economy'),
    FilterOption(value: 'emotions',      label: 'topic_emotions'),
    FilterOption(value: 'general',       label: 'topic_general'),
    FilterOption(value: 'health',        label: 'topic_health'),
    FilterOption(value: 'legal',         label: 'topic_legal'),
    FilterOption(value: 'media-news',    label: 'topic_media'),
    FilterOption(value: 'relationships', label: 'topic_relationships'),
    FilterOption(value: 'school',        label: 'topic_school'),
    FilterOption(value: 'travel',        label: 'topic_travel'),
    FilterOption(value: 'work',          label: 'topic_work'),
  ];

  Map<String, String> _activeFilters(UnregelmFilter f) {
    final m = <String, String>{};
    for (final l in f.cefrLevels) {
      m[l] = 'level:$l';
    }
    for (final c in f.verbClasses) {
      m[c.labelDe] = 'class:${c.name}';
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

  void _removeFilter(String encoded, UnregelmFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleLevel(encoded.substring(6));
    } else if (encoded.startsWith('class:')) {
      final c = VerbClass.values
          .firstWhere((v) => v.name == encoded.substring(6));
      n.toggleClass(c);
    } else if (encoded.startsWith('topic:')) {
      n.toggleTopic(encoded.substring(6));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredUnregelmProvider);
    final filter   = ref.watch(unregelVerbenFilterProvider);
    final notifier = ref.read(unregelVerbenFilterProvider.notifier);
    final activeMap = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'unregelm_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip  : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.unregelVerbenGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.unregelVerbenQuiz),
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
              hint      : AppL10n.t(context, 'search_unregelm'),
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
                  label   : 'Typ',
                  options : _classOptions,
                  selected: filter.verbClasses.map((c) => c.name).toSet(),
                  onChanged: (v, _) => notifier.toggleClass(
                      VerbClass.values.firstWhere((c) => c.name == v)),
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
                            v.principalParts.praeteritum
                                .toLowerCase()
                                .contains(_query) ||
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
  final UnregelmVerb verb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () =>
            context.push(AppRoutes.unregelVerbenDetail(verb.id)),
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
                          child: DeutschText(ganzeZeile: false, 
                            verb.verbInfinitive,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _AblautChip(verb.ablautPattern),
                      ],
                    ),
                    const SizedBox(height: 2),
                    DeutschText(ganzeZeile: false, 
                      '${verb.principalParts.praeteritum}  ·  ${verb.principalParts.partizipIi}',
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppL10n.meaning(context,
                          fa: verb.meaningFa, en: verb.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VerbClassBadge(verb.verbClass, small: true),
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

class _AblautChip extends StatelessWidget {
  const _AblautChip(this.pattern);
  final String pattern;

  @override
  Widget build(BuildContext context) {
    if (pattern.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color       : const Color(0xFF37474F).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(
            color: const Color(0xFF37474F).withValues(alpha: 0.3)),
      ),
      child: DeutschText(ganzeZeile: false,
        pattern,
        style: const TextStyle(
          fontSize  : 9,
          color     : Color(0xFF37474F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
