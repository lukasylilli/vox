// FILE: test/wortschatz_filter_test.dart
// PHASE: فاز F.2 / F.2b / F.2c (Lukas, 2026-10-14): Filterseite von
//        «Alle Wörter» — «oder» innerhalb, «und» zwischen den Drawern; Zahl je
//        Knopf; Filter bleiben gemerkt.
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';
import 'package:vox/features/wortschatz/controllers/wortschatz_filter_controller.dart';
import 'package:vox/features/wortschatz/data/wortschatz_filter.dart';
import 'package:vox/features/wortschatz/data/vox_buecher.dart';
import 'package:vox/features/wortschatz/screens/wortschatz_filter_screen.dart';

import 'helpers/wortschatz_overrides.dart';

Map<String, dynamic> _karte(String id, String wort, String wortart,
        String niveau) =>
    {
      'id': id,
      'wort': wort,
      'wortart': wortart,
      'niveau': niveau,
      'uebersetzung': {'fa': <String>[], 'en': <String>[]},
    };

final _index = [
  _karte('verb_gehen', 'gehen', 'verb', 'A1'),
  _karte('verb_erwaegen', 'erwägen', 'verb', 'C1'),
  _karte('nomen_haus', 'das Haus', 'nomen', 'A1'),
  _karte('adjektiv_gut', 'gut', 'adjektiv', 'A1'),
  _karte('adverb_wahrlich', 'wahrlich', 'adverb', 'C2'),
];

