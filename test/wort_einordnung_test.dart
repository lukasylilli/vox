// FILE: test/wort_einordnung_test.dart
// PHASE: فاز F.6 / F.6b (Lukas, 2026-10-14): Etiketten auf der Wort-Seite —
//        Beruf/anstößig/veraltet, Erklärung, Ersatz; Klick ⇒ «Alle Wörter»
//        mit genau diesem Filter.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/features/vokabular/widgets/wort_einordnung.dart';
import 'package:vox/features/wortschatz/controllers/wortschatz_filter_controller.dart';

Widget _app(ProviderContainer c, Map<String, dynamic> card,
    {Map<String, Map<String, dynamic>> byId = const {}}) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => Scaffold(
        body: ListView(children: [WortEinordnung(card: card, byId: byId)]),
      ),
    ),
    GoRoute(
      path: '/wortschatz/list',
      builder: (_, s) => Text('LISTE ${s.uri.query}'),
    ),
    GoRoute(
      path: '/vokabular/wort/:id',
      builder: (_, s) => Text('WORT ${s.pathParameters['id']}'),
    ),
  ]);
  return UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('ohne Einordnung: nichts', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c, {'id': 'verb_gehen', 'berufe': []}));
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('Beruf-Etikett ⇒ Liste mit genau diesem Filter', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c, {
      'id': 'nomen_waschlappen',
      'berufe': ['pflege_medizin', 'reinigung'],
    }));
    expect(find.text('Medicine & nursing'), findsOneWidget);
    expect(find.text('Cleaning'), findsOneWidget);
    await tester.tap(find.text('Medicine & nursing'));
    await tester.pumpAndSettle();
    expect(find.textContaining('LISTE'), findsOneWidget);
    final f = c.read(wortschatzFilterProvider);
    expect(f.berufe, {'pflege_medizin'});
    expect(f.anzahlAktiv, 1);
  });

  testWidgets('anstößig: Warnung, Erklärung, «Say instead» klickbar',
      (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(
      c,
      {
        'id': 'adjektiv_doof',
        'anstoessig': {
          'stufe': 'abwertend',
          'erklaerung': {'fa': 'توهین‌آمیز', 'en': 'Rude about people.'},
        },
        'ersatz': {
          'wort': 'unklug',
          'wortart': 'adjektiv',
          'uebersetzung': {'fa': 'نابخردانه', 'en': 'unwise'},
          'id_ref': 'adjektiv_unklug',
        },
      },
      byId: {'adjektiv_unklug': {}},
    ));
    expect(find.text('Derogatory'), findsOneWidget);
    expect(find.text('Rude about people.'), findsOneWidget);
    expect(find.text('Say instead: '), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('wort_ersatz')));
    await tester.pumpAndSettle();
    expect(find.text('WORT adjektiv_unklug'), findsOneWidget);
  });

  testWidgets('veraltet: Etikett + «Today\'s word»; fehlt es ⇒ Suche',
      (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c, {
      'id': 'nomen_fraeulein',
      'zeitlich': 'veraltet',
      'ersatz': {
        'wort': 'die Frau',
        'wortart': 'nomen',
        'uebersetzung': {'fa': 'خانم', 'en': 'Ms'},
        'id_ref': 'nomen_frau',
      },
    }));
    expect(find.text('Obsolete'), findsOneWidget);
    expect(find.text("Today's word: "), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('wort_ersatz')));
    await tester.pumpAndSettle();
    expect(find.text('LISTE suche=die%20Frau'), findsOneWidget);
  });
}
