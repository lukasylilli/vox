// FILE: lib/features/wortschatz/screens/wortschatz_home_screen.dart
// DEPS: app_routes.dart, allWordsProvider
// PURPOSE: Wortschatz section home — 6 sub-sections + quick stats
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../controllers/word_controller.dart';
import '../../../core/widgets/vox_button.dart';

class WortschatzHomeScreen extends ConsumerWidget {
  const WortschatzHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Zähler = alte Wortschatz-DB + Vokabular-Karten (beide in «Alle Wörter»).
    final wordsAsync = ref.watch(allWordsProvider);
    final kartenAsync = ref.watch(vokabularProvider);
    final count = (wordsAsync.valueOrNull?.length ?? 0) +
        (kartenAsync.valueOrNull?.length ?? 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Wortschatz')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Stats banner
          _StatsBanner(count: count),
          const SizedBox(height: AppSizes.md),
          // Sub-sections
          _MenuItem(
            icon    : Icons.menu_book_rounded,
            titleDe : 'Bücher',
            titleFa : AppL10n.t(context, 'vocab_books'),
            onTap   : () => context.push(AppRoutes.wortschatzBooks),
          ),
          _MenuItem(
            icon    : Icons.filter_list_rounded,
            titleDe : 'Alle Wörter',
            titleFa : AppL10n.t(context, 'all_words_sub'),
            onTap   : () => context.push(AppRoutes.wortschatzList),
          ),
          _MenuItem(
            icon    : Icons.inbox_rounded,
            titleDe : 'Leitner',
            titleFa : AppL10n.t(context, 'leitner_boxes_sub'),
            onTap   : () => context.push(AppRoutes.leitner),
          ),
          _MenuItem(
            icon    : Icons.folder_rounded,
            titleDe : 'Meine Kategorien',
            titleFa : AppL10n.t(context, 'my_categories_sub'),
            onTap   : () => context.push(AppRoutes.wortschatzCategories),
          ),
          const SizedBox(height: AppSizes.sm),
          // Add word — prominent button
          VoxButton.primary(
            label    : AppL10n.t(context, 'add_word'),
            icon     : Icons.add_rounded,
            size     : VoxButtonSize.large,
            expand   : true,
            onPressed: () => context.push(AppRoutes.wortschatzAddWord),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  const _StatsBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding     : const EdgeInsets.all(AppSizes.md),
      decoration  : BoxDecoration(
        color       : scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border      : Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppL10n.tf(context, 'n_words', {'n': '$count'}),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.primary, fontWeight: FontWeight.w800,
                )),
              Text(AppL10n.t(context, 'bank_subtitle'),
                style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.titleDe,
    required this.titleFa,
    required this.onTap,
  });

  final IconData icon;
  final String   titleDe;
  final String   titleFa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading     : Icon(icon, color: Theme.of(context).colorScheme.primary),
        title       : Text(titleDe, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle    : Text(titleFa),
        trailing    : const Icon(Icons.chevron_right_rounded),
        onTap       : onTap,
        shape       : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

