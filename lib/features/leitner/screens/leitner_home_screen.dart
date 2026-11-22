// FILE: lib/features/leitner/screens/leitner_home_screen.dart
// DEPS: leitner_controller.dart, deck_zeile.dart, deck_dialoge.dart,
//       box_progress_widget.dart, app_routes.dart
// PURPOSE: Leitner-Seite. X.4 (2026-11-17, Leitner wie Anki): oben was heute
//          dran ist (alle Decks, nach den Tageslimits) mit «alle üben»,
//          darunter der BAUM der Decks — jede Zeile mit Zahlen, eigenem
//          «üben» und Menü —, «neues Deck», und die Verteilung auf die 7
//          Fächer. Die frühere Seite «Meine Kategorien» ist hierin
//          aufgegangen (Kategorien sind Decks).
import 'package:vox/core/leitner/leitner_regeln.dart' show leitnerFaecher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/database/app_database.dart';
import '../../../core/leitner/deck_baum.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/leitner_controller.dart';
import '../widgets/box_progress_widget.dart';
import '../widgets/deck_dialoge.dart';
import '../widgets/deck_zeile.dart';
import '../widgets/standard_decks_sheet.dart';
import '../../../core/widgets/vox_button.dart';

/// Auf-/zugeklappte Decks im Baum (nur für diese Sitzung der App).
/// Fehlt ein Deck hier, gilt: eigene Decks offen, Standard-Decks zu — sonst
/// stünden Tausende Lektionen auf der Seite.
final deckOffenProvider = StateProvider<Map<String, bool>>((_) => const {});

/// Die sichtbaren Zeilen des Baums: ein Deck ist sichtbar, wenn alle Decks
/// darüber offen sind.
List<({DeckKnoten<Deck> knoten, bool hatKinder, bool offen})> sichtbareDecks(
    List<DeckKnoten<Deck>> baum, Map<String, bool> offen) {
  bool istOffen(Deck d) => offen[d.id] ?? !istStandardDeck(d.id);
  final ergebnis = <({DeckKnoten<Deck> knoten, bool hatKinder, bool offen})>[];
  // Tiefe, ab der (wegen eines zugeklappten Decks) nichts sichtbar ist.
  int? zuAb;
  for (var i = 0; i < baum.length; i++) {
    final k = baum[i];
    if (zuAb != null) {
      if (k.tiefe > zuAb) continue;
      zuAb = null;
    }
    final hatKinder = i + 1 < baum.length && baum[i + 1].tiefe > k.tiefe;
    final o = istOffen(k.deck);
    ergebnis.add((knoten: k, hatKinder: hatKinder, offen: o));
    if (hatKinder && !o) zuAb = k.tiefe;
  }
  return ergebnis;
}

