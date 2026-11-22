// FILE: test/deck_modus_erben_test.dart
// PURPOSE: Wächter für die Entscheidung Lukas 2026-11-22: Subdecks folgen
//          dem Modus des Decks darüber (Wiederholung/Notizbuch), bis man
//          eines von Hand umstellt.
//
//   · Rechnung (effektiveDeckModi): Kette über mehrere Ebenen, eigener Modus
//     gewinnt, oberste Ebene mit «erben» = Notizbuch, Kreis/fehlendes
//     Eltern-Deck ohne Absturz;
//   · Migration 9 → 10: Subdeck mit GLEICHEM Modus wie das Eltern-Deck ⇒
//     «erben» (jetzt keine Änderung, künftig folgt es), mit anderem Modus ⇒
//     bleibt;
//   · Ablage: Wort in einem erbenden Subdeck ist im Leitner, sobald das
//     Eltern-Deck auf Wiederholung steht — und wieder nicht, wenn es
//     zurückgestellt wird; von Hand umgestellt ⇒ folgt nicht mehr; «raus»
//     entfernt auch aus erbenden Subdecks; Standard-Subdecks entstehen
//     erbend;
//   · Sicherung: «erben» übersteht den Text, Leitner-Menge rechnet mit dem
//     Baum; unbekannter Modus ⇒ Notizbuch.
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart'
    show databaseProvider;

import 'generated_migrations/schema.dart';

typedef _D = ({String id, String? eltern, String modus});

Map<String, String> _modi(List<_D> d) => effektiveDeckModi(d,
    id: (x) => x.id, eltern: (x) => x.eltern, modus: (x) => x.modus);

