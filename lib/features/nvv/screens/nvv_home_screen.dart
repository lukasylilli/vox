// FILE: lib/features/nvv/screens/nvv_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/nvv_controller.dart';
import '../models/nvv_phrase.dart';
import '../../../core/widgets/vox_button.dart';

class NvvHomeScreen extends ConsumerStatefulWidget {
  const NvvHomeScreen({super.key});

  @override
  ConsumerState<NvvHomeScreen> createState() => _NvvHomeScreenState();
}

class _NvvHomeScreenState extends ConsumerState<NvvHomeScreen> {
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

  static const _topicOptions = [
    FilterOption(value: 'general',       label: 'topic_general'),
    FilterOption(value: 'daily-life',    label: 'topic_daily_life'),
    FilterOption(value: 'work',          label: 'topic_work'),
    FilterOption(value: 'emotions',      label: 'topic_emotions'),
    FilterOption(value: 'legal',         label: 'topic_legal'),
    FilterOption(value: 'politics',      label: 'topic_political'),
    FilterOption(value: 'economy',       label: 'topic_economy'),
    FilterOption(value: 'relationships', label: 'topic_relationships'),
    FilterOption(value: 'school',        label: 'topic_school'),
    FilterOption(value: 'health',        label: 'topic_health'),
    FilterOption(value: 'media-news',    label: 'topic_media'),
    FilterOption(value: 'travel',        label: 'topic_travel'),
  ];

  static const _grammarOptions = [
    FilterOption(value: 'preposition', label: 'mit Präposition'),
  ];

  // ─── active filter chip map ───────────────────────────────────────────────

  Map<String, String> _activeFilters(NvvFilter f) {
    final m = <String, String>{};
    for (final lvl in f.cefrLevels) {
      m[lvl] = 'level:$lvl';
    }
    for (final t in f.topics) {
      final label = _topicOptions
          .firstWhere((o) => o.value == t,
              orElse: () => FilterOption(value: t, label: t))
          .label;
      m[label] = 'topic:$t';
    }
    if (f.onlyPreposition) {
      m['mit Präposition'] = 'gram:preposition';
    }
    return m;
  }

  void _removeFilter(String encoded, NvvFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleCefr(encoded.substring(6));
    } else if (encoded.startsWith('topic:')) {
      n.toggleTopic(encoded.substring(6));
    } else if (encoded == 'gram:preposition') {
      n.togglePrepositionOnly();
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredNvvProvider);
    final filter        = ref.watch(nvvFilterProvider);
    final notifier      = ref.read(nvvFilterProvider.notifier);
    final activeMap     = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nomen-Verb-Verbindungen'),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.nvvGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.nvvQuiz),
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
              hint      : AppL10n.t(context, 'search_nvv'),
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
                  label   : 'Thema',
                  options : _topicOptions,
                  selected: filter.topics,
                  onChanged: (v, _) => notifier.toggleTopic(v),
                ),
                FilterAccordion(
                  label   : 'Grammatik',
                  options : _grammarOptions,
                  selected: filter.onlyPreposition
                      ? const {'preposition'}
                      : const {},
                  onChanged: (_, _) => notifier.togglePrepositionOnly(),
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
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('$e')),
              data   : (phrases) {
                final list = _query.isEmpty
                    ? phrases
                    : phrases.where((p) =>
                        p.phraseDe.toLowerCase().contains(_query) ||
                        p.meaningFa.contains(_query)).toList();

                if (list.isEmpty) {
                  return Center(
                      child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.separated(
                  padding         : const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount       : list.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 6),
                  itemBuilder     : (_, i) => _NvvTile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NVV tile ─────────────────────────────────────────────────────────────────

class _NvvTile extends StatelessWidget {
  const _NvvTile(this.phrase);
  final NvvPhrase phrase;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () => context.push(AppRoutes.nvvDetail(phrase.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase.phraseDe,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppL10n.meaning(context,
                          fa: phrase.meaningFa, en: phrase.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (phrase.hasPreposition) ...[
                      const SizedBox(height: 2),
                      Text(
                        phrase.preposition!,
                        style: TextStyle(
                          fontSize  : 12,
                          color     : cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VoxBadge.level(phrase.cefrLevel, small: true),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
