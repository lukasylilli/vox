// FILE: lib/features/categories/controllers/category_controller.dart
// DEPS: category_dao.dart, databaseProvider
// PURPOSE: Riverpod providers for UserCategories + CategoryWords
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/category_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final categoryDaoProvider = Provider<CategoryDao>((ref) =>
    CategoryDao(ref.watch(databaseProvider)));

// ── Category streams ──────────────────────────────────────────────────────────

final allCategoriesProvider = StreamProvider<List<UserCategory>>((ref) =>
    ref.watch(categoryDaoProvider).watchAll());

final wordsByCategoryProvider =
    StreamProvider.family<List<Word>, int>((ref, categoryId) =>
        ref.watch(categoryDaoProvider).watchWordsByCategory(categoryId));

// ── Per-word / per-category queries ──────────────────────────────────────────

final categoryIdsForWordProvider =
    FutureProvider.family<List<int>, int>((ref, wordId) =>
        ref.watch(categoryDaoProvider).categoryIdsForWord(wordId));

final isWordInCategoryProvider =
    FutureProvider.family<bool, ({int categoryId, int wordId})>((ref, args) =>
        ref
            .watch(categoryDaoProvider)
            .isWordInCategory(args.categoryId, args.wordId));
