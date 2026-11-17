// FILE: test/leitner_stapel_test.dart
// PHASE: X.2 (2026-11-17) — EIN Stapel, Decks, Fortschritt «Wort × Übung»
//        (ersetzt test/leitner_beide_quellen_test.dart: seit X.2 gibt es
//        keine zwei Quellen mehr).
//
// Wächter für die Entscheidungen von Lukas (PHASE_X.md):
//   · ein Wort kann in mehreren Decks liegen, der Fortschritt ist gemeinsam;
//   · Entfernen aus dem Leitner und Löschen eines Decks kosten nie
//     Fortschritt — wieder aufgenommen geht es im selben Fach weiter;
//   · Notizbuch-Decks werden nie wiederholt;
//   · alte Wörter (`eigen:…`) und Archivkarten stehen im selben Stapel.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

void main() {
  late AppDatabase db;
  late LeitnerDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = LeitnerDao(db);
  });
  tearDown(() => db.close());

  Future<Set<String>> imLeitner() async =>
      (await dao.imLeitnerBeobachten().first).toSet();

  test('Leitner-Knopf: rein ⇒ Deck «Leitner» (mit Wiederholung), ohne '
      'Fortschritt — das Wort ist neu', () async {
    await dao.aufnehmen('adjektiv_stolz');
    final deck = (await dao.decks()).single;
    expect(deck.id, standardDeckId);
    expect(deck.modus, deckModusWiederholen);
    expect(await imLeitner(), {'adjektiv_stolz'});
    expect(await dao.fortschritt('adjektiv_stolz', uebungBedeutung), isNull);
    // Zweimal aufnehmen ändert nichts.
    await dao.aufnehmen('adjektiv_stolz');
    expect(await db.select(db.deckWoerter).get(), hasLength(1));
  });

  test('raus und wieder rein: dasselbe Fach (Entfernen kostet nie Fortschritt)',
      () async {
    await dao.aufnehmen('nomen_tisch');
    for (var i = 0; i < 3; i++) {
      await dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true);
    }
    expect((await dao.fortschritt('nomen_tisch', uebungBedeutung))!.fach, 4);

    await dao.entfernen('nomen_tisch');
    expect(await imLeitner(), isEmpty);
    expect((await dao.fortschritt('nomen_tisch', uebungBedeutung))!.fach, 4);

    await dao.aufnehmen('nomen_tisch');
    expect(await imLeitner(), {'nomen_tisch'});
    expect((await dao.fortschritt('nomen_tisch', uebungBedeutung))!.fach, 4);
  });

  test('bewerten: bis ins 7. Fach, dann gelernt; falsch ⇒ Fach 1; von Hand '
      'zurück', () async {
    final jetzt = DateTime.utc(2026, 11, 17);
    for (var i = 0; i < 6; i++) {
      await dao.bewerten('w', uebungBedeutung, gewusst: true, jetzt: jetzt);
    }
    expect((await dao.fortschritt('w', uebungBedeutung))!.fach, 7);
    final raus =
        await dao.bewerten('w', uebungBedeutung, gewusst: true, jetzt: jetzt);
    expect(raus.gelernt, isTrue);
    expect((await dao.fortschritt('w', uebungBedeutung))!.naechsteWiederholung,
        isNull);

    await dao.zuruecklegen('w', uebungBedeutung, jetzt: jetzt);
    expect((await dao.fortschritt('w', uebungBedeutung))!.fach, 1);

    await dao.bewerten('w', uebungBedeutung, gewusst: true, jetzt: jetzt);
    await dao.bewerten('w', uebungBedeutung, gewusst: false, jetzt: jetzt);
    expect((await dao.fortschritt('w', uebungBedeutung))!.fach, 1);
  });

  test('jede Übung hat ihr eigenes Fach', () async {
    await dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true);
    await dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true);
    await dao.bewerten('nomen_tisch', uebungArtikel, gewusst: false);
    expect((await dao.fortschritt('nomen_tisch', uebungBedeutung))!.fach, 3);
    expect((await dao.fortschritt('nomen_tisch', uebungArtikel))!.fach, 1);
    expect(await dao.fortschritt('nomen_tisch', uebungSchreiben), isNull);
    expect((await dao.fortschrittBeobachten(uebungArtikel).first).keys,
        ['nomen_tisch']);
  });

  test('ein Wort in zwei Decks: einmal im Stapel; Notizbuch-Deck zählt nicht',
      () async {
    final notiz = await dao.deckAnlegen('Reise');
    expect(notiz.modus, deckModusNotiz);
    expect(notiz.id, matches(RegExp(r'^eigen:#[0-9a-f]{32}$')));
    final lernen =
        await dao.deckAnlegen('A1', modus: deckModusWiederholen);
    await dao.wortSetzen(notiz.id, 'nomen_koffer', true);
    expect(await imLeitner(), isEmpty, reason: 'Notizbuch ⇒ nie Wiederholung');

    await dao.aufnehmen('nomen_tisch');
    await dao.wortSetzen(lernen.id, 'nomen_tisch', true);
    expect(await dao.imLeitnerBeobachten().first, ['nomen_tisch']);
    expect(await dao.deckIdsVonWort('nomen_tisch'),
        {standardDeckId, lernen.id});

    // «raus aus dem Leitner» verlässt jedes Deck mit Wiederholung.
    await dao.wortSetzen(notiz.id, 'nomen_tisch', true);
    await dao.entfernen('nomen_tisch');
    expect(await imLeitner(), isEmpty);
    expect(await dao.deckIdsVonWort('nomen_tisch'), {notiz.id});
  });

  test('Deck löschen: Wörter verlassen es, Fortschritt bleibt, Subdecks '
      'rücken auf', () async {
    final oben = await dao.deckAnlegen('Deutsch', modus: deckModusWiederholen);
    final mitte = await dao.deckAnlegen('A1',
        elternId: oben.id, modus: deckModusWiederholen);
    final unten = await dao.deckAnlegen('Lektion 1',
        elternId: mitte.id, modus: deckModusWiederholen);
    await dao.wortSetzen(mitte.id, 'nomen_tisch', true);
    await dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true);

    await dao.deckLoeschen(mitte.id);
    expect(await dao.deck(mitte.id), isNull);
    expect((await dao.deck(unten.id))!.elternId, oben.id);
    expect(await imLeitner(), isEmpty);
    expect((await dao.fortschritt('nomen_tisch', uebungBedeutung))!.fach, 2);
  });

  test('jede Handlung wird als Ereignis festgehalten (für den Abgleich)',
      () async {
    final deck = await dao.deckAnlegen('Reise');
    await dao.wortSetzen(deck.id, 'nomen_koffer', true);
    await dao.wortSetzen(deck.id, 'nomen_koffer', false);
    await dao.deckLoeschen(deck.id);
    final m = {
      for (final e in await db.select(db.mitgliedschaften).get())
        '${e.art}/${e.wort}': e.drin,
    };
    expect(m, {'$artListe/': false, '$artListenwort/nomen_koffer': false});
  });

  test('Provider: Stapel aus Mitgliedschaft und Fortschritt, Zähler 1–7, '
      'gelernt getrennt', () async {
    final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);
    final frueher = DateTime.now().subtract(const Duration(days: 1));
    final spaeter = DateTime.now().add(const Duration(days: 5));

    await dao.aufnehmen('neu_wort'); //                       neu ⇒ Fach 1, fällig
    await dao.aufnehmen('eigen:gehen|verb'); //              altes Wort
    await dao.fortschrittSetzen(
        uebungBedeutung,
        LeitnerStand(
            wortId: 'eigen:gehen|verb', fach: 3, naechsteWiederholung: frueher));
    await dao.aufnehmen('adjektiv_stolz');
    await dao.fortschrittSetzen(
        uebungBedeutung,
        LeitnerStand(
            wortId: 'adjektiv_stolz', fach: 5, naechsteWiederholung: spaeter));
    await dao.aufnehmen('verb_helfen');
    await dao.fortschrittSetzen(uebungBedeutung,
        const LeitnerStand(wortId: 'verb_helfen', fach: leitnerGelerntFach));
    // Fortschritt ohne Mitgliedschaft zählt nicht zum Stapel.
    await dao.fortschrittSetzen(uebungBedeutung,
        const LeitnerStand(wortId: 'nicht_drin', fach: 2));

    final eintraege = await c.read(leitnerEintraegeProvider.future);
    expect(eintraege.map((e) => e.wortId).toSet(),
        {'neu_wort', 'eigen:gehen|verb', 'adjektiv_stolz', 'verb_helfen'});
    expect(eintraege.first.wortId, 'neu_wort', reason: 'Fach 1 zuerst');
    expect(eintraege.singleWhere((e) => e.istAltesWort).fach, 3);

    final faecher = await c.read(boxCountsProvider.future);
    expect(faecher.keys, [1, 2, 3, 4, 5, 6, 7]);
    expect(faecher, {1: 1, 2: 0, 3: 1, 4: 0, 5: 1, 6: 0, 7: 0});
    expect(await c.read(gelerntCountProvider.future), 1);
    expect(await c.read(dueCountProvider.future), 2,
        reason: 'neu + überfällig; nicht: später fällig, gelernt');
    expect(await c.read(isInLeitnerProvider('adjektiv_stolz').future), isTrue);
    expect(await c.read(isInLeitnerProvider('nicht_drin').future), isFalse);
  });
}
