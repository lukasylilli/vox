// FILE: lib/core/widgets/placeholder_section_screen.dart
// PURPOSE: Temp screen for routes not yet built — replaced phase by phase
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_l10n.dart';

class PlaceholderSectionScreen extends StatelessWidget {
  const PlaceholderSectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'under_construction'), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
