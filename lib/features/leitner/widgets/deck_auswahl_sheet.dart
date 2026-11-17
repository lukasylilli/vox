// FILE: lib/features/leitner/widgets/deck_auswahl_sheet.dart
// PHASE: X.3 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// DEPS: leitner_controller.dart (deckBaumProvider, deckIdsVonWortProvider,
//       leitnerDaoProvider), core/leitner/leitner_regeln.dart
// PURPOSE: Der Leitner-Knopf wählt das Deck (Wunsch Lukas 2026-11-03: «wie
//          Anki — die Karte in das Deck legen, das man will»). EIN Blatt für
//          jedes Wort, überall in der App — Archivkarten und alte Wörter:
//            · der Baum aller Decks, je Deck ein Haken (mehrere möglich; der
//              Fortschritt des Worts ist gemeinsam);
//            · «neues Deck» und, an jedem Deck, «neues Subdeck» — mit Name
//              und Modus (Wiederholung / nur Notizbuch); das Wort liegt
//              sofort darin;
//            · das Deck «Leitner» steht immer oben, auch bevor es angelegt
//              ist (ein Haken dort ist der bisherige Leitner-Knopf).
//          Ersetzt das Blatt «Meine Kategorien» (wort_actions.dart) und
//          add_to_category_sheet.dart: Kategorien SIND Decks (X.2).
//
// Jeder Haken wirkt sofort (kein «Speichern»); alle Anzeigen folgen von
// selbst, weil sie Ströme der Tabellen lesen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/leitner_controller.dart';

