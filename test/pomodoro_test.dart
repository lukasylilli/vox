// FILE: test/pomodoro_test.dart
// PHASE: Selbstlernen / Pomodoro (2026-10-05)
// PURPOSE: Der Pomodoro-Timer rechnet mit der ECHTEN Uhr: Sperrt man den
//          Bildschirm, kommen keine Ticks mehr — nach der Rückkehr muss die
//          verstrichene Zeit trotzdem abgezogen sein (früher blieb die Uhr
//          stehen). Dazu: Pause friert ein, Phase zu Ende während der Sperre,
//          Sichern und Wiederherstellen (auch kaputte Einträge).
//          B-14b: Bildschirm wach halten, Ton + Banner am Phasenende,
//          „automatisch weiter" (auch über mehrere Phasen hinweg), Schalter
//          werden gesichert.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/features/selbstlernen/controllers/selbstlernen_controller.dart';
import 'package:vox/features/selbstlernen/services/pomodoro_geraet.dart';

/// Falsche Uhr: läuft nur, wenn der Test sie vorstellt.
class _Uhr {
  DateTime jetzt = DateTime(2026, 10, 5, 12);
  void vor(Duration d) => jetzt = jetzt.add(d);
}

/// Attrappe: merkt sich, ob der Bildschirm gerade wach gehalten wird.
class _Wach implements BildschirmWach {
  bool wach = false;
  int anfragen = 0;

  @override
  Future<bool> halten() async {
    anfragen++;
    wach = true;
    return true;
  }

  @override
  Future<void> loslassen() async => wach = false;
}

/// Attrappe: zählt Töne und Vorbereitungen.
class _Klang implements PomodoroKlang {
  int toene = 0;
  int vorbereitet = 0;

  @override
  void vorbereiten() => vorbereitet++;

  @override
  Future<void> spielen() async => toene++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Wach wach;
  late _Klang klang;

  Future<ProviderContainer> bauen(
    _Uhr uhr, [
    Map<String, Object> prefs = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(prefs);
    wach = _Wach();
    klang = _Klang();
    final c = ProviderContainer(overrides: [
      pomodoroProvider.overrideWith(
          () => PomodoroNotifier(jetzt: () => uhr.jetzt, wach: wach, klang: klang)),
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

  // ── B-14b ──────────────────────────────────────────────────────────────────

  test('Bildschirm: wach, solange der Timer läuft — sonst freigegeben', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    expect(wach.wach, isFalse);

    notifier(c).start();
    expect(wach.wach, isTrue);

    notifier(c).pause();
    expect(wach.wach, isFalse);

    notifier(c).start();
    expect(wach.wach, isTrue);
    notifier(c).reset();
    expect(wach.wach, isFalse);
  });

  test('Bildschirm: Schalter aus ⇒ nie wach; mitten im Lauf ⇒ sofort frei', () async {
    final c = await bauen(_Uhr());
    notifier(c).setzeWachHalten(false);
    notifier(c).start();
    expect(wach.wach, isFalse);

    notifier(c).setzeWachHalten(true);
    expect(wach.wach, isTrue);
    notifier(c).setzeWachHalten(false);
    expect(wach.wach, isFalse);
  });

  test('Bildschirm: beim Zurückkehren erneut angefragt (Browser gibt beim Verbergen frei)',
      () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    final vorher = wach.anfragen;
    wach.wach = false; // der Browser hat die Sperre beim Sperren freigegeben

    uhr.vor(const Duration(seconds: 30));
    zurueck(c);

    expect(wach.anfragen, greaterThan(vorher));
    expect(wach.wach, isTrue);
  });

  test('Bildschirm: Phase zu Ende (ohne Auto) ⇒ freigegeben', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    uhr.vor(const Duration(minutes: 26));
    zurueck(c);
    expect(wach.wach, isFalse);
  });

  test('Phasenende: Banner + ein Ton; Banner bleibt bis zur nächsten Bedienung', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    expect(klang.vorbereitet, 1, reason: 'Ton wird beim Tippen auf Start freigegeben');

    uhr.vor(const Duration(minutes: 26));
    zurueck(c);

    expect(zustand(c).beendetePhase, PomodoroPhase.work);
    expect(klang.toene, 1);

    uhr.vor(const Duration(minutes: 5)); // Warten ändert am Banner nichts
    zurueck(c);
    expect(zustand(c).beendetePhase, PomodoroPhase.work);

    notifier(c).start();
    expect(zustand(c).beendetePhase, isNull);
  });

  test('Ton aus ⇒ kein Ton, Banner trotzdem', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).setzeKlang(false);
    notifier(c).start();
    uhr.vor(const Duration(minutes: 26));
    zurueck(c);

