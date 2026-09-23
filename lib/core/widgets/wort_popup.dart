// FILE: lib/core/widgets/wort_popup.dart
// DEPS: klick_wort_provider.dart, wort_card.dart, wort_actions.dart,
//       word_list_item.dart, go_router
// PURPOSE: DER Popup beim Klick auf ein Wort — überall in der App derselbe
//          (L.5f, Lukas 2026-09-17):
//            Stufe 1 — Klick auf ein Wort  → dieser Popup (Bottom-Sheet).
//            Stufe 2 — Klick auf den Eintrag im Popup → volle Wort-Seite.
//          Von dort prüft der Nutzer die Bedeutung oder legt das Wort in den
//          Leitner.
//
// Der Popup zeigt KEINE eigene Wort-Darstellung: Treffer aus dem Archiv sind
// die normale `WortCard` (Symbol, Genusfarbe, Übersetzung) mit den normalen
// `WortActions` (Audio, Leitner, Kategorien); Treffer der alten Datenbank sind
// das normale `WordListItem`. Ändert sich das Aussehen eines Worts, ändert es
// sich hier mit (Component Isolation — eine Quelle).
//
// Aufruf: `showWortPopup(context, angetipptesWort)` — meist über
// `KlickWortText` (klick_wort_text.dart), nicht von Hand.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/vokabular/controllers/vokabular_controller.dart'
    show vokabIndexProvider;
import '../../features/vokabular/widgets/wort_actions.dart';
import '../../features/wortschatz/widgets/word_list_item.dart';
import '../constants/app_routes.dart';
import '../constants/app_sizes.dart';
import '../grammatikon/wort_card.dart';
import '../l10n/app_l10n.dart';
import '../wort/klick_wort_provider.dart';
import '../wort/wort_form.dart';
import 'audio_play_button.dart';
import 'deutsch_text.dart';
import 'leitner_add_button.dart';
import 'vox_button.dart';

/// Öffnet den Wort-Popup für [rohWort] (so wie es im Text stand — Satzzeichen
/// am Rand werden entfernt). Ohne Buchstaben passiert nichts.
Future<void> showWortPopup(BuildContext context, String rohWort) {
  final anzeige = wortBereinigt(rohWort);
  final schluessel = wortSchluessel(anzeige);
  if (schluessel.isEmpty) return Future<void>.value();

  // Vor dem Öffnen holen: nach dem Schließen des Sheets ist sein Context weg.
  final router = GoRouter.of(context);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _WortPopupBlatt(
      anzeige: anzeige,
      schluessel: schluessel,
      oeffne: (pfad) {
        Navigator.of(sheetContext).pop();
        router.push<void>(pfad);
      },
      schliesse: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class _WortPopupBlatt extends ConsumerWidget {
  const _WortPopupBlatt({
    required this.anzeige,
    required this.schluessel,
    required this.oeffne,
    required this.schliesse,
  });

  final String anzeige;
  final String schluessel;
  final void Function(String pfad) oeffne;
  final VoidCallback schliesse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treffer = ref.watch(klickWortTrefferProvider(schluessel));

    Widget nichtGefunden() => _NichtGefunden(
          anzeige: anzeige,
          oeffne: oeffne,
          schliesse: schliesse,
        );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: treffer.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          // Wörterbuch nicht geladen ≠ Wort fehlt (L.5f-Nachtrag 2026-09-23).
          error: (_, _) => _LadenFehlgeschlagen(
            anzeige: anzeige,
            nochmal: () {
              ref.invalidate(vokabIndexProvider);
              ref.invalidate(klickWortTrefferProvider(schluessel));
            },
            schliesse: schliesse,
          ),
          data: (liste) {
            if (liste.isEmpty) return nichtGefunden();
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in liste) _TrefferZeile(treffer: t, oeffne: oeffne),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Eine Zeile pro Treffer. Tippen auf die Zeile = Stufe 2 (volle Wort-Seite).
class _TrefferZeile extends StatelessWidget {
  const _TrefferZeile({required this.treffer, required this.oeffne});

  final KlickWortTreffer treffer;
  final void Function(String pfad) oeffne;

  @override
  Widget build(BuildContext context) {
    final karte = treffer.karte;
    if (treffer.quelle == KlickWortQuelle.archiv && karte != null) {
      return WortCard(
        card: karte,
        trailing: WortActions(card: karte, kompakt: true),
        onTap: () => oeffne(treffer.pfad),
      );
    }

    final wort = treffer.wort!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WordListItem(word: wort, onTap: () => oeffne(treffer.pfad)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AudioPlayButton(text: wort.displayGerman, size: 24),
              const SizedBox(width: AppSizes.sm),
              LeitnerAddButton(wordId: wort.id),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kein Eintrag: das Wort trotzdem zeigen, und einen Weg in die Suche geben
/// (gebeugte Formen wie «ging» oder «Häuser» stehen nicht als Grundform da).
class _NichtGefunden extends StatelessWidget {
  const _NichtGefunden({
    required this.anzeige,
    required this.oeffne,
    required this.schliesse,
  });

  final String anzeige;
  final void Function(String pfad) oeffne;
  final VoidCallback schliesse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WortKopf(anzeige: anzeige),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(Icons.search_off_rounded,
                  color: scheme.onSurfaceVariant, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppL10n.t(context, 'not_in_dictionary'),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              VoxButton.tonal(
                label: AppL10n.t(context, 'search_in_vokabular'),
                icon: Icons.search_rounded,
                onPressed: () => oeffne(
                    '${AppRoutes.wortschatzList}?suche=${Uri.encodeComponent(anzeige)}'),
              ),
              VoxButton.text(
                label: AppL10n.t(context, 'close'),
                onPressed: schliesse,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Das angetippte Wort groß, mit Aussprache — auch wenn es (noch) keine
/// Karte hat: hören kann man jedes Wort (Wunsch Lukas, 2026-09-23).
class _WortKopf extends StatelessWidget {
  const _WortKopf({required this.anzeige});
  final String anzeige;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          child: DeutschText(
            anzeige,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        AudioPlayButton(text: anzeige, size: 26),
      ],
    );
  }
}

/// Das Wörterbuch (Wortindex) konnte nicht geladen werden — ehrlich sagen,
/// statt «nicht im Wörterbuch» zu behaupten, und einen neuen Versuch anbieten.
class _LadenFehlgeschlagen extends StatelessWidget {
  const _LadenFehlgeschlagen({
    required this.anzeige,
    required this.nochmal,
    required this.schliesse,
  });

  final String anzeige;
  final VoidCallback nochmal;
  final VoidCallback schliesse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WortKopf(anzeige: anzeige),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: scheme.error, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppL10n.t(context, 'wort_popup_ladefehler'),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              VoxButton.tonal(
                label: AppL10n.t(context, 'retry'),
                icon: Icons.refresh_rounded,
                onPressed: nochmal,
              ),
              VoxButton.text(
                label: AppL10n.t(context, 'close'),
                onPressed: schliesse,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
