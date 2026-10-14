// FILE: test/such_reihenfolge_screen_test.dart
// PHASE: فاز F.1 (Lukas, 2026-10-14): In «Alle Wörter» zeigt die Suche
//        «ging» die Karte gehen GANZ OBEN (vorher alphabetisch irgendwo),
//        mit der Zeile «Inflected form: ging» darunter.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';
import 'package:vox/features/wortschatz/screens/wortschatz_list_screen.dart';

Map<String, dynamic> _karte(String id, String wort, String wortart) => {
      'id': id,
      'wort': wort,
      'wortart': wortart,
      'niveau': 'A1',
      'uebersetzung': {'fa': <String>[], 'en': <String>[]},
    };

void main() {
  testWidgets('«ging» ⇒ gehen steht oben, mit Hinweis auf die Form',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Alphabetisch stünde «aufgingen» vor «gehen» — genau der alte Fehler.
    final index = [
      _karte('verb_aufgingen', 'aufgingen', 'verb'),
      _karte('verb_gehen', 'gehen', 'verb'),
      _karte('nomen_gingkobaum', 'der Gingkobaum', 'nomen'),
    ];
    const formen = {
      'ging': ['verb_gehen'],
    };

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allWordsProvider.overrideWith((ref) => Stream.value(<Word>[])),
        vokabIndexProvider.overrideWith((ref) async => index),
        vokabFormenStueckeProvider.overrideWith(
            (ref) async => {for (final f in formen.keys) vokabFormenDatei(f)}),
        vokabFormenStueckProvider.overrideWith((ref, datei) async => {
              for (final e in formen.entries)
                if (vokabFormenDatei(e.key) == datei) e.key: e.value,
            }),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        supportedLocales: [Locale('en'), Locale('fa')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: WortschatzListScreen(initialQuery: 'ging'),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final karten = tester.widgetList<WortCard>(find.byType(WortCard)).toList();
    expect(karten.map((k) => k.card['id']).toList(),
        ['verb_gehen', 'nomen_gingkobaum', 'verb_aufgingen']);
    expect(karten.first.hinweis, isNotNull);
    expect(karten[1].hinweis, isNull);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('Tippfehler «gehn» ⇒ «Did you mean?» gehen ⇒ Antippen sucht gehen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final index = [
      _karte('verb_gehen', 'gehen', 'verb'),
      _karte('nomen_tisch', 'der Tisch', 'nomen'),
    ];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allWordsProvider.overrideWith((ref) => Stream.value(<Word>[])),
        vokabIndexProvider.overrideWith((ref) async => index),
        vokabFormenStueckeProvider.overrideWith((ref) async => <String>{}),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        supportedLocales: [Locale('en'), Locale('fa')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: WortschatzListScreen(initialQuery: 'gehn'),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(WortCard), findsNothing);
    expect(find.text('Did you mean?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('vorschlag_gehen')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final karten = tester.widgetList<WortCard>(find.byType(WortCard)).toList();
    expect(karten.map((k) => k.card['id']).toList(), ['verb_gehen']);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
