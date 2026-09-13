// FILE: lib/core/database/dao/word_dao.dart
// DEPS: app_database.dart (generated types: Word, WordsCompanion, WordBooks)
// PURPOSE: All CRUD + query operations for the words table
import 'package:drift/drift.dart';
import '../app_database.dart';

class WordDao {
  WordDao(this._db);
  final AppDatabase _db;

  // ── Watch (reactive streams) ─────────────────────────────────────────────

  Stream<List<Word>> watchAll() =>
      (_db.select(_db.words)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<Word>> watchByLevel(String level) =>
      (_db.select(_db.words)
        ..where((t) => t.level.equals(level))
        ..orderBy([(t) => OrderingTerm.asc(t.german)]))
          .watch();

  Stream<List<Word>> watchByType(String type) =>
      (_db.select(_db.words)
        ..where((t) => t.wordType.equals(type))
        ..orderBy([(t) => OrderingTerm.asc(t.german)]))
          .watch();

  Stream<List<Word>> watchByBook(int bookId) {
    final query = _db.select(_db.words).join([
      innerJoin(
        _db.wordBooks,
        _db.wordBooks.wordId.equalsExp(_db.words.id),
      ),
    ])..where(_db.wordBooks.bookId.equals(bookId))
      ..orderBy([OrderingTerm.asc(_db.words.german)]);
    return query.map((row) => row.readTable(_db.words)).watch();
  }

  // ── Fetch (one-time) ─────────────────────────────────────────────────────

  Future<Word?> getById(int id) =>
      (_db.select(_db.words)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<Word>> search(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.words)
      ..where((t) =>
          t.german.lower().like(q) | t.meaningFa.like(q))
      ..orderBy([(t) => OrderingTerm.asc(t.german)]))
        .get();
  }

  Future<int> countAll() =>
      _db.words.count().getSingle();

  // ── Mutate ───────────────────────────────────────────────────────────────

  /// Upserts on the (german, word_type) unique key — matching the table constraint.
  Future<int> insert(WordsCompanion companion) =>
      _db.into(_db.words).insert(
        companion,
        onConflict: DoUpdate(
          (old) => companion,
          target: [_db.words.german, _db.words.wordType],
        ),
      );

  Future<bool> update(WordsCompanion companion) =>
      _db.update(_db.words).replace(companion);

  Future<int> delete(int id) =>
      (_db.delete(_db.words)..where((t) => t.id.equals(id))).go();

  // ── Book relations ───────────────────────────────────────────────────────

  Future<void> addToBook(int wordId, int bookId) =>
      _db.into(_db.wordBooks).insertOnConflictUpdate(
        WordBooksCompanion.insert(wordId: wordId, bookId: bookId),
      );

  Future<void> removeFromBook(int wordId, int bookId) =>
      (_db.delete(_db.wordBooks)
        ..where((t) => t.wordId.equals(wordId) & t.bookId.equals(bookId)))
          .go();

  // ── Books ────────────────────────────────────────────────────────────────

  Stream<List<Book>> watchAllBooks() =>
      (_db.select(_db.books)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> insertBook(String name) =>
      _db.into(_db.books).insertOnConflictUpdate(
        BooksCompanion.insert(name: name),
      );
}
