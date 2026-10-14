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
//          Filter (فاز F.2, 2026-10-14): eigene Filterseite
//          (wortschatz_filter_screen.dart), hier nur Knopf mit Zahl + Chips
//          der aktiven Filter. Filtern/Ordnen: data/wortschatz_filter.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/deutsch_text.dart';
import '../../../core/widgets/vox_search_field.dart';
import '../../../core/utils/formatters.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../vokabular/widgets/wort_actions.dart';
import '../controllers/word_controller.dart';
import '../controllers/wortschatz_filter_controller.dart';
import '../data/such_rang.dart';
import '../data/such_vorschlag.dart';
import '../data/wortschatz_filter.dart';
import 'wortschatz_filter_screen.dart';
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

  // ─── aktive Filter als Chips (Beschriftung → «bereich:wert») ──────────────

  Map<String, String> _aktiveChips(
          WortschatzFilter filter, WortschatzZugehoerigkeit z) =>
      {
        for (final b in FilterBereich.values)
          for (final w in filter.werte(b))
            ?WortschatzFilterScreen.beschriftung(context, b, w, z):
                '${b.name}:$w',
      };

  void _chipEntfernen(String kodiert) {
    final i = kodiert.indexOf(':');
    final b = FilterBereich.values.firstWhere(
        (x) => x.name == kodiert.substring(0, i),
        orElse: () => FilterBereich.niveau);
    ref
        .read(wortschatzFilterProvider.notifier)
        .entfernen(b, kodiert.substring(i + 1));
  }

  void _filterOeffnen() {
    final suche = _query.isEmpty ? '' : '?suche=${Uri.encodeComponent(_query)}';
    context.push('${AppRoutes.wortschatzFilter}$suche');
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(allWordsProvider);
    final sucheAsync =
        _query.isEmpty ? null : ref.watch(vokabSucheProvider(_query));
    // Karten, deren gebeugte Form gesucht wurde («ging» ⇒ gehen) — Rang
    // «Form» in such_rang.dart (فاز F.1).
    final formAsync =
        _query.isEmpty ? null : ref.watch(vokabFormTrefferProvider(_query));
    final basis = wortschatzBasisLesen(ref, _query);
    final z = basis?.zugehoerigkeit ?? WortschatzZugehoerigkeit.leer;
    // Ohne gelöschte Kategorien u. Ä. (wirken nicht, kein Chip).
    final filter = ref.watch(wortschatzFilterProvider).bereinigt(z);
    final chips = _aktiveChips(filter, z);
    final cs = Theme.of(context).colorScheme;

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
          // ── search bar + Filterknopf ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: VoxSearchField(
                    controller: _searchCtrl,
                    hint      : AppL10n.t(context, 'search_words'),
                    showClear : _query.isNotEmpty,
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  key: const ValueKey('filter_knopf'),
                  isLabelVisible: !filter.istLeer,
                  label: Text(Formatters.digits(filter.anzahlAktiv)),
                  backgroundColor: cs.primary,
                  textColor: cs.onPrimary,
                  child: VoxIconButton(
                    icon     : Icons.tune_rounded,
                    variant  : filter.istLeer
                        ? VoxIconVariant.outlined
                        : VoxIconVariant.filled,
                    tooltip  : AppL10n.t(context, 'filter_title'),
                    onPressed: _filterOeffnen,
                  ),
                ),
              ],
            ),
          ),

          // ── active filter bar ─────────────────────────────────────────────
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilterChipBar(
              activeFilters: chips,
              onRemove     : _chipEntfernen,
              onClearAll   : () =>
                  ref.read(wortschatzFilterProvider.notifier).allesLoeschen(),
            ),
          ],

          const Divider(height: 12),

          // ── results ───────────────────────────────────────────────────────
          Expanded(child: _ergebnisse(
              context, wordsAsync, sucheAsync, formAsync, filter, basis)),
        ],
      ),
    );
  }

  Widget _ergebnisse(
    BuildContext context,
    AsyncValue<Object?> wordsAsync,
    AsyncValue<List<Map<String, dynamic>>>? sucheAsync,
    AsyncValue<List<Map<String, dynamic>>>? formAsync,
    WortschatzFilter filter,
    WortschatzBasis? basis,
  ) {
    if (wordsAsync.hasError) {
      return Center(child: Text('${wordsAsync.error}'));
    }
    if (basis == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final formIds = <String>{
      for (final k in formAsync?.valueOrNull ??
          const <Map<String, dynamic>>[])
        k['id'] as String? ?? '',
    };
    final zeilen = wortschatzZeilen(basis, filter, formIds: formIds);

    if (zeilen.isEmpty) {
      // Tippfehler? Erst wenn die Suche fertig geladen ist — sonst blitzen
      // Vorschläge auf (فاز F.1c, such_vorschlag.dart). Quelle: alle Wörter
      // mit den aktiven Filtern, aber ohne Suche.
      final List<String> vorschlaege;
      if (_query.isEmpty || !(sucheAsync?.hasValue ?? false)) {
        vorschlaege = const [];
      } else {
        final ohneSuche = wortschatzBasisLesen(ref, '');
        vorschlaege = ohneSuche == null
            ? const []
            : suchVorschlaege(_query, [
                for (final z in wortschatzZeilen(ohneSuche, filter))
                  z.wert is WordModel
                      ? (z.wert as WordModel).german
                      : ((z.wert as Map<String, dynamic>)['wort'] as String? ??
                          ''),
              ]);
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppL10n.t(context, 'empty_filter'),
                  textAlign: TextAlign.center),
              if (vorschlaege.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppL10n.t(context, 'such_meintest_du'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  textDirection: TextDirection.ltr,
                  children: [
                    for (final v in vorschlaege)
                      VoxButton.tonal(
                        key: ValueKey('vorschlag_$v'),
                        label: v,
                        size: VoxButtonSize.small,
                        onPressed: () {
                          _searchCtrl.text = v;
                          _searchCtrl.selection =
                              TextSelection.collapsed(offset: v.length);
                        },
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Zeile «Gebeugte Form: ging» unter Treffern aus einer Form.
    final suchText = _searchCtrl.text.trim();
    Widget? hinweisFuer(SuchTreffer<Object> t) =>
        t.rang == SuchRang.form && suchText.isNotEmpty
            ? DeutschMitEtikett(
                etikett: AppL10n.t(context, 'such_form_etikett'),
                wert: suchText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              )
            : null;

    return ListView.builder(
      padding    : const EdgeInsets.fromLTRB(0, 4, 0, 80),
      itemCount  : zeilen.length,
      itemBuilder: (_, i) {
        final eintrag = zeilen[i].wert;
        final hinweis = hinweisFuer(zeilen[i]);
        if (eintrag is WordModel) {
          return WordListItem(
            word : eintrag,
            hinweis: hinweis,
            onTap: () => context.push(AppRoutes.wortschatzWordDetail
                .replaceFirst(':wordId', '${eintrag.id}')),
          );
        }
        final karte = eintrag as Map<String, dynamic>;
        return WortCard(
          card    : karte,
          hinweis : hinweis,
          trailing: WortActions(card: karte, kompakt: true),
          onTap   : () => context
              .push(AppRoutes.vokabularWort(karte['id'] as String? ?? '')),
        );
      },
    );
  }
}
