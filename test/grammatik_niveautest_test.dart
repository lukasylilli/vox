// FILE: test/grammatik_niveautest_test.dart
// PHASE: فاز G → G7b (2026-09-16) · فاز LAUNCH → L.2e
// PURPOSE: Kombinierter Niveau-Test A1–C2.
//
// Wächter:
//   · Einstellungen = Quelle (10 Fragen, 70 %, A1–C2), unbrauchbare ⇒ kein Test
//   · jedes Niveau hat Fragen, nur aus Lektionen dieses Niveaus, ohne transform
//   · ein Durchgang zieht höchstens 10, keine doppelt; C2 hat nur 3
//   · Seite: Einführung → Fragen; Ergebnis „bestanden/nicht bestanden"
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/features/grammatik/controllers/grammatik_lektion_controller.dart';
import 'package:vox/features/grammatik/models/grammatik_lektion.dart';
import 'package:vox/features/grammatik/models/grammatik_niveautest.dart';
import 'package:vox/features/grammatik/models/grammatik_uebung.dart';
import 'package:vox/features/grammatik/screens/grammatik_niveautest_screen.dart';
import 'package:vox/features/grammatik/widgets/uebung_karte.dart';
import 'package:vox/features/grammatik/widgets/uebungs_sitzung.dart';

Map<String, dynamic> lies(String pfad) =>
    jsonDecode(File(pfad).readAsStringSync()) as Map<String, dynamic>;

Widget app(Widget kind,
        {String sprache = 'en', List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: Locale(sprache),
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: kind,
      ),
    );

