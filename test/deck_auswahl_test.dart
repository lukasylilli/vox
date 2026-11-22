// FILE: test/deck_auswahl_test.dart
// PHASE: X.3 (2026-11-17) — der Leitner-Knopf wählt das Deck
//
// Wächter:
//   · Baum: Eltern vor Kindern, fehlendes Eltern-Deck ⇒ oberste Ebene, ein
//     Kreis lässt kein Deck verschwinden (core/leitner/deck_baum.dart);
//   · Blatt: das Deck «Leitner» steht immer oben, ein Haken legt hinein bzw.
//     nimmt heraus (Fortschritt bleibt), «neues Deck»/«neues Subdeck» legt an
//     und legt das Wort hinein, Modus wählbar;
//   · Wort-Seite: EIN Leitner-Knopf, kein eigener Kategorien-Knopf mehr.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/database/dao/leitner_dao.dart';
import 'package:vox/core/leitner/deck_baum.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';
import 'package:vox/features/leitner/controllers/leitner_controller.dart';
import 'package:vox/features/leitner/data/standard_decks.dart';
import 'package:vox/features/leitner/widgets/deck_auswahl_sheet.dart';
import 'package:vox/features/vokabular/widgets/wort_actions.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

typedef _D = ({String id, String? eltern});

List<(String, int)> _baum(List<_D> d) => [
  for (final k in deckBaum<_D>(d, id: (x) => x.id, eltern: (x) => x.eltern))
    (k.deck.id, k.tiefe),
];

