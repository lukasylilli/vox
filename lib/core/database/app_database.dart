// FILE: lib/core/database/app_database.dart
// PURPOSE: Drift database — all table definitions + DB singleton
// AFTER WRITING: run `dart run build_runner build` to generate app_database.g.dart
import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'app_database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

class Words extends Table {
  IntColumn    get id               => integer().autoIncrement()();
  TextColumn   get german           => text()();
  TextColumn   get article          => text().nullable()();         // der/die/das
  TextColumn   get plural           => text().nullable()();
  TextColumn   get wordType         => text()();                    // WordType enum value
  TextColumn   get level            => text().nullable()();         // GermanLevel enum value
  TextColumn   get meaningFa        => text()();
  TextColumn   get meaningEn        => text().nullable()();
  TextColumn   get pronunciation    => text().nullable()();
  TextColumn   get examplesJson     => text().nullable()();         // ["...", "..."]
  TextColumn   get conjugationJson  => text().nullable()();         // {inf,präs,prät,pp}
  TextColumn   get etymology        => text().nullable()();
  TextColumn   get commonErrors     => text().nullable()();
  TextColumn   get grammarNote      => text().nullable()();
  DateTimeColumn get createdAt      => dateTime().withDefault(currentDateAndTime)();

  // فاز B-10 (2026-09-16): fehlten fürs Grammatikon-Symbol bei drei Wortarten
  // (PROJECT_MAP.md → wortschatz_grammatikon.dart, "lieber kein Symbol als
  // ein falsches"). Alle drei nullable — bestehende Zeilen bleiben gültig,
  // ohne Symbol bis nachgetragen.
  //   Verb          → regelmaessig, trennbar (blob_wellig vs. kreis vs. doppel_*)
  //   Präposition   → grammatikDetail = Kasus ("akkusativ"|"dativ"|"genitiv"|"wechsel")
  //   Konnektor     → grammatikDetail = Untertyp ("koordinierend"|"subordinierend"|
  //                    "konjunktionaladverb")
  BoolColumn   get regelmaessig     => boolean().nullable()();
  BoolColumn   get trennbar         => boolean().nullable()();
  TextColumn   get grammatikDetail  => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{german, wordType}];
}

