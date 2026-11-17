// FILE: test/deck_seite_test.dart
// PHASE: X.4 (2026-11-17) — Deck-Baum auf der Leitner-Seite, Deck-Seite,
//        Üben eines Decks.
//
// Wächter:
//   · erstes Üben wird festgehalten (Tageslimit) und bleibt beim
//     Weiterüben, beim Zurücklegen und beim Zusammenführen;
//   · Sitzung eines Decks = nur seine Wörter samt Subdecks; Notizbuch nie;
//   · Leitner-Seite zeigt den Baum (eingerückt) mit «heute»-Zahlen;
//   · Deck-Seite: Zahlen, Subdecks, Wörter; Menü schaltet den Modus um und
//     löscht (Fortschritt bleibt);
//   · alte Adresse «Meine Kategorien» führt in den Leitner.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/leitner/screens/deck_screen.dart';
import 'package:vox/features/leitner/screens/leitner_home_screen.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

Map<String, dynamic> _karte(String id, String wort) => {
  'id': id,
  'wort': wort,
  'wortart': 'nomen',
  'niveau': 'A1',
  'uebersetzung': {
    'fa': ['x'],
    'en': ['y'],
  },
  'details': {'genus': 'der'},
};

final _index = {
  'nomen_tisch': _karte('nomen_tisch', 'der Tisch'),
  'nomen_stuhl': _karte('nomen_stuhl', 'der Stuhl'),
  'nomen_koffer': _karte('nomen_koffer', 'der Koffer'),
};

