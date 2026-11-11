// FILE: test/routen_test.dart
// PURPOSE: Audit 2026-11-11, Paket 7 — jede Adresse in
//          lib/core/constants/app_routes.dart muss im Router
//          (lib/core/router/app_router.dart) auf eine Seite führen. Bisher
//          hatte der Router keinen Test: eine Adresse ohne Seite fiel erst
//          auf, wenn ein Nutzer auf den Knopf tippte.
//
//          Dart kann die Konstanten nicht aufzählen — deshalb liest der Test
//          die Datei als Text. Platzhalter (`:id`) werden durch `1` ersetzt.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/router/app_router.dart';

void main() {
  test('jede Adresse aus AppRoutes führt im Router auf eine Seite', () {
    final quelle =
        File('lib/core/constants/app_routes.dart').readAsStringSync();
    final konstanten = RegExp(
      r"static const (?:String )?(\w+)\s*=\s*'([^']*)'",
    ).allMatches(quelle).toList();
    expect(konstanten.length, greaterThan(50),
        reason: 'app_routes.dart wurde nicht richtig gelesen');

    final dynamic konfiguration = appRouter.configuration;
    final ohneSeite = <String>[];
    for (final k in konstanten) {
      final name = k.group(1)!;
      final pfad = k.group(2)!.replaceAll(RegExp(r':\w+'), '1');
      dynamic treffer;
      try {
        treffer = konfiguration.findMatch(Uri.parse(pfad));
      } on TypeError {
        treffer = konfiguration.findMatch(pfad);
      }
      if (treffer.isError as bool) ohneSeite.add('$name = $pfad');
    }
    expect(ohneSeite, isEmpty,
        reason: 'Adressen ohne Seite im Router:\n${ohneSeite.join('\n')}');
  });
}
