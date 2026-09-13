// FILE: lib/features/schreiben/screens/schreiben_home_screen.dart
// DEPS: -
// PURPOSE: Stub — Schreiben بخش (فاز بعدی)
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class SchreibenHomeScreen extends StatelessWidget {
  const SchreibenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Schreiben')),
      body  : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_rounded, size: 72,
                color: scheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSizes.md),
            const Text('Schreiben',
                style: TextStyle(
                  fontSize  : 28,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'writing_practice'),
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
