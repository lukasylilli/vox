// FILE: test/globale_suche_test.dart
// PHASE: G8 (2026-11-16) — globale Suche über die ganze App + Glossar A–Z.
//
// Wächter an den ECHTEN Daten (assets/data/…):
//   · jeder Bereich (Grammatik und jedes Deck) liefert Einträge — ein neues
//     oder umbenanntes Deck fällt sonst still aus der Suche;
//   · jede Route eines Treffers führt im Router auf eine Seite;
//   · die Beispiele aus dem Gespräch mit Lukas stimmen («warten» findet
//     «warten auf», «ging» findet gehen, «Dativ» findet Grammatik).
// Dazu der Screen: gruppiert, 5 Treffer + «alle zeigen», Wörter mit
// Leitner-Knopf wie in «Alle Wörter».
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/core/router/app_router.dart';
import 'package:vox/core/services/feature_flags.dart';
import 'package:vox/features/auswendiglernen/controllers/auswendiglernen_controller.dart'
    show memorizeCategories;
import 'package:vox/features/grammatik/controllers/grammar_catalog_controller.dart';
import 'package:vox/features/grammatik/models/grammar_catalog.dart';
import 'package:vox/features/grammatik/screens/grammatik_home_screen.dart';
import 'package:vox/features/home/controllers/search_controller.dart';
import 'package:vox/features/home/data/such_index.dart';
import 'package:vox/features/home/screens/search_results_screen.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/widgets/wort_actions.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';

import 'helpers/wortschatz_overrides.dart';

