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
import 'package:vox/features/wortschatz/screens/wortschatz_filter_screen.dart';

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
    const a1OderC1 = WortschatzFilter(niveaus: {'a1', 'c1'});
    expect(wortschatzAnzahl(b, a1OderC1), 4);
    const a1UndVerb = WortschatzFilter(niveaus: {'a1'}, wortarten: {'verb'});
    expect(wortschatzAnzahl(b, a1UndVerb), 1);
  });

  test('alte Wortart «sonstige» umfasst Karten adverb/artikel', () {
    expect(
        wortschatzAnzahl(
            basis(), const WortschatzFilter(wortarten: {'sonstige'})),
        1);
  });

  test('Zahl je Knopf = nur dieser Wert im Drawer, andere Drawer bleiben', () {
    const f = WortschatzFilter(niveaus: {'c2'}, wortarten: {'verb'});
    // Niveau A1 bei Wortart verb ⇒ nur gehen.
    expect(wortschatzAnzahlMit(basis(), f, FilterBereich.niveau, 'a1'), 1);
    // Wortart nomen bei Niveau c2 ⇒ 0.
    expect(wortschatzAnzahlMit(basis(), f, FilterBereich.wortart, 'nomen'), 0);
  });

  test('JSON: hin und zurück, Unbekanntes fällt weg', () {
    const f = WortschatzFilter(niveaus: {'b1'}, wortarten: {'nomen'});
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
