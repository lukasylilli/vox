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
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/grammatikon/grammatikon_painter.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_button.dart';
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

class _Vorne extends StatelessWidget {
  const _Vorne({required this.karte});
  final Map<String, dynamic> karte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wort = karte['wort'] as String? ?? '';
    final niveau = karte['niveau'] as String?;

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
          WortSymbol(card: karte, size: 44),
          const SizedBox(height: AppSizes.md),
          WortZeile(
            card: karte,
            zentriert: true,
            style: theme.textTheme.headlineMedium,
          ),
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

class _Hinten extends StatelessWidget {
  const _Hinten({required this.karte});
  final Map<String, dynamic> karte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final id = karte['id'] as String? ?? '';

    // Übersetzung NUR in der eingestellten Sprache (فاز L) — wie WortCard.
    final fa = AppL10n.isFa(context);
    final u = (karte['uebersetzung'] as Map?)?.cast<String, dynamic>() ??
        const {};
    final liste =
        ((u[fa ? 'fa' : 'en'] as List?) ?? const []).cast<String>();

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
          Text(
            liste.join(fa ? '، ' : ', '),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
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
