// FILE: lib/features/leitner/widgets/deck_zeile.dart
// PHASE: X.4 (2026-11-17) — Leitner wie Anki
// PURPOSE: EINE Zeile eines Decks — im Baum der Leitner-Seite und in der
//          Liste der Subdecks einer Deck-Seite: Name, Modus, Zahlen (Wörter,
//          % gelernt), was heute dran ist (neu / Wiederholung, wie Anki),
//          Knopf «üben» und Menü (umbenennen, Subdeck, Modus, Tageslimit,
//          löschen). Tippen öffnet die Deck-Seite.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/leitner/deck_sitzung.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/leitner_controller.dart';
import 'deck_dialoge.dart';

class DeckZeile extends ConsumerWidget {
  const DeckZeile({
    super.key,
    required this.deck,
    required this.tiefe,
    required this.obersteEbene,
  });

  final Deck deck;

  /// Einrückung (0 = oberste Ebene im gezeigten Ausschnitt).
  final int tiefe;

  /// Hat das Deck kein Eltern-Deck? (Standard-Limit 50 statt 10.)
  final bool obersteEbene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final z = ref.watch(deckRechnerProvider).valueOrNull?.zaehler(deck.id) ??
        const DeckZaehler();
    final wiederholen = deck.modus == deckModusWiederholen;
    final prozent = (z.anteilGelernt * 100).round();

    return InkWell(
      key: ValueKey('deckzeile_${deck.id}'),
      onTap: () => context.push(AppRoutes.leitnerDeckSeite(deck.id)),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: AppSizes.sm + 18.0 * tiefe.clamp(0, 6),
            end: AppSizes.xs,
            top: AppSizes.xs,
            bottom: AppSizes.xs),
        child: Row(
          children: [
            Icon(
              wiederholen ? Icons.style_rounded : Icons.menu_book_outlined,
              size: 22,
              color: wiederholen ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${AppL10n.tf(context, 'deck_woerter_n', {'n': Formatters.digits(z.woerter)})}'
                    ' · '
                    '${AppL10n.tf(context, 'deck_gelernt_prozent', {'p': Formatters.digits(prozent)})}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (z.woerter > 0) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: z.anteilGelernt,
                        minHeight: 4,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            if (z.heute > 0) _HeuteZahlen(z: z),
            if (z.heute > 0)
              VoxIconButton(
                key: ValueKey('deck_ueben_${deck.id}'),
                icon: Icons.play_circle_fill_rounded,
                color: scheme.primary,
                tooltip: AppL10n.t(context, 'deck_ueben'),
                onPressed: () =>
                    context.push(AppRoutes.leitnerUeben(deck.id)),
              ),
            DeckMenue(deck: deck, obersteEbene: obersteEbene),
          ],
        ),
      ),
    );
  }
}

/// Wie Anki: blau = neu heute, orange = Wiederholung heute.
class _HeuteZahlen extends StatelessWidget {
  const _HeuteZahlen({required this.z});
  final DeckZaehler z;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (z.neuHeute > 0)
          Text(
              AppL10n.tf(context, 'deck_heute_neu',
                  {'n': Formatters.digits(z.neuHeute)}),
              style: s?.copyWith(
                  color: Colors.blue.shade700, fontWeight: FontWeight.w700)),
        if (z.faellig > 0)
          Text(
              AppL10n.tf(context, 'deck_heute_faellig',
                  {'n': Formatters.digits(z.faellig)}),
              style: s?.copyWith(
                  color: Colors.orange.shade800, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Menü eines Decks: umbenennen · Subdeck · Modus · Tageslimit · löschen.
class DeckMenue extends ConsumerWidget {
  const DeckMenue({
    super.key,
    required this.deck,
    required this.obersteEbene,
    this.nachLoeschen,
  });

  final Deck deck;
  final bool obersteEbene;

  /// Nach dem Löschen (z. B. Deck-Seite schließen).
  final VoidCallback? nachLoeschen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wiederholen = deck.modus == deckModusWiederholen;
    final limit = deck.neuProTag ??
        (obersteEbene ? neuProTagDeck : neuProTagSubdeck);
    return PopupMenuButton<String>(
      key: ValueKey('deck_menue_${deck.id}'),
      tooltip: AppL10n.t(context, 'deck_mehr'),
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (wahl) async {
        switch (wahl) {
          case 'umbenennen':
            await deckUmbenennen(context, ref, deck);
          case 'subdeck':
            await neuesDeckAnlegen(context, ref, eltern: deck);
          case 'modus':
            await ref.read(leitnerDaoProvider).deckEinstellen(deck.id,
                modus: wiederholen ? deckModusNotiz : deckModusWiederholen);
          case 'limit':
            await deckLimitAendern(context, ref, deck,
                obersteEbene: obersteEbene);
          case 'loeschen':
            if (await deckLoeschen(context, ref, deck)) nachLoeschen?.call();
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'umbenennen',
          child: ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(AppL10n.t(ctx, 'deck_umbenennen')),
          ),
        ),
        PopupMenuItem(
          value: 'subdeck',
          child: ListTile(
            leading: const Icon(Icons.subdirectory_arrow_right_rounded),
            title: Text(AppL10n.tf(ctx, 'deck_sub_neu', {'deck': deck.name})),
          ),
        ),
        PopupMenuItem(
          key: ValueKey('deck_modus_${deck.id}'),
          value: 'modus',
          child: ListTile(
            leading: Icon(wiederholen
                ? Icons.menu_book_outlined
                : Icons.repeat_rounded),
            // Zeigt, wohin umgeschaltet wird.
            title: Text(AppL10n.tf(ctx, 'deck_modus_wechseln', {
              'modus': AppL10n.t(
                  ctx, wiederholen ? 'deck_modus_notiz' : 'deck_modus_wiederholen'),
            })),
          ),
        ),
        if (wiederholen)
          PopupMenuItem(
            value: 'limit',
            child: ListTile(
              leading: const Icon(Icons.speed_rounded),
              title: Text(AppL10n.tf(
                  ctx, 'deck_limit_n', {'n': Formatters.digits(limit)})),
            ),
          ),
        PopupMenuItem(
          key: ValueKey('deck_loeschen_${deck.id}'),
          value: 'loeschen',
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded,
                color: Theme.of(ctx).colorScheme.error),
            title: Text(AppL10n.t(ctx, 'delete'),
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}