    expect(klang.toene, 0);
    expect(zustand(c).beendetePhase, PomodoroPhase.work);
  });

  test('Auto-weiter: nächste Phase läuft von selbst, Banner verschwindet nach 30 s',
      () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).setzeAutoWeiter(true);
    notifier(c).start();

    uhr.vor(const Duration(minutes: 26)); // 1 Minute in der Pause
    zurueck(c);

    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).running, isTrue);
    expect(zustand(c).secondsLeft, 4 * 60);
    expect(zustand(c).sessionCount, 1);
    expect(zustand(c).beendetePhase, PomodoroPhase.work);
    expect(klang.toene, 1);
    expect(wach.wach, isTrue);

    uhr.vor(const Duration(seconds: 31));
    zurueck(c);
    expect(zustand(c).beendetePhase, isNull);
    expect(zustand(c).running, isTrue);
  });

  test('Auto-weiter + lange Sperre: alle Phasen dazwischen werden nachgerechnet', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).setzeAutoWeiter(true);
    notifier(c).start();

    // 25 + 5 + 25 + 5 + 25 + 5 + 25 = 115 min ⇒ 4. Fokus fertig ⇒ lange Pause
    // läuft seit 2 Minuten.
    uhr.vor(const Duration(minutes: 117));
    zurueck(c);

    expect(zustand(c).phase, PomodoroPhase.longBreak);
    expect(zustand(c).sessionCount, 4);
    expect(zustand(c).secondsLeft, 13 * 60);
    expect(zustand(c).running, isTrue);
    expect(klang.toene, 1, reason: 'ein Ton für die ganze Sperre, nicht pro Phase');
  });

  test('Auto-weiter: Wochen Lücke ⇒ endet sauber, läuft weiter', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).setzeAutoWeiter(true);
    notifier(c).start();

    uhr.vor(const Duration(days: 21));
    zurueck(c);

    expect(zustand(c).running, isTrue);
    expect(zustand(c).secondsLeft, inInclusiveRange(1, zustand(c).phase.defaultSeconds));
  });

  test('Überspringen: ohne Auto ⇒ wartet; mit Auto und laufend ⇒ läuft weiter', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).start();
    notifier(c).skipPhase();
    expect(zustand(c).phase, PomodoroPhase.shortBreak);
    expect(zustand(c).running, isFalse);
    expect(zustand(c).sessionCount, 1);
    expect(wach.wach, isFalse);

    notifier(c).setzeAutoWeiter(true);
    notifier(c).start();
    notifier(c).skipPhase();
    expect(zustand(c).phase, PomodoroPhase.work);
    expect(zustand(c).running, isTrue);
    expect(zustand(c).secondsLeft, 25 * 60);
    expect(wach.wach, isTrue);
  });

  test('Reset behält die Schalter', () async {
    final c = await bauen(_Uhr());
    notifier(c).setzeAutoWeiter(true);
    notifier(c).setzeKlang(false);
    notifier(c).setzeWachHalten(false);
    notifier(c).reset();

    expect(zustand(c).autoWeiter, isTrue);
    expect(zustand(c).klang, isFalse);
    expect(zustand(c).wachHalten, isFalse);
  });

  test('Standard der Schalter: wach AN, Ton AN, Auto AUS', () async {
    final c = await bauen(_Uhr());
    expect(zustand(c).wachHalten, isTrue);
    expect(zustand(c).klang, isTrue);
    expect(zustand(c).autoWeiter, isFalse);
  });

  test('Schalter werden gesichert und wiederhergestellt', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr);
    notifier(c).setzeAutoWeiter(true);
    notifier(c).setzeKlang(false);
    notifier(c).setzeWachHalten(false);
    await notifier(c).gespeichert;

    final prefs = await SharedPreferences.getInstance();
    final c2 = await bauen(uhr, {kPomodoroKey: prefs.getString(kPomodoroKey)!});
    expect(zustand(c2).autoWeiter, isTrue);
    expect(zustand(c2).klang, isFalse);
    expect(zustand(c2).wachHalten, isFalse);
  });

  test('Wiederherstellen: laufend ⇒ Bildschirm wird gleich wieder wach gehalten', () async {
    final uhr = _Uhr();
    final c = await bauen(uhr, {
      kPomodoroKey: jsonEncode({
        'phase': 0,
        'sessionCount': 0,
        'secondsLeft': 25 * 60,
        'running': true,
        'endsAtMs': uhr.jetzt.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
      }),
    });
    expect(zustand(c).running, isTrue);
    expect(wach.wach, isTrue);
  });

  test('Alter Eintrag ohne Schalter ⇒ Standardwerte', () async {
    final c = await bauen(_Uhr(), {
      kPomodoroKey: jsonEncode({
        'phase': 0,
        'sessionCount': 1,
        'secondsLeft': 600,
        'running': false,
      }),
    });
    expect(zustand(c).wachHalten, isTrue);
    expect(zustand(c).klang, isTrue);
    expect(zustand(c).autoWeiter, isFalse);
    expect(zustand(c).secondsLeft, 600);
  });
}
