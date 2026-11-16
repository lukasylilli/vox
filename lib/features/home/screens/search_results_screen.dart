// FILE: lib/features/home/screens/search_results_screen.dart
// PHASE: G8 (2026-11-16) — globale Suche über die ganze App
// DEPS: search_controller.dart (suchGruppenProvider), such_index.dart,
//       wortschatz_filter_controller.dart (wortschatzBasisLesen),
//       wortschatz_zeile.dart
// PURPOSE: Ergebnisse der globalen Suche, GRUPPIERT (Entscheidung Lukas
//          2026-11-16): zuerst «Wörter», dann Grammatik, dann jedes Deck —
//          je Gruppe die ersten [suchVorschau] Treffer und ein Knopf
//          «alle zeigen». Wörter sehen aus wie in «Alle Wörter» (Symbol, Ton,
//          Leitner-Knopf) und kommen aus derselben Quelle wie dort — ohne die
//          Filter der Liste, denn hier wird in ALLEM gesucht.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_button.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../wortschatz/controllers/wortschatz_filter_controller.dart';
import '../../wortschatz/data/such_rang.dart';
import '../../wortschatz/data/wortschatz_filter.dart';
import '../../wortschatz/widgets/wortschatz_zeile.dart';
import '../controllers/search_controller.dart';
import '../data/such_index.dart';

