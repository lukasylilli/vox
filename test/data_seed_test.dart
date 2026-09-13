// Regression: Re-Seed auf bereits befüllter DB (Flag-Bump v1→v2) darf NICHT
// crashen — der alte _ensureBook-Upsert warf «UNIQUE constraint failed:
// books.name» und die App starb vor runApp (weißer Bildschirm).
// Prüft außerdem den v2-Grund: «Verben mit Präpositionen» bekommt meaningEn.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/services/data_seed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Seeding ist idempotent: zweiter Lauf auf voller DB crasht nicht',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // 1. Lauf — frische DB (wie Erstinstallation).
    SharedPreferences.setMockInitialValues({});
    await DataSeedService(db).seedIfNeeded();
    final buecher1 = await db.select(db.books).get();
    expect(buecher1, hasLength(4));

    // 2. Lauf — Flag zurückgesetzt (= Flag-Bump), DB ist schon voll.
    SharedPreferences.setMockInitialValues({});
    await DataSeedService(db).seedIfNeeded(); // warf früher SqliteException

    final buecher2 = await db.select(db.books).get();
    expect(buecher2, hasLength(4)); // keine Duplikate

    // v2-Grund: Präpositionen-Wörter haben jetzt meaningEn.
    final praepBuch = buecher2
        .firstWhere((b) => b.name == 'Verben mit Präpositionen');
    final link = await (db.select(db.wordBooks)
          ..where((t) => t.bookId.equals(praepBuch.id))
          ..limit(1))
        .getSingle();
    final wort = await (db.select(db.words)
          ..where((t) => t.id.equals(link.wordId)))
        .getSingle();
    expect(wort.meaningEn, isNotNull);
    expect(wort.meaningEn, isNotEmpty);
  });
}
