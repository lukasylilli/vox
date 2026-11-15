import 'dart:io';

// FILE: test/uebersicht_karte_test.dart
// PURPOSE: Vier Fälle, Schritt M2 (Entwurf Lukas 2026-11-15) — Übersicht «الف»
//          zuerst, Bedeutungen darunter; Seite «الف» zeigt alle Bedeutungen
//          nebeneinander; Seite «ب/ج» trägt oben den Weg zu «الف»; vorne auf
//          der Lernkarte «ب/ج» steht nur die Warnung.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/features/leitner/widgets/archiv_flash_card.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/widgets/uebersicht_karte.dart';
import 'package:vox/features/wortschatz/data/such_rang.dart';
import 'package:vox/features/wortschatz/data/wortschatz_filter.dart';

Map<String, dynamic> _glied(String id, String fa, String niveau) => {
      'id': id,
      'wort': 'die Bank',
      'wortart': 'nomen',
      'niveau': niveau,
      'uebersetzung': {'fa': [fa], 'en': [fa]},
      'details': {'genus': 'die'},
      'uebersicht_id': 'nomen_bank__alle',
    };

final _byId = <String, Map<String, dynamic>>{
  'nomen_bank': _glied('nomen_bank', 'نیمکت', 'A2'),
  'nomen_bank_2': _glied('nomen_bank_2', 'بانک', 'A1'),
  'nomen_bank__alle': {
    'id': 'nomen_bank__alle',
    'wort': 'Bank',
    'wortart': 'nomen',
    'uebersicht': true,
    'bedeutungen_ids': ['nomen_bank', 'nomen_bank_2'],
    'niveau': 'A1',
    'uebersetzung': {'fa': ['نیمکت', 'بانک'], 'en': ['x', 'y']},
  },
  'nomen_tisch': {
    'id': 'nomen_tisch',
    'wort': 'der Tisch',
    'wortart': 'nomen',
    'niveau': 'A1',
    'uebersetzung': {'fa': ['میز'], 'en': ['table']},
    'details': {'genus': 'der'},
  },
};

SuchTreffer<Object> _z(String id) =>
    SuchTreffer<Object>(wert: _byId[id]!, lemma: id, rang: SuchRang.genau);

late AppDatabase _db;

Widget _app(Widget kind) => ProviderScope(
      overrides: [
        vokabIndexByIdProvider.overrideWith((ref) => _byId),
        databaseProvider.overrideWithValue(_db),
      ],
      child: MaterialApp(
        locale: const Locale('fa'),
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => _db.close());

  group('Reihenfolge in Liste und Suche', () {
    List<String> ids(List<SuchTreffer<Object>> z) =>
        [for (final t in z) (t.wert as Map)['id'] as String];

    test('«الف» zuerst, direkt darunter alle Bedeutungen', () {
      final aus = bedeutungenGruppieren(
          [_z('nomen_bank'), _z('nomen_tisch'), _z('nomen_bank_2'),
           _z('nomen_bank__alle')],
          _byId);
      expect(ids(aus),
          ['nomen_bank__alle', 'nomen_bank', 'nomen_bank_2', 'nomen_tisch']);
    });

    test('trifft die Suche nur eine Bedeutung, kommen «الف» und alle dazu', () {
      expect(ids(bedeutungenGruppieren([_z('nomen_bank_2')], _byId)),
          ['nomen_bank__alle', 'nomen_bank', 'nomen_bank_2']);
    });

    test('ohne Index bleibt alles, wie es ist', () {
      expect(ids(bedeutungenGruppieren([_z('nomen_bank_2')], const {})),
          ['nomen_bank_2']);
    });
  });

  testWidgets('Seite «الف»: beide Bedeutungen nebeneinander, Leitner-Knopf',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        _app(UebersichtSeite(karte: _byId['nomen_bank__alle']!)));
    await tester.pump();
    expect(find.text('نیمکت'), findsOneWidget);
    expect(find.text('بانک'), findsOneWidget);
    // nebeneinander: gleiche Höhe, verschiedene x-Lage
    final a = tester.getCenter(find.text('نیمکت'));
    final b = tester.getCenter(find.text('بانک'));
    expect(a.dy, b.dy);
    expect(a.dx, isNot(b.dx));
    expect(find.byIcon(Icons.inventory_2_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seite «ب/ج»: Hinweis oben führt zu «الف»', (tester) async {
    await tester.pumpWidget(
        _app(const Scaffold(body: MehrdeutigBanner(id: 'nomen_bank_2'))));
    await tester.pump();
    expect(find.byKey(const ValueKey('mehrdeutig_banner')), findsOneWidget);
    await tester.pumpWidget(
        _app(const Scaffold(body: MehrdeutigBanner(id: 'nomen_tisch'))));
    await tester.pump();
    expect(find.byKey(const ValueKey('mehrdeutig_banner')), findsNothing);
  });

  testWidgets('Lernkarte «ب/ج» vorne: nur die Warnung, keine Bedeutung',
      (tester) async {
    await tester.pumpWidget(_app(Scaffold(
        body: SingleChildScrollView(
            child: ArchivFlashCard(karte: _byId['nomen_bank_2']!)))));
    await tester.pump();
    expect(find.byKey(const ValueKey('lernkarte_mehrdeutig')), findsOneWidget);
    expect(find.text('بانک'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('Fall 4 — der/die Abgeordnete (Lukas 2026-11-15)', () {
    final abgeordnete = <String, dynamic>{
      'id': 'nomen_abgeordnete',
      'wort': 'der/die Abgeordnete',
      'wortart': 'nomen',
      'details': {'genus': 'der/die', 'deklinationstyp': 'adjektivisch'},
    };

    testWidgets('drei Artikel in der Zeile über dem Wort', (tester) async {
      await tester.pumpWidget(_app(Scaffold(body: WortZeile(card: abgeordnete))));
      await tester.pump();
      expect(find.byKey(const ValueKey('wortzeile_drei_artikel')), findsOneWidget);
      expect(find.text('Abgeordnete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('nur adjektivisch gebeugte Nomen bekommen den Grammatik-Verweis', () {
      expect(istAdjektivischesNomen(abgeordnete), isTrue);
      expect(istAdjektivischesNomen(_byId['nomen_tisch']!), isFalse);
    });

    test('die verlinkte Lektion gibt es', () {
      expect(
          File('assets/data/grammatik/nomen.json')
              .readAsStringSync()
              .contains('"slug": "$adjektivNomenLektion"'),
          isTrue);
    });
  });
}
