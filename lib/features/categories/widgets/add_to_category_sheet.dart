// FILE: lib/features/categories/widgets/add_to_category_sheet.dart
// DEPS: category_controller.dart, leitner_dao.dart
// X.2: Kategorien sind Decks; das alte Wort wird über seine Text-id geführt.
// PURPOSE: Bottom sheet — shows all categories with checkboxes, toggles membership
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../leitner/controllers/leitner_controller.dart';
import '../controllers/category_controller.dart';
import '../../../core/widgets/vox_button.dart';

/// Shows a bottom sheet where the user can add/remove a word from categories.
/// Call via: showAddToCategorySheet(context, wordId)
Future<void> showAddToCategorySheet(BuildContext context, int wordId) {
  return showModalBottomSheet(
    context            : context,
    isScrollControlled : true,
    shape              : const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AddToCategorySheet(wordId: wordId),
  );
}

class _AddToCategorySheet extends ConsumerWidget {
  const _AddToCategorySheet({required this.wordId});
  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    // Nummer des alten Worts ⇒ Text-id, mit der die Decks es kennen.
    final wortId          = ref.watch(altWortIdProvider(wordId)).valueOrNull;
    final memberAsync     = wortId == null
        ? const AsyncValue<Set<String>>.loading()
        : ref.watch(deckIdsVonWortProvider(wortId));
    final theme           = Theme.of(context);

    return DraggableScrollableSheet(
      expand          : false,
      initialChildSize: 0.55,
      maxChildSize    : 0.9,
      builder         : (ctx, scroll) => Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: [
                Text(AppL10n.t(context, 'add_to_category'),
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                VoxButton.small(
                  label    : AppL10n.t(context, 'new_label'),
                  icon     : Icons.add_rounded,
                  onPressed: () => _createNew(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          // List
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (_, _) => const SizedBox.shrink(),
              data   : (cats) => cats.isEmpty
                  ? Center(
                      child: Text(AppL10n.t(context, 'no_categories_hint'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    )
                  : memberAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error  : (_, _) => const SizedBox.shrink(),
                      data   : (memberIds) => ListView.builder(
                        controller : scroll,
                        itemCount  : cats.length,
                        itemBuilder: (_, i) {
                          final cat   = cats[i];
                          final isIn  = memberIds.contains(cat.id);
                          return CheckboxListTile(
                            title   : Text(cat.name),
                            value   : isIn,
                            onChanged: (_) => _toggle(ref, cat.id, isIn),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, String deckId, bool isIn) async {
    final wortId = await ref.read(altWortIdProvider(wordId).future);
    if (wortId == null) return;
    await ref.read(leitnerDaoProvider).wortSetzen(deckId, wortId, !isIn);
  }

  Future<void> _createNew(BuildContext context, WidgetRef ref) async {
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
      final dao    = ref.read(leitnerDaoProvider);
      final wortId = await ref.read(altWortIdProvider(wordId).future);
      final deck   = await dao.deckAnlegen(name);
      if (wortId != null) await dao.wortSetzen(deck.id, wortId, true);
    }
  }
}
