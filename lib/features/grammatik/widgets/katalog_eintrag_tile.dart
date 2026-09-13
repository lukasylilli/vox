// FILE: lib/features/grammatik/widgets/katalog_eintrag_tile.dart
// DEPS: grammar_catalog.dart, vox_badge.dart, vox_snack_bar.dart
// PURPOSE: Eine Zeile des Grammatik-Katalogs — live → push(route),
//          geplant → "به‌زودی"-Snackbar. Überall gleiche Optik (G1).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_snack_bar.dart';
import '../models/grammar_catalog.dart';
import '../../../core/l10n/app_l10n.dart';

class KatalogEintragTile extends StatelessWidget {
  const KatalogEintragTile({
    super.key,
    required this.eintrag,
    this.leadingIcon,
    this.leadingColor,
  });

  final KatalogEintrag eintrag;

  /// Ohne Icon zeigt das Leading die Lektionsnummer (falls vorhanden).
  final IconData? leadingIcon;
  final Color?    leadingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live  = eintrag.isLive;
    final color = leadingColor ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: leadingIcon != null
              ? Icon(leadingIcon, color: color, size: 20)
              : Text(
                  '${eintrag.lektion ?? '•'}',
                  style: TextStyle(
                    color     : color,
                    fontWeight: FontWeight.w800,
                    fontSize  : 14,
                  ),
                ),
        ),
        title: Text(
          eintrag.de,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: live
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        subtitle: Text(
          AppL10n.meaning(context, fa: eintrag.fa, en: eintrag.en),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final n in eintrag.niveaus) ...[
              VoxBadge.level(n, small: true),
              const SizedBox(width: 3),
            ],
            const SizedBox(width: 2),
            live
                ? const Icon(Icons.chevron_right_rounded)
                : Icon(
                    Icons.lock_clock_rounded,
                    size : 18,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.35),
                  ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: () {
          final route = eintrag.route;
          if (route != null) {
            context.push(route);
          } else {
            VoxSnackBar.comingSoon(context, eintrag.de);
          }
        },
      ),
    );
  }
}