class LeitnerHomeScreen extends ConsumerWidget {
  const LeitnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final scheme     = theme.colorScheme;
    // X.4b: fehlende Standard-Decks beim Öffnen anlegen (Entscheidung 16).
    ref.watch(standardDecksEinrichtenProvider);
    final offen = ref.watch(deckOffenProvider);
    final dueAsync   = ref.watch(dueCountProvider);
    final countsAsync= ref.watch(boxCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitner'),
        actions: [
          VoxIconButton(
            icon: Icons.bar_chart_rounded,
            tooltip  : AppL10n.t(context, 'stats_label'),
            onPressed: () => context.push(AppRoutes.leitnerStats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [

          // ── Due cards banner ────────────────────────────────────────────
          dueAsync.when(
            loading: () => const _DueBanner(count: 0, loading: true),
            error  : (_, _) => const _DueBanner(count: 0),
            data   : (n) => _DueBanner(count: n),
          ),

          const SizedBox(height: AppSizes.lg),

          // ── Decks (X.4) ────────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: Text(AppL10n.t(context, 'decks_titel'),
                  style: theme.textTheme.titleMedium),
            ),
            VoxButton.tonal(
              key: const ValueKey('leitner_deck_neu'),
              label: AppL10n.t(context, 'deck_neu'),
              icon: Icons.create_new_folder_outlined,
              size: VoxButtonSize.small,
              onPressed: () => neuesDeckAnlegen(context, ref),
            ),
          ]),
          const SizedBox(height: AppSizes.sm),
          if ((ref.watch(geloeschteStandardDecksProvider).valueOrNull ??
                  const [])
              .isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: VoxButton.text(
                key: const ValueKey('leitner_standard_decks'),
                label: AppL10n.t(context, 'deck_standard_titel'),
                icon: Icons.restore_rounded,
                size: VoxButtonSize.small,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => const StandardDecksSheet(),
                ),
              ),
            ),
          ...switch (ref.watch(deckBaumProvider)) {
            AsyncData(:final value) when value.isEmpty => [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(AppL10n.t(context, 'decks_leer'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            AsyncData(:final value) => [
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (final z in sichtbareDecks(value, offen))
                      DeckZeile(
                        deck: z.knoten.deck,
                        tiefe: z.knoten.tiefe,
                        obersteEbene: z.knoten.tiefe == 0,
                        hatKinder: z.hatKinder,
                        offen: z.offen,
                        onAufklappen: () => ref
                            .read(deckOffenProvider.notifier)
                            .update((m) => {...m, z.knoten.deck.id: !z.offen}),
                      ),
                  ]),
                ),
              ],
            _ => const [
                Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
          },
          const SizedBox(height: AppSizes.lg),

          // ── Box progress ────────────────────────────────────────────────
          Text(AppL10n.t(context, 'box_distribution'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          const BoxProgressWidget(),

          const SizedBox(height: AppSizes.lg),

          // ── Box detail list ─────────────────────────────────────────────
          countsAsync.when(
            loading: () => const SizedBox.shrink(),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (counts) => Column(
              children: List.generate(leitnerFaecher, (i) {
                final box   = i + 1;
                final count = counts[box] ?? 0;
                final interval = boxIntervals[i];
                return ListTile(
                  leading     : CircleAvatar(
                    radius   : 16,
                    backgroundColor: scheme.primaryContainer,
                    child    : Text('$box',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                        fontSize: 12,
                      )),
                  ),
                  title       : Text('${AppL10n.t(context, 'box_label')} $box'),
                  subtitle    : Text(AppL10n.tf(context, 'every_x_days', {'n': '$interval'})),
                  trailing    : Text(Formatters.countLabel(count, AppL10n.t(context, 'card_unit')),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ),
          ),

          const SizedBox(height: AppSizes.xl),
        ],
      ),

      // ── Start Review FAB ─────────────────────────────────────────────────
      floatingActionButton: dueAsync.when(
        loading: () => null,
        error  : (_, _) => null,
        data   : (n) => n == 0
            ? null
            : VoxFab.extended(
                icon     : Icons.play_arrow_rounded,
                label    : AppL10n.tf(context, 'alle_ueben_n',
                    {'n': Formatters.digits(n)}),
                onPressed: () => context.push(AppRoutes.leitnerUeben(null)),
              ),
      ),
    );
  }
}

// ── Due count banner ──────────────────────────────────────────────────────────

class _DueBanner extends StatelessWidget {
  const _DueBanner({required this.count, this.loading = false});
  final int  count;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final hasCards = count > 0;

    return Container(
      padding   : const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCards
              ? [Colors.orange.withValues(alpha: 0.8), Colors.deepOrange.withValues(alpha: 0.8)]
              : [Colors.green.withValues(alpha: 0.6), Colors.teal.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        children: [
          Icon(
            hasCards ? Icons.notification_important_rounded : Icons.check_circle_rounded,
            color: Colors.white, size: 40,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loading ? '...' : AppL10n.tf(context, 'n_cards_due', {'n': '$count'}),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  hasCards ? AppL10n.t(context, 'ready_for_review_today') : AppL10n.t(context, 'all_cards_up_to_date'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