void main() {
  group('deckBaum', () {
    test('Eltern vor Kindern, Geschwister in Eingabe-Reihenfolge', () {
      expect(
        _baum([
          (id: 'b1', eltern: 'b'),
          (id: 'a', eltern: null),
          (id: 'b', eltern: null),
          (id: 'b1x', eltern: 'b1'),
          (id: 'a1', eltern: 'a'),
          (id: 'b2', eltern: 'b'),
        ]),
        [('a', 0), ('a1', 1), ('b', 0), ('b1', 1), ('b1x', 2), ('b2', 1)],
      );
    });

    test('fehlendes Eltern-Deck ⇒ oberste Ebene', () {
      expect(_baum([(id: 'x', eltern: 'weg')]), [('x', 0)]);
    });

    test('Kreis: jedes Deck genau einmal', () {
      final b = _baum([
        (id: 'a', eltern: 'b'),
        (id: 'b', eltern: 'a'),
        (id: 'c', eltern: 'c'),
      ]);
      expect(b.map((e) => e.$1).toSet(), {'a', 'b', 'c'});
      expect(b, hasLength(3));
    });

    test('deckMitSubdecks: alle Ebenen darunter', () {
      final d = <_D>[
        (id: 'a', eltern: null),
        (id: 'a1', eltern: 'a'),
        (id: 'a1x', eltern: 'a1'),
        (id: 'b', eltern: null),
      ];
      expect(
        deckMitSubdecks<_D>('a', d, id: (x) => x.id, eltern: (x) => x.eltern),
        {'a', 'a1', 'a1x'},
      );
      expect(
        deckMitSubdecks<_D>('b', d, id: (x) => x.id, eltern: (x) => x.eltern),
        {'b'},
      );
    });
  });

  group('Blatt', () {
    late AppDatabase db;
    late LeitnerDao dao;

    // Datenbank außerhalb der Widget-Zeit anlegen und schließen — im Test
    // selbst bliebe das Schließen an einer offenen Abfrage hängen.
    setUp(() {
      // Die Ton-Taste der Wort-Aktionen spricht mit dem Plugin flutter_tts —
      // im Test gibt es kein Gerät, also antwortet hier eine Attrappe.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter_tts'),
            (_) async => 1,
          );
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = LeitnerDao(db);
    });
    tearDown(() => db.close());

    Future<void> zeigen(WidgetTester tester, Widget kind) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            // X.4b: ohne Standard-Decks — die prüft standard_decks_test.dart.
            standardDecksProvider.overrideWith(
              (ref) async => StandardDecks.leer,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('fa')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: kind),
          ),
        ),
      );
      await _warten(tester);
    }

    Future<void> schliessen(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await _warten(tester);
    }

    testWidgets('«Leitner» steht immer oben; Haken legt hinein und nimmt '
        'heraus, der Fortschritt bleibt', (tester) async {
      await zeigen(
        tester,
        const DeckAuswahlSheet(wortId: 'nomen_tisch', wort: 'der Tisch'),
      );
      expect(find.text('Leitner'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('deck_$standardDeckId')));
      await _warten(tester);
      expect(await tester.runAsync(() => dao.imLeitnerBeobachten().first), [
        'nomen_tisch',
      ]);
      expect(
        tester
            .widget<Checkbox>(
              find.descendant(
                of: find.byKey(const ValueKey('deck_$standardDeckId')),
                matching: find.byType(Checkbox),
              ),
            )
            .value,
        isTrue,
      );

      await tester.runAsync(
        () => dao.bewerten('nomen_tisch', uebungBedeutung, gewusst: true),
      );
      await tester.tap(find.byKey(const ValueKey('deck_$standardDeckId')));
      await _warten(tester);
      expect(
        await tester.runAsync(() => dao.imLeitnerBeobachten().first),
        isEmpty,
      );
      expect(
        (await tester.runAsync(
          () => dao.fortschritt('nomen_tisch', uebungBedeutung),
        ))!.fach,
        2,
      );
      await schliessen(tester);
    });

    testWidgets('neues Deck (Notizbuch) und Subdeck darin — das Wort liegt in '
        'beiden', (tester) async {
      await zeigen(
        tester,
        const DeckAuswahlSheet(wortId: 'nomen_tisch', wort: 'der Tisch'),
      );

      await tester.tap(find.byKey(const ValueKey('deck_neu')));
      await _warten(tester);
      await tester.enterText(find.byKey(const ValueKey('deck_name')), 'Möbel');
      await tester.tap(find.text('Notebook only'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('deck_anlegen')));
      await _warten(tester);

      final moebel = (await tester.runAsync(() => dao.decks()))!.single;
      expect(
        (moebel.name, moebel.modus, moebel.elternId),
        ('Möbel', deckModusNotiz, null),
      );
      expect(await tester.runAsync(() => dao.deckIdsVonWort('nomen_tisch')), {
        moebel.id,
      });

      // Subdeck: übernimmt den Modus des Eltern-Decks.
      await tester.tap(
        find.descendant(
          of: find.byKey(ValueKey('deck_${moebel.id}')),
          matching: find.byIcon(Icons.subdirectory_arrow_right_rounded),
        ),
      );
      await _warten(tester);
      expect(find.text('New subdeck in “Möbel”'), findsWidgets);
      await tester.enterText(find.byKey(const ValueKey('deck_name')), 'Küche');
      await tester.tap(find.byKey(const ValueKey('deck_anlegen')));
      await _warten(tester);

      final kueche = (await tester.runAsync(
        () => dao.decks(),
      ))!.singleWhere((d) => d.name == 'Küche');
      expect((kueche.elternId, kueche.modus), (moebel.id, deckModusNotiz));
      expect(await tester.runAsync(() => dao.deckIdsVonWort('nomen_tisch')), {
        moebel.id,
        kueche.id,
      });
      // Im Baum eingerückt unter «Möbel».
      expect(
        tester.getTopLeft(find.text('Küche')).dx,
        greaterThan(tester.getTopLeft(find.text('Möbel')).dx),
      );
      await schliessen(tester);
    });

    testWidgets('Name leer ⇒ nichts angelegt', (tester) async {
      await zeigen(
        tester,
        const DeckAuswahlSheet(wortId: 'nomen_tisch', wort: 'der Tisch'),
      );
      await tester.tap(find.byKey(const ValueKey('deck_neu')));
      await _warten(tester);
      await tester.tap(find.byKey(const ValueKey('deck_anlegen')));
      await _warten(tester);
      expect(await tester.runAsync(() => dao.decks()), isEmpty);
      await schliessen(tester);
    });

    // Die Wort-Aktionen lesen über den Wort-Store, der beim Laden selbst in
    // die Datenbank schreibt — deshalb liegen die Daten VOR dem Aufbau bereit.
    const tisch = {
      'id': 'nomen_tisch',
      'wort': 'der Tisch',
      'wortart': 'nomen',
    };

    testWidgets('Wort-Seite: EIN Knopf öffnet die Deck-Auswahl, kein '
        'Kategorien-Knopf mehr', (tester) async {
      await zeigen(tester, const WortActions(card: tisch));
      expect(find.text('My Categories'), findsNothing);
      expect(find.text('Add to Leitner'), findsOneWidget);
      await tester.tap(find.text('Add to Leitner'));
      await _warten(tester);
      expect(find.byType(DeckAuswahlSheet), findsOneWidget);
      await schliessen(tester);
    });

    testWidgets('Wort-Seite: nur im Notizbuch ⇒ «In notebook»', (tester) async {
      await tester.runAsync(() async {
        final notiz = await dao.deckAnlegen('Reise');
        await dao.wortSetzen(notiz.id, 'nomen_tisch', true);
      });
      await zeigen(tester, const WortActions(card: tisch));
      expect(find.text('In notebook'), findsOneWidget);
      await schliessen(tester);
    });

    testWidgets('Wort-Seite: in einem Deck mit Wiederholung ⇒ «In Leitner»', (
      tester,
    ) async {
      await tester.runAsync(() => dao.aufnehmen('nomen_tisch'));
      await zeigen(tester, const WortActions(card: tisch));
      expect(find.text('In Leitner'), findsOneWidget);
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
