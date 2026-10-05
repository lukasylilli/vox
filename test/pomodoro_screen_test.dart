// FILE: test/pomodoro_screen_test.dart
// PHASE: Selbstlernen / Pomodoro (2026-10-05, B-14b)
// PURPOSE: Die Seite zeigt nach einem Phasenende (auch während der Sperre
//          verpasst) das Banner und hat die drei Schalter, die den Notifier
//          wirklich umstellen. Aufbau der MaterialApp 1:1 wie in
//          test/l10n_paritaet_test.dart (Global*Localizations für Farsi).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/features/selbstlernen/controllers/selbstlernen_controller.dart';
import 'package:vox/features/selbstlernen/screens/pomodoro_screen.dart';
import 'package:vox/features/selbstlernen/services/pomodoro_geraet.dart';

class _Wach implements BildschirmWach {
  @override
  Future<bool> halten() async => true;
  @override
  Future<void> loslassen() async {}
}

class _Klang implements PomodoroKlang {
  @override
  void vorbereiten() {}
  @override
  Future<void> spielen() async {}
}

void main() {
  var jetzt = DateTime(2026, 10, 5, 12);

  Future<ProviderContainer> zeigen(WidgetTester tester, String sprache) async {
    SharedPreferences.setMockInitialValues({});
    jetzt = DateTime(2026, 10, 5, 12);
    final c = ProviderContainer(overrides: [
      pomodoroProvider.overrideWith(() => PomodoroNotifier(
            jetzt: () => jetzt,
            wach: _Wach(),
            klang: _Klang(),
          )),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        locale: Locale(sprache),
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PomodoroScreen(),
      ),
    ));
    return c;
  }

  testWidgets('drei Schalter: Standard wach AN, Auto AUS, Ton AN — und sie schalten um',
      (tester) async {
    final c = await zeigen(tester, 'en');

    Switch schalter(String key) =>
        tester.widget<Switch>(find.descendant(
            of: find.byKey(Key(key)), matching: find.byType(Switch)));

    expect(schalter('pomo_switch_keep_awake').value, isTrue);
    expect(schalter('pomo_switch_auto_next').value, isFalse);
    expect(schalter('pomo_switch_sound').value, isTrue);

    await tester.ensureVisible(find.byKey(const Key('pomo_switch_auto_next')));
    await tester.tap(find.byKey(const Key('pomo_switch_auto_next')));
    await tester.pump();
    expect(c.read(pomodoroProvider).autoWeiter, isTrue);
    expect(schalter('pomo_switch_auto_next').value, isTrue);

    await tester.ensureVisible(find.byKey(const Key('pomo_switch_sound')));
    await tester.tap(find.byKey(const Key('pomo_switch_sound')));
    await tester.pump();
    expect(c.read(pomodoroProvider).klang, isFalse);
  });

  testWidgets('Banner erscheint nach Phasenende und verschwindet beim Start', (tester) async {
    final c = await zeigen(tester, 'en');
    expect(find.byKey(const Key('pomo_ende_banner')), findsNothing);

    c.read(pomodoroProvider.notifier).start();
    jetzt = jetzt.add(const Duration(minutes: 26)); // Bildschirm war gesperrt
    c.read(pomodoroProvider.notifier)
        .didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.byKey(const Key('pomo_ende_banner')), findsOneWidget);
    expect(find.text('Focus phase finished'), findsOneWidget);

    c.read(pomodoroProvider.notifier).start();
    await tester.pump();
    expect(find.byKey(const Key('pomo_ende_banner')), findsNothing);

    c.read(pomodoroProvider.notifier).pause(); // Timer des Notifiers beenden
    await tester.pump();
  });

  testWidgets('Banner auch auf Farsi', (tester) async {
    final c = await zeigen(tester, 'fa');
    c.read(pomodoroProvider.notifier).start();
    jetzt = jetzt.add(const Duration(minutes: 26));
    c.read(pomodoroProvider.notifier)
        .didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('فاز تمرکز تمام شد'), findsOneWidget);
  });
}
