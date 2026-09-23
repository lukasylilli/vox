// FILE: test/deutsch_text_test.dart
// PURPOSE: Deutscher Text läuft links-nach-rechts, auch wenn die Oberfläche
//          persisch (RTL) ist — Fehlerbericht Lukas, 2026-09-18:
//          «در زبان آلمانی نقطه در سمت اشتباه است و کل خط به راست رفته».
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/widgets/deutsch_text.dart';
import 'package:vox/core/widgets/klick_wort_text.dart';
import 'package:vox/core/widgets/vox_button.dart';

void main() {
  group('DeutschText', () {
    testWidgets('bleibt LTR und linksbündig in einer RTL-Oberfläche',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl, // Oberfläche auf Persisch
          child: MediaQuery(
            data: MediaQueryData(),
            child: DeutschText('Ich komme aus Österreich.'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textDirection, TextDirection.ltr,
          reason: 'sonst rutscht der Schlusspunkt an den Satzanfang');
      expect(text.textAlign, TextAlign.left,
          reason: 'sonst klebt die Zeile am rechten Rand');
    });

    // Nachtrag 2026-09-23: kurze Zeile in einer Spalte mit `start` — in RTL
    // stand sie trotz textAlign.left am RECHTEN Rand (Fund beim iPhone-Test).
    Future<Rect> zeileIn(WidgetTester tester, TextDirection richtung,
        Widget kind) async {
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: richtung,
          child: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [kind],
              ),
            ),
          ),
        ),
      ));
      // Relativ zur Spalte (die Testfläche ist breiter als 400).
      final spalte = tester.getRect(find.byType(Column));
      return tester
          .getRect(find.byType(RichText).first)
          .shift(Offset(-spalte.left, -spalte.top));
    }

    for (final (name, kind) in [
      ('DeutschText', const DeutschText('Kurz.') as Widget),
      ('KlickWortText', const KlickWortText('Kurz.')),
    ]) {
      testWidgets('$name: kurze Zeile steht in RTL am LINKEN Rand',
          (tester) async {
        final r = await zeileIn(tester, TextDirection.rtl, kind);
        expect(r.left, 0, reason: 'Deutsch gehört an den linken Rand');
      });

      testWidgets('$name: in LTR unverändert links', (tester) async {
        final r = await zeileIn(tester, TextDirection.ltr, kind);
        expect(r.left, 0);
      });
    }

    testWidgets('ganzeZeile: false ⇒ Verhalten wie vorher (Titel, Chips)',
        (tester) async {
      final r = await zeileIn(tester, TextDirection.rtl,
          const DeutschText('Kurz.', ganzeZeile: false));
      expect(r.right, 400, reason: 'bewusst ausgenommen: bleibt, wo er war');
    });

    testWidgets('zentriert bleibt zentriert', (tester) async {
      final r = await zeileIn(tester, TextDirection.rtl,
          const DeutschText('Kurz.', textAlign: TextAlign.center));
      expect(r.left, greaterThan(0));
    });

    testWidgets('in einer Row ohne feste Breite: kein Überlauf, bleibt schmal',
        (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(children: [DeutschText('Kurz.'), Text('X')]),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(DeutschText)).width, lessThan(200));
    });

    testWidgets('bleibt LTR auch in einer LTR-Oberfläche', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr, // Oberfläche auf Englisch
          child: MediaQuery(
            data: MediaQueryData(),
            child: DeutschText('Ich komme aus Österreich.'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textDirection, TextDirection.ltr);
      expect(text.textAlign, TextAlign.left);
    });

    testWidgets('reicht Stil und maxLines durch', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQueryData(),
            child: DeutschText(
              'Ein sehr langer deutscher Beispielsatz zum Abschneiden.',
              style: TextStyle(fontSize: 21),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, 21);
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('VoxOptionButton.istDeutsch', () {
    Widget huelle(Widget kind) => MaterialApp(
          locale: const Locale('fa'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: kind),
          ),
        );

    testWidgets('istDeutsch: true ⇒ Label läuft LTR', (tester) async {
      await tester.pumpWidget(huelle(VoxOptionButton(
        label: 'Ich komme aus Österreich.',
        istDeutsch: true,
        onPressed: () {},
      )));

      final text = tester.widget<Text>(
          find.descendant(of: find.byType(VoxOptionButton), matching: find.byType(Text)));
      expect(text.textDirection, TextDirection.ltr);
    });

    testWidgets('Standard (Übersetzung) folgt weiter der Oberfläche',
        (tester) async {
      await tester.pumpWidget(huelle(VoxOptionButton(
        label: 'من از اتریش می‌آیم.',
        onPressed: () {},
      )));

      final text = tester.widget<Text>(
          find.descendant(of: find.byType(VoxOptionButton), matching: find.byType(Text)));
      expect(text.textDirection, isNull,
          reason: 'Übersetzungen erben die Richtung der Oberfläche');
    });
  });
}