class Books extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class WordBooks extends Table {
  IntColumn get wordId => integer().references(Words, #id)();
  IntColumn get bookId => integer().references(Books, #id)();

  @override
  Set<Column> get primaryKey => {wordId, bookId};
}

class UserCategories extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text()();
}

class CategoryWords extends Table {
  IntColumn get categoryId => integer().references(UserCategories, #id)();
  IntColumn get wordId     => integer().references(Words, #id)();

  @override
  Set<Column> get primaryKey => {categoryId, wordId};
}

// Box 1-5: reviewInterval = 1/2/4/8/16 days
class LeitnerCards extends Table {
  IntColumn    get id          => integer().autoIncrement()();
  IntColumn    get wordId      => integer().references(Words, #id).unique()();
  IntColumn    get boxNumber   => integer().withDefault(const Constant(1))();
  DateTimeColumn get nextReview => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();
}

// ── Placeholders for future phases (schema v1) ───────────────────────────────
// Tables are defined now so migrations stay clean when content is added later.

class GrammarLessons extends Table {
  IntColumn  get id      => integer().autoIncrement()();
  TextColumn get title   => text()();
  TextColumn get level   => text()();
  TextColumn get content => text()();       // Markdown/HTML body
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
}

class MemorizeItems extends Table {
  IntColumn  get id       => integer().autoIncrement()();
  TextColumn get category => text()();      // one of the 15 Auswendiglernen categories
  TextColumn get phrase   => text()();
  TextColumn get meaning  => text()();      // FA meaning
  TextColumn get meaningEn => text().nullable()();  // فاز L3-E: EN meaning
  TextColumn get level    => text().nullable()();
  TextColumn get examplesJson => text().nullable()();
}

class ReadingTexts extends Table {
  IntColumn  get id       => integer().autoIncrement()();
  TextColumn get title    => text()();
  TextColumn get level    => text()();
  TextColumn get content  => text()();
  TextColumn get audioPath => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

class AudioItems extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get title     => text()();
  TextColumn get level     => text()();
  TextColumn get audioPath => text()();
  TextColumn get transcript => text().nullable()();  // JSON: [{word, startMs, endMs}]
}

class Habits extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get name      => text()();
  TextColumn get daysJson  => text()();   // [1,2,3,4,5] = Mon-Fri
  TextColumn get shift     => text()();   // morning/afternoon/evening
  IntColumn  get streakCount => integer().withDefault(const Constant(0))();
  BoolColumn get isActive  => boolean().withDefault(const Constant(true))();
}

class HabitSessions extends Table {
  IntColumn    get id        => integer().autoIncrement()();
  IntColumn    get habitId   => integer().references(Habits, #id)();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn    get durationMinutes => integer().nullable()();
}

// فاز S.0c (2026-09-16): eigene Listen zu ARCHIVKARTEN — bisher in
// SharedPreferences unter vokab_user_kategorien_v1. Zwei Tabellen statt einer
// JSON-Liste, damit Wörter einer Liste einzeln abgefragt werden können (wie
// bei den eigenen Wörtern in CategoryWords) und weil eine Kategorie beliebig
// viele Wörter referenziert (n:m) — genau das Muster, das UserCategories/
// CategoryWords für eigene Wörter schon nutzt.
class ArchivKategorien extends Table {
  TextColumn get id   => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArchivKategorieWoerter extends Table {
  TextColumn get kategorieId => text().references(ArchivKategorien, #id)();
  TextColumn get wortId      => text()(); // Archivkarten-ID, z. B. adjektiv_stolz

  @override
  Set<Column> get primaryKey => {kategorieId, wortId};
}

// فاز S.0b (2026-09-15): Leitner-Stand der ARCHIVKARTEN (die ~26.200 Wörter aus
// assets/vocab/) — bisher in SharedPreferences unter vokab_user_leitner_v1.
// Eigener Schlüsseltyp, bewusst getrennt von LeitnerCards: die Archivkarten
// haben Text-IDs wie "adjektiv_stolz", keine drift-Zeilen-ID. Dieselbe Text-ID
// wie in core/backup/nutzer_zustand.dart (LeitnerStand.wortId) — das ist die
// Brücke zwischen Datei-Sicherung und Ablage.
class ArchivLeitner extends Table {
  TextColumn     get wortId     => text()();
  IntColumn      get boxNumber  => integer().withDefault(const Constant(1))();
  DateTimeColumn get nextReview => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {wortId};
}

// ── Database class ────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Words, Books, WordBooks,
  UserCategories, CategoryWords,
  LeitnerCards, ArchivLeitner,
  ArchivKategorien, ArchivKategorieWoerter,
  GrammarLessons, MemorizeItems,
  ReadingTexts, AudioItems,
  Habits, HabitSessions,
])
class AppDatabase extends _$AppDatabase {
  /// Im Browser: SQLite als WebAssembly (siehe connection/web.dart).
  AppDatabase() : super(openConnection());

  /// Für Tests: in-memory Executor statt Datei (z. B. NativeDatabase.memory()).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // فاز L3-E: EN-Bedeutung für Auswendiglernen-Karten
      if (from < 2) {
        await m.addColumn(memorizeItems, memorizeItems.meaningEn);
      }
      // فاز S.0b: Leitner-Stand der Archivkarten bekommt eine eigene Tabelle.
      // Der Inhalt von vokab_user_leitner_v1 (SharedPreferences) wandert beim
      // ersten Start NICHT automatisch hierher — das übernimmt weiterhin
      // core/backup/user_state_repository.dart zur Laufzeit (lesen() liest
      // schon heute beide Quellen). Eine leere neue Tabelle ist deshalb
      // unbedenklich; nichts geht verloren.
      if (from < 3) {
        await m.createTable(archivLeitner);
      }
      // فاز S.0c: eigene Listen zu Archivkarten. Wie bei S.0b wandert der
      // Inhalt von vokab_user_kategorien_v1 NICHT automatisch hierher — das
      // übernimmt user_state_repository.dart zur Laufzeit (Übergangspfad,
      // dieselbe „vereinigen statt überschreiben"-Regel wie beim Leitner).
      if (from < 4) {
        await m.createTable(archivKategorien);
        await m.createTable(archivKategorieWoerter);
      }
      // فاز B-10: Grammatikfelder für Verb/Präposition/Konnektor.
      if (from < 5) {
        await m.addColumn(words, words.regelmaessig);
        await m.addColumn(words, words.trennbar);
        await m.addColumn(words, words.grammatikDetail);
      }
    },
  );
}