void main() {
  WortschatzBasis basis() => wortschatzBasis(
      alleWoerter: const [], kartenTreffer: _index, query: '');

  test('ohne Filter: alles; «oder» im Drawer, «und» zwischen Drawern', () {
    final b = basis();
    expect(wortschatzAnzahl(b, WortschatzFilter.leer), 5);
    final a1OderC1 = WortschatzFilter(niveaus: {'a1', 'c1'});
    expect(wortschatzAnzahl(b, a1OderC1), 4);
    final a1UndVerb = WortschatzFilter(niveaus: {'a1'}, wortarten: {'verb'});
    expect(wortschatzAnzahl(b, a1UndVerb), 1);
  });

  test('alte Wortart «sonstige» umfasst Karten adverb/artikel', () {
    expect(
        wortschatzAnzahl(
            basis(), WortschatzFilter(wortarten: {'sonstige'})),
        1);
  });

  test('Zahl je Knopf = nur dieser Wert im Drawer, andere Drawer bleiben', () {
    final f = WortschatzFilter(niveaus: {'c2'}, wortarten: {'verb'});
    // Niveau A1 bei Wortart verb ⇒ nur gehen.
    expect(wortschatzAnzahlMit(basis(), f, FilterBereich.niveau, 'a1'), 1);
    // Wortart nomen bei Niveau c2 ⇒ 0.
    expect(wortschatzAnzahlMit(basis(), f, FilterBereich.wortart, 'nomen'), 0);
  });

  group('Bücher und eigene Kategorien (F.4)', () {
    const z = WortschatzZugehoerigkeit(
      buecher: [
        FilterGruppe(
            id: 'starten_a1', name: 'A1 Starten wir', karten: {'verb_gehen'}),
        FilterGruppe(
            id: 'konnektoren', name: 'Konnektoren', altWoerter: {7}),
      ],
      kategorien: [
        FilterGruppe(
            id: 'archiv:k1', name: 'Arbeit', karten: {'nomen_haus', 'gut'}),
      ],
    );
    WortschatzBasis mitZ() => wortschatzBasis(
        alleWoerter: const [],
        kartenTreffer: _index,
        query: '',
        zugehoerigkeit: z);

    test('Buch filtert nach Mitgliedschaft; mehrere Bücher = oder', () {
      expect(
          wortschatzAnzahl(mitZ(), WortschatzFilter(buecher: {'starten_a1'})),
          1);
      expect(
          wortschatzAnzahl(mitZ(),
              WortschatzFilter(buecher: {'starten_a1', 'konnektoren'})),
          1); // Konnektoren hat hier nur ein altes Wort, keine Karte
    });

    test('Kategorie und Niveau zusammen = und', () {
      expect(
          wortschatzAnzahl(
              mitZ(), WortschatzFilter(kategorien: {'archiv:k1'})),
          1); // nur nomen_haus existiert im Index («gut» ist keine id)
      expect(
          wortschatzAnzahl(mitZ(),
              WortschatzFilter(kategorien: {'archiv:k1'}, niveaus: {'c1'})),
          0);
    });

    test('gelöschte Kategorie: wirkt nicht und verschwindet aus bereinigt',
        () {
      final f = WortschatzFilter(kategorien: {'archiv:weg'}, niveaus: {'a1'});
      expect(f.bereinigt(z).kategorien, isEmpty);
      expect(f.bereinigt(z).niveaus, {'a1'});
      expect(wortschatzAnzahl(mitZ(), f), 3); // wie nur A1
    });
  });

  test('JSON: hin und zurück, Unbekanntes fällt weg', () {
    final f = WortschatzFilter(
        niveaus: {'b1'}, wortarten: {'nomen'}, buecher: {'konnektoren'});
    expect(WortschatzFilter.fromJson(f.toJson()).toJson(), f.toJson());
    final kaputt = WortschatzFilter.fromJson({
      'niveaus': ['b1', 'z9', 3],
      'wortarten': ['nomen', 'gibtsnicht'],
    });
    expect(kaputt.niveaus, {'b1'});
    expect(kaputt.wortarten, {'nomen'});
  });

  testWidgets('Filterseite: Zahlen, Umschalten, Zähler unten, gemerkt',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      allWordsProvider.overrideWith((ref) => Stream.value(<Word>[])),
      vokabIndexProvider.overrideWith((ref) async => _index),
      ...wortschatzGruppenOverrides(buecher: const [
        VoxBuch(id: 'starten_a1', name: 'A1 Starten wir', karten: ['verb_gehen']),
      ]),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('en'),
        supportedLocales: [Locale('en'), Locale('fa')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: WortschatzFilterScreen(),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Show 5 words'), findsOneWidget);
    // Drawer «Bücher» mit dem VOX-Buch und seiner Zahl (F.4); «My
    // categories» leer ⇒ Hinweis.
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('A1 Starten wir'), findsOneWidget);
    expect(find.textContaining('No categories yet'), findsOneWidget);
    await tester.tap(find.text('A1 Starten wir'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Show 1 words'), findsOneWidget);
    await tester.tap(find.text('A1 Starten wir'));
    await tester.pump(const Duration(milliseconds: 300));
    // Zahl am Knopf A1 = 3.
    expect(
        find.descendant(
            of: find.ancestor(
                of: find.text('A1'), matching: find.byType(InkWell)).first,
            matching: find.text('3')),
        findsOneWidget);

    await tester.tap(find.text('A1'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Show 3 words'), findsOneWidget);

    // Gemerkt (F.2c).
    final prefs = await SharedPreferences.getInstance();
    final json = jsonDecode(prefs.getString(wortschatzFilterSchluessel)!)
        as Map<String, dynamic>;
    expect(json['niveaus'], ['a1']);

    await tester.tap(find.byKey(const ValueKey('filter_alle_loeschen')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Show 5 words'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });

  test('gespeicherter Filter wird beim Start geladen', () async {
    SharedPreferences.setMockInitialValues({
      wortschatzFilterSchluessel: jsonEncode({
        'niveaus': ['b2'],
        'wortarten': ['verb'],
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(wortschatzFilterProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final f = c.read(wortschatzFilterProvider);
    expect(f.niveaus, {'b2'});
    expect(f.wortarten, {'verb'});
  });
}
