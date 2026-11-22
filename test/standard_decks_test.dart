// FILE: test/standard_decks_test.dart
// PHASE: X.4b (2026-11-17) — Standard-Decks (Entscheidung Lukas Nr. 16)
//
// Wächter:
//   · Rechnung: Niveau / VOX-Bücher / Wortart / Berufe, je Subdeck nur mit
//     Wörtern; Karten UND alte Wörter; keine Decks für «anstößig»/«zeitlich»;
//   · an den ECHTEN Karten: jedes Standard-Deck hat genau die Wörter, die
//     der gleichnamige Filter in «Alle Wörter» zeigt (eine Regel, zwei Orte);
//   · Ablage: fehlende werden angelegt (als Notizbuch), Gelöschte bleiben
//     gelöscht, Zurückholen bringt Deck und Subdecks wieder, vom Nutzer
//     Geändertes bleibt;
//   · Rechner/Leitner: Wörter aus den Daten zählen; ein auf «Wiederholung»
//     gestelltes Standard-Deck bringt seine Wörter in den Leitner;
//   · Lektionen (Wunsch Lukas 2026-11-22): je 20 Wörter, ab 10 Lektionen in
//     Teilen zu 10; FEST — neue Wörter ändern alte Lektionen nie, sie kommen
//     in die letzte oder eine neue; ein Wort in mehreren Filtern steht in
//     jedem passenden Deck; jede Karte steht in der festen Reihenfolge;
//   · virtuelle Lektionen: erben den Modus, Löschen/Zurückholen, rücken
//     beim Löschen des Eltern-Decks hoch.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/leitner/data/standard_decks.dart';
import 'package:vox/features/leitner/data/wort_reihenfolge.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';
import 'package:vox/features/wortschatz/data/wortschatz_filter.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

Map<String, dynamic> _k(String id, String wortart, String niveau,
        [List<String>? berufe]) =>
    {
      'id': id,
      'wortart': wortart,
      'niveau': niveau,
      'berufe': ?berufe,
    };

/// Wörter eines Standard-Decks = die seiner Lektionen, in Reihenfolge.
List<String> _woerter(StandardDecks s, String deck) => <String>[
      for (final e in s.woerter.entries)
        if (e.key.startsWith('$deck:')) ...e.value,
    ];

/// [n] Nomen auf A1, ids n000, n001, ….
List<Map<String, dynamic>> _viele(int n, [int ab = 0]) => [
      for (var i = ab; i < ab + n; i++)
        _k('n${i.toString().padLeft(3, '0')}', 'nomen', 'A1'),
    ];

StandardDecks _beispiel() => standardDecksBerechnen(
      reihenfolge: const {
        'nomen_tisch': 0,
        'nomen_spritze': 1,
        'verb_gehen': 2,
        'adjektiv_vulgaer': 3,
      },
      karten: [
        _k('nomen_tisch', 'nomen', 'A1'),
        _k('nomen_spritze', 'nomen', 'B1', ['pflege_medizin']),
        _k('verb_gehen', 'verb', 'A1'),
        _k('adjektiv_vulgaer', 'adjektiv', 'C2'),
      ],
      altWoerter: const [
        (
          wortId: 'eigen:Feierabend|nomen',
          niveau: 'a2',
          wortart: 'nomen',
          ausApp: false,
        ),
      ],
      buecher: const [
        (id: 'konnektoren', name: 'Konnektoren', woerter: ['nomen_tisch']),
        (id: 'leer', name: 'Leeres Buch', woerter: []),
      ],
    );