void main() {
  late AppDatabase db;
  late LeitnerDao dao;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = LeitnerDao(db);
  });
  tearDown(() => db.close());

  group('Daten', () {
    test('erstes Üben: gesetzt beim ersten Antworten, bleibt danach', () async {
      final t1 = DateTime.utc(2026, 11, 17, 8);
      final t2 = DateTime.utc(2026, 11, 19, 8);
      final a = await dao.bewerten(
        'w',
        uebungBedeutung,
        gewusst: true,
        jetzt: t1,
      );
      expect(a.ersteWiederholung, t1);
      await dao.bewerten('w', uebungBedeutung, gewusst: false, jetzt: t2);
      await dao.zuruecklegen('w', uebungBedeutung, jetzt: t2);
      await dao.bewerten('w', uebungBedeutung, gewusst: true, jetzt: t2);
      expect(
        (await dao.fortschritt(
          'w',
          uebungBedeutung,
        ))!.ersteWiederholung!.toUtc(),
        t1,
      );
    });

    test('Zusammenführen: das frühere erste Üben gewinnt; fehlt es auf einer '
        'Seite, bleibt das andere', () {
      final t1 = DateTime.utc(2026, 11, 1), t2 = DateTime.utc(2026, 11, 5);
      final a = LeitnerStand(wortId: 'w', fach: 3, ersteWiederholung: t2);
      final b = LeitnerStand(wortId: 'w', fach: 2, ersteWiederholung: t1);
      expect(LeitnerStand.zusammen(a, b).ersteWiederholung, t1);
      expect(LeitnerStand.zusammen(b, a).ersteWiederholung, t1);
      const ohne = LeitnerStand(wortId: 'w', fach: 5);
      expect(LeitnerStand.zusammen(ohne, a).ersteWiederholung, t2);
      // JSON: nur wenn bekannt.
      expect(ohne.toJson().containsKey('ersteWiederholung'), isFalse);
      expect(LeitnerStand.vonJson(a.toJson()).ersteWiederholung, t2);
    });

    test('Sitzung eines Decks: nur seine Wörter samt Subdecks', () async {
      final oben = await dao.deckAnlegen('Möbel', modus: deckModusWiederholen);
      final sub = await dao.deckAnlegen(
        'Küche',
        elternId: oben.id,
        modus: deckModusWiederholen,
      );
      final notiz = await dao.deckAnlegen('Reise');
      await dao.wortSetzen(oben.id, 'nomen_tisch', true);
      await dao.wortSetzen(sub.id, 'nomen_stuhl', true);
      await dao.wortSetzen(notiz.id, 'nomen_koffer', true);
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(c.dispose);
      expect(await c.read(leitnerSitzungProvider(oben.id).future), [
        'nomen_tisch',
        'nomen_stuhl',
      ]);
      expect(await c.read(leitnerSitzungProvider(sub.id).future), [
        'nomen_stuhl',
      ]);
      expect(
        await c.read(leitnerSitzungProvider(notiz.id).future),
        isEmpty,
        reason: 'Notizbuch wird nie geübt',
      );
      expect(await c.read(dueCountProvider.future), 2);
    });
  });

  group('Seiten', () {
    Future<void> zeigen(WidgetTester tester, Widget seite) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            vokabIndexByIdProvider.overrideWith((ref) => _index),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('fa')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: seite,
          ),
        ),
      );
      await _warten(tester);
    }

    Future<void> schliessen(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await _warten(tester);
    }

    Future<({Deck oben, Deck sub})> anlegen(WidgetTester tester) async =>
        (await tester.runAsync(() async {
          final oben = await dao.deckAnlegen(
            'Möbel',
            modus: deckModusWiederholen,
          );
          final sub = await dao.deckAnlegen(
            'Küche',
            elternId: oben.id,
            modus: deckModusWiederholen,
          );
          await dao.wortSetzen(oben.id, 'nomen_tisch', true);
          await dao.wortSetzen(sub.id, 'nomen_stuhl', true);
          return (oben: oben, sub: sub);
        }))!;

    testWidgets('Leitner-Seite: Baum eingerückt, «heute»-Zahlen, «alle üben»', (
      tester,
    ) async {
      final d = await anlegen(tester);
      await zeigen(tester, const LeitnerHomeScreen());
      expect(find.text('Decks'), findsOneWidget);
      final x0 = tester.getTopLeft(find.text('Möbel')).dx;
      final x1 = tester.getTopLeft(find.text('Küche')).dx;
      expect(x1, greaterThan(x0), reason: 'Subdeck eingerückt');
      expect(
        find.descendant(
          of: find.byKey(ValueKey('deckzeile_${d.oben.id}')),
          matching: find.text('2 new'),
        ),
        findsOneWidget,
      );
      expect(find.text('Review all (2)'), findsOneWidget);
      await schliessen(tester);
    });

    testWidgets('Leitner-Seite ohne Decks: Hinweis', (tester) async {
      await zeigen(tester, const LeitnerHomeScreen());
      expect(find.textContaining('No decks yet'), findsOneWidget);
      await schliessen(tester);
    });

    testWidgets('Deck-Seite: Zahlen, Subdeck, Wörter; Modus umschalten', (
      tester,
    ) async {
      final d = await anlegen(tester);
      await zeigen(tester, DeckScreen(deckId: d.oben.id));
      expect(find.text('Subdecks'), findsOneWidget);
      expect(find.text('Küche'), findsOneWidget);
      expect(find.text('2 words'), findsWidgets);
      expect(
        find.byKey(const ValueKey('deckwort_nomen_tisch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('deckwort_nomen_stuhl')),
        findsNothing,
        reason: 'Wörter der Subdecks stehen auf deren Seite',
      );
      expect(find.byKey(const ValueKey('deck_ueben')), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('deck_menue_${d.oben.id}')).first);
      await _warten(tester);
      await tester.tap(find.byKey(ValueKey('deck_modus_${d.oben.id}')));
      await _warten(tester);
      final neu = await tester.runAsync(() => dao.deck(d.oben.id));
      expect(neu!.modus, deckModusNotiz);
      expect(find.text('Notebook only'), findsWidgets);
      await schliessen(tester);
    });

    testWidgets('Deck löschen über das Menü: weg, Fortschritt bleibt', (
      tester,
    ) async {
      final d = await anlegen(tester);
      await tester.runAsync(
        () => dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true),
      );
      await zeigen(tester, DeckScreen(deckId: d.oben.id));
      await tester.tap(find.byKey(ValueKey('deck_menue_${d.oben.id}')).first);
      await _warten(tester);
      await tester.tap(find.byKey(ValueKey('deck_loeschen_${d.oben.id}')));
      await _warten(tester);
      await tester.tap(find.byKey(const ValueKey('deck_loeschen_ja')));
      await _warten(tester);
      expect(await tester.runAsync(() => dao.deck(d.oben.id)), isNull);
      final kueche = await tester.runAsync(() => dao.deck(d.sub.id));
      expect(kueche!.elternId, isNull, reason: 'Subdeck rückt hoch');
      expect(
        (await tester.runAsync(
          () => dao.fortschritt('nomen_tisch', uebungBedeutung),
        ))!.fach,
        2,
      );
      await schliessen(tester);
    });
  });
}

Future<void> _warten(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}
