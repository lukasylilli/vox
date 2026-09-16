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
// Fassung 1 gab es in diesem Repository nie — die Geschichte beginnt am
// 2026-09-13 mit Fassung 2 (erste Web-Veröffentlichung). Siehe PLAN.md → L.1b.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      }

      // ── Heben und Schema prüfen ─────────────────────────────────────────
      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, zielFassung,
          options: const ValidationOptions(validateDropped: true));

      // ── Lernstand ───────────────────────────────────────────────────────
      final karte = await db.select(db.leitnerCards).getSingle();
      expect(karte.boxNumber, 4);
      expect(karte.nextReview.toUtc(),
          DateTime.fromMillisecondsSinceEpoch(faelligSek * 1000, isUtc: true));
      expect(karte.lastReview, isNotNull);

      SharedPreferences.setMockInitialValues({});
      final zustand = await UserStateRepository(
              db, await SharedPreferences.getInstance())
          .lesen();
      expect(zustand.leitner['eigen:Feierabend|nomen']!.fach, 4);
      final reise = zustand.kategorien.singleWhere((k) => k.name == 'Reise');
      expect(reise.id, 'eigen:Reise',
          reason: 'alte Listen behalten ihre id (S.6)');
      expect(reise.wortIds, ['eigen:Feierabend|nomen']);
      if (von >= 3) {
        expect(zustand.leitner['adjektiv_stolz']!.fach, 5);
      }
      if (von >= 4) {
        expect(zustand.kategorien.singleWhere((k) => k.id == 'kat_1').wortIds,
            ['adjektiv_stolz']);
      }
      if (von >= 6) {
        expect(zustand.mitgliedschaften.values.single.id, 'eigen:Reise');
      }
    });
  }
}
