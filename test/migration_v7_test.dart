// FILE: test/migration_v7_test.dart
// PHASE: فاز S, Schritt S.6 (2026-09-16)
// PURPOSE: Die Migration auf Fassung 7 an einer ECHTEN Datei prüfen: Eine
//          Datenbank im Stand von Fassung 6 wird nachgebaut, geschlossen und
//          neu geöffnet — genau das, was im Browser eines Nutzers nach dem
//          Update passiert.
//
// Warum das wichtig ist: Bestehende eigene Listen müssen ihre bisherige id
// `eigen:<Name>` behalten. Sonst passten Sicherungen, die Server-Kopie und
// die gespeicherten Ereignisse nicht mehr zu den Listen, und derselbe Name
// auf zwei Geräten würde nach dem Update zu zwei verschiedenen Listen.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/database/app_database.dart';

void main() {
  test('S.6 Migration 6 → 7: bestehende Listen behalten ihre alte id, '
      'doppelte Namen bekommen eine eigene', () async {
    final ordner = Directory.systemTemp.createTempSync('vox_migration_v7_');
    addTearDown(() => ordner.deleteSync(recursive: true));
    final datei = File('${ordner.path}/vox.sqlite');

    // Stand von Fassung 6 nachbauen: heutige Tabellen anlegen, die zwei
    // neuen Spalten samt Index wieder entfernen, Fassung auf 6 setzen.
    final alt = AppDatabase.forTesting(NativeDatabase(datei));
    await alt.customStatement("INSERT INTO user_categories (name) "
        "VALUES ('Reise'), ('Arbeit'), ('Reise')");
    await alt.customStatement('DROP INDEX user_categories_uid');
    await alt.customStatement('ALTER TABLE user_categories DROP COLUMN uid');
    await alt
        .customStatement('ALTER TABLE user_categories DROP COLUMN name_am_ms');
    await alt.customStatement('PRAGMA user_version = 6');
    await alt.close();

    // Neu öffnen ⇒ drift führt onUpgrade(6 → 7) aus.
    final neu = AppDatabase.forTesting(NativeDatabase(datei));
    addTearDown(neu.close);
    final zeilen = await neu.select(neu.userCategories).get();
    zeilen.sort((x, y) => x.id.compareTo(y.id));

    expect(zeilen.map((z) => z.name).toList(), ['Reise', 'Arbeit', 'Reise']);
    expect(zeilen[0].uid, 'eigen:Reise', reason: 'älteste Zeile behält die id');
    expect(zeilen[1].uid, 'eigen:Arbeit');
    expect(zeilen[2].uid, matches(RegExp(r'^eigen:#[0-9a-f]{32}$')),
        reason: 'doppelter Name ⇒ neue feste id, sonst bräche der Index');
    expect(zeilen.every((z) => z.nameAmMs == null), isTrue);
    expect(eigeneListenId(zeilen[1]), 'eigen:Arbeit');

    // Der eindeutige Index steht: eine zweite Zeile mit derselben id scheitert.
    await expectLater(
      neu.customStatement("INSERT INTO user_categories (name, uid) "
          "VALUES ('X', 'eigen:Arbeit')"),
      throwsA(anything),
    );
  });
}