void main() {
  final lektionen = <String, GrammatikLektion>{};
  final uebungen = <String, List<GrammatikUebung>>{};
  for (final pfad in grammatikContentFiles) {
    final d = lies(pfad);
    for (final l in (d['lessons'] as List)) {
      final lek = GrammatikLektion.fromJson(l as Map<String, dynamic>);
      lektionen[lek.slug] = lek;
    }
    for (final e in (d['exercises'] as List)) {
      final u = GrammatikUebung.ausJson(e as Map<String, dynamic>);
      if (u != null) (uebungen[u.lektionSlug] ??= []).add(u);
    }
  }
  final niveauTest = GrammatikNiveauTest.ausJson(lies(grammatikNiveauTestDatei))!;

  List<Override> overrides() => [
        grammatikLektionenProvider.overrideWith((ref) async => lektionen),
        grammatikUebungenProvider.overrideWith((ref) async => uebungen),
        grammatikNiveauTestProvider.overrideWith((ref) async => niveauTest),
      ];

  group('Einstellungen', () {
    test('wie in der Quelle', () {
      expect(niveauTest.fragenProNiveau, 10);
      expect(niveauTest.bestehensQuote, 0.7);
      expect(niveauTest.quoteProzent, 70);
      expect(niveauTest.niveaus, ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']);
      // Die Datei stammt aus der Quelle — dort steht dieselbe Einstellung.
      final quelle =
          File('old files Lukasalmani/1/Grammatik').readAsStringSync();
      expect(quelle, contains('"questionsPerLevel": 10'));
      expect(quelle, contains('"passThreshold": 0.7'));
    });

    test('unbrauchbare Einstellungen ⇒ kein Test', () {
      Map<String, dynamic> mit(Map<String, dynamic> c) => {'config': c};
      const gut = {
        'questionsPerLevel': 10,
        'passThreshold': 0.7,
        'levels': ['A1'],
      };
      expect(GrammatikNiveauTest.ausJson(mit(gut)), isNotNull);
      expect(GrammatikNiveauTest.ausJson({}), isNull);
      expect(GrammatikNiveauTest.ausJson(mit({...gut, 'questionsPerLevel': 0})),
          isNull);
      expect(GrammatikNiveauTest.ausJson(mit({...gut, 'passThreshold': 1.5})),
          isNull);
      expect(GrammatikNiveauTest.ausJson(mit({...gut, 'levels': []})), isNull);
      expect(GrammatikNiveauTest.ausJson(mit({...gut, 'levels': [1]})), isNull);
    });
  });

  group('Fragen', () {
    test('jedes Niveau hat Fragen — nur passende Lektionen, ohne transform', () {
      for (final n in niveauTest.niveaus) {
        final vorrat = niveauTest.vorrat(n, lektionen, uebungen);
        expect(vorrat, isNotEmpty, reason: n);
        for (final u in vorrat) {
          expect(lektionen[u.lektionSlug]!.levels, contains(n),
              reason: '${u.schluessel} gehört nicht zu $n');
          expect(u.art, isNot(UebungsArt.transform), reason: u.schluessel);
        }
        expect(vorrat.map((u) => u.schluessel).toSet().length, vorrat.length,
            reason: '$n: doppelt');
      }
    });

    test('Vorratsgrößen (Stand der Inhalte)', () {
      final groesse = {
        for (final n in niveauTest.niveaus)
          n: niveauTest.vorrat(n, lektionen, uebungen).length,
      };
      // A1: 86 aus der alten Quelle + 5 aus Buch-Lektion 1 (personalpronomen,
      // L.6 2026-09-18; die sechste ist transform und zählt hier nie mit)
      // + 3 aus Buch-Lektion 2 (konjugation-praesens, L.6 2026-09-18;
      // multipleChoice/fillBlank, keine transform/wordOrder).
      expect(groesse, {
        'A1': 94, 'A2': 146, 'B1': 170, 'B2': 107, 'C1': 24, 'C2': 3,
      });
      expect(niveauTest.vorrat('a1', lektionen, uebungen).length, 94,
          reason: 'Kleinschreibung aus der Route');
      expect(niveauTest.vorrat('X9', lektionen, uebungen), isEmpty);
    });

    test('mit Zufall: Beispiel-Übungen dazu, aber kein Satzbau daraus (G7c)', () {
      for (final n in niveauTest.niveaus) {
        final fest = niveauTest.vorrat(n, lektionen, uebungen);
        final mit = niveauTest.vorrat(n, lektionen, uebungen, zufall: Random(3));
        final erzeugt = mit.where((u) => u.ausBeispiel).toList();
        expect(mit.length, fest.length + erzeugt.length, reason: n);
        expect(erzeugt, isNotEmpty, reason: n);
        for (final u in erzeugt) {
          expect(u.art, isNot(UebungsArt.wordOrder), reason: u.schluessel);
          expect(lektionen[u.lektionSlug]!.levels, contains(n));
        }
        expect(mit.map((u) => u.schluessel).toSet().length, mit.length,
            reason: '$n: doppelt');
      }
    });

    test('ein Durchgang: höchstens 10, keine doppelt, zufällig', () {
      final a1 = niveauTest.vorrat('A1', lektionen, uebungen);
      final eins = niveauTest.ziehe(a1, Random(1));
      final zwei = niveauTest.ziehe(a1, Random(2));
      expect(eins.length, 10);
      expect(eins.map((u) => u.schluessel).toSet().length, 10);
      expect(eins.map((u) => u.schluessel).toList(),
          isNot(zwei.map((u) => u.schluessel).toList()));
      final c2 = niveauTest.ziehe(niveauTest.vorrat('C2', lektionen, uebungen), Random(1));
      expect(c2.length, 3);
    });
  });

  group('Seite', () {
    for (final sprache in const ['en', 'fa']) {
      testWidgets('Einführung → erste Frage ($sprache)', (tester) async {
        tester.view.physicalSize = const Size(900, 3000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(app(
          GrammatikNiveauTestScreen(level: 'b1', zufall: Random(7)),
          sprache: sprache,
          overrides: overrides(),
        ));
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        final start = sprache == 'fa' ? 'شروع آزمون' : 'Start the test';
        expect(find.text(start), findsOneWidget);
        await tester.tap(find.text(start));
        await tester.pump();
        expect(find.byType(UebungKarte), findsOneWidget);
        final fortschritt =
            sprache == 'fa' ? 'تمرین 1 از 10' : 'Exercise 1 of 10';
        expect(find.text(fortschritt), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Niveau ohne Test ⇒ „به‌زودی", kein Absturz', (tester) async {
      await tester.pumpWidget(app(
        const GrammatikNiveauTestScreen(level: 'x9'),
        overrides: overrides(),
      ));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(UebungKarte), findsNothing);
    });

    testWidgets('Karte im Katalog nur für Niveaus mit Test', (tester) async {
      await tester.pumpWidget(app(
        const Scaffold(
          body: Column(children: [
            NiveauTestKarte(level: 'c2'),
            NiveauTestKarte(level: 'x9'),
          ]),
        ),
        overrides: overrides(),
      ));
      await tester.pump();
      await tester.pump();
      expect(find.text('Level test C2'), findsOneWidget);
      expect(find.text('Level test X9'), findsNothing);
      expect(find.text('3 random questions from the C2 lessons — pass mark 70%'),
          findsOneWidget);
    });
  });

  group('Ergebnis', () {
    Future<void> beantworte(
        WidgetTester tester, List<GrammatikUebung> fragen, int richtig) async {
      for (var i = 0; i < fragen.length; i++) {
        final u = fragen[i];
        final wahl = i < richtig
            ? u.loesung
            : u.optionen.firstWhere((o) => o != u.loesung);
        await tester.tap(find
            .descendant(
                of: find.byType(OutlinedButton), matching: find.text(wahl))
            .first);
        await tester.pump();
        await tester.tap(find.byKey(uebungWeiterKey));
        await tester.pump();
      }
    }

    final mc = [
      for (final l in uebungen.values)
        for (final u in l)
          if (u.art == UebungsArt.multipleChoice) u,
    ].take(10).toList();

    testWidgets('7 von 10 ⇒ bestanden', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var neu = 0;
      final fertig = <(int, int)>[];
      await tester.pumpWidget(app(Scaffold(
        body: UebungsSitzung(
          uebungen: mc,
          bestehensQuote: 0.7,
          onNochmal: () => neu++,
          onZurueck: () {},
          onFertig: (r, n) => fertig.add((r, n)),
        ),
      )));
      await beantworte(tester, mc, 7);
      // T.1: genau einmal, mit dem Ergebnis — Grundlage fürs Speichern.
      expect(fertig, [(7, 10)]);
      expect(find.text('7 of 10 correct'), findsOneWidget);
      expect(find.text('Passed!'), findsOneWidget);
      await tester.tap(find.text('New test'));
      expect(neu, 1);
    });

    testWidgets('6 von 10 ⇒ nicht bestanden', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(Scaffold(
        body: UebungsSitzung(
          uebungen: mc,
          bestehensQuote: 0.7,
          onZurueck: () {},
        ),
      )));
      await beantworte(tester, mc, 6);
      expect(find.text('6 of 10 correct'), findsOneWidget);
      expect(find.text('Not yet — review the lessons and try again'),
          findsOneWidget);
    });
  });
}
