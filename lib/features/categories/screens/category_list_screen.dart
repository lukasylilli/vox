// FILE: lib/features/categories/screens/category_list_screen.dart
// DEPS: category_controller.dart, category_dao.dart, app_routes.dart
// PURPOSE: List of all user categories + create/delete/rename actions
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/category_controller.dart';
import '../../../core/widgets/vox_button.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'my_categories'))),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (cats) => cats.isEmpty
            ? _EmptyState(onCreate: () => _createCategory(context, ref))
            : ListView.builder(
                padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount  : cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Text(cat.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        )),
                    ),
                    title   : Text(cat.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VoxIconButton(
                          icon: Icons.edit_rounded, iconSize: 18,
                          tooltip  : AppL10n.t(context, 'rename'),
                          onPressed: () => _rename(context, ref, cat.id, cat.name),
                        ),
                        VoxIconButton(
                          icon: Icons.delete_outline_rounded, iconSize: 18,
                          tooltip  : AppL10n.t(context, 'delete'),
                          onPressed: () => _delete(context, ref, cat.id, cat.name),
                        ),
                      ],
                    ),
                    onTap: () => context.push(
                      '${AppRoutes.wortschatzCategories}/${cat.id}',
                      extra: cat.name,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: VoxFab.extended(
        icon     : Icons.add_rounded,
        label    : AppL10n.t(context, 'new_category'),
        onPressed: () => _createCategory(context, ref),
      ),
    );
  }

  Future<void> _createCategory(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.t(ctx, 'new_category')),
        content: TextField(
          controller : ctrl,
          autofocus  : true,
          decoration : InputDecoration(hintText: AppL10n.t(ctx, 'category_name_hint')),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          VoxButton.text(
            label    : AppL10n.t(ctx, 'cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          VoxButton.primary(
            label    : AppL10n.t(ctx, 'create'),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(categoryDaoProvider).insertCategory(name);
      ref.invalidate(allCategoriesProvider);
    }
  }

  Future<void> _rename(
      BuildContext context, WidgetRef ref, int id, String current) async {
    final ctrl = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.t(ctx, 'rename')),
        content: TextField(
          controller: ctrl,
          autofocus : true,
          decoration: InputDecoration(hintText: AppL10n.t(ctx, 'new_name_hint')),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          VoxButton.text(
            label    : AppL10n.t(ctx, 'cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          VoxButton.primary(
            label    : AppL10n.t(ctx, 'save'),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && name != current) {
      await ref.read(categoryDaoProvider).updateCategory(id, name);
      ref.invalidate(allCategoriesProvider);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.tf(ctx, 'delete_quoted', {'x': name})),
        content: Text(AppL10n.t(ctx, 'delete_category_confirm')),
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
    );
    if (confirmed == true) {
      await ref.read(categoryDaoProvider).deleteCategory(id);
      ref.invalidate(allCategoriesProvider);
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

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
            Icon(Icons.folder_open_rounded, size: 72,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.lg),
            Text(AppL10n.t(context, 'no_categories'),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(AppL10n.t(context, 'category_intro'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.lg),
            VoxButton.primary(
              label    : AppL10n.t(context, 'create_first_category'),
              icon     : Icons.add_rounded,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
