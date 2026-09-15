// FILE: test/l10n_paritaet_test.dart
// PHASE: فاز S (2026-09-15)
// PURPOSE: Die App ist zweisprachig (FA/EN, umschaltbar in den Einstellungen).
//          Fehlt ein Schlüssel in einer Sprache, fällt AppL10n.t still auf EN
//          oder auf den Schlüsselnamen zurück — der Nutzer sieht dann rohen
//          Text wie "storage_ok_title". Dieser Test macht das sichtbar,
//          BEVOR es veröffentlicht wird.
//
// Aufbau der MaterialApp bewusst 1:1 wie in test/vokabular_test.dart —
// mit den Global*Localizations aus flutter_localizations. Die
// Default*Localizations kennen kein Farsi und lassen den Test scheitern.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/l10n/app_l10n.dart';

void main() {
  // Die Schlüssel aus فاز S. Wächst die Liste, wächst der Schutz.
  const schluessel = [
    'section_storage',
    'storage_ok_title',
    'storage_ok_sub',
    'storage_warn_title',
    'storage_warn_sub',
    'storage_how_ios',
    'storage_how_android',
    'storage_how_desktop',
  ];

  // t() braucht einen BuildContext, die Textmap selbst ist privat — deshalb
  // über einen echten Widget-Baum lesen.
  Future<String> hole(WidgetTester tester, String sprache, String key) async {
    late String ergebnis;
    await tester.pumpWidget(MaterialApp(
      locale: Locale(sprache),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        ergebnis = AppL10n.t(context, key);
        return const SizedBox.shrink();
      }),
    ));
    return ergebnis;
  }

  testWidgets('Speicher-Texte gibt es in beiden Sprachen', (tester) async {
    for (final k in schluessel) {
      for (final sprache in ['fa', 'en']) {
        final wert = await hole(tester, sprache, k);
        expect(wert, isNot(k),
            reason: 'Schlüssel "$k" fehlt in "$sprache" — '
                'AppL10n.t fällt auf den Schlüsselnamen zurück.');
        expect(wert.trim(), isNotEmpty, reason: '"$k" ($sprache) ist leer.');
      }
    }
  });

  testWidgets('FA und EN sind wirklich verschiedene Texte', (tester) async {
    for (final k in schluessel) {
      final fa = await hole(tester, 'fa', k);
      final en = await hole(tester, 'en', k);
      expect(fa, isNot(en),
          reason: 'Für "$k" liefern FA und EN denselben Text — '
              'vermutlich fehlt der FA-Eintrag und EN ist der Fallback.');
    }
  });
}
