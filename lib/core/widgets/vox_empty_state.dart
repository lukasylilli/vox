// FILE: lib/core/widgets/vox_empty_state.dart
// STATUS: [x] LIVE (B9 — 2026-07-04)
// PURPOSE: Design System — the one empty/placeholder state for all screens.
//          Named constructors cover the recurring cases.
import 'package:flutter/material.dart';
import '../../core/l10n/app_l10n.dart';

class VoxEmptyState extends StatelessWidget {
  const VoxEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.detail,
  });

  /// AppL10n.t(context, 'no_phrases_found') — search/filter produced no hits.
  const VoxEmptyState.noResults({super.key, this.message = 'nothing_found'})
      : icon   = Icons.search_off_rounded,
        detail = null;

  /// Deck/feature has no content yet.
  const VoxEmptyState.noData({super.key, this.message = 'no_content_yet', this.detail})
      : icon = Icons.inbox_rounded;

  /// Locked / coming soon.
  const VoxEmptyState.comingSoon({super.key, this.message = 'coming_soon', this.detail})
      : icon = Icons.lock_outline_rounded;

  final IconData icon;
  final String   message;
  final String?  detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size : 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            AppL10n.t(context, message),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(
              detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
