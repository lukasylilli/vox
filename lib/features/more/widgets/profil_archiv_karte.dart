// FILE: lib/features/more/widgets/profil_archiv_karte.dart
// PHASE: فاز P / P.3 (2026-09-20)
// PURPOSE: «آرشیو من» — was der Nutzer angelegt hat, als Zahlen, mit Sprung
//          zum Leitner und zu den Listen.
//
// ⚠️ Nur Lesen. Die Zahlen kommen aus `archivUebersichtProvider`, der über
//    dieselbe Ablage liest wie Sicherung und Konto — es gibt keine zweite
//    Zählweise. Bearbeitet wird in den jeweiligen Bereichen, nicht hier.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/profil_controller.dart';

class ProfilArchivKarte extends ConsumerWidget {
  const ProfilArchivKarte({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uebersicht = ref.watch(archivUebersichtProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: uebersicht.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (u) => _inhalt(context, u),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context, ArchivUebersicht u) {
    if (u.istLeer) {
      return Row(children: [
        const Icon(Icons.inventory_2_outlined),
        const SizedBox(width: AppSizes.sm),
        Expanded(child: Text(AppL10n.t(context, 'profile_archive_empty'))),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _zeile(context, Icons.style_outlined, 'profile_archive_leitner',
            u.leitnerKarten),
        if (u.proFach.isNotEmpty) ...[
          const SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              for (final e in u.proFach.entries)
                Chip(
                  label: Text(AppL10n.tf(context, 'profile_archive_box',
                      {'n': '${e.key}', 'c': '${e.value}'})),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.sm),
        _zeile(context, Icons.folder_outlined, 'profile_archive_lists',
            u.listen),
        _zeile(context, Icons.sticky_note_2_outlined, 'profile_archive_notes',
            u.notizen),
        _zeile(context, Icons.edit_note_outlined, 'profile_archive_words',
            u.eigeneWoerter),
        const SizedBox(height: AppSizes.md),
        Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: [
          VoxButton.tonal(
            label: AppL10n.t(context, 'profile_open_leitner'),
            icon: Icons.style_outlined,
            onPressed: () => context.push(AppRoutes.leitner),
          ),
          VoxButton.secondary(
            label: AppL10n.t(context, 'profile_open_lists'),
            icon: Icons.folder_open_outlined,
            onPressed: () => context.push(AppRoutes.wortschatzCategories),
          ),
        ]),
      ],
    );
  }

  Widget _zeile(BuildContext context, IconData icon, String schluessel, int n) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Icon(icon, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(AppL10n.t(context, schluessel))),
          Text('$n', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      );
}
