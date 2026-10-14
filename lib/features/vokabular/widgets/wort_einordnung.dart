// FILE: lib/features/vokabular/widgets/wort_einordnung.dart
// PHASE: فاز F.6 / F.6b (Lukas, 2026-10-14)
// PURPOSE: EINE Quelle für die Anzeige der Einordnung (Prompt-Regel 17:
//          berufe · anstoessig · zeitlich · ersatz):
//            · Texte (l10n) und Icons je Wert — auch die Filterseite nutzt sie,
//            · [WortEinordnung]: Etiketten auf der Wort-Seite.
//          Aussehen kommt NUR aus dem Code (Regel 1: die Karte liefert keine
//          Icons/Farben). Berufe: neutral; Warnungen (anstößig/veraltet):
//          ruhiges Bernstein (AppColors.warning).
//          Klick auf ein Etikett ⇒ «Alle Wörter» mit genau diesem Filter
//          (F.6b). Ersatz ⇒ klickbarer Verweis wie im Wortnetz.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../wortschatz/controllers/wortschatz_filter_controller.dart';
import '../../wortschatz/data/wortschatz_filter.dart';
import 'wortseite_bausteine.dart' show vokabUeb;

/// Icon je Berufsfeld (vokabBerufe).
IconData berufIcon(String beruf) => switch (beruf) {
      'pflege_medizin' => Icons.medical_services_rounded,
      'it' => Icons.computer_rounded,
      'technik' => Icons.build_rounded,
      'bau' => Icons.construction_rounded,
      'gastro_hotel' => Icons.restaurant_rounded,
      'logistik' => Icons.local_shipping_rounded,
      'kinder_bildung' => Icons.child_care_rounded,
      'reinigung' => Icons.cleaning_services_rounded,
      'buero' => Icons.business_center_rounded,
      _ => Icons.work_outline_rounded,
    };

/// Text eines Einordnungs-Werts (l10n-Schlüssel `beruf_…`, `anstoessig_…`,
/// `zeitlich_…`).
String einordnungText(BuildContext context, FilterBereich b, String wert) =>
    switch (b) {
      FilterBereich.beruf => AppL10n.t(context, 'beruf_$wert'),
      FilterBereich.anstoessig => AppL10n.t(context, 'anstoessig_$wert'),
      FilterBereich.zeitlich => AppL10n.t(context, 'zeitlich_$wert'),
      _ => wert,
    };

/// Etiketten der Einordnung auf der Wort-Seite. Nichts eingeordnet ⇒ nichts.
class WortEinordnung extends ConsumerWidget {
  const WortEinordnung({super.key, required this.card, required this.byId});

  final Map<String, dynamic> card;

  /// id → Index-Eintrag — gibt es das Ersatz-Wort in VOX?
  final Map<String, Map<String, dynamic>> byId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final berufe = [
      for (final b in (card['berufe'] as List?) ?? const [])
        if (b is String) b,
    ];
    final anst = card['anstoessig'] is Map
        ? (card['anstoessig'] as Map).cast<String, dynamic>()
        : null;
    final stufe = anst?['stufe'] as String?;
    final zeitlich = card['zeitlich'] as String?;
    final ersatz = card['ersatz'] is Map
        ? (card['ersatz'] as Map).cast<String, dynamic>()
        : null;
    if (berufe.isEmpty && stufe == null && zeitlich == null) {
      return const SizedBox.shrink();
    }

    void zuListe(FilterBereich b, String wert) {
      ref.read(wortschatzFilterProvider.notifier).nurDieser(b, wert);
      context.push(AppRoutes.wortschatzList);
    }

    final erklaerung = vokabUeb(context, anst?['erklaerung']);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (stufe != null)
                _Etikett(
                  key: const ValueKey('etikett_anstoessig'),
                  icon: Icons.warning_amber_rounded,
                  text: einordnungText(
                      context, FilterBereich.anstoessig, stufe),
                  warnung: true,
                  onTap: () => zuListe(FilterBereich.anstoessig, stufe),
                ),
              if (zeitlich != null)
                _Etikett(
                  key: const ValueKey('etikett_zeitlich'),
                  icon: Icons.history_rounded,
                  text: einordnungText(
                      context, FilterBereich.zeitlich, zeitlich),
                  warnung: true,
                  onTap: () => zuListe(FilterBereich.zeitlich, zeitlich),
                ),
              for (final b in berufe)
                _Etikett(
                  key: ValueKey('etikett_beruf_$b'),
                  icon: berufIcon(b),
                  text: einordnungText(context, FilterBereich.beruf, b),
                  onTap: () => zuListe(FilterBereich.beruf, b),
                ),
            ],
          ),
          if (erklaerung != null && erklaerung.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.5)),
              ),
              child: Text(erklaerung, style: theme.textTheme.bodyMedium),
            ),
          ],
          if (ersatz != null && (stufe != null || zeitlich != null)) ...[
            const SizedBox(height: 10),
            _ErsatzZeile(
              ersatz: ersatz,
              titel: AppL10n.t(
                  context,
                  stufe != null
                      ? 'wort_ersatz_respekt'
                      : 'wort_ersatz_heute'),
              vorhanden: byId.containsKey(ersatz['id_ref']),
            ),
          ],
        ],
      ),
    );
  }
}

class _Etikett extends StatelessWidget {
  const _Etikett({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.warnung = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool warnung;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vorder = warnung ? cs.onSurface : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: warnung
              ? AppColors.warning.withValues(alpha: 0.18)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: warnung
              ? Border.all(color: AppColors.warning.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: warnung ? AppColors.warning : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: vorder,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Heutiges Wort: die Frau» / «Sag stattdessen: …» — klickbar, wenn es das
/// Wort in VOX gibt; sonst Suche in «Alle Wörter».
class _ErsatzZeile extends StatelessWidget {
  const _ErsatzZeile({
    required this.ersatz,
    required this.titel,
    required this.vorhanden,
  });

  final Map<String, dynamic> ersatz;
  final String titel;
  final bool vorhanden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wort = ersatz['wort'] as String? ?? '';
    final id = ersatz['id_ref'] as String? ?? '';
    final ueb = vokabUeb(context, ersatz['uebersetzung']);
    return InkWell(
      key: const ValueKey('wort_ersatz'),
      borderRadius: BorderRadius.circular(12),
      onTap: () => vorhanden
          ? context.push(AppRoutes.vokabularWort(id))
          : context.push(
              '${AppRoutes.wortschatzList}?suche=${Uri.encodeComponent(wort)}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: vorhanden
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: vorhanden ? 1.5 : 1,
          ),
          color: vorhanden
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
        ),
        child: Row(
          children: [
            Text('$titel: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            Text(
              wort,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: vorhanden ? theme.colorScheme.primary : null,
              ),
            ),
            if (ueb != null && ueb.isNotEmpty) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '· $ueb',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
