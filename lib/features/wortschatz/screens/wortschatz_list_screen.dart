// FILE: lib/features/wortschatz/screens/wortschatz_list_screen.dart
// PURPOSE: «Alle Wörter» — EINE Liste für beide Quellen:
//            · alte Wortschatz-DB (drift → WordModel → WordListItem)
//            · Vokabular-Karten aus assets/vocab/ (SUPER-PROMPT v3.0 → WortCard)
//              — seit V.2 als Index-Einträge (vokabIndexProvider), nicht als
//              volle Karten; WortCard braucht nur diese Felder.
//          Das frühere «Vokabular-Archiv» (eigene Home/Liste) wurde hierher
//          verschmolzen; Wort-Seite bleibt /vokabular/wort/:id.
//          Grundregel (Lukas, 2026-09-24): JEDE Karte hat ihre eigene Zeile
//          (→ eigene Seite), auch wenn es dasselbe Wort schon als alte Zeile
//          gibt. Nichts wird ausgeblendet; Doppelte erst am Ende (L.4d).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../vokabular/widgets/wort_actions.dart';
import '../controllers/word_controller.dart';
import '../data/altwort_karte.dart';
import '../widgets/word_list_item.dart';
import '../../../core/widgets/vox_button.dart';

class WortschatzListScreen extends ConsumerStatefulWidget {
  const WortschatzListScreen({super.key, this.initialQuery = ''});

  /// Vorbefüllte Suche (query param `suche`) — z. B. vom Wortnetz-Dialog
  /// der Wort-Seite («Suche in allen Wörtern»).
  final String initialQuery;

  @override
  ConsumerState<WortschatzListScreen> createState() =>
      _WortschatzListScreenState();
}

