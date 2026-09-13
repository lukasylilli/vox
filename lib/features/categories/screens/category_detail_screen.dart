// FILE: lib/features/categories/screens/category_detail_screen.dart
// DEPS: category_controller.dart, wordsByCategoryProvider, word_list_item.dart
// PURPOSE: Words inside a category with remove-from-category swipe action
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../../wortschatz/widgets/word_list_item.dart';
import '../controllers/category_controller.dart';
import '../../../core/widgets/vox_button.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });
  final int     categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? AppL10n.t(context, 'category_label')),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (words) => words.isEmpty
            ? _EmptyCategory(categoryId: categoryId)
            : ListView.builder(
                padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount  : words.length,
                itemBuilder: (_, i) {
                  final word  = words[i];
                  final model = word.toModel();
                  return Dismissible(
                    key      : ValueKey(word.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding  : const EdgeInsets.only(right: AppSizes.lg),
                      color    : Colors.red.withValues(alpha: 0.85),
                      child    : const Icon(Icons.remove_circle_outline_rounded,
                          color: Colors.white),
                    ),
                    confirmDismiss: (_) => showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title  : Text(AppL10n.tf(context, 'delete_quoted', {'x': model.german})),
                        content: Text(AppL10n.t(context, 'remove_from_category_msg')),
                        actions: [
                          VoxButton.text(
                            label    : AppL10n.t(ctx, 'cancel'),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                          VoxButton.destructive(
                            label    : AppL10n.t(ctx, 'delete'),
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) async {
                      await ref
                          .read(categoryDaoProvider)
                          .removeWordFromCategory(categoryId, word.id);
                      ref.invalidate(wordsByCategoryProvider(categoryId));
                      ref.invalidate(categoryIdsForWordProvider(word.id));
                    },
                    child: WordListItem(
                      word  : model,
                      onTap : () => context.push(
                        '/wortschatz/word/${word.id}',
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.categoryId});
  final int categoryId;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 72,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.lg),
            Text(AppL10n.t(context, 'category_empty'),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'category_empty_hint'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.lg),
            VoxButton.secondary(
              label    : AppL10n.t(context, 'go_to_wortschatz'),
              icon     : Icons.search_rounded,
              onPressed: () => context.go(AppRoutes.wortschatz),
            ),
          ],
        ),
      ),
    );
  }
}
