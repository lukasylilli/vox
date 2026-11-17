// FILE: lib/core/widgets/leitner_add_button.dart
// DEPS: leitner_controller.dart, deck_auswahl_sheet.dart
// PURPOSE: Shared button — shows whether a word is in Leitner and which box;
//          X.3 (2026-11-17): a tap opens the deck picker
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/leitner/controllers/leitner_controller.dart';
import '../../features/leitner/widgets/deck_auswahl_sheet.dart';
import '../../features/wortschatz/controllers/word_controller.dart';
import '../l10n/app_l10n.dart';
import '../leitner/leitner_regeln.dart';

/// Leitner-Knopf eines ALTEN Worts (Tabelle `Words`). X.3: er wählt das Deck
/// — dieselbe Auswahl wie bei den Archivkarten (deck_auswahl_sheet.dart).
class LeitnerAddButton extends ConsumerWidget {
  const LeitnerAddButton({super.key, required this.wordId, this.compact = false});

  /// Nummer des alten Worts. Der Leitner kennt seit X.2 nur Text-ids —
  /// [altWortIdProvider] übersetzt.
  final int  wordId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const laedt = SizedBox(
      width: 22, height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    final idAsync = ref.watch(altWortIdProvider(wordId));
    final wortId  = idAsync.valueOrNull;
    if (wortId == null) {
      return idAsync.isLoading ? laedt : const SizedBox.shrink();
    }
    final imLeitner =
        ref.watch(isInLeitnerProvider(wortId)).valueOrNull ?? false;
    final imDeck =
        ref.watch(deckIdsVonWortProvider(wortId)).valueOrNull?.isNotEmpty ??
            false;

    Future<void> waehlen() async {
      final wort = await ref.read(wordDaoProvider).getById(wordId);
      if (!context.mounted) return;
      await showDeckAuswahl(context,
          wortId: wortId, wort: wort?.german ?? '');
    }

    final String label;
    if (imLeitner) {
      final stand = ref
          .watch(leitnerFortschrittProvider(uebungBedeutung))
          .valueOrNull?[wortId];
      label = AppL10n.tf(context, 'leitner_box_n',
          {'n': '${anzeigeFach(stand).clamp(1, leitnerFaecher)}'});
    } else {
      label = AppL10n.t(
          context, imDeck ? 'deck_im_notizbuch' : 'add_to_leitner');
    }

    if (compact) {
      return imLeitner
          ? IconButton(
              tooltip  : label,
              icon     : const Icon(Icons.check_circle_rounded),
              color    : Colors.green,
              onPressed: waehlen,
            )
          : IconButton.filled(
              tooltip  : label,
              icon     : Icon(imDeck
                  ? Icons.inventory_2_rounded
                  : Icons.add_circle_outline_rounded),
              onPressed: waehlen,
            );
    }
    return imLeitner
        ? OutlinedButton.icon(
            onPressed: waehlen,
            icon     : const Icon(Icons.check_circle_rounded, color: Colors.green),
            label    : Text(label),
          )
        : FilledButton.tonalIcon(
            onPressed: waehlen,
            icon     : Icon(imDeck ? Icons.inventory_2_rounded : Icons.add_rounded),
            label    : Text(label),
          );
  }
}
