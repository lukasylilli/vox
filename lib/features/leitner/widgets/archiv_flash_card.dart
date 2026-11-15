// FILE: lib/features/leitner/widgets/archiv_flash_card.dart
// PURPOSE: Lernkarte für eine Archivkarte (Wort-Prompt, assets/vocab) im
//          Leitner — B-13 (2026-09-23).
//          Vorne: Symbol + Wort, gefärbt wie in der Wortschatz-Liste
//          (WortSymbol / WortZeile — keine eigene Farbregel), Aussprache.
//          Hinten: Übersetzung in der eingestellten Sprache (nie beide) und
//          der Weg zur vollen Wortseite.
//          Braucht nur den Index-Eintrag (id, wort, wortart, niveau,
//          uebersetzung, Symbol-Felder) — keine volle Karte, kein Laden.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/grammatikon/grammatikon_painter.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../vokabular/widgets/uebersicht_karte.dart';
import '../../vokabular/widgets/wortseite_bausteine.dart'
    show vokabBedeutungenTexte, vokabNr;
import 'wende_karte.dart';

class ArchivFlashCard extends StatelessWidget {
  const ArchivFlashCard({super.key, required this.karte, this.onFlip});

  /// Index-Eintrag der Archivkarte (vokabIndexByIdProvider).
  final Map<String, dynamic> karte;
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) => WendeKarte(
        key: ValueKey(karte['id']),
        vorne: _Vorne(karte: karte),
        hinten: _Hinten(karte: karte),
        onFlip: onFlip,
      );
}

class _Vorne extends ConsumerWidget {
  const _Vorne({required this.karte});
  final Map<String, dynamic> karte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wort = karte['wort'] as String? ?? '';
    final niveau = karte['niveau'] as String?;
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};
    // Vier Fälle (Lukas 2026-11-15): Übersicht «الف» ⇒ nur das Wort (kein
    // Symbol — die Bedeutungen haben verschiedene Artikel). Bedeutungskarte
    // «ب/ج» ⇒ KEINE Bedeutungshilfe, nur die Warnung «mehrere Bedeutungen».
    final uebersicht = istUebersicht(karte);
    final warnung = uebersicht
        ? AppL10n.t(context, 'mehrdeutig_liste')
        : mehrdeutigWarnung(context, karte, byId);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: scheme.outline, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!uebersicht) ...[
            WortSymbol(card: karte, size: 44),
            const SizedBox(height: AppSizes.md),
          ],
          WortZeile(
            card: karte,
            zentriert: true,
            style: theme.textTheme.headlineMedium,
          ),
          if (warnung != null) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              key: const ValueKey('lernkarte_mehrdeutig'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                warnung,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          if (niveau != null) ...[
            const SizedBox(height: AppSizes.sm),
            VoxBadge.level(niveau, small: true),
          ],
          const SizedBox(height: AppSizes.lg),
          AudioPlayButton(text: wort),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(AppL10n.t(context, 'tap_to_reveal'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hinten extends ConsumerWidget {
  const _Hinten({required this.karte});
  final Map<String, dynamic> karte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final id = karte['id'] as String? ?? '';
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};

    // Übersetzung NUR in der eingestellten Sprache (فاز L) — wie WortCard.
    final fa = AppL10n.isFa(context);
    final u = (karte['uebersetzung'] as Map?)?.cast<String, dynamic>() ??
        const {};
    final liste =
        ((u[fa ? 'fa' : 'en'] as List?) ?? const []).cast<String>();
    final bedeutungen = vokabBedeutungenTexte(context, karte);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border:
            Border.all(color: scheme.primary.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WortZeile(
              card: karte, zentriert: true, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSizes.lg),
          // Übersicht «الف»: ALLE Bedeutungen nebeneinander (Spalten, ab drei
          // ein Raster) — nie untereinander (Lukas 2026-11-15).
          if (istUebersicht(karte))
            BedeutungsRaster(
              glieder: uebersichtGlieder(karte, byId),
              gross: true,
            )
          else
          // Mehrere Bedeutungen (Regel 20, Lukas 2026-10-19): die ERSTE
          // groß — sie reicht für «richtig»; die übrigen klein darunter.
          Text(
            bedeutungen != null
                ? '${vokabNr(context, 1)}. ${bedeutungen.first}'
                : liste.join(fa ? '، ' : ', '),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (bedeutungen != null && !istUebersicht(karte)) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              AppL10n.t(context, 'leitner_erste_bedeutung'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            for (var i = 1; i < bedeutungen.length; i++)
              Text(
                '${vokabNr(context, i + 1)}. ${bedeutungen[i]}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
          ],
          // Bedeutungskarte «ب/ج»: hinten NUR ihre eigene Bedeutung (Lukas
          // 2026-11-15) — der frühere Hinweis auf die anderen Bedeutungen
          // entfällt; die Übersicht «الف» ist eine eigene Lernkarte.
          const SizedBox(height: AppSizes.lg),
          if (id.isNotEmpty)
            VoxButton.text(
              label: AppL10n.t(context, 'leitner_wortseite'),
              icon: Icons.open_in_new_rounded,
              onPressed: () => context.push(AppRoutes.vokabularWort(id)),
            ),
        ],
      ),
    );
  }
}
