// 2026-09-26: Farbschema aus dem Browser-Speicher — nur eine gültige Zahl zählt.
// Hintergrund: Root-in (gleiche Herkunft lukasylilli.github.io) schrieb bis
// Root-in PLAN 31.8 `theme_mode` als Text in denselben Speicher.
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/features/more/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemeMode> ladeFarbschema() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final s = await container.read(settingsProvider.future);
    return s.themeMode;
  }

  test('gespeicherte Zahl gilt (2 = dunkel)', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 2});
    expect(await ladeFarbschema(), ThemeMode.dark);
  });

  test('ohne Eintrag: System', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await ladeFarbschema(), ThemeMode.system);
  });

  test('Text von Root-in ("dark") bringt Vox nicht zum Absturz', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    expect(await ladeFarbschema(), ThemeMode.system);
  });

  test('Zahl außerhalb des Bereichs: System', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 7});
    expect(await ladeFarbschema(), ThemeMode.system);
  });
}