/// Öffnet die Deck-Auswahl für das Wort [wortId] (Text-id). [wort] ist nur
/// die Überschrift.
Future<void> showDeckAuswahl(
  BuildContext context, {
  required String wortId,
  required String wort,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DeckAuswahlSheet(wortId: wortId, wort: wort),
    );

class DeckAuswahlSheet extends ConsumerWidget {
  const DeckAuswahlSheet({super.key, required this.wortId, required this.wort});

  final String wortId;
  final String wort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final baum = ref.watch(deckBaumProvider).valueOrNull;
    final drin = ref.watch(deckIdsVonWortProvider(wortId)).valueOrNull;
    final hoehe = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
          left: AppSizes.md,
          right: AppSizes.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppL10n.tf(context, 'deck_auswahl_titel', {'wort': wort}),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            AppL10n.t(context, 'deck_auswahl_hinweis'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.sm),
          if (baum == null || drin == null)
            const Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: hoehe * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Das Deck «Leitner» steht immer da — vor dem ersten
                  // Gebrauch als Zeile ohne Tabelle dahinter.
                  if (!baum.any((k) => k.deck.id == standardDeckId))
                    _DeckZeile(
                      key: const ValueKey('deck_$standardDeckId'),
                      name: standardDeckName,
                      tiefe: 0,
                      wiederholen: true,
                      gewaehlt: false,
                      onChanged: (_) =>
                          ref.read(leitnerDaoProvider).aufnehmen(wortId),
                      onSubdeck: () async {
                        final dao = ref.read(leitnerDaoProvider);
                        final leitner = await dao.standardDeck();
                        if (context.mounted) {
                          await _neuesDeck(context, ref, eltern: leitner);
                        }
                      },
                    ),
                  for (final k in baum)
                    _DeckZeile(
                      key: ValueKey('deck_${k.deck.id}'),
                      name: k.deck.name,
                      tiefe: k.tiefe,
                      wiederholen: k.deck.modus == deckModusWiederholen,
                      gewaehlt: drin.contains(k.deck.id),
                      onChanged: (rein) => ref
                          .read(leitnerDaoProvider)
                          .wortSetzen(k.deck.id, wortId, rein),
                      onSubdeck: () => _neuesDeck(context, ref, eltern: k.deck),
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSizes.sm),
          VoxButton.tonal(
            key: const ValueKey('deck_neu'),
            label: AppL10n.t(context, 'deck_neu'),
            icon: Icons.create_new_folder_outlined,
            expand: true,
            onPressed: () => _neuesDeck(context, ref),
          ),
          const SizedBox(height: AppSizes.sm),
          VoxButton.primary(
            label: AppL10n.t(context, 'done'),
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Fragt Name und Modus, legt das Deck an und das Wort hinein.
  Future<void> _neuesDeck(BuildContext context, WidgetRef ref,
      {Deck? eltern}) async {
    final neu = await showDialog<({String name, String modus})>(
      context: context,
      builder: (_) => _NeuesDeckDialog(eltern: eltern),
    );
    if (neu == null) return;
    final dao = ref.read(leitnerDaoProvider);
    final deck =
        await dao.deckAnlegen(neu.name, elternId: eltern?.id, modus: neu.modus);
    await dao.wortSetzen(deck.id, wortId, true);
  }
}

// ─── Eine Zeile im Baum ──────────────────────────────────────────────────────

class _DeckZeile extends StatelessWidget {
  const _DeckZeile({
    super.key,
    required this.name,
    required this.tiefe,
    required this.wiederholen,
    required this.gewaehlt,
    required this.onChanged,
    required this.onSubdeck,
  });

  final String name;
  final int tiefe;
  final bool wiederholen;
  final bool gewaehlt;
  final ValueChanged<bool> onChanged;
  final VoidCallback onSubdeck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grau = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: () => onChanged(!gewaehlt),
      child: Padding(
        // Einrückung je Ebene — begrenzt, damit tiefe Bäume lesbar bleiben.
        padding: EdgeInsetsDirectional.only(start: 20.0 * tiefe.clamp(0, 6)),
        child: Row(
          children: [
            Checkbox(value: gewaehlt, onChanged: (v) => onChanged(v ?? false)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          wiederholen
                              ? Icons.repeat_rounded
                              : Icons.menu_book_outlined,
                          size: 13,
                          color: wiederholen
                              ? theme.colorScheme.primary
                              : grau),
                      const SizedBox(width: 4),
                      Text(
                        AppL10n.t(
                            context,
                            wiederholen
                                ? 'deck_modus_wiederholen'
                                : 'deck_modus_notiz'),
                        style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                wiederholen ? theme.colorScheme.primary : grau),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            VoxIconButton(
              icon: Icons.subdirectory_arrow_right_rounded,
              iconSize: 20,
              tooltip:
                  AppL10n.tf(context, 'deck_sub_neu', {'deck': name}),
              onPressed: onSubdeck,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dialog «neues Deck / neues Subdeck» ─────────────────────────────────────

class _NeuesDeckDialog extends StatefulWidget {
  const _NeuesDeckDialog({this.eltern});

  /// Eltern-Deck (dann wird ein Subdeck angelegt) oder null.
  final Deck? eltern;

  @override
  State<_NeuesDeckDialog> createState() => _NeuesDeckDialogState();
}

class _NeuesDeckDialogState extends State<_NeuesDeckDialog> {
  final _name = TextEditingController();

  // Ein Subdeck beginnt im Modus seines Eltern-Decks; ein neues Deck der
  // obersten Ebene mit Wiederholung — wer über den Leitner-Knopf ein Deck
  // anlegt, will in aller Regel lernen. Beides ist hier umschaltbar.
  late String _modus = widget.eltern?.modus ?? deckModusWiederholen;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _fertig() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name: name, modus: _modus));
  }

  @override
  Widget build(BuildContext context) {
    final eltern = widget.eltern;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(eltern == null
          ? AppL10n.t(context, 'deck_neu')
          : AppL10n.tf(context, 'deck_sub_neu', {'deck': eltern.name})),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('deck_name'),
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
                hintText: AppL10n.t(context, 'deck_name_hint')),
            onSubmitted: (_) => _fertig(),
          ),
          const SizedBox(height: AppSizes.md),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: deckModusWiederholen,
                icon: const Icon(Icons.repeat_rounded),
                label: Text(AppL10n.t(context, 'deck_modus_wiederholen')),
              ),
              ButtonSegment(
                value: deckModusNotiz,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(AppL10n.t(context, 'deck_modus_notiz')),
              ),
            ],
            selected: {_modus},
            onSelectionChanged: (s) => setState(() => _modus = s.single),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            AppL10n.t(
                context,
                _modus == deckModusWiederholen
                    ? 'deck_modus_wiederholen_info'
                    : 'deck_modus_notiz_info'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        VoxButton.text(
          label: AppL10n.t(context, 'cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        VoxButton.primary(
          key: const ValueKey('deck_anlegen'),
          label: AppL10n.t(context, 'create'),
          onPressed: _fertig,
        ),
      ],
    );
  }
}
