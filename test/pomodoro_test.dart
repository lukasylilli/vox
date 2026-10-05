// FILE: test/pomodoro_test.dart
// PHASE: Selbstlernen / Pomodoro (2026-10-05)
// PURPOSE: Der Pomodoro-Timer rechnet mit der ECHTEN Uhr: Sperrt man den
//          Bildschirm, kommen keine Ticks mehr — nach der Rückkehr muss die
//          verstrichene Zeit trotzdem abgezogen sein (früher blieb die Uhr
//          stehen). Dazu: Pause friert ein, Phase zu Ende während der Sperre,
//          Sichern und Wiederherstellen (auch kaputte Einträge).
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/features/selbstlernen/controllers/selbstlernen_controller.dart';

/// Falsche Uhr: läuft nur, wenn der Test sie vorstellt.
class _Uhr {
  DateTime jetzt = DateTime(2026, 10, 5, 12);
  void vor(Duration d) => jetzt = jetzt.add(d);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> bauen(
    _Uhr uhr, [
    Map<String, Object> prefs = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer(overrides: [
      pomodoroProvider
          .overrideWith(() => PomodoroNotifier(jetzt: () => uhr.jetzt)),
    ]);
    addTearDown(c.dispose);
    await c.read(pomodoroProvider.notifier).bereit;
    return c;
  }

  PomodoroNotifier notifier(ProviderContainer c) =>
      c.read(pomodoroProvider.notifier);
  PomodoroState zustand(ProviderContainer c) => c.read(pomodoroProvider);

  /// So meldet Flutter-Web „Seite wieder sichtbar" (Bildschirm entsperrt).
  void zurueck(ProviderContainer c) =>
      notifier(c).didChangeAppLifecycleState(AppLifecycleState.resumed);

  test('Anfang: 25:00, Fokus, läuft nicht', () async {
    final c = await bauen(_Uhr());
    expect(zustand(c).phase, PomodoroPhase.work);
    expect(zustand(c).secondsLeft, 25 * 60);
    expect(zustand(c).running, isFalse);
  });

  test('Bildschirm gesperrt: nach der Rückkehr ist die Zeit abgezogen', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    expect(zustand(c).running, isTrue);

    // 90 s Sperre — dabei kam KEIN Tick (der Test lässt keinen echten Timer ablaufen).
    uhr.vor(const Duration(seconds: 90));
    zurueck(c);

    expect(zustand(c).secondsLeft, 25 * 60 - 90);
    expect(zustand(c).running, isTrue);
  });

