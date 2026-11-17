// FILE: test/migration_test.dart
// PHASE: فاز LAUNCH, Schritt L.1b (2026-09-16)
// PURPOSE: Jede veröffentlichte Datenbank-Fassung wird auf die aktuelle
//          gehoben — mit echten Nutzerdaten darin — und danach geprüft:
//          (1) das Schema ist GENAU das, was eine frische Installation hätte
//              (drift SchemaVerifier: Tabellen, Spalten, Einschränkungen, Indizes),
//          (2) Leitner-Fächer, Termine, Listen und Ereignisse sind noch da.
//
// Die Schemata der alten Fassungen stammen NICHT aus einer Nachbildung,
// sondern aus dem echten Code von damals: `.github/workflows/build-runner.yml`
// holt je Fassung den letzten Commit aus der Git-Geschichte und lässt
// `drift_dev schema dump` darauf laufen (drift_schemas/), daraus entstehen
// die Hilfsdateien in test/generated_migrations/.
//
// X.2 (2026-11-17, Fassung 8): sechs alte Tabellen ⇒ drei neue
// (LeitnerFortschritt, Decks, DeckWoerter). Dieser Test ist der Wächter
// dafür, dass dabei KEIN Fach, kein Termin, keine Liste und kein Ereignis
// verloren geht — aus jeder je veröffentlichten Fassung.
//
// Fassung 1 gab es in diesem Repository nie — die Geschichte beginnt am
// 2026-09-13 mit Fassung 2 (erste Web-Veröffentlichung). Siehe PLAN.md → L.1b.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';

import 'generated_migrations/schema.dart';

/// Erste Fassung, die je veröffentlicht wurde.
const ersteFassung = 2;

