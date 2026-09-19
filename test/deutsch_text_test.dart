// FILE: test/deutsch_text_test.dart
// PURPOSE: Deutscher Text läuft links-nach-rechts, auch wenn die Oberfläche
//          persisch (RTL) ist — Fehlerbericht Lukas, 2026-09-18:
//          «در زبان آلمانی نقطه در سمت اشتباه است و کل خط به راست رفته».
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/widgets/deutsch_text.dart';
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
