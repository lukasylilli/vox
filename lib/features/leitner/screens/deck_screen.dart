// FILE: lib/features/leitner/screens/deck_screen.dart
// PHASE: X.4 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// DEPS: leitner_controller.dart (deckRechner, deckBaum, deckWoerter),
//       deck_zeile.dart, deck_dialoge.dart, wortschatz_zeile.dart
// PURPOSE: Die Seite EINES Decks (früher: Seite einer «Kategorie»,
//          categories/screens/category_detail_screen.dart):
//            · Zahlen: neu · in Lernphase · gelernt, % gelernt (Nr. 2, 6);
//            · heute dran (neu / Wiederholung) + Knopf «dieses Deck üben»
//              — samt Subdecks (Nr. 11);
//            · Subdecks als Zeilen, darunter die Wörter dieses Decks; Wort
//              wischen = aus dem Deck nehmen (Fortschritt bleibt, Nr. 7);
//            · Menü: umbenennen, Subdeck, Modus, Tageslimit, löschen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/leitner/deck_sitzung.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../../core/models/word_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_button.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../../wortschatz/data/such_rang.dart';
import '../../wortschatz/widgets/wortschatz_zeile.dart';
import '../controllers/leitner_controller.dart';
import '../widgets/deck_zeile.dart';

class DeckScreen extends ConsumerWidget {
  const DeckScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baum = ref.watch(deckBaumProvider).valueOrNull;
    if (baum == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    final i = baum.indexWhere((k) => k.deck.id == deckId);
    if (i < 0) {
      // Gelöscht (auch auf einem anderen Gerät) oder nie da gewesen.
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppL10n.t(context, 'empty'))),
      );
    }
    final deck = baum[i].deck;
    final tiefe = baum[i].tiefe;
    // Direkte Subdecks: die folgenden Knoten genau eine Ebene tiefer, bis
    // der Baum wieder auf diese Ebene zurückkehrt.
    final subdecks = <Deck>[];
    for (var j = i + 1; j < baum.length && baum[j].tiefe > tiefe; j++) {
      if (baum[j].tiefe == tiefe + 1) subdecks.add(baum[j].deck);
    }
    final z = ref.watch(deckRechnerProvider).valueOrNull?.zaehler(deckId) ??
        const DeckZaehler();
    final woerter = ref.watch(deckWoerterProvider(deckId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          DeckMenue(
            deck: deck,
            obersteEbene: tiefe == 0,
            // Navigator statt go_router: die Seite kann auch ohne Router
            // stehen (Tests); im Router ist es dasselbe Zurück.
            nachLoeschen: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Kopf(deck: deck, z: z),
          if (subdecks.isNotEmpty) ...[
            _Ueberschrift(AppL10n.t(context, 'deck_subdecks')),
            for (final s in subdecks)
              DeckZeile(deck: s, tiefe: 0, obersteEbene: false),
            const Divider(height: AppSizes.lg),
          ],
          _Ueberschrift(AppL10n.t(context, 'deck_woerter')),
          ...woerter.when(
            loading: () => const [
              Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) =>
                [Center(child: Text('${AppL10n.t(context, 'error')}: $e'))],
            data: (zeilen) => zeilen.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Text(AppL10n.t(context, 'deck_leer'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ]
                : [
                    for (final zeile in zeilen)
                      _WortZeile(deckId: deckId, zeile: zeile),
                  ],
          ),
        ],
      ),
      floatingActionButton: z.heute > 0
          ? VoxFab.extended(
              key: const ValueKey('deck_ueben'),
              icon: Icons.play_arrow_rounded,
              label: '${AppL10n.t(context, 'deck_ueben')} '
                  '(${Formatters.digits(z.heute)})',
              onPressed: () => context.push(AppRoutes.leitnerUeben(deckId)),
            )
          : null,
    );
  }
}

class _Ueberschrift extends StatelessWidget {
  const _Ueberschrift(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      );
}

/// Zahlen des Decks: Modus, neu · lernt · gelernt, Fortschrittsbalken.
class _Kopf extends StatelessWidget {
  const _Kopf({required this.deck, required this.z});
  final Deck deck;
  final DeckZaehler z;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wiederholen = deck.modus == deckModusWiederholen;
    Widget zahl(String schluessel, int n, Color farbe) => Expanded(
          child: Column(children: [
            Text(Formatters.digits(n),
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: farbe, fontWeight: FontWeight.w800)),
            Text(
              AppL10n.tf(context, schluessel, {'n': ''}).trim(),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ]),
        );
    return Card(
      margin: const EdgeInsets.all(AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(
                  wiederholen
                      ? Icons.repeat_rounded
                      : Icons.menu_book_outlined,
                  size: 18,
                  color:
                      wiederholen ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppL10n.t(context,
                      wiederholen ? 'deck_modus_wiederholen' : 'deck_modus_notiz'),
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(
                AppL10n.tf(context, 'deck_woerter_n',
                    {'n': Formatters.digits(z.woerter)}),
                style: theme.textTheme.labelLarge,
              ),
            ]),
            const SizedBox(height: AppSizes.md),
            Row(children: [
              zahl('deck_neu_n', z.neu, Colors.blue.shade700),
              zahl('deck_lernt_n', z.lernt, Colors.orange.shade800),
              zahl('deck_gelernt_n', z.gelernt, Colors.green.shade700),
            ]),
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: z.anteilGelernt,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppL10n.tf(context, 'deck_gelernt_prozent',
                  {'p': Formatters.digits((z.anteilGelernt * 100).round())}),
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ein Wort des Decks — dieselbe Zeile wie in «Alle Wörter»; wischen nimmt
/// es aus diesem Deck (Fortschritt bleibt).
class _WortZeile extends ConsumerWidget {
  const _WortZeile({required this.deckId, required this.zeile});
  final String deckId;
  final ({String wortId, Object wert}) zeile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wert = zeile.wert;
    final Object eintrag = wert is Word ? wert.toModel() : wert;
    final name = eintrag is WordModel
        ? eintrag.german
        : '${(eintrag as Map)['wort'] ?? ''}';
    return Dismissible(
      key: ValueKey('deckwort_${zeile.wortId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: AppSizes.lg),
        color: Colors.red.withValues(alpha: 0.85),
        child: const Icon(Icons.remove_circle_outline_rounded,
            color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(name),
          content: Text(AppL10n.t(ctx, 'deck_aus_entfernen')),
          actions: [
            VoxButton.text(
              label: AppL10n.t(ctx, 'cancel'),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            VoxButton.destructive(
              label: AppL10n.t(ctx, 'delete'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          ref.read(leitnerDaoProvider).wortSetzen(deckId, zeile.wortId, false),
      child: WortschatzZeile(
        treffer:
            SuchTreffer<Object>(wert: eintrag, lemma: name, rang: SuchRang.genau),
      ),
    );
  }
}