bool _hatSeite(String route) {
  final dynamic konfiguration = appRouter.configuration;
  dynamic treffer;
  try {
    treffer = konfiguration.findMatch(Uri.parse(route));
  } on TypeError {
    treffer = konfiguration.findMatch(route);
  }
  return !(treffer.isError as bool);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Suchindex aus den echten Daten', () {
    late AppDatabase db;
    late ProviderContainer c;
    late List<SuchEintrag> index;

    setUpAll(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.memorizeItems).insert(MemorizeItemsCompanion.insert(
            category: memorizeCategories.first,
            phrase: 'Schwein haben',
            meaning: 'شانس آوردن',
            meaningEn: const Value('to be lucky'),
          ));
      await db.into(db.memorizeItems).insert(MemorizeItemsCompanion.insert(
            category: 'gibt es nicht',
            phrase: 'ins Gras beißen',
            meaning: 'مردن',
          ));
      c = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)]);
      index = await c.read(suchIndexProvider.future);
    });

    tearDownAll(() async {
      c.dispose();
      await db.close();
    });

    test('jeder Bereich liefert Einträge', () {
      final anzahl = <SuchBereich, int>{};
      for (final e in index) {
        anzahl[e.bereich] = (anzahl[e.bereich] ?? 0) + 1;
      }
      for (final b in SuchBereich.values) {
        expect(anzahl[b] ?? 0, greaterThan(0),
            reason: '${b.name}: nichts durchsuchbar — Deck umbenannt '
                'oder in search_controller.dart vergessen?');
      }
      // Grammatik: alle Einträge des Katalogs, die es schon gibt.
      expect(anzahl[SuchBereich.grammatik], greaterThanOrEqualTo(84));
    });

    test('jeder Bereich hat einen bekannten Schalter (oder keinen)', () {
      for (final b in SuchBereich.values) {
        if (b.flag.isEmpty) continue;
        expect(FeatureFlags.keys, contains(b.flag), reason: b.name);
      }
    });

    test('jeder Eintrag hat Titel und eine Route, die auf eine Seite führt',
        () {
      final kaputt = <String>[];
      for (final e in index) {
        if (e.titel.trim().isEmpty) kaputt.add('${e.bereich.name}: ohne Titel');
        if (!_hatSeite(e.route)) {
          kaputt.add('${e.bereich.name}: «${e.titel}» → ${e.route}');
        }
      }
      expect(kaputt, isEmpty, reason: kaputt.take(20).join('\n'));
    });

    test('«warten» findet «warten auf» in Verben mit Präpositionen', () {
      final g = suchGruppen(index, 'warten');
      expect(g[SuchBereich.verbPraep]!.first.titel, 'warten auf');
    });

    test('«ging» findet gehen über die Stammform', () {
      final g = suchGruppen(index, 'ging');
      expect(g[SuchBereich.unregelmVerben]!.map((e) => e.titel),
          contains('gehen'));
    });

    test('«Dativ» findet Grammatik und das Deck', () {
      final g = suchGruppen(index, 'Dativ');
      expect(g[SuchBereich.grammatik], isNotEmpty);
      expect(g.keys.first, SuchBereich.grammatik,
          reason: 'Grammatik steht vor den Decks');
    });

    test('«obwohl» findet den Konnektor; eine persische Bedeutung auch', () {
      expect(suchGruppen(index, 'obwohl')[SuchBereich.konnektoren]!.first.titel,
          'obwohl');
      final obwohl = index.firstWhere((e) =>
          e.bereich == SuchBereich.konnektoren && e.titel == 'obwohl');
      expect(
          suchGruppen(index, obwohl.fa)[SuchBereich.konnektoren], contains(obwohl));
    });

    test('importierte Phrasen: Route der Kategorie, sonst die Übersicht', () {
      final g = suchGruppen(index, 'Schwein')[SuchBereich.auswendiglernen]!;
      expect(g.single.route, '/auswendiglernen/0');
      final ohne = suchGruppen(index, 'Gras')[SuchBereich.auswendiglernen]!;
      expect(ohne.single.route, '/auswendiglernen');
    });
  });

  group('Screen', () {
    Map<String, dynamic> karte(String id, String wort) => {
          'id': id,
          'wort': wort,
          'wortart': 'verb',
          'niveau': 'A1',
          'uebersetzung': {
            'fa': <String>['x'],
            'en': <String>['y'],
          },
          'details': <String, dynamic>{},
        };

    Future<AppDatabase> zeigen(WidgetTester tester, String query) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          allWordsProvider.overrideWith((ref) => Stream.value(<Word>[])),
          ...wortschatzGruppenOverrides(),
          vokabIndexProvider.overrideWith((ref) async => [
                karte('verb_warten', 'warten'),
                karte('verb_abwarten', 'abwarten'),
              ]),
          vokabFormenStueckeProvider.overrideWith((ref) async => <String>{}),
          suchIndexProvider.overrideWith((ref) async => [
                for (var i = 0; i < 8; i++)
                  SuchEintrag(
                    bereich: SuchBereich.verbPraep,
                    titel: 'warten auf $i',
                    fa: 'منتظر بودن',
                    en: 'to wait for',
                    route: '/verb-praep/$i',
                    niveau: 'B1',
                  ),
                const SuchEintrag(
                  bereich: SuchBereich.grammatik,
                  titel: 'Wartezeit im Satz',
                  fa: 'x',
                  en: 'y',
                  route: '/grammatik/lektion/wartezeit',
                ),
              ]),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('fa')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SearchResultsScreen(initialQuery: query),
        ),
      ));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      return db;
    }

    testWidgets('gruppiert: Wörter, Grammatik, Deck — 5 Treffer + «alle zeigen»',
        (tester) async {
      final db = await zeigen(tester, 'wart');

      // Reihenfolge der Gruppen von oben nach unten.
      double y(String name) =>
          tester.getTopLeft(find.byKey(ValueKey('such_gruppe_$name'))).dy;
      expect(y('woerter'), lessThan(y('grammatik')));
      expect(y('grammatik'), lessThan(y('verbPraep')));

      // Wörter wie in «Alle Wörter»: Karte + Leitner/Ton (WortActions).
      final karten =
          tester.widgetList<WortCard>(find.byType(WortCard)).toList();
      expect(karten.map((k) => k.card['id']), ['verb_warten', 'verb_abwarten']);
      expect(find.byType(WortActions), findsNWidgets(2));

      // Deck: 8 Treffer, 5 sichtbar, Knopf zeigt alle — und wieder weniger.
      Finder zeilen() => find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('such_verbPraep_'));
      expect(zeilen(), findsNWidgets(suchVorschau));
      expect(find.byKey(const ValueKey('such_alle_grammatik')), findsNothing,
          reason: 'eine Gruppe mit einem Treffer braucht keinen Knopf');
      await tester.tap(find.byKey(const ValueKey('such_alle_verbPraep')));
      await tester.pump();
      expect(zeilen(), findsNWidgets(8));
      await tester.tap(find.byKey(const ValueKey('such_alle_verbPraep')));
      await tester.pump();
      expect(zeilen(), findsNWidgets(suchVorschau));

      await tester.pumpWidget(const SizedBox());
      await db.close();
    });

    testWidgets('nichts gefunden ⇒ Hinweis mit der Suche; leer ⇒ Aufforderung',
        (tester) async {
      var db = await zeigen(tester, 'zzzz');
      expect(find.textContaining('«zzzz»'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await db.close();

      db = await zeigen(tester, '');
      expect(find.text('Type something to search'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });

    testWidgets('Tippen sucht nach kurzer Pause neu', (tester) async {
      final db = await zeigen(tester, '');
      await tester.enterText(find.byKey(const ValueKey('such_feld')), 'wart');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('such_gruppe_verbPraep')), findsNothing,
          reason: 'noch in der Pause');
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byKey(const ValueKey('such_gruppe_verbPraep')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  });

  group('Glossar A–Z (Grammatik)', () {
    KatalogEintrag eintrag(String slug, String de) => KatalogEintrag(
          slug: slug,
          de: de,
          fa: 'fa',
          en: 'en',
          niveaus: const ['a1'],
          thema: 'verben',
          satzglied: 'praedikat',
          lektion: null,
          route: '/grammatik/lektion/$slug',
        );

    test('Sortierschlüssel: Artikel zählt nicht, Umlaut = Grundbuchstabe', () {
      expect(katalogSortierSchluessel('Die vier Fälle (Kasus)'),
          'vier falle (kasus)');
      expect(katalogSortierSchluessel('Übersicht'), 'ubersicht');
      expect(katalogSortierSchluessel('Das'), 'das',
          reason: 'ein einzelnes Wort ist kein Artikel-Vorsatz');
    });

    test('Gruppen nach Buchstabe, alphabetisch, nichts geht verloren', () {
      final k = GrammatikKatalog(
        themen: const [],
        satzglieder: const [],
        eintraege: [
          eintrag('z', 'Zeitformen'),
          eintrag('v', 'Die vier Fälle'),
          eintrag('ae', 'Ähnliche Verben'),
          eintrag('a', 'Adjektive'),
          eintrag('n', '3 Arten von Sätzen'),
        ],
      );
      final g = k.alphabetisch;
      expect(g.map((x) => x.buchstabe), ['#', 'A', 'V', 'Z']);
      expect(g[1].eintraege.map((e) => e.de), ['Adjektive', 'Ähnliche Verben']);
      expect(g.expand((x) => x.eintraege).length, 5);
    });

    test('echter Katalog: jeder Eintrag genau einmal, Buchstaben aufsteigend',
        () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final katalog = await c.read(grammatikKatalogProvider.future);
      final g = katalog.alphabetisch;
      expect(g.expand((x) => x.eintraege).map((e) => e.slug).toSet().length,
          katalog.eintraege.length);
      final buchstaben = [for (final x in g) x.buchstabe];
      expect(buchstaben, [...buchstaben]..sort());
      expect(buchstaben.toSet().length, buchstaben.length);
    });

    testWidgets('Ansicht «A–Z» zeigt Buchstaben und Einträge', (tester) async {
      SharedPreferences.setMockInitialValues({'grammatik_sort_mode': 'alphabetisch'});
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          grammatikKatalogProvider.overrideWith((ref) async => GrammatikKatalog(
                themen: const [],
                satzglieder: const [],
                eintraege: [
                  eintrag('p', 'Passiv'),
                  eintrag('a', 'Adjektive'),
                ],
              )),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('fa')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: GrammatikHomeScreen(),
        ),
      ));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('A–Z'), findsOneWidget);
      expect(find.byKey(const ValueKey('glossar_A')), findsOneWidget);
      expect(find.byKey(const ValueKey('glossar_P')), findsOneWidget);
      expect(
          tester.getTopLeft(find.text('Adjektive')).dy,
          lessThan(tester.getTopLeft(find.text('Passiv')).dy));
    });
  });
}