/// Symbol der Gruppe — dieselben wie auf den Kacheln der Bereiche.
IconData suchBereichIcon(SuchBereich b) => switch (b) {
      SuchBereich.grammatik          => Icons.menu_book_rounded,
      SuchBereich.konnektoren        => Icons.link_rounded,
      SuchBereich.dativVerben        => Icons.swap_horiz_rounded,
      SuchBereich.nvv                => Icons.extension_rounded,
      SuchBereich.praepositionen     => Icons.category_rounded,
      SuchBereich.unregelmVerben     => Icons.format_list_numbered_rounded,
      SuchBereich.trennbarVerben     => Icons.call_split_rounded,
      SuchBereich.reflexivVerben     => Icons.loop_rounded,
      SuchBereich.verbPraep          => Icons.merge_type_rounded,
      SuchBereich.modalverben        => Icons.tune_rounded,
      SuchBereich.redemittelGoetheB2 => Icons.school_rounded,
      SuchBereich.redemittelOesdB2   => Icons.school_rounded,
      SuchBereich.redemittelOesdC1   => Icons.school_rounded,
      SuchBereich.redemittel1010     => Icons.format_list_bulleted_rounded,
      SuchBereich.auswendiglernen    => Icons.format_quote_rounded,
    };

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  /// Schlüssel der Gruppe «Wörter» in [_offen] (die übrigen: [SuchBereich]).
  static const _woerter = 'woerter';

  late final TextEditingController _ctrl;
  Timer? _warten;

  /// Die Suche, nach der gerade gesucht wird (getrimmt, wie getippt).
  String _query = '';

  /// Gruppen, die ganz aufgeklappt sind.
  final Set<Object> _offen = {};

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery.trim();
  }

  @override
  void dispose() {
    _warten?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // Erst suchen, wenn kurz nicht getippt wurde — sonst läuft je Buchstabe
  // eine Suche über das ganze Archiv.
  void _getippt(String text) {
    _warten?.cancel();
    _warten = Timer(const Duration(milliseconds: 250), () => _suchen(text));
    setState(() {}); // Löschen-Knopf zeigen/verbergen
  }

  void _suchen(String text) {
    _warten?.cancel();
    final q = text.trim();
    if (q == _query || !mounted) return;
    setState(() {
      _query = q;
      _offen.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey('such_feld'),
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppL10n.t(context, 'global_search_hint'),
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isNotEmpty
                ? VoxIconButton(
                    icon: Icons.clear_rounded,
                    onPressed: () {
                      _ctrl.clear();
                      _suchen('');
                    },
                  )
                : null,
          ),
          onChanged: _getippt,
          onSubmitted: _suchen,
        ),
      ),
      body: _query.isEmpty ? _hinweis(context) : _ergebnisse(context),
    );
  }

  Widget _hinweis(BuildContext context) => _Mitte(
        icon: Icons.search_rounded,
        text: AppL10n.t(context, 'search_prompt'),
      );

  Widget _ergebnisse(BuildContext context) {
    final q = _query.toLowerCase();

    // ── Wörter: dieselbe Quelle und Reihenfolge wie «Alle Wörter» ──────────
    final basis = wortschatzBasisLesen(ref, q);
    final formIds = <String>{
      for (final k in ref.watch(vokabFormTrefferProvider(q)).valueOrNull ??
          const <Map<String, dynamic>>[])
        k['id'] as String? ?? '',
    };
    final karteNachId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};
    final woerter = basis == null
        ? null
        : wortschatzZeilen(basis, WortschatzFilter.leer,
            formIds: formIds, karteNachId: karteNachId);

    // ── alles andere: Grammatik + Decks ────────────────────────────────────
    final gruppenAsync = ref.watch(suchGruppenProvider(_query));
    final gruppen = gruppenAsync.valueOrNull;

    final laedt = woerter == null || gruppenAsync.isLoading;
    final nichts = (woerter?.isEmpty ?? true) && (gruppen?.isEmpty ?? true);
    if (nichts && laedt) {
      return const Center(child: CircularProgressIndicator());
    }
    if (nichts && !gruppenAsync.hasError) {
      return _Mitte(
        icon: Icons.search_off_rounded,
        text: '${AppL10n.t(context, 'empty')} «$_query»',
      );
    }

    return CustomScrollView(
      slivers: [
        if (woerter != null && woerter.isNotEmpty)
          ..._gruppe<SuchTreffer<Object>>(
            context,
            schluessel: _woerter,
            icon: Icons.translate_rounded,
            titel: AppL10n.t(context, 'such_gruppe_woerter'),
            deutsch: false,
            treffer: woerter,
            zeile: (t) => WortschatzZeile(treffer: t, suchText: _query),
          ),
        if (gruppen != null)
          for (final g in gruppen.entries)
            ..._gruppe<SuchEintrag>(
              context,
              schluessel: g.key,
              icon: suchBereichIcon(g.key),
              titel: g.key.titel,
              deutsch: true,
              treffer: g.value,
              zeile: (e) => _EintragZeile(eintrag: e, query: _query),
            ),
        if (gruppenAsync.hasError)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Text(
                '${AppL10n.t(context, 'error')}: ${gruppenAsync.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        if (laedt)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  /// Überschrift + Zeilen + «alle zeigen» einer Gruppe.
  List<Widget> _gruppe<T>(
    BuildContext context, {
    required Object schluessel,
    required IconData icon,
    required String titel,
    required bool deutsch,
    required List<T> treffer,
    required Widget Function(T) zeile,
  }) {
    final name = schluessel is SuchBereich ? schluessel.name : '$schluessel';
    final offen = _offen.contains(schluessel);
    final mehr = treffer.length > suchVorschau;
    final sichtbar = offen || !mehr ? treffer.length : suchVorschau;
    final theme = Theme.of(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          key: ValueKey('such_gruppe_$name'),
          padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  titel,
                  // Deutsche Namen der Bereiche stehen auch in einer
                  // persischen Oberfläche links-nach-rechts.
                  textDirection: deutsch ? TextDirection.ltr : null,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                Formatters.digits(treffer.length),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList.builder(
        itemCount: sichtbar,
        itemBuilder: (_, i) => zeile(treffer[i]),
      ),
      if (mehr)
        SliverToBoxAdapter(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: VoxButton.text(
                key: ValueKey('such_alle_$name'),
                label: offen
                    ? AppL10n.t(context, 'such_weniger')
                    : AppL10n.tf(context, 'such_alle_zeigen',
                        {'n': Formatters.digits(treffer.length)}),
                size: VoxButtonSize.small,
                onPressed: () => setState(() =>
                    offen ? _offen.remove(schluessel) : _offen.add(schluessel)),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: Divider(height: 1)),
    ];
  }
}

// ─── Hinweis in der Mitte (leer / nichts gefunden) ───────────────────────────

class _Mitte extends StatelessWidget {
  const _Mitte({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Colors.grey),
              const SizedBox(height: AppSizes.md),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

// ─── Zeile eines Treffers aus Grammatik / einem Deck ─────────────────────────

class _EintragZeile extends StatelessWidget {
  const _EintragZeile({required this.eintrag, required this.query});

  final SuchEintrag eintrag;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bedeutung =
        AppL10n.meaning(context, fa: eintrag.fa, en: eintrag.en).trim();
    return ListTile(
      key: ValueKey('such_${eintrag.bereich.name}_${eintrag.route}'),
      dense: true,
      // Deutscher Titel: immer links-nach-rechts und am linken Rand, auch in
      // einer persischen Oberfläche (wie DeutschText).
      title: SizedBox(
        width: double.infinity,
        child: Text.rich(
          _hervorgehoben(eintrag.titel, query),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge,
        ),
      ),
      subtitle: bedeutung.isEmpty
          ? null
          : Text(bedeutung, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: eintrag.niveau.isEmpty
          ? const Icon(Icons.chevron_right_rounded)
          : Text(
              eintrag.niveau,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
      onTap: () => context.push(eintrag.route),
    );
  }

  /// Die Fundstelle fett — nur wenn sie im Titel steht.
  static TextSpan _hervorgehoben(String text, String query) {
    final q = query.trim().toLowerCase();
    final i = q.isEmpty ? -1 : text.toLowerCase().indexOf(q);
    // toLowerCase kann die Länge ändern (z. B. «İ») — dann nicht hervorheben.
    if (i < 0 || text.toLowerCase().length != text.length) {
      return TextSpan(text: text);
    }
    return TextSpan(children: [
      TextSpan(text: text.substring(0, i)),
      TextSpan(
        text: text.substring(i, i + q.length),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      TextSpan(text: text.substring(i + q.length)),
    ]);
  }
}
