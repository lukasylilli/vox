// FILE: lib/core/database/dao/category_dao.dart
// DEPS: app_database.dart (generated: UserCategory, CategoryWord, etc.)
// PURPOSE: CRUD for UserCategories + CategoryWords (reference-based, no word copies)
import 'package:drift/drift.dart';

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

  Future<int> insertCategory(String name) async {
    final id = await _db.into(_db.userCategories).insert(
      UserCategoriesCompanion.insert(name: name),
    );
    await _db.eigeneListeMerken(name, drin: true); // S.5
    return id;
  }

  /// Umbenennen. ⚠️ S.5: Die geräteübergreifende id einer eigenen Liste ist
  /// ihr Name — für den Abgleich ist Umbenennen deshalb „alte Liste weg,
  /// neue Liste da" (samt ihrer Wörter).
  Future<bool> updateCategory(int id, String newName) async {
    final alt = await getById(id);
    final geaendert = await (_db.update(_db.userCategories)
          ..where((t) => t.id.equals(id)))
        .write(UserCategoriesCompanion(name: Value(newName)))
        .then((n) => n > 0);
    if (geaendert && alt != null && alt.name != newName) {
      await _db.eigeneListeMerken(alt.name, drin: false);
      await _db.eigeneListeMerken(newName, drin: true);
      for (final z in await (_db.select(_db.categoryWords)
            ..where((t) => t.categoryId.equals(id)))
          .get()) {
        await _db.eigenesListenwortMerken(id, z.wordId, drin: true);
      }
    }
    return geaendert;
  }

  Future<int> deleteCategory(int id) async {
    final kat = await getById(id);
    if (kat != null) await _db.eigeneListeMerken(kat.name, drin: false); // S.5
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
