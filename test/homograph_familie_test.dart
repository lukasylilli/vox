// FILE: test/homograph_familie_test.dart
// PHASE: L.4 (2026-10-19) — Wunsch Lukas: Hat ein Wort mehrere Karten
//        (der See / die See, die Bank / die Bank²), soll man das sehen.
//        Prüft: Familien NUR aus den ids erkannt (nicht aus der Karte),
//        feste Nummern im Index (See¹, See²), Hinweis mit Weg zur anderen
//        Karte — und dass Wörter OHNE Familie nichts davon zeigen.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';
import 'package:vox/features/vokabular/widgets/homograph_hinweis.dart';

Map<String, dynamic> _k(String id, String wort, {String fa = '', String en = ''}) =>
    {
      'id': id,
      'wort': wort,
      'wortart': 'nomen',
      'uebersetzung': {
        'fa': [fa],
        'en': [en],
      },
      'details': {'genus': wort.split(' ').first},
    };

final _seeDer = _k('nomen_see', 'der See', fa: 'دریاچه', en: 'lake');
final _seeDie = _k('nomen_see_die', 'die See', fa: 'دریا', en: 'sea');
final _bank = _k('nomen_bank', 'die Bank', fa: 'نیمکت', en: 'bench');
final _bank2 = _k('nomen_bank_2', 'die Bank', fa: 'بانک', en: 'bank');
final _tisch = _k('nomen_tisch', 'der Tisch', fa: 'میز', en: 'table');

Widget _app(ProviderContainer c, String id) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => Scaffold(body: HomographHinweis(id: id)),
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

ProviderContainer _container(List<Map<String, dynamic>> karten) {
  final c = ProviderContainer(overrides: [
    vokabIndexByIdProvider.overrideWith(
        (ref) async => {for (final k in karten) k['id'] as String: k}),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Familien: gleiche Grund-id, Hauptbedeutung zuerst; Einzelwort nie',
      () {
    final f = vokabHomographFamilien([_seeDie, _tisch, _seeDer, _bank2, _bank]);
    expect(f, {
      'nomen_see': ['nomen_see', 'nomen_see_die'],
      'nomen_bank': ['nomen_bank', 'nomen_bank_2'],
    });
  });

  test('Index-Bau: homograph_nr nur für Familien, Wörter ohne Familie ohne',
      () {
    final text = vokabIndexBauen({
      for (final k in [_seeDer, _seeDie, _tisch])
        'assets/vocab/nomen/${k['id']}.json': k,
    });
    final karten = {
      for (final e in (jsonDecode(text)['karten'] as List))
        e['id']: e as Map,
    };
    expect(karten['nomen_see']!['homograph_nr'], 1);
    expect(karten['nomen_see_die']!['homograph_nr'], 2);
    expect(karten['nomen_tisch']!.containsKey('homograph_nr'), isFalse);
  });

  test('Hochgestellte Nummer: 1 → ¹ … 9 → ⁹, sonst nichts', () {
    expect(homographHoch(1), '¹');
    expect(homographHoch(2), '²');
    expect(homographHoch(9), '⁹');
    expect(homographHoch(null), isNull);
    expect(homographHoch(0), isNull);
  });

  testWidgets('Hinweis zeigt die andere Karte mit Bedeutung und führt hin',
      (tester) async {
    final c = _container([_seeDer, _seeDie, _tisch]);
    await tester.pumpWidget(_app(c, 'nomen_see'));
    await tester.pumpAndSettle();
    expect(find.textContaining('separate card'), findsOneWidget);
    expect(find.text('= sea'), findsOneWidget);
    await tester.tap(find.text('= sea'));
    await tester.pumpAndSettle();
    expect(find.text('WORT nomen_see_die'), findsOneWidget);
  });

  testWidgets('Wort ohne Familie: kein Hinweis', (tester) async {
    final c = _container([_seeDer, _seeDie, _tisch]);
    await tester.pumpWidget(_app(c, 'nomen_tisch'));
    await tester.pumpAndSettle();
    expect(find.textContaining('separate card'), findsNothing);
  });
}