/// 2026-09-20 00:00 UTC in Sekunden — so legt drift DateTime ab.
const faelligSek = 1789862400;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final aktuell = AppDatabase.forTesting(NativeDatabase.memory());
  final zielFassung = aktuell.schemaVersion;
  tearDownAll(aktuell.close);

  test('für jede Fassung ab $ersteFassung gibt es ein Schema', () {
    expect(GeneratedHelper.versions,
        [for (var v = ersteFassung; v <= zielFassung; v++) v],
        reason: 'Neue schemaVersion ⇒ build-runner.yml laufen lassen, er '
            'legt drift_schemas/ und test/generated_migrations/ an.');
    expect(File('drift_schemas/drift_schema_v$zielFassung.json').existsSync(),
        isTrue);
  });

  test('frische Installation entspricht dem, was der Code erwartet', () async {
    await aktuell.validateDatabaseSchema(
        options: const ValidationOptions(validateDropped: true));
  });

  for (var von = ersteFassung; von < zielFassung; von++) {
    test('Fassung $von → $zielFassung: Schema stimmt, Lernstand bleibt',
        () async {
      final schema = await verifier.schemaAt(von);
      final roh = schema.rawDatabase;

      // ── Nutzerdaten, wie sie in Fassung `von` aussehen konnten ──────────
      roh.execute(
          "INSERT INTO words (german, word_type, meaning_fa) "
          "VALUES ('Feierabend', 'nomen', 'پایان کار')");
      if (von < 8) {
        roh.execute(
            'INSERT INTO leitner_cards (word_id, box_number, next_review, last_review) '
            'VALUES (1, 4, ?, ?)',
            [faelligSek, faelligSek - 86400]);
        roh.execute("INSERT INTO user_categories (name) VALUES ('Reise')");
        roh.execute(
            'INSERT INTO category_words (category_id, word_id) VALUES (1, 1)');
        if (von >= 3) {
          roh.execute(
              "INSERT INTO archiv_leitner (wort_id, box_number, next_review) "
              "VALUES ('adjektiv_stolz', 5, ?)",
              [faelligSek]);
        }
        if (von >= 4) {
          roh.execute(
              "INSERT INTO archiv_kategorien (id, name) VALUES ('kat_1', 'Prüfung')");
          roh.execute("INSERT INTO archiv_kategorie_woerter (kategorie_id, wort_id) "
              "VALUES ('kat_1', 'adjektiv_stolz')");
        }
        if (von >= 6) {
          roh.execute("INSERT INTO mitgliedschaften (art, schluessel, wort, drin, am_ms) "
              "VALUES ('liste', 'eigen:Reise', '', 1, 1789000000000)");
          // Vor X.2: «in den Stapel» / «aus dem Stapel» je Wort.
          roh.execute("INSERT INTO mitgliedschaften (art, schluessel, wort, drin, am_ms) "
              "VALUES ('leitner', 'adjektiv_stolz', '', 1, 1789000000001)");
          roh.execute("INSERT INTO mitgliedschaften (art, schluessel, wort, drin, am_ms) "
              "VALUES ('leitner', 'adjektiv_alt', '', 0, 1789000000002)");
        }
      } else {
        // Ab Fassung 8 (X.2): derselbe Lernstand in den neuen Tabellen — so,
        // wie die Migration auf 8 ihn hinterlassen hätte.
        roh.execute(
            'INSERT INTO leitner_fortschritt (wort_id, uebung, fach, '
            'naechste_wiederholung, letzte_wiederholung) VALUES '
            "('eigen:Feierabend|nomen', 'bedeutung', 4, ?, ?), "
            "('adjektiv_stolz', 'bedeutung', 5, ?, NULL)",
            [faelligSek, faelligSek - 86400, faelligSek]);
        roh.execute("INSERT INTO decks (id, name, modus) VALUES "
            "('deck:leitner', 'Leitner', 'wiederholen'), "
            "('eigen:Reise', 'Reise', 'notiz'), "
            "('kat_1', 'Prüfung', 'notiz')");
        roh.execute("INSERT INTO deck_woerter (deck_id, wort_id) VALUES "
            "('deck:leitner', 'eigen:Feierabend|nomen'), "
            "('deck:leitner', 'adjektiv_stolz'), "
            "('eigen:Reise', 'eigen:Feierabend|nomen'), "
            "('kat_1', 'adjektiv_stolz')");
        roh.execute("INSERT INTO mitgliedschaften (art, schluessel, wort, drin, am_ms) VALUES "
            "('liste', 'eigen:Reise', '', 1, 1789000000000), "
            "('listenwort', 'deck:leitner', 'adjektiv_stolz', 1, 1789000000001), "
            "('listenwort', 'deck:leitner', 'adjektiv_alt', 0, 1789000000002)");
      }

      // ── Heben und Schema prüfen ─────────────────────────────────────────
      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, zielFassung,
          options: const ValidationOptions(validateDropped: true));

      // ── Lernstand ────────────────────────────────────────────────────────
      // Die alten Tabellen sind weg (validateDropped oben) — ihr Inhalt
      // steht in den neuen.
      final fortschritt = {
        for (final z in await db.select(db.leitnerFortschritt).get())
          z.wortId: z,
      };
      final karte = fortschritt['eigen:Feierabend|nomen']!;
      expect(karte.uebung, uebungBedeutung);
      expect(karte.fach, 4);
      expect(karte.naechsteWiederholung!.toUtc(),
          DateTime.fromMillisecondsSinceEpoch(faelligSek * 1000, isUtc: true));
      expect(karte.letzteWiederholung, isNotNull);
      expect(karte.ersteWiederholung, isNull,
          reason: 'X.4: erstes Üben ist für alten Lernstand unbekannt — '
              'zählt nicht als «heute begonnen»');

      SharedPreferences.setMockInitialValues({});
      final zustand = await UserStateRepository(
              db, await SharedPreferences.getInstance())
          .lesen();
      expect(zustand.leitner['eigen:Feierabend|nomen']!.fach, 4);
      final reise = zustand.kategorien.singleWhere((k) => k.name == 'Reise');
      expect(reise.id, 'eigen:Reise',
          reason: 'alte Listen behalten ihre id (S.6)');
      expect(reise.wortIds, ['eigen:Feierabend|nomen']);
      // Der bisherige Stapel ist das Deck «Leitner», mit Wiederholung.
      final stapel =
          zustand.kategorien.singleWhere((k) => k.id == standardDeckId);
      expect(stapel.wiederholen, isTrue);
      expect(stapel.wortIds, contains('eigen:Feierabend|nomen'));
      expect(reise.wiederholen, isFalse,
          reason: 'eigene Listen werden Notizbücher — keine ungewollte '
              'Wiederholung');
      if (von >= 3) {
        expect(zustand.leitner['adjektiv_stolz']!.fach, 5);
        expect(stapel.wortIds, contains('adjektiv_stolz'));
        expect(zustand.imLeitner,
            {'eigen:Feierabend|nomen', 'adjektiv_stolz'});
      }
      if (von >= 4) {
        expect(zustand.kategorien.singleWhere((k) => k.id == 'kat_1').wortIds,
            ['adjektiv_stolz']);
      }
      if (von >= 6) {
        final m = zustand.mitgliedschaften;
        expect(m[mitgliedschaftsSchluessel(artListe, 'eigen:Reise')]!.drin,
            isTrue);
        // «Stapel»-Ereignisse hängen jetzt am Deck «Leitner».
        expect(
            m[mitgliedschaftsSchluessel(
                    artListenwort, standardDeckId, 'adjektiv_stolz')]!
                .drin,
            isTrue);
        final raus = m[mitgliedschaftsSchluessel(
            artListenwort, standardDeckId, 'adjektiv_alt')]!;
        expect(raus.drin, isFalse);
        expect(raus.am.millisecondsSinceEpoch, 1789000000002);
        expect(m, hasLength(3));
      }
    });
  }
}
