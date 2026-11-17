// FILE: test/migration_v8_test.dart
// PHASE: X.2 (2026-11-17) — Leitner wie Anki
// PURPOSE: Die Migration auf Fassung 8 an den ECHTEN Schemata der Fassungen
//          6 und 7 (drift_schemas/, test/generated_migrations/): sechs alte
//          Tabellen ⇒ LeitnerFortschritt, Decks, DeckWoerter. Gehoben wird
//          auf die AKTUELLE Fassung (X.4: 9) — der Weg führt über 8.
//
// Ergänzt test/migration_test.dart (jede Fassung, ein Wort) um die Fälle, an
// denen eine Überführung scheitern könnte:
//   · eigene Listen behalten ihre id — auch die von vor S.6 (`eigen:<Name>`)
//     und doppelte Namen (früher test/migration_v7_test.dart);
//   · ein Wort in mehreren Listen, eine Liste mit Karten und eine mit alten
//     Wörtern;
//   · eine Leitner-Karte, deren Wort es nicht mehr gibt, kostet nichts;
//   · ein leerer Stapel legt kein Deck «Leitner» an.
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';

import 'generated_migrations/schema.dart';

const _sek = 1789862400; // 2026-09-20 00:00 UTC, so legt drift DateTime ab

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  Future<AppDatabase> heben(InitializedSchema schema) async {
    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, db.schemaVersion,
        options: const ValidationOptions(validateDropped: true));
    return db;
  }

  test('6 → 8: Listen von vor S.6 behalten `eigen:<Name>`, doppelte Namen '
      'bekommen eine eigene id', () async {
    final schema = await verifier.schemaAt(6);
    schema.rawDatabase.execute("INSERT INTO user_categories (name) "
        "VALUES ('Reise'), ('Arbeit'), ('Reise')");
    final db = await heben(schema);

    final decks = await LeitnerDao(db).decks();
    expect(decks.map((d) => d.name).toList()..sort(),
        ['Arbeit', 'Reise', 'Reise']);
    final ids = decks.map((d) => d.id).toSet();
    expect(ids, containsAll(['eigen:Reise', 'eigen:Arbeit']));
    expect(ids.singleWhere((i) => i.startsWith('eigen:#')),
        matches(RegExp(r'^eigen:#[0-9a-f]{32}$')));
    expect(decks.every((d) => d.modus == deckModusNotiz), isTrue);
    expect(decks.any((d) => d.id == standardDeckId), isFalse,
        reason: 'leerer Stapel ⇒ kein Deck «Leitner»');
  });

  test('7 → 8: Fortschritt, Stapel, Listen und Ereignisse vollständig', () async {
    final schema = await verifier.schemaAt(7);
    final roh = schema.rawDatabase;
    roh.execute("INSERT INTO words (id, german, word_type, meaning_fa) VALUES "
        "(1, 'Feierabend', 'nomen', 'x'), (2, 'gehen', 'verb', 'y'), "
        "(3, 'weg', 'adverb', 'z')");
    // Stapel: zwei alte Wörter, zwei Archivkarten.
    roh.execute(
        'INSERT INTO leitner_cards (word_id, box_number, next_review, last_review) '
        'VALUES (1, 4, ?, ?), (2, 1, ?, NULL)',
        [_sek, _sek - 86400, _sek + 86400]);
    roh.execute(
        "INSERT INTO archiv_leitner (wort_id, box_number, next_review, last_review) "
        "VALUES ('adjektiv_stolz', 5, ?, ?), ('verb_laufen', 2, ?, NULL)",
        [_sek, _sek - 3600, _sek]);
    // Listen: eine mit Karten, eine mit alten Wörtern (feste id), ein Wort
    // in zwei Listen.
    roh.execute("INSERT INTO archiv_kategorien (id, name) "
        "VALUES ('kat_1', 'Prüfung'), ('kat_2', 'Leer')");
    roh.execute("INSERT INTO archiv_kategorie_woerter (kategorie_id, wort_id) "
        "VALUES ('kat_1', 'adjektiv_stolz'), ('kat_1', 'nomen_tisch')");
    roh.execute("INSERT INTO user_categories (id, name, uid, name_am_ms) VALUES "
        "(1, 'Reise', 'eigen:#00112233445566778899aabbccddeeff', 1789000000000), "
        "(2, 'Alt', 'eigen:Alt', NULL)");
    roh.execute('INSERT INTO category_words (category_id, word_id) '
        'VALUES (1, 1), (1, 2), (2, 1)');
    roh.execute("INSERT INTO mitgliedschaften (art, schluessel, wort, drin, am_ms) VALUES "
        "('leitner', 'adjektiv_stolz', '', 1, 100), "
        "('leitner', 'verb_fort', '', 0, 200), "
        "('listenwort', 'kat_1', 'nomen_tisch', 1, 300), "
        "('wort', 'weg|adverb', '', 1, 400)");
    final db = await heben(schema);

    // ── Fortschritt: jedes Fach, jeder Termin ────────────────────────────
    final f = {
      for (final z in await db.select(db.leitnerFortschritt).get()) z.wortId: z,
    };
    expect(f.keys.toSet(), {
      'eigen:Feierabend|nomen',
      'eigen:gehen|verb',
      'adjektiv_stolz',
      'verb_laufen',
    });
    expect(f.values.every((z) => z.uebung == uebungBedeutung), isTrue);
    expect(f['eigen:Feierabend|nomen']!.fach, 4);
    expect(f['eigen:gehen|verb']!.fach, 1);
    expect(f['eigen:gehen|verb']!.letzteWiederholung, isNull);
    expect(f['adjektiv_stolz']!.fach, 5);
    expect(
        f['adjektiv_stolz']!.naechsteWiederholung!.millisecondsSinceEpoch ~/
            1000,
        _sek);
    expect(
        f['adjektiv_stolz']!.letzteWiederholung!.millisecondsSinceEpoch ~/ 1000,
        _sek - 3600);
    expect(f['verb_laufen']!.fach, 2);

    // ── Decks ────────────────────────────────────────────────────────────
    final dao = LeitnerDao(db);
    final decks = {for (final d in await dao.decks()) d.id: d};
    expect(decks.keys.toSet(), {
      standardDeckId,
      'kat_1',
      'kat_2',
      'eigen:#00112233445566778899aabbccddeeff',
      'eigen:Alt',
    });
    expect(decks[standardDeckId]!.modus, deckModusWiederholen);
    expect(decks[standardDeckId]!.name, standardDeckName);
    expect(decks['kat_1']!.name, 'Prüfung');
    expect(decks['eigen:#00112233445566778899aabbccddeeff']!.nameAmMs,
        1789000000000);
    expect(decks['eigen:Alt']!.nameAmMs, isNull);
    Future<Set<String>> woerter(String deck) async =>
        (await dao.deckWoerterBeobachten(deck).first).toSet();
    expect(await woerter(standardDeckId), f.keys.toSet(),
        reason: 'der Stapel ist das Deck «Leitner»');
    expect(await woerter('kat_1'), {'adjektiv_stolz', 'nomen_tisch'});
    expect(await woerter('kat_2'), isEmpty);
    expect(await woerter('eigen:#00112233445566778899aabbccddeeff'),
        {'eigen:Feierabend|nomen', 'eigen:gehen|verb'});
    expect(await woerter('eigen:Alt'), {'eigen:Feierabend|nomen'});
    expect((await dao.imLeitnerBeobachten().first).toSet(), f.keys.toSet());

    // ── Ereignisse ───────────────────────────────────────────────────────
    final m = {
      for (final e in await db.select(db.mitgliedschaften).get())
        '${e.art}/${e.schluessel}/${e.wort}': e,
    };
    expect(m.keys.toSet(), {
      'listenwort/$standardDeckId/adjektiv_stolz',
      'listenwort/$standardDeckId/verb_fort',
      'listenwort/kat_1/nomen_tisch',
      'wort/weg|adverb/',
    });
    expect(m['listenwort/$standardDeckId/verb_fort']!.drin, isFalse);
    expect(m['listenwort/$standardDeckId/verb_fort']!.amMs, 200);

    // ── Die App-Wörter selbst bleiben unberührt ──────────────────────────
    expect(await db.select(db.words).get(), hasLength(3));
  });
}