void main() {
  group('Rechnung', () {
    test('Gruppen und Subdecks nur mit Wörtern; Eltern vor Kindern', () {
      final s = _beispiel();
      expect([for (final d in s.decks) if (!d.virtuell) d.id], [
        'std:niveau',
        'std:niveau:a1',
        'std:niveau:a2',
        'std:niveau:b1',
        'std:niveau:c2',
        'std:buch',
        'std:buch:konnektoren',
        'std:wortart',
        'std:wortart:nomen',
        'std:wortart:verb',
        'std:wortart:adjektiv',
        'std:beruf',
        'std:beruf:pflege_medizin',
      ]);
      final namen = {for (final d in s.decks) d.id: d.name};
      expect(namen['std:niveau:a1'], 'A1');
      expect(namen['std:buch:konnektoren'], 'Konnektoren');
      expect(namen['std:wortart:nomen'], 'Nomen');
      expect(namen['std:beruf:pflege_medizin'], 'Medizin und Pflege');
      expect(s.decks.where((d) => d.eltern == null).every((d) => d.ordnung >= 1000),
          isTrue,
          reason: 'eigene Decks (Ordnung 0) stehen oben');
    });

    test('Wörter: Karten und alte Wörter, Bücher, Berufe', () {
      final s = _beispiel();
      List<String> w(String d) => _woerter(s, d);
      expect(w('std:niveau:a1'), ['nomen_tisch', 'verb_gehen']);
      expect(w('std:niveau:a2'), ['eigen:Feierabend|nomen']);
      expect(w('std:wortart:nomen'),
          ['nomen_tisch', 'nomen_spritze', 'eigen:Feierabend|nomen']);
      expect(w('std:buch:konnektoren'), ['nomen_tisch']);
      expect(w('std:beruf:pflege_medizin'), ['nomen_spritze']);
      expect(
          s.woerter.keys
              .any((k) => k.contains('anstoessig') || k.contains('zeitlich')),
          isFalse);
      expect(s.woerter.keys.every(istStandardLektion), isTrue,
          reason: 'Wörter stehen nur in Lektionen');
      // Ein Wort in mehreren Filtern ⇒ in jedem passenden Deck.
      expect(s.gruppen['nomen_spritze'], {
        'std:niveau:b1',
        'std:wortart:nomen',
        'std:beruf:pflege_medizin',
      });
      expect(istStandardDeck('std:niveau:a1'), isTrue);
      expect(istStandardDeck(standardDeckId), isFalse);
    });

    test('echte Karten: jedes Standard-Deck = der gleichnamige Filter', () {
      final liste = File(vokabIndexStueckeDatei);
      if (!liste.existsSync()) {
        markTestSkipped('Wortindex nicht gebaut (dart run tool/vokab_index.dart)');
        return;
      }
      final dateien = <String, String>{
        vokabIndexStueckeDatei: liste.readAsStringSync(),
        for (final p in vokabIndexStueckeLesen(liste.readAsStringSync()))
          p: File(p).readAsStringSync(),
      };
      final karten = vokabIndexLesen(dateien);
      final s = standardDecksBerechnen(
          karten: karten, altWoerter: const [], buecher: const []);
      void gleich(String deck, WortschatzFilter f) {
        final pruefer = f.kartenPruefer();
        final erwartet = {
          for (final k in karten)
            if (pruefer(k)) k['id'] as String,
        };
        expect(_woerter(s, deck).toSet(), erwartet, reason: deck);
      }

      for (final n in wortschatzNiveaus) {
        gleich('std:niveau:$n', WortschatzFilter(niveaus: {n}));
      }
      for (final d in s.decks.where((d) => d.eltern == 'std:wortart')) {
        gleich(d.id, WortschatzFilter(wortarten: {d.id.split(':').last}));
      }
      for (final d in s.decks.where((d) => d.eltern == 'std:beruf')) {
        gleich(d.id, WortschatzFilter(berufe: {d.id.split(':').last}));
      }
      expect(s.decks, isNotEmpty);
      // Ganz ohne JSON-Umweg: der Text ist lesbar (Wächter gegen Format).
      expect(jsonDecode(dateien[vokabIndexStueckeDatei]!), isA<Map>());

      // Wächter: jede Karte steht in der festen Reihenfolge — sonst fehlt im
      // Wort-Ablauf der Schritt tool/wort_reihenfolge.dart.
      final reihenfolge = wortReihenfolgeLesen(
          File(wortReihenfolgeAsset).readAsStringSync());
      final fehlen = <String>[
        for (final k in karten)
          if (!reihenfolge.containsKey(k['id'])) k['id'] as String,
      ];
      expect(fehlen, isEmpty,
          reason: 'dart tool/wort_reihenfolge.dart ausführen');
    });
  });

  group('Lektionen', () {
    test('je 20 Wörter; Name «Lektion n»; unter dem Deck', () {
      final s = standardDecksBerechnen(
          karten: _viele(45), altWoerter: const [], buecher: const []);
      final lektionen =
          s.decks.where((d) => d.eltern == 'std:niveau:a1').toList();
      expect([for (final l in lektionen) l.name],
          ['Lektion 1', 'Lektion 2', 'Lektion 3']);
      expect(lektionen.every((l) => l.virtuell), isTrue);
      expect([for (final l in lektionen) s.woerter[l.id]!.length],
          [20, 20, 5]);
      expect(s.woerter['std:niveau:a1:l1']!.first, 'n000');
    });

    test('mehr als 10 Lektionen ⇒ Teile zu 10', () {
      final s = standardDecksBerechnen(
          karten: _viele(250), altWoerter: const [], buecher: const []);
      final teile = s.decks.where((d) => d.eltern == 'std:niveau:a1').toList();
      expect([for (final t in teile) t.name],
          ['Teil 1 (Lektion 1–10)', 'Teil 2 (Lektion 11–13)']);
      expect(s.decks.where((d) => d.eltern == teile[1].id).length, 3);
      expect(s.decks.firstWhere((d) => d.name == 'Lektion 13').eltern,
          teile[1].id);
      expect(s.woerter[s.decks.firstWhere((d) => d.name == 'Lektion 13').id],
          hasLength(10));
    });

    test('fest: neue Wörter ändern alte Lektionen nie', () {
      Map<String, int> alsMap(List<String> ids) =>
          {for (var i = 0; i < ids.length; i++) ids[i]: i};
      final alt = _viele(30);
      var liste = wortReihenfolgeVerlaengern(const [], alt);
      final vorher = standardDecksBerechnen(
          karten: alt,
          altWoerter: const [],
          buecher: const [],
          reihenfolge: alsMap(liste));
      // Neues Wort, das alphabetisch VOR allen steht — trotzdem hinten.
      final neu = [...alt, _k('a_neu', 'nomen', 'A1')];
      liste = wortReihenfolgeVerlaengern(liste, neu);
      final nachher = standardDecksBerechnen(
          karten: neu,
          altWoerter: const [],
          buecher: const [],
          reihenfolge: alsMap(liste));
      expect(nachher.woerter['std:niveau:a1:l1'],
          vorher.woerter['std:niveau:a1:l1']);
      expect(nachher.woerter['std:niveau:a1:l2']!.last, 'a_neu');
      expect(nachher.gruppen['a_neu'],
          {'std:niveau:a1', 'std:wortart:nomen'});
    });

    test('Reihenfolge-Datei: nur anhängen, lesbar', () {
      final r = wortReihenfolgeVerlaengern(
          const ['b'], [_k('a', 'nomen', 'A1'), _k('b', 'nomen', 'A1')]);
      expect(r, ['b', 'a']);
      expect(wortReihenfolgeLesen(wortReihenfolgeText(r)), {'b': 0, 'a': 1});
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

    List<({String id, String name, String? eltern, int ordnung})> soll() => [
          for (final d in _beispiel().decks)
            if (!d.virtuell)
              (id: d.id, name: d.name, eltern: d.eltern, ordnung: d.ordnung),
        ];

    test('anlegen: Gruppen Notizbuch, Subdecks erben (= Notizbuch), mehrfach '
        'ausführbar, ohne Ereignis', () async {
      expect(await dao.standardDecksAnlegen(soll()), 13);
      expect(await dao.standardDecksAnlegen(soll()), 0);
      final decks = await dao.decks();
      expect(
          decks.every((d) =>
              d.modus == (d.elternId == null ? deckModusNotiz : deckModusErben)),
          isTrue);
      expect(LeitnerDao.modi(decks).values.toSet(), {deckModusNotiz});
      expect(decks.firstWhere((d) => d.id == 'std:niveau:a1').elternId,
          'std:niveau');
      expect(await db.select(db.mitgliedschaften).get(), isEmpty);
    });

    test('gelöscht bleibt gelöscht; Zurückholen bringt Deck und Subdecks '
        'wieder darunter', () async {
      await dao.standardDecksAnlegen(soll());
      await dao.deckLoeschen('std:niveau');
      expect((await dao.deck('std:niveau:a1'))!.elternId, isNull,
          reason: 'Subdecks rücken beim Löschen hoch');
      expect(await dao.standardDecksAnlegen(soll()), 0);
      expect(await dao.deck('std:niveau'), isNull);
      expect(await dao.geloeschteDecks(), {'std:niveau'});

      await dao.standardDeckZurueckholen(
          (id: 'std:niveau', name: 'Niveau', eltern: null, ordnung: 1000),
          kinder: ['std:niveau:a1', 'std:niveau:a2']);
      expect(await dao.deck('std:niveau'), isNotNull);
      expect((await dao.deck('std:niveau:a1'))!.elternId, 'std:niveau');
      expect(await dao.geloeschteDecks(), isEmpty);
    });

    test('vom Nutzer Geändertes bleibt (Name, Modus)', () async {
      await dao.standardDecksAnlegen(soll());
      await dao.deckUmbenennen('std:niveau:a1', 'Mein A1');
      await dao.deckEinstellen('std:niveau:a1', modus: deckModusWiederholen);
      await dao.standardDecksAnlegen(soll());
      final a1 = (await dao.deck('std:niveau:a1'))!;
      expect((a1.name, a1.modus), ('Mein A1', deckModusWiederholen));
    });

    test('Rechner und Leitner: Wörter aus den Daten zählen; auf Wiederholung '
        'gestellt ⇒ im Leitner und in der Sitzung', () async {
      final c = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        standardDecksProvider.overrideWith((ref) async => _beispiel()),
      ]);
      addTearDown(c.dispose);
      await c.read(standardDecksEinrichtenProvider.future);
      var r = await c.read(deckRechnerProvider.future);
      expect(r.zaehler('std:niveau').woerter, 5);
      expect(r.zaehler('std:niveau:a1').woerter, 2);
      expect(r.sitzungAlle(), isEmpty, reason: 'alles Notizbuch');
      expect(await c.read(isInLeitnerProvider('nomen_tisch').future), isFalse);

      await dao.deckEinstellen('std:niveau:a1', modus: deckModusWiederholen);
      await dao.wortSetzen('std:niveau:a1', 'nomen_tisch', true); // doppelt
      await Future<void>.delayed(const Duration(milliseconds: 50));
      r = await c.read(deckRechnerProvider.future);
      expect(r.sitzung('std:niveau:a1'), ['nomen_tisch', 'verb_gehen'],
          reason: 'jedes Wort einmal');
      expect(await c.read(isInLeitnerProvider('verb_gehen').future), isTrue);
      expect(await c.read(deckIdsVonWortProvider('verb_gehen').future),
          containsAll(['std:niveau:a1', 'std:wortart:verb']));
      expect(
          await c.read(standardDeckIdsVonWortProvider('nomen_tisch').future),
          containsAll(['std:niveau:a1', 'std:buch:konnektoren']));
    });

    test('virtuelle Lektionen: erben den Modus, ohne Zeile; Löschen und '
        'Zurückholen; rücken beim Löschen des Eltern-Decks hoch', () async {
      final c = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        standardDecksProvider.overrideWith((ref) async => _beispiel()),
      ]);
      addTearDown(c.dispose);
      await c.read(standardDecksEinrichtenProvider.future);
      await c.read(geloeschteDeckIdsProvider.future);
      Future<Deck?> l1() async => (await c.read(deckListeProvider.future))
          .where((d) => d.id == 'std:niveau:a1:l1')
          .firstOrNull;
      Future<void> warten() =>
          Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await dao.deck('std:niveau:a1:l1'), isNull, reason: 'keine Zeile');
      expect((await l1())!.elternId, 'std:niveau:a1');
      Future<String?> modusL1() async =>
          (await c.read(deckModiProvider.future))['std:niveau:a1:l1'];
      expect((await l1())!.modus, deckModusErben);
      expect(await modusL1(), deckModusNotiz);

      await dao.deckEinstellen('std:niveau:a1', modus: deckModusWiederholen);
      await warten();
      expect(await modusL1(), deckModusWiederholen);
      // Lukas 2026-11-22: die GRUPPE auf Wiederholung ⇒ alle darunter auch.
      await dao.deckEinstellen('std:niveau:a1', modus: deckModusErben);
      await dao.deckEinstellen('std:niveau', modus: deckModusWiederholen);
      await warten();
      expect(await modusL1(), deckModusWiederholen);
      expect(await c.read(isInLeitnerProvider('verb_gehen').future), isTrue);
      await dao.deckEinstellen('std:niveau', modus: deckModusNotiz);
      await dao.deckEinstellen('std:niveau:a1', modus: deckModusWiederholen);
      await warten();

      await dao.deckLoeschen('std:niveau:a1:l1');
      await warten();
      expect(await l1(), isNull);
      expect(await c.read(geloeschteStandardDecksProvider.future),
          contains(isA<StandardDeck>()
              .having((d) => d.id, 'id', 'std:niveau:a1:l1')));
      await dao.virtuellesDeckZurueckholen('std:niveau:a1:l1');
      await warten();
      expect(await l1(), isNotNull);

      await dao.deckLoeschen('std:niveau:a1');
      await warten();
      expect((await l1())!.elternId, 'std:niveau');
      expect(await modusL1(), deckModusNotiz, reason: 'erbt von Niveau');

      // Anpassen legt erst die Zeile an; danach gilt sie.
      await dao.deckSicherstellen((await l1())!);
      await dao.deckUmbenennen('std:niveau:a1:l1', 'Meine Lektion');
      await warten();
      expect((await l1())!.name, 'Meine Lektion');
    });
  });
}
