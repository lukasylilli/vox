// FILE: lib/features/auswendiglernen/screens/category_items_screen.dart
// DEPS: auswendiglernen_controller.dart
// PURPOSE: لیست آیتم‌های یک دسته + دکمه‌های مرور کارتی و cloze
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/auswendiglernen_controller.dart';
import '../../../core/widgets/vox_button.dart';

class CategoryItemsScreen extends ConsumerWidget {
  const CategoryItemsScreen({
    super.key,
    required this.categoryIndex,
  });
  final int categoryIndex;

  String get _category => memorizeCategories[categoryIndex];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsByCategoryProvider(_category));
    final theme      = Theme.of(context);
    final scheme     = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_category),
        actions: [
          VoxIconButton(
            icon: Icons.style_rounded,
            tooltip: AppL10n.t(context, 'card_review'),
            onPressed: () =>
                context.push('/auswendiglernen/$categoryIndex/memorize'),
          ),
          VoxIconButton(
            icon: Icons.edit_note_rounded,
            tooltip: AppL10n.t(context, 'cloze_practice_title'),
            onPressed: () =>
                context.push('/auswendiglernen/$categoryIndex/cloze'),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (items) => items.isEmpty
            ? _EmptyCategory(categoryIndex: categoryIndex)
            : Column(
                children: [
                  // Action bar
                  Container(
                    padding   : const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      border: Border(
                          bottom: BorderSide(color: scheme.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Text(Formatters.countLabel(items.length, AppL10n.t(context, 'item_unit')),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            )),
                        const Spacer(),
                        VoxButton.primary(
                          label    : AppL10n.t(context, 'card_review'),
                          icon     : Icons.style_rounded,
                          onPressed: () => context
                              .push('/auswendiglernen/$categoryIndex/memorize'),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        VoxButton.secondary(
                          label    : AppL10n.t(context, 'cloze_practice_label'),
                          icon     : Icons.edit_note_rounded,
                          onPressed: () => context
                              .push('/auswendiglernen/$categoryIndex/cloze'),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding        : const EdgeInsets.all(AppSizes.sm),
                      itemCount      : items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder    : (_, i) => _ItemTile(item: items[i]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});
  final MemorizeItem item;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: 0),
      title  : Text(item.phrase,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          )),
      subtitle: Text(AppL10n.meaning(context,
          fa: item.meaning, en: item.meaningEn ?? item.meaning),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          )),
      children: [
        if (item.examplesJson != null && item.examplesJson!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.examplesJson!
                    .replaceAll(RegExp(r'^\[|\]$'), '')
                    .replaceAll('","', '\n• ')
                    .replaceAll('"', ''),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.categoryIndex});
  final int categoryIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size : 72,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: AppSizes.lg),
          Text(AppL10n.t(context, 'category_empty'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(AppL10n.t(context, 'content_from_phase12'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