class _WortschatzListScreenState extends ConsumerState<WortschatzListScreen> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  Set<String> _selectedLevels = {};
  Set<String> _selectedTypes  = {};

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery.toLowerCase().trim();
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
    FilterOption(value: 'a1', label: 'A1'),
    FilterOption(value: 'a2', label: 'A2'),
    FilterOption(value: 'b1', label: 'B1'),
    FilterOption(value: 'b2', label: 'B2'),
    FilterOption(value: 'c1', label: 'C1'),
    FilterOption(value: 'c2', label: 'C2'),
  ];

  static final _typeOptions = WordType.values
      .map((t) => FilterOption(value: t.name, label: t.label))
      .toList();

  // Wortart-Tabelle und Sortier-Lemma: EINE Quelle, ../data/altwort_karte.dart
  // (altwortTypZuWortart, altwortLemma).

  List<Map<String, dynamic>> _gefilterteKarten(
      List<Map<String, dynamic>> karten) {
    var liste = karten;
    if (_selectedLevels.isNotEmpty) {
      liste = liste
          .where((k) => _selectedLevels
              .contains((k['niveau'] as String? ?? '').toLowerCase()))
          .toList();
    }
    if (_selectedTypes.isNotEmpty) {
      final erlaubt = _selectedTypes
          .expand((t) => altwortTypZuWortart[t] ?? const <String>{})
          .toSet();
      liste = liste.where((k) => erlaubt.contains(k['wortart'])).toList();
    }
    if (_query.isNotEmpty) {
      liste = liste.where((k) => vokabKartePasst(k, _query)).toList();
    }
    return liste;
  }

  // ─── active filter chip map ───────────────────────────────────────────────

  Map<String, String> get _activeFilters {
    final m = <String, String>{};
    for (final lvl in _selectedLevels) {
      m[lvl.toUpperCase()] = 'level:$lvl';
    }
    for (final t in _selectedTypes) {
      final label = WordType.values
          .firstWhere((wt) => wt.name == t,
              orElse: () => WordType.sonstige)
          .label;
      m[label] = 'type:$t';
    }
    return m;
  }

  void _removeFilter(String encoded) {
    setState(() {
      if (encoded.startsWith('level:')) {
        _selectedLevels = {..._selectedLevels}..remove(encoded.substring(6));
      } else if (encoded.startsWith('type:')) {
        _selectedTypes = {..._selectedTypes}..remove(encoded.substring(5));
      }
    });
  }

  void _clearAll() => setState(() {
        _selectedLevels = {};
        _selectedTypes  = {};
      });

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(allWordsProvider);
    final kartenAsync = ref.watch(vokabIndexProvider);
    final activeMap  = _activeFilters;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'all_words_title')),
        actions: [
          VoxIconButton(
            icon: Icons.add_rounded,
            tooltip : AppL10n.t(context, 'add_word'),
            onPressed: () => context.push(AppRoutes.wortschatzAddWord),
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
              hint      : AppL10n.t(context, 'search_words'),
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
                  selected: _selectedLevels,
                  onChanged: (v, _) => setState(() {
                    final s = {..._selectedLevels};
                    s.contains(v) ? s.remove(v) : s.add(v);
                    _selectedLevels = s;
                  }),
                ),
                FilterAccordion(
                  label   : 'Wortart',
                  options : _typeOptions,
                  selected: _selectedTypes,
                  onChanged: (v, _) => setState(() {
                    final s = {..._selectedTypes};
                    s.contains(v) ? s.remove(v) : s.add(v);
                    _selectedTypes = s;
                  }),
                ),
              ],
            ),
          ),

          // ── active filter bar ─────────────────────────────────────────────
          if (activeMap.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilterChipBar(
              activeFilters: activeMap,
              onRemove     : _removeFilter,
              onClearAll   : _clearAll,
            ),
          ],

          const Divider(height: 12),

          // ── results ───────────────────────────────────────────────────────
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('$e')),
              data   : (words) {
                var list = words.map((w) => w.toModel()).toList();

                if (_selectedLevels.isNotEmpty) {
                  list = list.where((w) =>
                      w.level != null &&
                      _selectedLevels.contains(w.level!.name)).toList();
                }
                if (_selectedTypes.isNotEmpty) {
                  list = list.where((w) =>
                      _selectedTypes.contains(w.wordType.name)).toList();
                }
                if (_query.isNotEmpty) {
                  list = list.where((w) =>
                      w.german.toLowerCase().contains(_query) ||
                      w.meaningFa.contains(_query) ||
                      (w.meaningEn?.toLowerCase().contains(_query) ?? false))
                      .toList();
                }

                // Vokabular-Karten (assets/vocab/) mit denselben Filtern.
                final karten = _gefilterteKarten(
                    kartenAsync.valueOrNull ?? const []);

                // Beide Quellen alphabetisch gemischt (Artikel zählt nicht).
                final zeilen = <MapEntry<String, Object>>[
                  for (final w in list) MapEntry(altwortLemma(w.german), w),
                  for (final k in karten)
                    MapEntry(altwortLemma(k['wort'] as String? ?? ''), k),
                ]..sort((a, b) => a.key.compareTo(b.key));

                if (zeilen.isEmpty) {
                  return Center(
                      child: Text(AppL10n.t(context, 'empty_filter')));
                }

                return ListView.builder(
                  padding    : const EdgeInsets.fromLTRB(0, 4, 0, 80),
                  itemCount  : zeilen.length,
                  itemBuilder: (_, i) {
                    final eintrag = zeilen[i].value;
                    if (eintrag is WordModel) {
                      return WordListItem(
                        word : eintrag,
                        onTap: () => context.push(
                            AppRoutes.wortschatzWordDetail
                                .replaceFirst(':wordId', '${eintrag.id}')),
                      );
                    }
                    final karte = eintrag as Map<String, dynamic>;
                    return WortCard(
                      card    : karte,
                      trailing: WortActions(card: karte, kompakt: true),
                      onTap   : () => context.push(AppRoutes
                          .vokabularWort(karte['id'] as String? ?? '')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
