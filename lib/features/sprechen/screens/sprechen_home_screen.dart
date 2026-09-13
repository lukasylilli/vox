// FILE: lib/features/sprechen/screens/sprechen_home_screen.dart
// DEPS: -
// PURPOSE: Stub — Sprechen بخش (فاز بعدی)
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class SprechenHomeScreen extends StatelessWidget {
  const SprechenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sprechen')),
      body  : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, size: 72,
                color: scheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSizes.md),
            const Text('Sprechen',
                style: TextStyle(
                  fontSize  : 28,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'speaking_practice'),
                style: TextStyle(
                    fontSize: 16, color: scheme.onSurfaceVariant)),
            const SizedBox(height: AppSizes.xl),
            Chip(
              label: Text(AppL10n.t(context, 'coming_soon')),
              backgroundColor: scheme.secondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
