// FILE: lib/features/lesen/controllers/lesen_controller.dart
// DEPS: lesen_dao.dart, rss_service.dart, tts_service.dart, databaseProvider
// PURPOSE: Riverpod providers for Lesen — texts, RSS feed, reader state
//          (Wort-Nachschlagen beim Klick: seit L.5f core/wort/klick_wort_provider.dart)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/lesen_dao.dart';
import '../../../core/services/rss_service.dart';

// ── DAO ───────────────────────────────────────────────────────────────────────

final lesenDaoProvider = Provider<LesenDao>((ref) =>
    LesenDao(ref.watch(databaseProvider)));

// ── Text streams ──────────────────────────────────────────────────────────────

final allTextsProvider = StreamProvider<List<ReadingText>>((ref) =>
    ref.watch(lesenDaoProvider).watchAll());

final textsByLevelProvider =
    StreamProvider.family<List<ReadingText>, String>((ref, level) =>
        ref.watch(lesenDaoProvider).watchByLevel(level));

final textByIdProvider =
    FutureProvider.family<ReadingText?, int>((ref, id) =>
        ref.watch(lesenDaoProvider).getById(id));

final textLevelCountsProvider = FutureProvider<Map<String, int>>((ref) =>
    ref.watch(lesenDaoProvider).countByLevel());

// ── RSS ───────────────────────────────────────────────────────────────────────

// Configurable RSS feed URLs — user can update these
const defaultRssFeeds = [
  'https://www.tagesschau.de/xml/rss2/',     // Tagesschau
  'https://rss.dw.com/rdf/rss-de-all',       // Deutsche Welle
];

final rssFeedUrlProvider = StateProvider<String>((ref) => defaultRssFeeds[0]);

final rssItemsProvider = FutureProvider<List<RssItem>>((ref) {
  final url = ref.watch(rssFeedUrlProvider);
  return ref.watch(rssServiceProvider).fetch(url);
});

// ── Reader state ──────────────────────────────────────────────────────────────

final readerFontSizeProvider = StateProvider<double>((ref) => 16.0);
