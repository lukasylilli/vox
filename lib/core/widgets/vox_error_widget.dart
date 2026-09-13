// FILE: lib/core/widgets/vox_error_widget.dart
// DEPS: -
// PURPOSE: Konsistentes Error-Widget für alle .when(error:...) Aufrufe
import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../l10n/app_l10n.dart';

class VoxErrorWidget extends StatelessWidget {
  const VoxErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object    error;
  final VoidCallback? onRetry;
  final bool      compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              color: scheme.error, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text('$error',
                style: TextStyle(color: scheme.error, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onRetry,
              child: Text(AppL10n.t(context, 'try_again'),
                  style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: scheme.error.withValues(alpha: 0.7)),
            const SizedBox(height: AppSizes.md),
            Text(AppL10n.t(context, 'error_occurred'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(
                  color: scheme.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppL10n.t(context, 'try_again')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
