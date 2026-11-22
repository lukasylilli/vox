// FILE: lib/features/leitner/widgets/standard_decks_sheet.dart
// PHASE: X.4b (2026-11-17) — Standard-Decks zurückholen
// PURPOSE: Entscheidung Lukas Nr. 16, Weg «الف»: auf der Leitner-Seite zeigt
//          «Standard-Decks» die gelöschten Standard-Decks; ein Knopf holt
//          eines zurück — mit den Wörtern von HEUTE (sie werden ja aus den
//          Daten berechnet) und unverändertem Fortschritt (der war nie weg).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/leitner_controller.dart';

class StandardDecksSheet extends ConsumerWidget {
  const StandardDecksSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weg = ref.watch(geloeschteStandardDecksProvider).valueOrNull;
    final alle = ref.watch(standardDecksProvider).valueOrNull?.decks ??
        const <StandardDeck>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, 0, AppSizes.md, AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppL10n.t(context, 'deck_standard_titel'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(AppL10n.t(context, 'deck_standard_hinweis'),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSizes.sm),
          if (weg == null)
            const Center(child: CircularProgressIndicator())
          else if (weg.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Text(AppL10n.t(context, 'deck_standard_leer'),
                  textAlign: TextAlign.center),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final d in weg)
                    ListTile(
                      key: ValueKey('std_weg_${d.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(d.eltern == null
                          ? Icons.folder_outlined
                          : Icons.subdirectory_arrow_right_rounded),
                      title: Text(d.name),
                      subtitle: d.eltern == null
                          ? null
                          : Text(alle
                                  .where((e) => e.id == d.eltern)
                                  .firstOrNull
                                  ?.name ??
                              ''),
                      trailing: VoxButton.tonal(
                        key: ValueKey('std_zurueck_${d.id}'),
                        label: AppL10n.t(context, 'deck_standard_zurueck'),
                        icon: Icons.restore_rounded,
                        size: VoxButtonSize.small,
                        onPressed: () => d.virtuell
                            // Lektion/Teil: nur das Ereignis — eine Zeile
                            // braucht sie nicht.
                            ? ref
                                .read(leitnerDaoProvider)
                                .virtuellesDeckZurueckholen(d.id)
                            : ref
                            .read(leitnerDaoProvider)
                            .standardDeckZurueckholen(
                              (
                                id: d.id,
                                name: d.name,
                                eltern: d.eltern,
                                ordnung: d.ordnung,
                              ),
                              kinder: [
                                for (final k in alle)
                                  if (k.eltern == d.id) k.id,
                              ],
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
