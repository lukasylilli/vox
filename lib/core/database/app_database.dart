// FILE: lib/core/database/app_database.dart
// PURPOSE: Drift database — all table definitions + DB singleton
// AFTER WRITING: run `dart run build_runner build` to generate app_database.g.dart
import 'package:drift/drift.dart';

import '../backup/nutzer_zustand.dart'
    show
        LeitnerStand,
        artWort,
        deckModusErben,
        deckModusNotiz,
        deckModusWiederholen,
        effektiveDeckModi,
        standardDeckId,
        standardDeckName,
        uebungBedeutung;
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

// ── Leitner wie Anki (X.2, 2026-11-17 — docs/zukunft/PHASE_X.md) ─────────────
//
// Drei Tabellen ersetzen sechs (LeitnerCards, ArchivLeitner, UserCategories,
// CategoryWords, ArchivKategorien, ArchivKategorieWoerter). Alle Schlüssel
// sind TEXT-ids, dieselben wie in core/backup/nutzer_zustand.dart:
//   · Archivkarten  `adjektiv_stolz`
//   · alte Wörter   `eigen:<german>|<wordType>` (Tabelle Words)
// Damit gibt es EINEN Stapel statt zwei und EINE Art Liste statt zwei.

/// Fortschritt «Wort × Übung»: Fach 1–7, danach 8 = gelernt
/// (core/leitner/leitner_regeln.dart). Eine Zeile entsteht erst mit der
/// ersten Antwort — ein Wort ohne Zeile ist «neu». Der Fortschritt gehört zum
/// Wort, nicht zum Deck: Entfernen aus einem Deck löscht hier nichts.
class LeitnerFortschritt extends Table {
  TextColumn     get wortId => text()();
  TextColumn     get uebung => text()();
  IntColumn      get fach   => integer().withDefault(const Constant(1))();
  // null = kein Termin (gelernt, oder aus einem Stand ohne Termin).
  DateTimeColumn get naechsteWiederholung => dateTime().nullable()();
  DateTimeColumn get letzteWiederholung   => dateTime().nullable()();
  // X.4: erstes Üben (Tageslimit neuer Wörter); null = vor X.4 / unbekannt.
  DateTimeColumn get ersteWiederholung    => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {wortId, uebung};
}

