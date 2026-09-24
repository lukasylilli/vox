// FILE: lib/features/konnektoren/screens/konnektoren_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../controllers/konnektoren_controller.dart';
import '../models/konnektor.dart';
import '../widgets/connector_type_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class KonnektorenHomeScreen extends ConsumerStatefulWidget {
  const KonnektorenHomeScreen({super.key});

  @override
  ConsumerState<KonnektorenHomeScreen> createState() =>
      _KonnektorenHomeScreenState();
}

class _KonnektorenHomeScreenState
    extends ConsumerState<KonnektorenHomeScreen> {
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

  static final _typeOptions = ConnectorType.values
      .map((ct) => FilterOption(value: ct.name, label: ct.labelDe))
      .toList();

  static final _semantikOptions = SemanticRole.values
      .map((sr) => FilterOption(value: sr.name, label: sr.labelFa))
      .toList();

  // ─── active filter chip map ───────────────────────────────────────────────

  Map<String, String> _activeFilters(KonnektorFilter f) {
    final m = <String, String>{};
    for (final lvl in f.cefrLevels) {
      m[lvl] = 'level:$lvl';
    }
    for (final ct in f.connectorTypes) {
      m[ct.labelDe] = 'type:${ct.name}';
    }
    for (final sr in f.semanticRoles) {
      m[sr.labelFa] = 'role:${sr.name}';
    }
    return m;
  }

  void _removeFilter(String encoded, KonnektorFilterNotifier n) {
    if (encoded.startsWith('level:')) {
      n.toggleCefr(encoded.substring(6));
    } else if (encoded.startsWith('type:')) {
      final ct = ConnectorType.values
          .firstWhere((c) => c.name == encoded.substring(5));
      n.toggleType(ct);
    } else if (encoded.startsWith('role:')) {
      final sr = SemanticRole.values
          .firstWhere((s) => s.name == encoded.substring(5));
      n.toggleSemanticRole(sr);
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredKonnektorenProvider);
    final filter        = ref.watch(konnektorFilterProvider);
    final notifier      = ref.read(konnektorFilterProvider.notifier);
    final activeFilters = _activeFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'konnektoren_title')),
        actions: [
          VoxIconButton(
            icon: Icons.menu_book_rounded,
            tooltip: AppL10n.t(context, 'view_grammar'),
            onPressed: () => context.push(AppRoutes.konnektorenGrammar),
          ),
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip: AppL10n.t(context, 'start_quiz'),
            onPressed: () => context.push(AppRoutes.konnektorenQuiz),
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
              hint      : AppL10n.t(context, 'search_konnektoren'),
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
                  label   : 'Art',
                  options : _typeOptions,
                  selected: filter.connectorTypes.map((ct) => ct.name).toSet(),
                  onChanged: (v, _) => notifier.toggleType(
                      ConnectorType.values.firstWhere((c) => c.name == v)),
                ),
                FilterAccordion(
                  label   : 'Semantik',
                  options : _semantikOptions,
                  selected: filter.semanticRoles.map((sr) => sr.name).toSet(),
                  onChanged: (v, _) => notifier.toggleSemanticRole(
                      SemanticRole.values.firstWhere((s) => s.name == v)),
                ),
              ],
            ),
          ),

          // ── active filter bar ─────────────────────────────────────────────
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilterChipBar(
              activeFilters: activeFilters,
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
              data   : (all) {
                final list = _query.isEmpty
                    ? all
                    : all.where((k) =>
                        k.connector.toLowerCase().contains(_query) ||
                        k.meaningFa.contains(_query) ||
                        k.meaningEn.toLowerCase().contains(_query)).toList();

                if (list.isEmpty) {
                  return Center(child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.builder(
                  padding    : const EdgeInsets.only(bottom: 80),
                  itemCount  : list.length,
                  itemBuilder: (ctx, i) => _KonnektorTile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── connector tile ───────────────────────────────────────────────────────────

class _KonnektorTile extends StatelessWidget {
  const _KonnektorTile(this.k);
  final Konnektor k;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child : InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(AppRoutes.konnektorenDetail(k.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeutschText(ganzeZeile: false, // Listentitel neben dem Symbol
                      k.connector,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppL10n.meaning(context,
                          fa: k.meaningFa, en: k.meaningEn),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    DeutschText(
                      k.exampleDe,
                      style: tt.bodySmall?.copyWith(
                        color    : cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
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
                  ConnectorTypeBadge(k.connectorType, small: true),
                  const SizedBox(height: 4),
                  VoxBadge.level(k.cefrLevel, small: true),
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
