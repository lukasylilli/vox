// Tests فاز V Stufe ۳/۴: vokabId (Regel 5), Suche, User-Store (Leitner-Flag +
// Kategorien, getrennt vom Content), Asset-Loader (lädt Demo-Wort aus pubspec)
// und DetailsRenderer (Verb: Perfekt wird GEBAUT, nie gespeichert — Regel 7).
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/controllers/vokabular_user_state.dart';
import 'package:vox/features/vokabular/widgets/details_renderer.dart';
import 'package:vox/features/vokabular/widgets/wort_notiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('vokabId (ID-Regel 5 des SUPER-PROMPT)', () {
    test('Nomen: Artikel weg, Umlaute umschrieben', () {
      expect(vokabId('nomen', 'der Kühlschrank'), 'nomen_kuehlschrank');
      expect(vokabId('nomen', 'die Straße'), 'nomen_strasse');
      expect(vokabId('nomen', 'das Öl'), 'nomen_oel');
    });
    test('Verb/Adjektiv unverändert klein', () {
      expect(vokabId('verb', 'aufstehen'), 'verb_aufstehen');
      expect(vokabId('adjektiv', 'schön'), 'adjektiv_schoen');
    });
  });

  test('vokabKartePasst: DE / FA / EN, case-insensitive', () {
    final karte = {
      'wort': 'das Buch',
      'uebersetzung': {
        'fa': ['کتاب'],
        'en': ['book'],
      },
    };
    expect(vokabKartePasst(karte, 'buch'), isTrue);
    expect(vokabKartePasst(karte, 'کتاب'), isTrue);
    expect(vokabKartePasst(karte, 'BOOK'), isTrue);
    expect(vokabKartePasst(karte, 'tisch'), isFalse);
  });

  test('Notiz-Färbung: Wort-Index an Cursor/Markierung + farbige Spans', () {
    const text = 'der Hund läuft';
    expect(notizWortIndizes(text, 4, 4), {1}); // Cursor in «Hund»
    expect(notizWortIndizes(text, 0, 8), {0, 1}); // Markierung über 2 Wörter

    // Runs: der | ' ' | Hund | ' ' | läuft → Wort-Index 1 = spans[2]
    final spans = notizSpans(text, const {1: 'gelb'});
    expect(spans[2].style?.color, notizFarben['gelb']);
    expect(spans[0].style, isNull); // ungefärbt = Theme-Farbe
  });

  group('VokabularUserStore', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('toggleLeitner: Flag rein (Box 1) / raus — kein Auto-Import', () async {
      final store = container.read(vokabularUserProvider.notifier);
      expect(container.read(vokabularUserProvider).imLeitner('verb_lernen'),
          isFalse); // Wortschatz ≠ Leitner: Standard ist NICHT im Stapel

      expect(await store.toggleLeitner('verb_lernen'), isTrue);
      final s = container.read(vokabularUserProvider);
      expect(s.imLeitner('verb_lernen'), isTrue);
      expect(s.leitner['verb_lernen']!.box, 1);
      expect(s.leitner['verb_lernen']!.nextReviewDate, isNotNull);

      expect(await store.toggleLeitner('verb_lernen'), isFalse);
      expect(container.read(vokabularUserProvider).imLeitner('verb_lernen'),
          isFalse);
    });

    test('Kategorien: erstellen + Wort rein/raus (nur IDs)', () async {
      final store = container.read(vokabularUserProvider.notifier);
      final kat = await store.createKategorie('Prüfung B1');

      await store.toggleWortInKategorie(kat.id, 'verb_lernen');
      expect(
          container
              .read(vokabularUserProvider)
              .kategorien
              .first
              .wortIds,
          ['verb_lernen']);

      await store.toggleWortInKategorie(kat.id, 'verb_lernen');
      expect(
          container.read(vokabularUserProvider).kategorien.first.wortIds,
          isEmpty);
    });

    test('Notiz: setzen (text + Wortfarben), leeren Text = löschen', () async {
      final store = container.read(vokabularUserProvider.notifier);
      await store.setzeNotiz('adjektiv_aalartig',
          const VokabNotiz(text: 'das muss ich lernen', farben: {0: 'gelb'}));

      final n =
          container.read(vokabularUserProvider).notizen['adjektiv_aalartig']!;
      expect(n.text, 'das muss ich lernen');
      expect(n.farben, {0: 'gelb'});

      await store.setzeNotiz('adjektiv_aalartig', const VokabNotiz(text: ' '));
      expect(container.read(vokabularUserProvider).notizen, isEmpty);
    });

    test('Persistenz: neuer Container lädt gespeicherten Zustand', () async {
      final store = container.read(vokabularUserProvider.notifier);
      await store.toggleLeitner('verb_lernen');
      await store.createKategorie('Arbeit');
      await store.setzeNotiz(
          'verb_lernen', const VokabNotiz(text: 'täglich üben', farben: {1: 'rot'}));

      final zweiter = ProviderContainer();
      addTearDown(zweiter.dispose);
      // _load ist async — kurz auf den geladenen Zustand warten.
      await zweiter.read(vokabularUserProvider.notifier).toggleLeitner('x');
      final s = zweiter.read(vokabularUserProvider);
      expect(s.imLeitner('verb_lernen'), isTrue);
      expect(s.kategorien.map((k) => k.name), contains('Arbeit'));
      expect(s.notizen['verb_lernen']!.text, 'täglich üben');
      expect(s.notizen['verb_lernen']!.farben, {1: 'rot'});
    });
  });

  test('Asset-Loader: Demo-Wort wird über pubspec gefunden', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final karten = await container.read(vokabularProvider.future);
    expect(karten.map((k) => k['id']), contains('verb_lernen'));
  });

  late Map<String, dynamic> verbKarte;
  setUpAll(() async {
    // rootBundle in plain async laden — innerhalb testWidgets (FakeAsync)
    // kommt das Asset-Future nie an.
    final json =
        await rootBundle.loadString('assets/vocab/verb/verb_lernen.json');
    verbKarte = jsonDecode(json) as Map<String, dynamic>;
  });

  testWidgets('DetailsRenderer Verb: Perfekt gebaut, nicht gespeichert',
      (tester) async {
    final karte = verbKarte;
    // Regel 7: Karte enthält KEIN Perfekt.
    expect(
        ((karte['details'] as Map)['konjugation'] as Map)
            .containsKey('perfekt'),
        isFalse);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(child: DetailsRenderer(card: karte))),
    ));
    expect(find.text('Konjugation'), findsOneWidget);
    expect(find.text('hat gelernt'), findsWidgets); // PerfektBuilder-Ableitung
    expect(find.text('Stammformen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
