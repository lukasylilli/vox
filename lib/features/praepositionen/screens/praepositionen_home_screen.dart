// FILE: lib/features/praepositionen/screens/praepositionen_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/deutsch_text.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/praepositionen_controller.dart';
import '../models/praep_cluster.dart';
import '../../../core/widgets/vox_button.dart';

class PraepositonenHomeScreen extends ConsumerStatefulWidget {
  const PraepositonenHomeScreen({super.key});

  @override
  ConsumerState<PraepositonenHomeScreen> createState() =>
      _PraepositonenHomeScreenState();
}

class _PraepositonenHomeScreenState
    extends ConsumerState<PraepositonenHomeScreen> {
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

  static const _wordClassOptions = [
    FilterOption(value: 'verb',      label: 'wc_verb'),
    FilterOption(value: 'adjective', label: 'wc_adjective'),
    FilterOption(value: 'noun',      label: 'wc_noun'),
  ];

  static const _caseOptions = [
    FilterOption(value: 'akkusativ', label: 'Akkusativ'),
    FilterOption(value: 'dativ',     label: 'Dativ'),
  ];

  // ─── active filter chip map ───────────────────────────────────────────────

  Map<String, String> _activeFilters(PraepFilter f) {
    final m = <String, String>{};
    for (final lvl in f.cefrLevels) {
      m[lvl] = 'level:$lvl';
    }
    for (final wc in f.wordClasses) {
      final label = _wordClassOptions
          .firstWhere((o) => o.value == wc,
              orElse: () => FilterOption(value: wc, label: wc))
          .label;
      m[label] = 'wc:$wc';
    }
    for (final c in f.cases) {
      final label = _caseOptions
          .firstWhere((o) => o.value == c,
              orElse: () => FilterOption(value: c, label: c))
          .label;
      m[label] = 'case:$c';
    }
    return m;
  }

  void _removeFilter(String encoded, PraepFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleCefr(encoded.substring(6));
    } else if (encoded.startsWith('wc:')) {
      n.toggleWordClass(encoded.substring(3));
    } else if (encoded.startsWith('case:')) {
      n.toggleCase(encoded.substring(5));
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredPraepProvider);
    final filter        = ref.watch(praepFilterProvider);
    final notifier      = ref.read(praepFilterProvider.notifier);
    final activeMap     = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'praep_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip : AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.praepositonenGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.praepositonenQuiz),
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
              hint      : AppL10n.t(context, 'search_praep'),
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
                  label   : 'Wortart',
                  options : _wordClassOptions,
                  selected: filter.wordClasses,
                  onChanged: (v, _) => notifier.toggleWordClass(v),
                ),
                FilterAccordion(
                  label   : 'Kasus',
                  options : _caseOptions,
                  selected: filter.cases,
                  onChanged: (v, _) => notifier.toggleCase(v),
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
              data   : (clusters) {
                final list = _query.isEmpty
                    ? clusters
                    : clusters.where((c) =>
                        c.meaningFa.contains(_query) ||
                        c.meaningEn.toLowerCase().contains(_query) ||
                        // R-2.1: auch nach dem deutschen Wort suchbar,
                        // das jetzt in der Liste steht.
                        c.members.any((m) =>
                            m.lemma.toLowerCase().contains(_query)) ||
                        c.prepositions.any((p) =>
                            p.toLowerCase().contains(_query))).toList();

                if (list.isEmpty) {
                  return Center(
                      child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.separated(
                  padding         : const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount       : list.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 6),
                  itemBuilder     : (_, i) => _ClusterTile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── cluster tile ─────────────────────────────────────────────────────────────

class _ClusterTile extends StatelessWidget {
  const _ClusterTile(this.cluster);
  final PraepCluster cluster;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap       : () =>
            context.push(AppRoutes.praepositonenDetail(cluster.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // R-2.1: das Wort MIT Präposition zuerst — so, wie man
                    // es lernen soll («abhängen · abhängig · … von»).
                    DeutschText(
                      cluster.vollform,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppL10n.meaning(context,
                          fa: cluster.meaningFa, en: cluster.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VoxBadge.level(cluster.cefrLevel, small: true),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
