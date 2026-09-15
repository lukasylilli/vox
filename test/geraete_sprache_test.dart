// L.3 (2026-09-16): Startsprache — Englisch, außer das Gerät spricht Persisch.
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/l10n/geraete_sprache.dart';
import 'package:vox/features/more/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeraeteSprache.aus', () {
    test('Englisches Gerät → en', () {
      expect(GeraeteSprache.aus(const [Locale('en', 'US')]), 'en');
    });

    test('Persisches Gerät → fa (auch fa-AF und Dari)', () {
      expect(GeraeteSprache.aus(const [Locale('fa', 'IR')]), 'fa');
      expect(GeraeteSprache.aus(const [Locale('fa', 'AF')]), 'fa');
      expect(GeraeteSprache.aus(const [Locale('prs')]), 'fa');
    });

    test('Nicht unterstützte Sprache → Englisch', () {
      expect(GeraeteSprache.aus(const [Locale('de', 'AT')]), 'en');
      expect(GeraeteSprache.aus(const [Locale('tr')]), 'en');
      expect(GeraeteSprache.aus(const []), 'en');
    });

    test('Erste unterstützte Gerätesprache entscheidet', () {
      expect(GeraeteSprache.aus(const [Locale('de'), Locale('fa')]), 'fa');
      expect(GeraeteSprache.aus(const [Locale('de'), Locale('en'), Locale('fa')]), 'en');
      expect(GeraeteSprache.aus(const [Locale('en'), Locale('fa')]), 'en');
    });
  });

  group('SettingsNotifier — ui_language', () {
    Future<String> ladeSprache() async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final s = await container.read(settingsProvider.future);
      return s.uiLanguage;
    }

    test('ohne gespeicherte Wahl: Gerätesprache', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await ladeSprache(), GeraeteSprache.aktuell);
    });

    test('gespeicherte Wahl hat Vorrang', () async {
      SharedPreferences.setMockInitialValues({'ui_language': 'fa'});
      expect(await ladeSprache(), 'fa');
      SharedPreferences.setMockInitialValues({'ui_language': 'en'});
      expect(await ladeSprache(), 'en');
    });

    test('ungültiger Wert wird ignoriert', () async {
      SharedPreferences.setMockInitialValues({'ui_language': 'xx'});
      expect(await ladeSprache(), GeraeteSprache.aktuell);
    });
  });
}
