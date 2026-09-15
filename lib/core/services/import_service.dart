// FILE: lib/core/services/import_service.dart
// DEPS: app_database.dart, drift
// PURPOSE: CSV/JSON-Import für Wörter und Auswendiglernen-Phrasen
import 'dart:convert';

import 'package:drift/drift.dart' show Value, InsertMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../../features/wortschatz/controllers/word_controller.dart';

enum ImportType { words, memorizePhrases }

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    this.error,
  });

  final int     imported;
  final int     skipped;
  final String? error;

  bool get success => error == null;
}

class ImportService {
  ImportService(this._db);
  final AppDatabase _db;

  // ── CSV words import ──────────────────────────────────────────────────────
  // Expected CSV columns: german,meaningFa,wordType,level,article,plural
  Future<ImportResult> importWordsCsv(String csvText) async {
    final lines   = csvText.trim().split('\n');
    var imported  = 0;
    var skipped   = 0;

    for (final line in lines.skip(1)) {
      final cols = line.split(',').map((c) => c.trim()).toList();
      if (cols.length < 2) { skipped++; continue; }

      final german    = cols[0];
      final meaningFa = cols[1];
      if (german.isEmpty || meaningFa.isEmpty) { skipped++; continue; }

      final wordType =
          cols.length > 2 && cols[2].isNotEmpty ? cols[2] : 'andere';
      try {
        await _db.into(_db.words).insertOnConflictUpdate(WordsCompanion.insert(
          german    : german,
          meaningFa : meaningFa,
          wordType  : wordType,
          level     : Value(cols.length > 3 && cols[3].isNotEmpty ? cols[3] : null),
          article   : Value(cols.length > 4 && cols[4].isNotEmpty ? cols[4] : null),
          plural    : Value(cols.length > 5 && cols[5].isNotEmpty ? cols[5] : null),
        ));
        await _db.nutzerwortMerkenNachSchluessel(german, wordType,
            drin: true); // S.5
        imported++;
      } catch (_) {
        skipped++;
      }
    }
    return ImportResult(imported: imported, skipped: skipped);
  }

  // ── JSON words import ─────────────────────────────────────────────────────
  // Expected: [{"german":"...","meaningFa":"...","wordType":"...","level":"a1",...}]
  Future<ImportResult> importWordsJson(String jsonText) async {
    late List<dynamic> list;
    try {
      list = jsonDecode(jsonText) as List;
    } catch (e) {
      return ImportResult(imported: 0, skipped: 0, error: 'JSON ungültig: $e');
    }

    var imported = 0;
    var skipped  = 0;

    for (final item in list) {
      if (item is! Map<String, dynamic>) { skipped++; continue; }
      final german    = item['german']    as String?;
      final meaningFa = item['meaningFa'] as String?;
      if (german == null || meaningFa == null) { skipped++; continue; }

      final wordType = (item['wordType'] as String?) ?? 'andere';
      try {
        await _db.into(_db.words).insertOnConflictUpdate(WordsCompanion.insert(
          german    : german,
          meaningFa : meaningFa,
          wordType  : wordType,
          level     : Value(item['level']   as String?),
          article   : Value(item['article'] as String?),
          plural    : Value(item['plural']  as String?),
        ));
        await _db.nutzerwortMerkenNachSchluessel(german, wordType,
            drin: true); // S.5
        imported++;
      } catch (_) {
        skipped++;
      }
    }
    return ImportResult(imported: imported, skipped: skipped);
  }

  // ── JSON memorize phrases import ──────────────────────────────────────────
  // Expected: [{"phrase":"...","meaning":"...","category":"Farben"}]
  Future<ImportResult> importMemorizeJson(String jsonText) async {
    late List<dynamic> list;
    try {
      list = jsonDecode(jsonText) as List;
    } catch (e) {
      return ImportResult(imported: 0, skipped: 0, error: 'JSON ungültig: $e');
    }

    var imported = 0;
    var skipped  = 0;

    for (final item in list) {
      if (item is! Map<String, dynamic>) { skipped++; continue; }
      final phrase   = item['phrase']   as String?;
      final meaning  = item['meaning']  as String?;
      final category = item['category'] as String?;
      if (phrase == null || meaning == null || category == null) {
        skipped++;
        continue;
      }

      try {
        await _db.into(_db.memorizeItems).insert(
          MemorizeItemsCompanion.insert(
            phrase   : phrase,
            meaning  : meaning,
            meaningEn: Value(item['meaning_en'] as String?),
            category : category,
            level    : Value(item['level'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        imported++;
      } catch (_) {
        skipped++;
      }
    }
    return ImportResult(imported: imported, skipped: skipped);
  }
}

final importServiceProvider = Provider<ImportService>(
  (ref) => ImportService(ref.read(databaseProvider)),
);