void main() {
  group('Rechnung', () {
    test('erbt über mehrere Ebenen; eigener Modus gewinnt', () {
      final m = _modi([
        (id: 'a', eltern: null, modus: deckModusWiederholen),
        (id: 'b', eltern: 'a', modus: deckModusErben),
        (id: 'c', eltern: 'b', modus: deckModusErben),
        (id: 'd', eltern: 'b', modus: deckModusNotiz),
        (id: 'e', eltern: 'd', modus: deckModusErben),
      ]);
      expect(m, {
        'a': deckModusWiederholen,
        'b': deckModusWiederholen,
        'c': deckModusWiederholen,
        'd': deckModusNotiz,
        'e': deckModusNotiz,
      });
    });

    test('oberste Ebene, fehlendes Eltern-Deck und Kreis ⇒ Notizbuch', () {
      final m = _modi([
        (id: 'top', eltern: null, modus: deckModusErben),
        (id: 'waise', eltern: 'gibtsnicht', modus: deckModusErben),
        (id: 'x', eltern: 'y', modus: deckModusErben),
        (id: 'y', eltern: 'x', modus: deckModusErben),
      ]);
      expect(m.values.toSet(), {deckModusNotiz});
      expect(m.length, 4);
    });
  });

  group('Migration 9 → 10', () {
    late SchemaVerifier verifier;
    setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

    test('gleicher Modus wie das Eltern-Deck ⇒ erben; anderer bleibt', () async {
      final schema = await verifier.schemaAt(9);
      schema.rawDatabase.execute("INSERT INTO decks (id, name, eltern_id, modus) "
          "VALUES ('a', 'A', NULL, 'wiederholen'), "
          "('a1', 'A1', 'a', 'wiederholen'), "
          "('a2', 'A2', 'a', 'notiz'), "
          "('a2x', 'A2x', 'a2', 'notiz'), "
          "('n', 'N', NULL, 'notiz'), "
          "('n1', 'N1', 'n', 'notiz'), "
          "('w', 'Waise', 'weg', 'wiederholen')");
      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 10);

      final roh = {for (final d in await LeitnerDao(db).decks()) d.id: d.modus};
      expect(roh, {
        'a': deckModusWiederholen,
        'a1': deckModusErben,
        'a2': deckModusNotiz, // bewusst anders gestellt ⇒ bleibt
        'a2x': deckModusErben,
        'n': deckModusNotiz,
        'n1': deckModusErben,
        'w': deckModusWiederholen, // Eltern-Deck fehlt ⇒ bleibt
      });
      // Jetzt ändert sich nichts am wirklichen Modus.
      final m = LeitnerDao.modi(await LeitnerDao(db).decks());
      expect([m['a1'], m['a2'], m['a2x'], m['n1']],
          [deckModusWiederholen, deckModusNotiz, deckModusNotiz, deckModusNotiz]);
    });
  });

  group('Ablage', () {
    late AppDatabase db;
    late LeitnerDao dao;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = LeitnerDao(db);
    });
    tearDown(() => db.close());

    test('erbendes Subdeck folgt dem Eltern-Deck; von Hand ⇒ eigener Modus',
        () async {
      final eltern = await dao.deckAnlegen('Möbel', modus: deckModusNotiz);
      final sub = await dao.deckAnlegen('Küche',
          elternId: eltern.id, modus: deckModusErben);
      await dao.wortSetzen(sub.id, 'nomen_tisch', true);
      expect(await dao.istImLeitner('nomen_tisch'), isFalse);

      await dao.deckEinstellen(eltern.id, modus: deckModusWiederholen);
      expect(await dao.istImLeitner('nomen_tisch'), isTrue);
      expect(await dao.imLeitnerBeobachten().first, ['nomen_tisch']);

      // Von Hand umgestellt ⇒ folgt nicht mehr.
      await dao.deckEinstellen(sub.id, modus: deckModusNotiz);
      expect(await dao.istImLeitner('nomen_tisch'), isFalse);
      await dao.deckEinstellen(eltern.id, modus: deckModusNotiz);
      await dao.deckEinstellen(eltern.id, modus: deckModusWiederholen);
      expect(await dao.istImLeitner('nomen_tisch'), isFalse);

      // «Wie das Deck darüber» ⇒ folgt wieder.
      await dao.deckEinstellen(sub.id, modus: deckModusErben);
      expect(await dao.istImLeitner('nomen_tisch'), isTrue);

      // Leitner-Knopf «raus» nimmt es auch aus dem erbenden Subdeck.
      await dao.entfernen('nomen_tisch');
      expect(await dao.istImLeitner('nomen_tisch'), isFalse);
    });

    test('Standard-Subdecks entstehen erbend, Gruppen als Notizbuch', () async {
      await dao.standardDecksAnlegen([
        (id: 'std:niveau', name: 'Niveau', eltern: null, ordnung: 1000),
        (id: 'std:niveau:a1', name: 'A1', eltern: 'std:niveau', ordnung: 0),
      ]);
      expect((await dao.deck('std:niveau'))!.modus, deckModusNotiz);
      expect((await dao.deck('std:niveau:a1'))!.modus, deckModusErben);
    });

    test('Provider: Rechner und Modus-Anzeige nutzen den wirklichen Modus',
        () async {
      final eltern =
          await dao.deckAnlegen('Reise', modus: deckModusWiederholen);
      final sub = await dao.deckAnlegen('Hotel',
          elternId: eltern.id, modus: deckModusErben);
      await dao.wortSetzen(sub.id, 'nomen_zimmer', true);
      final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(c.dispose);
      expect((await c.read(deckModiProvider.future))[sub.id],
          deckModusWiederholen);
      final r = await c.read(deckRechnerProvider.future);
      expect(r.sitzung(sub.id), ['nomen_zimmer']);
      expect(await c.read(isInLeitnerProvider('nomen_zimmer').future), isTrue);
    });
  });

  group('Sicherung', () {
    test('«erben» übersteht den Text; Leitner-Menge rechnet mit dem Baum', () {
      const z = NutzerZustand(kategorien: [
        KategorieStand(id: 'a', name: 'A', modus: deckModusWiederholen),
        KategorieStand(
            id: 'a1',
            name: 'A1',
            eltern: 'a',
            modus: deckModusErben,
            wortIds: ['nomen_tisch']),
      ]);
      final zurueck = NutzerZustand.vonJson(z.toJson());
      expect(zurueck.kategorien.last.modus, deckModusErben);
      expect(zurueck.imLeitner, {'nomen_tisch'});
      expect(
          KategorieStand.vonJson(const {'id': 'x', 'name': 'X', 'modus': 'quatsch'})
              .modus,
          deckModusNotiz);
    });
  });
}
