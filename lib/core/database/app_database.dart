// FILE: lib/core/database/app_database.dart
// PURPOSE: Drift database — all table definitions + DB singleton
// AFTER WRITING: run `dart run build_runner build` to generate app_database.g.dart
import 'package:drift/drift.dart';

import '../backup/nutzer_zustand.dart'
    show LeitnerStand, artLeitner, artListe, artListenwort, artWort;
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

  // فاز S.5 (2026-09-15): true = kommt aus den App-Daten (Seed aus
  // assets/data/), nicht vom Nutzer. Solche Wörter bringt jedes Gerät selbst
  // mit — sie gehören nicht in eine Sicherung. Gesetzt NUR vom Seed
  // (data_seed_service.dart), nach Daten, nie geraten. null = Nutzerwort.
  BoolColumn   get ausApp           => boolean().nullable()();

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

  // فاز S.6 (2026-09-16): feste geräteübergreifende id (`eigen:#<32 Hex>`,
  // siehe neueEigeneListenId in core/backup/nutzer_zustand.dart). Vorher war
  // der NAME die id — Umbenennen hieß für den Abgleich „alte Liste weg, neue
  // da", und Wörter, die ein anderes Gerät offline in die alte Liste legte,
  // gingen verloren. Listen von vor S.6 bekommen in der Migration
  // `eigen:<Name>`, also genau ihre bisherige id.
  // ⚠️ Nullable nur, weil SQLite beim Hinzufügen einer Spalte keinen
  // Standardwert je Zeile kennt; die Migration füllt jede Zeile, jede neue
  // Zeile bekommt sie beim Anlegen. Eindeutig über den Index
  // `user_categories_uid` (siehe _listenIdIndex).
  TextColumn get uid      => text().nullable()();
  // Wann der Name vergeben wurde, Millisekunden seit 1970 (UTC) — beim
  // Abgleich gewinnt der später vergebene Name. null = unbekannt (älter als
  // jede Umbenennung). Millisekunden aus demselben Grund wie Mitgliedschaften.amMs.
  IntColumn  get nameAmMs => integer().nullable()();
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

// فاز S.5 (2026-09-15): die letzte bewusste Handlung je Eintrag — aufgenommen
// oder entfernt, mit Zeitpunkt. Ohne sie käme beim Abgleich jede Entfernung
// vom anderen Gerät zurück (Zusammenführen vereinigt). Arten und Schlüssel
// wie in core/backup/nutzer_zustand.dart (Mitgliedschaft):
//   leitner    · schluessel = wortId
//   liste      · schluessel = Listen-id
//   listenwort · schluessel = Listen-id, wort = wortId
//   wort       · schluessel = `<german>|<wordType>` (nur Nutzerwörter)
// Eine Zeile je Eintrag — nur die LETZTE Handlung zählt.
class Mitgliedschaften extends Table {
  TextColumn     get art        => text()();
  TextColumn     get schluessel => text()();
  TextColumn     get wort       => text().withDefault(const Constant(''))();
  BoolColumn     get drin       => boolean()();
  // Millisekunden seit 1970 (UTC). ⚠️ Bewusst KEIN DateTimeColumn: drift legt
  // DateTime ohne build.yaml-Option in SEKUNDEN ab — zwei Handlungen in
  // derselben Sekunde wären dann gleichzeitig, und „drin" gewönne immer.
  IntColumn      get amMs       => integer()();

  @override
  Set<Column> get primaryKey => {art, schluessel, wort};
}

// S.6: Eindeutigkeit der Listen-id. Als eigener Index, weil SQLite eine
// UNIQUE-Spalte nicht nachträglich hinzufügen kann (ALTER TABLE ADD COLUMN).
const _listenIdIndex = 'CREATE UNIQUE INDEX IF NOT EXISTS user_categories_uid '
    'ON user_categories (uid)';

/// Geräteübergreifende id einer eigenen Liste (S.6). `uid` fehlt nur bei einer
/// Zeile, die die Migration auf Fassung 7 nicht gesehen hat — dann gilt die
/// alte Form `eigen:<Name>`, genau das, was die Migration dort einträgt.
String eigeneListenId(UserCategory k) => k.uid ?? 'eigen:${k.name}';