/// Ein Deck — auch jede frühere «eigene Liste» ist eines (gleiche id wie
/// vorher: `eigen:#<Hex>`, `eigen:<Name>`, `kat_<Millisekunden>`).
class Decks extends Table {
  TextColumn get id   => text()();
  TextColumn get name => text()();
  // id des übergeordneten Decks; null = oberste Ebene. Bewusst ohne
  // Fremdschlüssel: beim Abgleich kann ein Deck vor seinem Eltern-Deck
  // ankommen; ein fehlendes Eltern-Deck heißt «oberste Ebene».
  TextColumn get elternId => text().nullable()();
  IntColumn  get ordnung  => integer().withDefault(const Constant(0))();
  // deckModusWiederholen | deckModusNotiz | deckModusErben (wie Eltern-Deck)
  TextColumn get modus => text().withDefault(const Constant(deckModusNotiz))();
  // Neue Wörter pro Tag; null = Standard (leitner_regeln.dart).
  IntColumn  get neuProTag => integer().nullable()();
  // Millisekunden seit 1970 (UTC), wie Mitgliedschaften.amMs: wann der Name
  // bzw. die Einstellungen (Eltern, Modus, Limit, Ordnung) zuletzt geändert
  // wurden — beim Abgleich gewinnt das Spätere. null = unbekannt/älter.
  IntColumn  get nameAmMs  => integer().nullable()();
  IntColumn  get standAmMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Wort ↔ Deck (n:m). Ein Wort kann in mehreren Decks liegen.
class DeckWoerter extends Table {
  TextColumn get deckId => text().references(Decks, #id)();
  TextColumn get wortId => text()();
  // Wann aufgenommen (Millisekunden) — Reihenfolge der neuen Wörter.
  IntColumn  get hinzuMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {deckId, wortId};
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

// فاز S.5 (2026-09-15): die letzte bewusste Handlung je Eintrag — aufgenommen
// oder entfernt, mit Zeitpunkt. Ohne sie käme beim Abgleich jede Entfernung
// vom anderen Gerät zurück (Zusammenführen vereinigt). Arten und Schlüssel
// wie in core/backup/nutzer_zustand.dart (Mitgliedschaft):
//   liste      · schluessel = Deck-id
//   listenwort · schluessel = Deck-id, wort = wortId
//   (bis Fassung 7 der Datenbank auch `leitner` · schluessel = wortId — die
//    Migration auf 8 macht daraus `listenwort` am Standard-Deck)
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

// ── Database class ────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Words, Books, WordBooks,
  LeitnerFortschritt, Decks, DeckWoerter,
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
  int get schemaVersion => 10;

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
      // (X.2: die Tabelle gibt es im Schema nicht mehr — Fassung 8 überführt
      //  und löscht sie. Deshalb hier als festes SQL, wortgleich mit dem, was
      //  drift damals anlegte.)
      if (from < 3) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS archiv_leitner ('
          'wort_id TEXT NOT NULL, '
          'box_number INTEGER NOT NULL DEFAULT 1, '
          'next_review INTEGER NOT NULL, '
          'last_review INTEGER NULL, '
          'PRIMARY KEY (wort_id))',
        );
      }
      // فاز S.0c: eigene Listen zu Archivkarten. Wie bei S.0b wandert der
      // Inhalt von vokab_user_kategorien_v1 NICHT automatisch hierher — das
      // übernimmt user_state_repository.dart zur Laufzeit (Übergangspfad,
      // dieselbe „vereinigen statt überschreiben"-Regel wie beim Leitner).
      if (from < 4) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS archiv_kategorien ('
          'id TEXT NOT NULL, name TEXT NOT NULL, PRIMARY KEY (id))',
        );
        await customStatement(
          'CREATE TABLE IF NOT EXISTS archiv_kategorie_woerter ('
          'kategorie_id TEXT NOT NULL REFERENCES archiv_kategorien (id), '
          'wort_id TEXT NOT NULL, '
          'PRIMARY KEY (kategorie_id, wort_id))',
        );
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
        await customStatement(
            'ALTER TABLE user_categories ADD COLUMN uid TEXT NULL');
        await customStatement(
            'ALTER TABLE user_categories ADD COLUMN name_am_ms INTEGER NULL');
        await customStatement(
          "UPDATE user_categories SET uid = 'eigen:' || name "
          'WHERE uid IS NULL AND id = (SELECT MIN(u2.id) FROM user_categories u2 '
          'WHERE u2.name = user_categories.name)',
        );
        await customStatement(
          "UPDATE user_categories SET uid = 'eigen:#' || lower(hex(randomblob(16))) "
          'WHERE uid IS NULL',
        );
        // Eindeutigkeit als eigener Index, weil SQLite eine UNIQUE-Spalte
        // nicht nachträglich hinzufügen kann (ALTER TABLE ADD COLUMN).
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS user_categories_uid '
          'ON user_categories (uid)',
        );
      }
      // فاز X.2 (2026-11-17): Leitner wie Anki. Drei neue Tabellen übernehmen
      // ALLES aus den sechs alten; erst danach werden die alten gelöscht.
      // ⚠️ Nichts geht verloren (test/migration_v8_test.dart):
      //   · Fach und Termine jedes Worts ⇒ Fortschritt der Übung «bedeutung»
      //     (Archivkarten mit ihrer id, alte Wörter als `eigen:<Wort>|<Art>`);
      //   · alle Wörter des bisherigen Stapels ⇒ Deck «Leitner» mit
      //     Wiederholung — genau das war der Stapel;
      //   · jede eigene Liste ⇒ ein Deck mit DERSELBEN id und denselben
      //     Wörtern, als Notizbuch (keine ungewollte Wiederholung);
      //   · Ereignisse «in den Stapel/aus dem Stapel» ⇒ Wort im Deck «Leitner».
      if (from < 8) {
        await m.createTable(leitnerFortschritt);
        await m.createTable(decks);
        await m.createTable(deckWoerter);
        const eigen = "'eigen:' || w.german || '|' || w.word_type";
        await customStatement(
          'INSERT OR REPLACE INTO leitner_fortschritt '
          '(wort_id, uebung, fach, naechste_wiederholung, letzte_wiederholung) '
          "SELECT wort_id, '$uebungBedeutung', box_number, next_review, "
          'last_review FROM archiv_leitner',
        );
        await customStatement(
          'INSERT OR REPLACE INTO leitner_fortschritt '
          '(wort_id, uebung, fach, naechste_wiederholung, letzte_wiederholung) '
          "SELECT $eigen, '$uebungBedeutung', c.box_number, c.next_review, "
          'c.last_review FROM leitner_cards c JOIN words w ON w.id = c.word_id',
        );
        await customStatement(
          'INSERT INTO decks (id, name, modus) '
          "SELECT '$standardDeckId', '$standardDeckName', "
          "'$deckModusWiederholen' "
          'WHERE EXISTS (SELECT 1 FROM leitner_fortschritt)',
        );
        await customStatement(
          'INSERT OR IGNORE INTO deck_woerter (deck_id, wort_id) '
          "SELECT '$standardDeckId', wort_id FROM leitner_fortschritt",
        );
        await customStatement(
          'INSERT OR IGNORE INTO decks (id, name) '
          'SELECT id, name FROM archiv_kategorien',
        );
        await customStatement(
          'INSERT OR IGNORE INTO deck_woerter (deck_id, wort_id) '
          'SELECT kategorie_id, wort_id FROM archiv_kategorie_woerter',
        );
        const uid = "COALESCE(u.uid, 'eigen:' || u.name)";
        await customStatement(
          'INSERT OR IGNORE INTO decks (id, name, name_am_ms) '
          'SELECT $uid, u.name, u.name_am_ms FROM user_categories u',
        );
        await customStatement(
          'INSERT OR IGNORE INTO deck_woerter (deck_id, wort_id) '
          'SELECT $uid, $eigen FROM category_words cw '
          'JOIN user_categories u ON u.id = cw.category_id '
          'JOIN words w ON w.id = cw.word_id',
        );
        await customStatement(
          'INSERT OR REPLACE INTO mitgliedschaften '
          '(art, schluessel, wort, drin, am_ms) '
          "SELECT 'listenwort', '$standardDeckId', schluessel, drin, am_ms "
          "FROM mitgliedschaften WHERE art = 'leitner'",
        );
        await customStatement(
            "DELETE FROM mitgliedschaften WHERE art = 'leitner'");
        // Erst jetzt, nachdem alles übernommen ist.
        for (final tabelle in const [
          'category_words',
          'user_categories',
          'archiv_kategorie_woerter',
          'archiv_kategorien',
          'leitner_cards',
          'archiv_leitner',
        ]) {
          await customStatement('DROP TABLE IF EXISTS $tabelle');
        }
      }
      // فاز X.4 (2026-11-17): erstes Üben je «Wort × Übung» — für das
      // Tageslimit neuer Wörter. Bestehende Zeilen bleiben null (= nicht heute).
      // (Wer von < 8 kommt, bekommt die Tabelle oben schon mit der Spalte.)
      if (from >= 8 && from < 9) {
        await m.addColumn(
            leitnerFortschritt, leitnerFortschritt.ersteWiederholung);
      }
      // Lukas 2026-11-22: Subdecks folgen dem Modus des Decks darüber, bis
      // man eines von Hand umstellt. Nur Daten, keine Spalte: jedes Subdeck,
      // dessen Modus heute GLEICH dem des Eltern-Decks ist, bekommt «erben»
      // — so ändert sich jetzt nichts, aber künftig folgt es. Ein Subdeck
      // mit anderem Modus hat der Nutzer bewusst so gestellt und bleibt.
      if (from < 10) {
        await subdecksErbenLassen();
      }
    },
  );

  /// Migration v10 (siehe onUpgrade). Öffentlich nur für den Test.
  Future<void> subdecksErbenLassen() async {
    final alle = await select(decks).get();
    final modi = effektiveDeckModi(alle,
        id: (d) => d.id, eltern: (d) => d.elternId, modus: (d) => d.modus);
    final ids = {for (final d in alle) d.id};
    final erben = [
      for (final d in alle)
        if (d.elternId != null &&
            ids.contains(d.elternId) &&
            d.modus != deckModusErben &&
            d.modus == modi[d.elternId])
          d.id,
    ];
    if (erben.isEmpty) return;
    // Ohne standAm: die Umstellung ist keine Handlung des Nutzers.
    await (update(decks)..where((t) => t.id.isIn(erben)))
        .write(const DecksCompanion(modus: Value(deckModusErben)));
  }

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
