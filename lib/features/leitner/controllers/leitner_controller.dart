// FILE: lib/features/leitner/controllers/leitner_controller.dart
// DEPS: leitner_dao.dart, databaseProvider, word_controller.dart
// PURPOSE: Riverpod providers for Leitner — due cards, box counts, add/remove
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/leitner_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final leitnerDaoProvider = Provider<LeitnerDao>((ref) =>
    LeitnerDao(ref.watch(databaseProvider)));

// ── Streams ───────────────────────────────────────────────────────────────────

final dueCardsProvider = StreamProvider<List<LeitnerCard>>((ref) =>
    ref.watch(leitnerDaoProvider).watchDue());

final allLeitnerCardsProvider = StreamProvider<List<LeitnerCard>>((ref) =>
    ref.watch(leitnerDaoProvider).watchAll());

final leitnerByBoxProvider =
    StreamProvider.family<List<LeitnerCard>, int>((ref, box) =>
        ref.watch(leitnerDaoProvider).watchByBox(box));

// ── Async fetches ─────────────────────────────────────────────────────────────

final boxCountsProvider = FutureProvider<Map<int, int>>((ref) =>
    ref.watch(leitnerDaoProvider).countsByBox());

final dueCountProvider = FutureProvider<int>((ref) =>
    ref.watch(leitnerDaoProvider).countDue());

final isInLeitnerProvider = FutureProvider.family<bool, int>((ref, wordId) =>
    ref.watch(leitnerDaoProvider).isInLeitner(wordId));

// ── Box metadata ──────────────────────────────────────────────────────────────

const boxLabels    = ['Tag 1', '2 Tage', '4 Tage', '8 Tage', '16 Tage'];
const boxIntervals = LeitnerDao.boxIntervals; // [1, 2, 4, 8, 16]
