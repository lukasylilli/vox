// FILE: test/vokab_suche_test.dart
// PHASE: Wunsch Lukas (2026-09-30): Suche UND Antippen finden ein Wort auch
//        in einer gebeugten Form — für jede Wortart («aalartige», «Häuser»,
//        «ging» ⇒ Karte). Prüft [vokabSucheProvider] und
//        [vokabTrefferZusammen] (das Antippen prüft vokab_formen_test.dart).
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/wort/altwort_formen.dart';
import 'package:vox/core/wort/klick_wort_provider.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';

Map<String, dynamic> _karte(String id, String wort, String wortart,
        {List<String> fa = const []}) =>
    {
      'id': id,
      'wort': wort,
      'wortart': wortart,
      'uebersetzung': {'fa': fa, 'en': <String>[]},
    };

ProviderContainer _container(
  List<Map<String, dynamic>> index,
  Map<String, List<String>> formen,
) {
  final c = ProviderContainer(overrides: [
    vokabIndexProvider.overrideWith((ref) async => index),
    vokabFormenStueckeProvider.overrideWith(
        (ref) async => {for (final f in formen.keys) vokabFormenDatei(f)}),
    vokabFormenStueckProvider.overrideWith((ref, datei) async => {
          for (final e in formen.entries)
            if (vokabFormenDatei(e.key) == datei) e.key: e.value,
        }),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  final gehen = _karte('verb_gehen', 'gehen', 'verb', fa: ['رفتن']);
  final haus = _karte('nomen_haus', 'das Haus', 'nomen', fa: ['خانه']);
  final aalartig = _karte('adjektiv_aalartig', 'aalartig', 'adjektiv');
  final index = [aalartig, gehen, haus];
  final formen = {
    'ging': ['verb_gehen'],
    'häuser': ['nomen_haus'],
    'aalartige': ['adjektiv_aalartig'],
  };

  test('gebeugte Form findet die Karte — Verb, Nomen, Adjektiv', () async {
    final c = _container(index, formen);
    Future<List<String>> ids(String q) async => [
          for (final k in await c.read(vokabSucheProvider(q).future))
            k['id'] as String,
        ];
    expect(await ids('ging'), ['verb_gehen']);
    expect(await ids('häuser'), ['nomen_haus']);
    expect(await ids('aalartige'), ['adjektiv_aalartig']);
  });

  test('Grundform und Übersetzung finden weiter wie bisher', () async {
    final c = _container(index, formen);
    final treffer = await c.read(vokabSucheProvider('geh').future);
    expect(treffer.map((k) => k['id']), ['verb_gehen']);
    final fa = await c.read(vokabSucheProvider('خانه').future);
    expect(fa.map((k) => k['id']), ['nomen_haus']);
  });

  test('unbekannte Form ⇒ keine erfundenen Treffer', () async {
    final c = _container(index, formen);
    expect(await c.read(vokabSucheProvider('xyzq').future), isEmpty);
    expect(await c.read(vokabSucheProvider('   ').future), isEmpty);
  });

  test('vokabTrefferZusammen: Form zuerst, jede Karte nur einmal', () {
    final z = vokabTrefferZusammen([gehen], [haus, gehen]);
    expect(z.map((k) => k['id']), ['verb_gehen', 'nomen_haus']);
  });

  group('alte Wörter (drift) — gebeugte Formen', () {
    final konj = jsonEncode(
        {'inf': 'empfehlen', 'präs': 'empfiehlt', 'prät': 'empfahl',
         'pp': 'hat empfohlen'});

    test('altwortFormen: Verb (erstes/letztes Wort) und Nomen (Plural, -n)',
        () {
      expect(
          altwortFormen(wortart: 'verb', german: 'empfehlen',
              conjugationJson: konj),
          {'empfiehlt', 'empfahl', 'empfohlen'});
      expect(
          altwortFormen(wortart: 'verb', german: 'zurückgeben',
              conjugationJson: jsonEncode({'präs': 'gibt zurück',
                  'prät': 'gab zurück', 'pp': 'hat zurückgegeben'})),
          {'gibt', 'gab', 'zurückgegeben'});
      expect(altwortFormen(wortart: 'nomen', german: 'Haus', plural: 'die Häuser'),
          {'häuser', 'häusern'});
      expect(altwortFormen(wortart: 'nomen', german: 'Auto', plural: 'Autos'),
          {'autos'});
      expect(altwortFormen(wortart: 'konnektor', german: 'weil'), isEmpty);
      expect(altwortFormen(wortart: 'verb', german: 'x', conjugationJson: '{'),
          isEmpty, reason: 'kaputtes JSON ⇒ keine Formen, kein Absturz');
    });

    test('nachForm + Antippen: «empfahl» findet empfehlen, «empf» nicht',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db.into(db.words).insert(WordsCompanion.insert(
            german: 'empfehlen',
            wordType: 'verb',
            meaningFa: 'توصیه کردن',
            conjugationJson: Value(konj),
          ));
      final c = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        vokabIndexProvider.overrideWith((ref) async => const []),
        vokabFormenStueckeProvider.overrideWith((ref) async => const {}),
      ]);
      addTearDown(c.dispose);
      final dao = c.read(wordDaoProvider);
      expect((await dao.nachForm('empfahl')).map((w) => w.german),
          ['empfehlen']);
      expect(await dao.nachForm('empf'), isEmpty,
          reason: 'nur ganze Formen, kein Teilstring');
      final t = await c.read(klickWortTrefferProvider('empfahl').future);
      expect(t, hasLength(1));
    });
  });
}
