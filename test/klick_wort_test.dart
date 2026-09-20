// FILE: test/klick_wort_test.dart
// PHASE: L.5f (2026-09-20) — Klick auf ein Wort, überall gleich.
// PURPOSE: Hält die Regeln fest, die nicht geraten werden dürfen:
//          · Text zerlegen verliert/verdoppelt kein Zeichen,
//          · Schlüssel: Artikel/Präposition/Groß-Klein, KEINE Formenerkennung,
//          · Homographen: alle Treffer, keine Auswahl,
//          · KlickWortText: jedes Wort antippbar, Rest nicht, Richtung LTR,
//          · Popup ohne Treffer: «nicht im Wörterbuch» + Weg in die Suche.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vox/core/wort/klick_wort.dart';
import 'package:vox/core/wort/klick_wort_provider.dart';
import 'package:vox/core/wort/wort_form.dart';
import 'package:vox/core/widgets/klick_wort_text.dart';
import 'package:vox/core/widgets/wort_popup.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';

void main() {
  group('zerlegeText', () {
    test('kein Zeichen geht verloren oder wird doppelt', () {
      const texte = [
        'Ich komme aus Österreich.',
        'Straße, Fuß & Größe — 3 Äpfel!',
        '  Zeilen\numbruch\t',
        '',
        '123 456',
        'مرحبا Hallo',
      ];
      for (final t in texte) {
        expect(zerlegeText(t).map((k) => k.text).join(), t);
      }
    });

    test('Wörter und Rest werden unterschieden', () {
      final k = zerlegeText('Ich komme, 3x.');
      expect(k.where((t) => t.istWort).map((t) => t.text).toList(),
          ['Ich', 'komme', 'x']);
      expect(k.where((t) => !t.istWort).map((t) => t.text).toList(),
          [' ', ', 3', '.']);
    });

    test('Umlaute und ß gehören zum Wort; persische Schrift nicht', () {
      final w = zerlegeText('Größe Äpfel Fuß مرحبا')
          .where((t) => t.istWort)
          .map((t) => t.text)
          .toList();
      expect(w, ['Größe', 'Äpfel', 'Fuß']);
    });
  });

  group('wortSchluessel', () {
    test('Groß/Klein und Satzzeichen am Rand', () {
      expect(wortSchluessel('(Haus),'), 'haus');
      expect(wortSchluessel('HAUS'), 'haus');
      expect(wortBereinigt('„Haus“.'), 'Haus');
    });

    test('Artikel zählt nur bei Mehrwort-Einträgen nicht mit', () {
      expect(wortSchluessel('die Angst'), 'angst');
      expect(wortSchluessel('der'), 'der'); // eigener Eintrag «der»
      expect(wortSchluessel('die'), 'die');
    });

    test('nachgestellte Präposition zählt nicht mit', () {
      expect(wortSchluessel('warten auf'), 'warten');
      expect(wortSchluessel('in'), 'in');
      expect(wortSchluessel('Bescheid geben'), 'bescheid geben');
    });

    test('Nomen und Verb mit gleicher Schreibung: gleicher Schlüssel', () {
      expect(wortSchluessel('Reisen'), wortSchluessel('reisen'));
    });

    test('keine Buchstaben → leer', () {
      expect(wortSchluessel('123'), '');
      expect(wortSchluessel(' , '), '');
    });

    test('keine Formenerkennung (bewusst nicht geraten)', () {
      expect(wortSchluessel('ging'), isNot(wortSchluessel('gehen')));
      expect(wortSchluessel('Häuser'), isNot(wortSchluessel('Haus')));
    });

    test('stripPreposition wie bisher', () {
      expect(stripPreposition('warten auf'), 'warten');
      expect(stripPreposition('Tisch'), 'Tisch');
      expect(stripPreposition('auf'), 'auf');
    });
  });

  group('klickWortTrefferProvider (Archiv)', () {
    Map<String, dynamic> karte(String id, String wort, String wortart) =>
        {'id': id, 'wort': wort, 'wortart': wortart};

    ProviderContainer container() {
      final c = ProviderContainer(overrides: [
        vokabIndexProvider.overrideWith((ref) async => [
              karte('nomen_angst', 'die Angst', 'nomen'),
              karte('nomen_reisen', 'das Reisen', 'nomen'),
              karte('verb_reisen', 'reisen', 'verb'),
              karte('artikel_der', 'der', 'artikel'),
            ]),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('Nomen mit Artikel wird über das bloße Wort gefunden', () async {
      final t = await container().read(klickWortTrefferProvider('angst').future);
      expect(t, hasLength(1));
      expect(t.single.quelle, KlickWortQuelle.archiv);
      expect(t.single.pfad, '/vokabular/wort/nomen_angst');
    });

    test('Homographen: alle Treffer, keine Auswahl', () async {
      final t =
          await container().read(klickWortTrefferProvider('reisen').future);
      expect(t.map((x) => x.karte!['id']).toSet(),
          {'nomen_reisen', 'verb_reisen'});
    });

    test('der einzelne Artikel ist ein eigener Eintrag', () async {
      final t = await container().read(klickWortTrefferProvider('der').future);
      expect(t.single.karte!['id'], 'artikel_der');
    });
  });

  group('KlickWortText', () {
    Future<List<TextSpan>> spansVon(WidgetTester tester, Widget w) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
      final text = tester.widget<Text>(find.byType(Text));
      return (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    }

    testWidgets('jedes Wort antippbar, Rest nicht, Text unverändert',
        (tester) async {
      final spans =
          await spansVon(tester, const KlickWortText('Ich komme, sagt er.'));
      expect(spans.map((s) => s.text).join(), 'Ich komme, sagt er.');
      expect(spans.where((s) => s.recognizer != null).map((s) => s.text),
          ['Ich', 'komme', 'sagt', 'er']);
      expect(spans.where((s) => s.recognizer == null).map((s) => s.text),
          [' ', ', ', ' ', '.']);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textDirection, TextDirection.ltr);
      expect(text.textAlign, TextAlign.left);
    });

    testWidgets('markiert: Wörter sichtbar unterstrichen; sonst normal',
        (tester) async {
      var spans = await spansVon(
          tester, const KlickWortText('Haus', markiert: true));
      expect(spans.single.style?.decoration, TextDecoration.underline);

      spans = await spansVon(tester, const KlickWortText('Haus'));
      expect(spans.single.style, isNull);
    });

    testWidgets('neuer Text → neue Wörter, kein Fehler', (tester) async {
      var spans = await spansVon(tester, const KlickWortText('eins zwei'));
      expect(spans.where((s) => s.recognizer != null), hasLength(2));
      spans = await spansVon(tester, const KlickWortText('nur'));
      expect(spans.where((s) => s.recognizer != null), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('showWortPopup ohne Treffer', () {
    testWidgets('«nicht im Wörterbuch» + Suche mit vorgefülltem Wort',
        (tester) async {
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (ctx, _) => Scaffold(
            body: Builder(
              builder: (inner) => GestureDetector(
                onTap: () => showWortPopup(inner, 'Ging,'),
                child: const Text('ÖFFNEN'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/wortschatz/list',
          builder: (ctx, state) =>
              Scaffold(body: Text('LISTE ${state.uri.queryParameters['suche']}')),
        ),
      ]);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          klickWortTrefferProvider
              .overrideWith((ref, schluessel) async => <KlickWortTreffer>[]),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));

      await tester.tap(find.text('ÖFFNEN'));
      await tester.pumpAndSettle();

      expect(find.text('Ging'), findsOneWidget); // Satzzeichen entfernt
      expect(find.text('Not in dictionary'), findsOneWidget);

      await tester.tap(find.text('Search all words'));
      await tester.pumpAndSettle();
      expect(find.text('LISTE Ging'), findsOneWidget);
    });

    testWidgets('ohne Buchstaben öffnet sich nichts', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (inner) => GestureDetector(
                onTap: () => showWortPopup(inner, '123'),
                child: const Text('ÖFFNEN'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ÖFFNEN'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });
  });
}
