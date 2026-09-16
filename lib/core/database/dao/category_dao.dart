// FILE: lib/core/database/dao/category_dao.dart
// DEPS: app_database.dart (generated: UserCategory, CategoryWord, etc.)
// PURPOSE: CRUD for UserCategories + CategoryWords (reference-based, no word copies)
import 'package:drift/drift.dart';

import '../../backup/nutzer_zustand.dart' show neueEigeneListenId;
import '../app_database.dart';

class CategoryDao {
  CategoryDao(this._db);
  final AppDatabase _db;

  // ── UserCategories ─────────────────────────────────────────────────────────

  Stream<List<UserCategory>> watchAll() =>
      (_db.select(_db.userCategories)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<List<UserCategory>> getAll() =>
      (_db.select(_db.userCategories)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<UserCategory?> getById(int id) =>
      (_db.select(_db.userCategories)
        ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Neue Liste. S.6: Sie bekommt sofort ihre feste id — sie bleibt, egal
  /// wie oft die Liste umbenannt wird.
  Future<int> insertCategory(String name) async {
    final listenId = neueEigeneListenId();
    final id = await _db.into(_db.userCategories).insert(
      UserCategoriesCompanion.insert(
        name: name,
        uid: Value(listenId),
        nameAmMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    await _db.eigeneListeMerken(listenId, drin: true); // S.5
    return id;
  }

  /// Umbenennen. S.6: Die id der Liste bleibt; nur Name und Zeitpunkt
  /// ändern sich. Beim Abgleich gewinnt der später vergebene Name, und
  /// Wörter, die ein anderes Gerät inzwischen in die Liste gelegt hat,
  /// bleiben drin (vorher: „alte Liste weg, neue da" — diese Wörter gingen
  /// verloren).
  Future<bool> updateCategory(int id, String newName) async {
    final alt = await getById(id);
    if (alt == null) return false;
    if (alt.name == newName) return true;
    return (_db.update(_db.userCategories)..where((t) => t.id.equals(id)))
        .write(UserCategoriesCompanion(
          name: Value(newName),
          nameAmMs: Value(DateTime.now().millisecondsSinceEpoch),
        ))
        .then((n) => n > 0);
  }

  Future<int> deleteCategory(int id) async {
    final kat = await getById(id);
    if (kat != null) {
      await _db.eigeneListeMerken(eigeneListenId(kat), drin: false); // S.5
    }
    // Remove all words from this category first
    await (_db.delete(_db.categoryWords)
      ..where((t) => t.categoryId.equals(id)))
        .go();
    return (_db.delete(_db.userCategories)
      ..where((t) => t.id.equals(id)))
        .go();
  }

  // ── CategoryWords ──────────────────────────────────────────────────────────

  /// Words belonging to a category, joined with Words table.
  Stream<List<Word>> watchWordsByCategory(int categoryId) {
    final query = _db.select(_db.words).join([
      innerJoin(
        _db.categoryWords,
        _db.categoryWords.wordId.equalsExp(_db.words.id),
      ),
    ])
      ..where(_db.categoryWords.categoryId.equals(categoryId))
      ..orderBy([OrderingTerm.asc(_db.words.german)]);
    return query.map((row) => row.readTable(_db.words)).watch();
  }

  Future<List<Word>> getWordsByCategory(int categoryId) {
    final query = _db.select(_db.words).join([
      innerJoin(
        _db.categoryWords,
        _db.categoryWords.wordId.equalsExp(_db.words.id),
      ),
    ])
      ..where(_db.categoryWords.categoryId.equals(categoryId))
      ..orderBy([OrderingTerm.asc(_db.words.german)]);
    return query.map((row) => row.readTable(_db.words)).get();
  }

  Future<bool> isWordInCategory(int categoryId, int wordId) async {
    final row = await (_db.select(_db.categoryWords)
      ..where((t) =>
          t.categoryId.equals(categoryId) & t.wordId.equals(wordId)))
        .getSingleOrNull();
    return row != null;
  }

  /// Returns list of category IDs that contain this word.
  Future<List<int>> categoryIdsForWord(int wordId) async {
    final rows = await (_db.select(_db.categoryWords)
      ..where((t) => t.wordId.equals(wordId)))
        .get();
    return rows.map((r) => r.categoryId).toList();
  }

  Future<void> addWordToCategory(int categoryId, int wordId) async {
    await _db.into(_db.categoryWords).insertOnConflictUpdate(
      CategoryWordsCompanion.insert(
        categoryId: categoryId,
        wordId    : wordId,
      ),
    );
    await _db.eigenesListenwortMerken(categoryId, wordId, drin: true); // S.5
  }

  Future<int> removeWordFromCategory(int categoryId, int wordId) async {
    await _db.eigenesListenwortMerken(categoryId, wordId, drin: false); // S.5
    return (_db.delete(_db.categoryWords)
      ..where((t) =>
          t.categoryId.equals(categoryId) & t.wordId.equals(wordId)))
        .go();
  }

  Future<int> countInCategory(int categoryId) async {
    final rows = await (_db.select(_db.categoryWords)
      ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    return rows.length;
  }
}
