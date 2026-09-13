// FILE: lib/features/auswendiglernen/controllers/auswendiglernen_controller.dart
// DEPS: memorize_dao.dart, app_database.dart
// PURPOSE: Providers + ۱۵ دسته ثابت برای Auswendiglernen
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/memorize_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── دسته‌های حفظیات (فقط Redewendungen — بقیه به فایل‌های اختصاصی منتقل شدند) ───

const memorizeCategories = [
  'Redewendungen',  // 0 — اصطلاحات و عبارات آلمانی
];

const memorizeCategoryIconsFa = [
  'اصطلاحات',
];

// ── DAO provider ──────────────────────────────────────────────────────────────

final memorizeDaoProvider = Provider<MemorizeDao>(
  (ref) => MemorizeDao(ref.watch(databaseProvider)),
);

// ── Providers ─────────────────────────────────────────────────────────────────

final allMemorizeItemsProvider = StreamProvider<List<MemorizeItem>>(
  (ref) => ref.watch(memorizeDaoProvider).watchAll(),
);

final itemsByCategoryProvider =
    StreamProvider.family<List<MemorizeItem>, String>(
  (ref, category) =>
      ref.watch(memorizeDaoProvider).watchByCategory(category),
);

final categoryCountsProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(memorizeDaoProvider).countByCategory(memorizeCategories),
);

// Returns items as a one-shot list (for session screens that need a snapshot)
final categoryItemsSnapshotProvider =
    FutureProvider.family<List<MemorizeItem>, String>(
  (ref, category) =>
      ref.watch(memorizeDaoProvider).getByCategory(category),
);
