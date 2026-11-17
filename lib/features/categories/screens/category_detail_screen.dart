// FILE: lib/features/categories/screens/category_detail_screen.dart
// DEPS: category_controller.dart (deckWoerterProvider), wortschatz_zeile.dart
// PURPOSE: Words inside a category with remove-from-category swipe action
//          X.2: die Kategorie ist ein Deck — es kann alte Wörter UND
//          Archivkarten enthalten.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/database/app_database.dart' show Word;
import '../../../core/models/word_model.dart';
import '../../leitner/controllers/leitner_controller.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../../wortschatz/data/such_rang.dart';
import '../../wortschatz/widgets/wortschatz_zeile.dart';
import '../controllers/category_controller.dart';
import '../../../core/widgets/vox_button.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  /// id des Decks (X.2: Text-id).
  final String  categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(deckWoerterProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? AppL10n.t(context, 'category_label')),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (zeilen) => zeilen.isEmpty
            ? _EmptyCategory(categoryId: categoryId)
            : ListView.builder(
                padding    : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount  : zeilen.length,
                itemBuilder: (_, i) {
                  final zeile = zeilen[i];
                  // Altes Wort oder Archivkarte — dieselbe Zeile wie in
                  // «Alle Wörter» (wortschatz_zeile.dart).
                  final wert  = zeile.wert;
                  final Object eintrag = wert is Word ? wert.toModel() : wert;
                  final name  = eintrag is WordModel
                      ? eintrag.german
                      : '${(eintrag as Map)['wort'] ?? ''}';
                  return Dismissible(
                    key      : ValueKey(zeile.wortId),
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
                        title  : Text(AppL10n.tf(context, 'delete_quoted', {'x': name})),
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
                    onDismissed: (_) => ref
                        .read(leitnerDaoProvider)
                        .wortSetzen(categoryId, zeile.wortId, false),
                    child: WortschatzZeile(
                      treffer: SuchTreffer<Object>(
                          wert: eintrag, lemma: name, rang: SuchRang.genau),
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
  final String categoryId;

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