  test('Phase war während der Sperre zu Ende: nächste Phase, Sitzung gezählt', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();

    uhr.vor(const Duration(minutes: 26));
    zurueck(c);

    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).secondsLeft, 5 * 60);
    expect(zustand(c).sessionCount, 1);
    expect(zustand(c).running, isFalse);
  });

  test('Pause friert die Restzeit ein, Weiterlaufen zählt ab da', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();

    uhr.vor(const Duration(seconds: 60));
    notifier(c).pause();
    expect(zustand(c).secondsLeft, 25 * 60 - 60);
    expect(zustand(c).running, isFalse);

    uhr.vor(const Duration(minutes: 10)); // Pause: darf nichts kosten
    zurueck(c);
    expect(zustand(c).secondsLeft, 25 * 60 - 60);

    notifier(c).start();
    uhr.vor(const Duration(seconds: 40));
    zurueck(c);
    expect(zustand(c).secondsLeft, 25 * 60 - 100);
  });

  test('Pause nach Ablauf der Phase: nächste Phase, nicht „pausiert"', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();

    uhr.vor(const Duration(minutes: 30));
    notifier(c).pause();

    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).sessionCount, 1);
    expect(zustand(c).running, isFalse);
  });

  test('Systemuhr zurückgestellt: nie mehr als die volle Phase', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();

    uhr.vor(const Duration(hours: -3));
    zurueck(c);

    expect(zustand(c).secondsLeft, 25 * 60);
    expect(zustand(c).running, isTrue);
  });

  test('Reset: volle Zeit der aktuellen Phase, Sitzungen bleiben', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    uhr.vor(const Duration(minutes: 26));
    zurueck(c); // ⇒ Pause-Phase, 1 Sitzung

    notifier(c).start();
    uhr.vor(const Duration(minutes: 2));
    zurueck(c);
    notifier(c).reset();

    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).secondsLeft, 5 * 60);
    expect(zustand(c).sessionCount, 1);
    expect(zustand(c).running, isFalse);
  });

  test('vierte Sitzung ⇒ lange Pause', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr, {
      kPomodoroKey: jsonEncode({
        'phase': 0,
        'sessionCount': 3,
        'secondsLeft': 25 * 60,
        'running': false,
      }),
    });
    notifier(c).start();
    uhr.vor(const Duration(minutes: 25, seconds: 1));
    zurueck(c);

    expect(zustand(c).phase, PomodoroPhase.longBreak);
    expect(zustand(c).sessionCount, 4);
  });

  test('Sichern: Start schreibt Phase, Endzeitpunkt und „läuft"', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    await notifier(c).gespeichert;

    final prefs = await SharedPreferences.getInstance();
    final j = jsonDecode(prefs.getString(kPomodoroKey)!) as Map<String, dynamic>;
    expect(j['running'], isTrue);
    expect(j['phase'], 0);
    expect(
      j['endsAtMs'],
      uhr.jetzt.add(const Duration(minutes: 25)).millisecondsSinceEpoch,
    );
  });

  test('Wiederherstellen: lief noch ⇒ rechnet vom Endzeitpunkt weiter', () async {
    final uhr = _Uhr();
    final ende = uhr.jetzt.add(const Duration(minutes: 10));
    final c = await bauen(uhr, {
      kPomodoroKey: jsonEncode({
        'phase': 0,
        'sessionCount': 2,
        'secondsLeft': 25 * 60,
        'running': true,
        'endsAtMs': ende.millisecondsSinceEpoch,
      }),
    });

    expect(zustand(c).running, isTrue);
    expect(zustand(c).secondsLeft, 10 * 60);
    expect(zustand(c).sessionCount, 2);
  });

  test('Wiederherstellen: war schon vorbei ⇒ nächste Phase, pausiert', () async {
    final uhr = _Uhr();
    final ende = uhr.jetzt.subtract(const Duration(minutes: 1));
    final c = await bauen(uhr, {
      kPomodoroKey: jsonEncode({
        'phase': 0,
        'sessionCount': 3,
        'secondsLeft': 25 * 60,
        'running': true,
        'endsAtMs': ende.millisecondsSinceEpoch,
      }),
    });

    expect(zustand(c).phase, PomodoroPhase.longBreak);
    expect(zustand(c).sessionCount, 4);
    expect(zustand(c).running, isFalse);
  });

  test('Wiederherstellen: pausiert ⇒ Restzeit bleibt', () async {
    final c = await bauen(_Uhr(), {
      kPomodoroKey: jsonEncode({
        'phase': 1,
        'sessionCount': 2,
        'secondsLeft': 120,
        'running': false,
      }),
    });

    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).secondsLeft, 120);
    expect(zustand(c).running, isFalse);
  });

  test('Kaputter Eintrag wird ignoriert: Standardzustand', () async {
    for (final kaputt in <String>[
      'kein json',
      '[1,2]',
      jsonEncode({'phase': 9, 'sessionCount': 0}),
      jsonEncode({'phase': 0, 'sessionCount': -1}),
    ]) {
      final c = await bauen(_Uhr(), {kPomodoroKey: kaputt});
      expect(zustand(c).phase, PomodoroPhase.work, reason: kaputt);
      expect(zustand(c).secondsLeft, 25 * 60, reason: kaputt);
      expect(zustand(c).running, isFalse, reason: kaputt);
    }
  });
}