// ── Database class ────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Words, Books, WordBooks,
  UserCategories, CategoryWords,
  LeitnerCards, ArchivLeitner,
  ArchivKategorien, ArchivKategorieWoerter,
  Mitgliedschaften,
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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(_listenIdIndex); // S.6
    },
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
      // فاز S.5: Entfernungen als Ereignisse + Herkunft der Wörter. `ausApp`
      // bleibt für bestehende Zeilen zunächst leer; der Seed (Marke v3) setzt
      // es beim nächsten Start nach Daten.
      if (from < 6) {
        await m.createTable(mitgliedschaften);
        await m.addColumn(words, words.ausApp);
      }
      // فاز S.6: feste Listen-id. Bestehende Listen behalten ihre bisherige id
      // `eigen:<Name>` — so passen Sicherungen, Server-Kopie und gespeicherte
      // Ereignisse weiter zusammen. Gab es einen Namen doppelt (möglich, der
      // Name war nie eindeutig), behält die älteste Zeile die alte id, jede
      // weitere bekommt eine neue zufällige in derselben Form wie
      // neueEigeneListenId(). Erst danach der eindeutige Index.
      if (from < 7) {
        await m.addColumn(userCategories, userCategories.uid);
        await m.addColumn(userCategories, userCategories.nameAmMs);
        await customStatement(
          "UPDATE user_categories SET uid = 'eigen:' || name "
          'WHERE uid IS NULL AND id = (SELECT MIN(u2.id) FROM user_categories u2 '
          'WHERE u2.name = user_categories.name)',
        );
        await customStatement(
          "UPDATE user_categories SET uid = 'eigen:#' || lower(hex(randomblob(16))) "
          'WHERE uid IS NULL',
        );
        await customStatement(_listenIdIndex);
      }
    },
  );

  // ── Mitgliedschaft protokollieren (S.5) ──────────────────────────────────
  //
  // Jede Stelle, die etwas aufnimmt oder entfernt, ruft eine dieser Methoden.
  // Sie liegen hier, weil alle DAOs die Datenbank kennen, aber nicht einander.

  /// Merkt sich die letzte Handlung für einen Eintrag.
  Future<void> mitgliedschaftMerken(
    String art,
    String schluessel, {
    String wort = '',
    required bool drin,
    DateTime? am,
  }) async {
    final zeile = MitgliedschaftenCompanion.insert(
      art: art,
      schluessel: schluessel,
      wort: Value(wort),
      drin: drin,
      amMs: (am ?? DateTime.now()).millisecondsSinceEpoch,
    );
    await into(mitgliedschaften).insert(
      zeile,
      onConflict: DoUpdate(
        (_) => zeile,
        target: [mitgliedschaften.art, mitgliedschaften.schluessel,
                 mitgliedschaften.wort],
      ),
    );
  }

  /// Text-ID eines Worts der Tabelle `Words` (`eigen:<german>|<wordType>`),
  /// oder null, wenn es die Nummer nicht gibt.
  Future<String?> wortIdVon(int wordId) async {
    final w = await (select(words)..where((t) => t.id.equals(wordId)))
        .getSingleOrNull();
    return w == null ? null : LeitnerStand.eigenesWort(w.german, w.wordType);
  }

  /// Leitner-Karte eines Worts aufgenommen/entfernt.
  Future<void> leitnerMerken(int wordId, {required bool drin}) async {
    final id = await wortIdVon(wordId);
    if (id != null) await mitgliedschaftMerken(artLeitner, id, drin: drin);
  }

  /// Eigene Liste angelegt/gelöscht. [listenId] ist die feste id der Liste
  /// ([eigeneListenId], S.6) — nicht mehr ihr Name.
  Future<void> eigeneListeMerken(String listenId, {required bool drin}) =>
      mitgliedschaftMerken(artListe, listenId, drin: drin);

  /// Wort in eine eigene Liste aufgenommen/daraus entfernt.
  Future<void> eigenesListenwortMerken(int categoryId, int wordId,
      {required bool drin}) async {
    final kat = await (select(userCategories)
          ..where((t) => t.id.equals(categoryId)))
        .getSingleOrNull();
    final wortId = await wortIdVon(wordId);
    if (kat == null || wortId == null) return;
    await mitgliedschaftMerken(artListenwort, eigeneListenId(kat),
        wort: wortId, drin: drin);
  }

  /// Wie [nutzerwortMerken], aber über den eindeutigen Schlüssel statt die
  /// Nummer — für Einfügungen, die die Nummer nicht verlässlich liefern.
  Future<void> nutzerwortMerkenNachSchluessel(String german, String wordType,
      {required bool drin}) async {
    final w = await (select(words)
          ..where((t) => t.german.equals(german) & t.wordType.equals(wordType)))
        .getSingleOrNull();
    if (w != null) await nutzerwortMerken(w.id, drin: drin);
  }

  /// Nutzerwort angelegt/gelöscht. App-Wörter werden nicht protokolliert —
  /// sie gehören nicht in eine Sicherung.
  Future<void> nutzerwortMerken(int wordId, {required bool drin}) async {
    final w = await (select(words)..where((t) => t.id.equals(wordId)))
        .getSingleOrNull();
    if (w == null || w.ausApp == true) return;
    await mitgliedschaftMerken(
        artWort, LeitnerStand.wortSchluessel(w.german, w.wordType),
        drin: drin);
  }
}
