// FILE: lib/features/vokabular/widgets/wort_actions.dart
// PURPOSE: Die Aktionen eines Vokabular-Worts:
//          🔊 Audio (TtsService) | Leitner-Knopf.
//          X.3 (2026-11-17): der Leitner-Knopf WÄHLT DAS DECK — er öffnet die
//          Deck-Auswahl (features/leitner/widgets/deck_auswahl_sheet.dart).
//          Der frühere dritte Knopf «Meine Kategorien» ist darin aufgegangen:
//          Kategorien sind Decks (X.2).
//          Der Knopf zeigt, wo das Wort liegt: in einem Deck mit Wiederholung
//          («im Leitner»), nur in einem Notizbuch-Deck, oder nirgends.
//          kompakt=true → Icon-Reihe für Listen; sonst große Buttons (Wort-Seite).
//          Puzzling: nur VoxButton/VoxIconButton/AudioPlayButton — keine rohen Buttons.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/vox_button.dart';
import '../../leitner/controllers/leitner_controller.dart'
    show imLeitnerMengeProvider;
import '../../leitner/widgets/deck_auswahl_sheet.dart';
import '../controllers/vokabular_user_state.dart';

class WortActions extends ConsumerWidget {
  final Map<String, dynamic> card;
  final bool kompakt;

  const WortActions({super.key, required this.card, this.kompakt = false});

  String get _id => card['id'] as String? ?? '';
  String get _wort => card['wort'] as String? ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Von Hand in einem Deck mit Wiederholung — oder (X.4b) aus den Daten in
    // einem Standard-Deck, das auf «Wiederholung» steht.
    final imLeitner = ref.watch(
            vokabularUserProvider.select((s) => s.imLeitner(_id))) ||
        (ref.watch(imLeitnerMengeProvider).valueOrNull?.contains(_id) ??
            false);
    final imNotizbuch = ref.watch(
        vokabularUserProvider.select((s) => s.imNotizbuch(_id)));
    final scheme = Theme.of(context).colorScheme;
    void waehlen() => showDeckAuswahl(context, wortId: _id, wort: _wort);

    if (kompakt) {
      // Liste (2026-11-15): nur Aussprache + Leitner — die Zeile musste für
      // X.3 nicht umgebaut werden, der Knopf wählt jetzt das Deck.
      return Row(mainAxisSize: MainAxisSize.min, children: [
        AudioPlayButton(text: _wort, size: 20),
        VoxIconButton(
          icon: imLeitner || imNotizbuch
              ? Icons.inventory_2_rounded
              : Icons.inventory_2_outlined,
          color: imLeitner
              ? scheme.primary
              : imNotizbuch
                  ? scheme.onSurfaceVariant
                  : null,
          iconSize: 20,
          tooltip: AppL10n.t(
              context,
              imLeitner
                  ? 'in_leitner'
                  : imNotizbuch
                      ? 'deck_im_notizbuch'
                      : 'add_to_leitner'),
          onPressed: waehlen,
        ),
      ]);
    }

    return Row(children: [
      AudioPlayButton(text: _wort, size: 28),
      const SizedBox(width: 8),
      Expanded(
        child: imLeitner
            ? VoxButton.success(
                label: AppL10n.t(context, 'in_leitner'),
                icon: Icons.check_rounded,
                onPressed: waehlen,
              )
            : VoxButton.tonal(
                label: AppL10n.t(context,
                    imNotizbuch ? 'deck_im_notizbuch' : 'add_to_leitner'),
                icon: imNotizbuch
                    ? Icons.inventory_2_rounded
                    : Icons.inventory_2_outlined,
                onPressed: waehlen,
              ),
      ),
    ]);
  }
}
