// FILE: test/leitner_beide_quellen_test.dart
// PHASE: B-13 (2026-09-23) — Leitner-Bereich zeigte Archivkarten nicht
// PURPOSE: Gemeldet von Lukas (iPhone-Test): Ein Wort aus „Wortschatz" wurde
//          „zu Leitner hinzugefügt", der Leitner-Bereich meldete aber keine
//          Karte. Ursache: zwei Tabellen (`LeitnerCards` für App-Wörter,
//          `ArchivLeitner` für Archivkarten), der Bereich las nur die erste.
//          Diese Tests halten fest, dass Zähler, Fächer und Wiederholung
//          BEIDE Quellen sehen und eine Bewertung nur die eigene Karte ändert.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late UserStateRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UserStateRepository(db, await SharedPreferences.getInstance());
  });
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);
    return c;
  }

  Future<int> appWort(String german) => db.into(db.words).insert(
      WordsCompanion.insert(
          german: german, wordType: 'nomen', meaningFa: 'x'));

  test('Archivkarte aus „Wortschatz" erscheint im Leitner-Bereich '
      '(der gemeldete Fehler)', () async {
    await repo.archivLeitnerAufnehmen('verb_helfen', DateTime.now());
    final c = container();

    final eintraege = await c.read(leitnerEintraegeProvider.future);
    expect(eintraege.whereType<ArchivEintrag>().single.wortId, 'verb_helfen');
    expect(await c.read(dueCountProvider.future), 1,
        reason: 'Archivkarten sind sofort nach dem Aufnehmen fällig.');
    expect((await c.read(boxCountsProvider.future))[1], 1);
  });

  test('beide Quellen zusammen: Zähler und Fächer', () async {
    final id = await appWort('Tisch');
    await LeitnerDao(db).addWord(id); // App-Wort: erst morgen fällig
    await repo.archivLeitnerAufnehmen('verb_helfen', DateTime.now());
    final c = container();

    final eintraege = await c.read(leitnerEintraegeProvider.future);
    expect(eintraege.whereType<AppWortEintrag>(), hasLength(1));
    expect(eintraege.whereType<ArchivEintrag>(), hasLength(1));
    expect((await c.read(boxCountsProvider.future))[1], 2);
    expect(await c.read(dueCountProvider.future), 1);
  });

  test('Zähler folgen neuen Aufnahmen von selbst (ohne Auffrischen)',
      () async {
    final c = container();
    final sub = c.listen(leitnerEintraegeProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await c.read(leitnerEintraegeProvider.future), isEmpty);

    await repo.archivLeitnerAufnehmen('verb_helfen', DateTime.now());
    await pumpEventQueue();
    expect(await c.read(leitnerEintraegeProvider.future), hasLength(1));
  });

  group('archivLeitnerBewerten', () {
    final jetzt = DateTime(2026, 9, 23, 12);

    Future<({int fach, DateTime naechste})> stand(String id) async {
      final s = (await repo.archivLesen()).leitner[id]!;
      return (fach: s.fach, naechste: s.naechsteWiederholung!);
    }

    test('gewusst ⇒ ein Fach weiter, Abstand wie bei App-Wörtern', () async {
      await repo.archivLeitnerAufnehmen('verb_helfen', jetzt);
      await repo.archivLeitnerBewerten('verb_helfen',
          gewusst: true, jetzt: jetzt);
      final s = await stand('verb_helfen');
      expect(s.fach, 2);
      expect(s.naechste,
          jetzt.add(Duration(days: LeitnerDao.boxIntervals[1])));
    });

    test('höchstens Fach 5', () async {
      await repo.archivLeitnerAufnehmen('verb_helfen', jetzt);
      for (var i = 0; i < 8; i++) {
        await repo.archivLeitnerBewerten('verb_helfen',
            gewusst: true, jetzt: jetzt);
      }
      expect((await stand('verb_helfen')).fach, 5);
    });

    test('nicht gewusst ⇒ Fach 1, morgen wieder', () async {
      await repo.archivLeitnerAufnehmen('verb_helfen', jetzt);
      await repo.archivLeitnerBewerten('verb_helfen',
          gewusst: true, jetzt: jetzt);
      await repo.archivLeitnerBewerten('verb_helfen',
          gewusst: false, jetzt: jetzt);
      final s = await stand('verb_helfen');
      expect(s.fach, 1);
      expect(s.naechste, jetzt.add(const Duration(days: 1)));
    });

    test('legt nie eine Karte an und ändert keine andere', () async {
      await repo.archivLeitnerAufnehmen('adjektiv_stolz', jetzt);
      await repo.archivLeitnerBewerten('verb_helfen',
          gewusst: true, jetzt: jetzt);
      final z = await repo.archivLesen();
      expect(z.leitner.keys, ['adjektiv_stolz']);
      expect(z.leitner['adjektiv_stolz']!.fach, 1);
    });
  });
}
