// Tests فاز V Stufe ۲: EndungResolver (Heuristik + explizit + Präfix),
// WortText (Span-Aufbau) und WortCard (Smoke, FA + EN — nie Dual-Display).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/endung_resolver.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/core/grammatikon/wort_text.dart';
import 'package:vox/core/l10n/app_l10n.dart';

void main() {
  group('EndungResolver.splitEndung', () {
    test('Automatik: längste Endung zuerst', () {
      expect(EndungResolver.splitEndung('Buches'),
          (stamm: 'Buch', endung: 'es'));
      expect(EndungResolver.splitEndung('kleinem'),
          (stamm: 'klein', endung: 'em'));
      expect(EndungResolver.splitEndung('schnellsten'),
          (stamm: 'schnell', endung: 'sten'));
      expect(EndungResolver.splitEndung('lernte'),
          (stamm: 'lern', endung: 'te'));
    });

    test('explizit: passt / passt nicht / leer', () {
      expect(EndungResolver.splitEndung('Kindern', 'n'),
          (stamm: 'Kinder', endung: 'n'));
      // explizite Endung passt nicht ans Wortende → nie falsch färben
      expect(EndungResolver.splitEndung('Tisch', 'em'),
          (stamm: 'Tisch', endung: ''));
      // '' = keine Markierung (auch wenn Automatik etwas fände)
      expect(EndungResolver.splitEndung('Buches', ''),
          (stamm: 'Buches', endung: ''));
    });

    test('kurze Wörter bleiben ungeteilt (Stamm ≥ 2)', () {
      expect(EndungResolver.splitEndung('es'), (stamm: 'es', endung: ''));
      expect(EndungResolver.splitEndung(''), (stamm: '', endung: ''));
    });

    test('splitPraefix: Partizip II und trennbares Verb', () {
      expect(EndungResolver.splitPraefix('gehabt', 'ge'),
          (praefix: 'ge', rest: 'habt'));
      expect(EndungResolver.splitPraefix('aufstehen', 'auf'),
          (praefix: 'auf', rest: 'stehen'));
      // Präfix passt nicht → keine Markierung
      expect(EndungResolver.splitPraefix('stehen', 'auf'),
          (praefix: '', rest: 'stehen'));
    });
  });

  testWidgets('WortText: Stamm + farbige Endung + Präfix als Spans',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WortText(
            wort: 'gehabt', praefix: 'ge', endung: 't', color: Colors.green),
      ),
    ));
    final rich = tester.widget<Text>(find.byType(Text));
    final spans = (rich.textSpan! as TextSpan).children!;
    expect(spans.length, 3); // Präfix + Stamm + Endung
    expect((spans[0] as TextSpan).text, 'ge');
    expect((spans[1] as TextSpan).text, 'hab');
    expect((spans[2] as TextSpan).text, 't');
    expect((spans[2] as TextSpan).style!.color, Colors.green);
    expect(tester.takeException(), isNull);
  });

  group('WortCard', () {
    final nomenKarte = <String, dynamic>{
      'wort': 'das Buch',
      'wortart': 'nomen',
      'details': {'genus': 'das'},
      'uebersetzung': {
        'fa': ['کتاب'],
        'en': ['book'],
      },
      'niveau': 'A1',
      'box': 1,
    };
    final verbKarte = <String, dynamic>{
      'wort': 'lernen',
      'wortart': 'verb',
      'details': {'regelmaessig': true},
      'uebersetzung': {
        'fa': ['یاد گرفتن'],
        'en': ['to learn'],
      },
      'niveau': 'A1',
      'box': 1,
    };

    Widget app(Locale locale, Widget child) => MaterialApp(
          locale: locale,
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: child),
        );

    testWidgets('EN-Modus: nur EN-Übersetzung, kein FA (فاز L)', (tester) async {
      await tester.pumpWidget(
          app(const Locale('en'), WortCard(card: nomenKarte)));
      expect(find.textContaining('book'), findsOneWidget);
      expect(find.textContaining('کتاب'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FA-Modus: nur FA-Übersetzung, kein EN', (tester) async {
      await tester.pumpWidget(
          app(const Locale('fa'), WortCard(card: nomenKarte)));
      expect(find.textContaining('کتاب'), findsOneWidget);
      expect(find.textContaining('book'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Nomen: Artikel getrennt gerendert; Verb rendert ohne Fehler',
        (tester) async {
      await tester.pumpWidget(
          app(const Locale('en'), WortCard(card: nomenKarte)));
      expect(find.text('das '), findsOneWidget); // Artikel in Genusfarbe
      expect(find.text('A1'), findsOneWidget); // VoxBadge.level

      await tester.pumpWidget(
          app(const Locale('en'), WortCard(card: verbKarte)));
      expect(tester.takeException(), isNull);
    });
  });
}
