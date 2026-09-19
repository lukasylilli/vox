// FILE: lib/core/services/data_seed_service.dart
// PURPOSE: One-time seeding of vocabulary from JSON assets into SQLite DB.
//          Runs on first launch only (SharedPreferences flag vocab_seeded_v2 —
//          v2, weil v1 bei «Verben mit Präpositionen» meaningEn nicht schrieb;
//          der Bump lässt bestehende Installationen einmalig nach-seeden,
//          alle Inserts sind Upserts → idempotent).
//          Creates 4 Books and inserts words linked to them.
//
// ⚠️ L.1e (2026-09-18): `german` + `wordType` dieser Wörter bilden den
//    Leitner-Schlüssel der Nutzer (`eigen:<german>|<wordType>`). Ändert sich
//    einer davon, ist der Fortschritt des Nutzers zu diesem Wort verwaist.
//    Der Wächter `tool/seed_schluessel_pruefen.dart` macht CI rot, wenn ein
//    schon veröffentlichter Schlüssel verschwindet — siehe PLAN.md → L.1e.
import 'dart:convert';

import 'package:drift/drift.dart' show Value, DoUpdate;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import 'seed_wortschluessel.dart';

class DataSeedService {
  DataSeedService(this._db);
  final AppDatabase _db;

  // v3 (S.5, 2026-09-15): setzt `Words.ausApp` — bestehende Installationen
  // seeden einmal nach, alle Inserts sind Upserts, also exakt nach Daten.
  static const _prefKey = 'vocab_seeded_v3';

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) == true) return;

    await _db.transaction(() async {
      await _seedDativAkkusativ();
      await _seedKonnektoren();
      await _seedNvv();
      await _seedPraepositionen();
    });

    await prefs.setBool(_prefKey, true);
  }

  Future<int> _ensureBook(String name) async {
    // Kein Upsert: insertOnConflictUpdate zielt auf den PK (id), der Konflikt
    // beim Re-Seed passiert aber auf UNIQUE name → SqliteException und die App
    // stirbt vor runApp (weißer Bildschirm). Deshalb: erst suchen, dann anlegen.
    final row = await (_db.select(_db.books)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (row != null) return row.id;
    return _db.into(_db.books).insert(BooksCompanion.insert(name: name));
  }

  Future<void> _link(int wordId, int bookId) async {
    if (wordId <= 0 || bookId <= 0) return;
    await _db.into(_db.wordBooks).insertOnConflictUpdate(
      WordBooksCompanion.insert(wordId: wordId, bookId: bookId),
    );
  }

  // ── Dativ & Akkusativ Verben ──────────────────────────────────────────────

  Future<void> _seedDativAkkusativ() async {
    final raw  = await rootBundle.loadString('assets/data/dativ_akkusativ_data.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final bookId = await _ensureBook('Dativ und Akkusativ Verben');

    for (final j in list) {
      final inf = j['verb_infinitive'] as String;
      final pp  = j['principal_parts'] as Map<String, dynamic>;
      final conjugationJson = jsonEncode({
        'inf' : inf,
        'präs': pp['praesens_3sg'] ?? '',
        'prät': pp['praeteritum']  ?? '',
        'pp'  : pp['perfekt']      ?? '',
      });

      final companion = WordsCompanion.insert(
        ausApp         : const Value(true), // S.5: App-Wort, nicht sichern
        german         : inf,
        wordType       : 'verb',
        meaningFa      : j['meaning_fa'] as String,
        meaningEn      : Value(j['meaning_en'] as String?),
        level          : Value(j['cefr_level'] as String?),
        examplesJson   : Value(jsonEncode([j['example_de']])),
        conjugationJson: Value(conjugationJson),
        grammarNote    : Value(j['case_type'] as String?),
      );
      final id = await _db.into(_db.words).insert(
        companion,
        onConflict: DoUpdate((old) => companion, target: [_db.words.german, _db.words.wordType]),
      );
      await _link(id, bookId);
    }
  }

  // ── Konnektoren ───────────────────────────────────────────────────────────

  Future<void> _seedKonnektoren() async {
    final raw  = await rootBundle.loadString('assets/data/konnektoren_data.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final bookId = await _ensureBook('Konnektoren');

    for (final j in list) {
      final companion = WordsCompanion.insert(
        ausApp         : const Value(true), // S.5: App-Wort, nicht sichern
        german      : j['connector'] as String,
        wordType    : 'konnektor',
        meaningFa   : j['meaning_fa'] as String,
        meaningEn   : Value(j['meaning_en'] as String?),
        level       : Value(j['cefr_level'] as String?),
        examplesJson: Value(jsonEncode([j['example_de']])),
        grammarNote : Value(j['connector_type'] as String?),
      );
      final id = await _db.into(_db.words).insert(
        companion,
        onConflict: DoUpdate((old) => companion, target: [_db.words.german, _db.words.wordType]),
      );
      await _link(id, bookId);
    }
  }

  // ── Nomen-Verb-Verbindungen ───────────────────────────────────────────────

  Future<void> _seedNvv() async {
    final raw  = await rootBundle.loadString('assets/data/nvv_data.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final bookId = await _ensureBook('Nomen-Verb-Verbindungen');

    for (final j in list) {
      final companion = WordsCompanion.insert(
        ausApp         : const Value(true), // S.5: App-Wort, nicht sichern
        german      : j['phrase_de'] as String,
        wordType    : 'sonstige',
        meaningFa   : j['meaning_fa'] as String,
        meaningEn   : Value(j['meaning_en'] as String?),
        level       : Value(j['cefr_level'] as String?),
        examplesJson: Value(jsonEncode([j['example_de']])),
      );
      final id = await _db.into(_db.words).insert(
        companion,
        onConflict: DoUpdate((old) => companion, target: [_db.words.german, _db.words.wordType]),
      );
      await _link(id, bookId);
    }
  }

  // ── Präpositionen clusters ────────────────────────────────────────────────

  Future<void> _seedPraepositionen() async {
    final raw    = await rootBundle.loadString('assets/data/praepositionen_data.json');
    final list   = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final bookId = await _ensureBook('Verben mit Präpositionen');

    for (final cluster in list) {
      final meaningFa = cluster['meaning_fa'] as String;
      final meaningEn = cluster['meaning_en'] as String?;
      final level     = cluster['cefr_level'] as String?;
      final members   = (cluster['members'] as List).cast<Map<String, dynamic>>();
      final examples  = (cluster['examples'] as List).cast<Map<String, dynamic>>();

      for (final m in members) {
        final lemma = m['lemma'] as String;
        final prep  = m['preposition'] as String;
        final wt    = _mapWordClass(m['word_class'] as String? ?? '');

        final memberExamples = examples
            .where((e) => e['member_lemma'] == lemma)
            .map((e) => e['de'] as String)
            .toList();

        final companion = WordsCompanion.insert(
          ausApp      : const Value(true), // S.5: App-Wort, nicht sichern
          german      : '$lemma $prep',
          wordType    : wt,
          meaningFa   : meaningFa,
          meaningEn   : Value(meaningEn),
          level       : Value(level),
          examplesJson: Value(
            memberExamples.isEmpty ? null : jsonEncode(memberExamples),
          ),
          grammarNote : Value('$prep + ${m['case'] ?? ''}'),
        );
        final id = await _db.into(_db.words).insert(
          companion,
          onConflict: DoUpdate((old) => companion, target: [_db.words.german, _db.words.wordType]),
        );
        await _link(id, bookId);
      }
    }
  }

  // ⚠️ L.1e: Die Ableitung von `wordType` steht in seed_wortschluessel.dart —
  // sie bestimmt den Leitner-Schlüssel der Nutzer und darf es nur EINMAL
  // geben, sonst laufen Seeding und Wächter auseinander.
  String _mapWordClass(String wc) => mapWordClass(wc);
}
