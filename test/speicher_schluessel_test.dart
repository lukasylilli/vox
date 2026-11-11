// FILE: test/speicher_schluessel_test.dart
// PURPOSE: Wächter (Audit 2026-11-11, Paket 6) — VOX und Root-in liegen auf
//          derselben Herkunft (lukasylilli.github.io) und teilen sich deshalb
//          den Browser-Speicher: shared_preferences legt jeden Schlüssel als
//          `flutter.<name>` in localStorage ab, für BEIDE Apps. Ein gleicher
//          Name mit anderem Inhalt hat VOX schon einmal lahmgelegt
//          (`theme_mode`, 2026-09-26).
//
//          Regel: Jeder NEUE Schlüssel beginnt mit `vox_`. Die alten Namen
//          unten bleiben, wie sie sind — ein Umbenennen würde die
//          Einstellungen und den Lernstand der Nutzer verlieren.
//
//          Rot? Dann steht in einer Datei, die SharedPreferences benutzt, eine
//          neue Textkonstante. Ist sie ein Speicherschlüssel ⇒ `vox_`
//          davorsetzen. Ist sie keiner ⇒ unten bei [keineSchluessel] eintragen.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Schlüssel aus der Zeit vor der Regel — eingefroren, nie erweitern.
const alteSchluessel = {
  'theme_mode',
  'tts_rate',
  'tts_language',
  'current_level',
  'daily_goal_min',
  'ui_language',
  'grammatik_sort_mode',
  'pomodoro_zustand_v1',
  'vocab_seeded_v3',
  'vokab_user_leitner_v1',
  'vokab_user_kategorien_v1',
  'vokab_user_notizen_v1',
};

/// Textkonstanten in denselben Dateien, die KEIN Speicherschlüssel sind.
const keineSchluessel = {
  'eigen:', // Präfix für eigene Wörter im Lernstand
  'leitner', 'liste', 'listenwort', 'wort', // Arten einer Mitgliedschaft
  'vox', // App-Kennung in der Sicherungshülle
};

void main() {
  test('neue Speicherschlüssel beginnen mit vox_', () {
    final konstante =
        RegExp(r"const\s+(?:String\s+)?\w+\s*=\s*'([^'\n]*)'\s*;");
    final direkt = RegExp(
      r"\.(?:get|getString|getBool|getInt|getDouble|getStringList|setString|"
      r"setBool|setInt|setDouble|setStringList|remove|containsKey)"
      r"\(\s*'([^'\n]*)'",
    );
    final verstoesse = <String>[];
    var dateien = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('.g.dart')) continue;
      final text = f.readAsStringSync();
      if (!text.contains('SharedPreferences')) continue;
      dateien++;
      final namen = {
        ...konstante.allMatches(text).map((m) => m.group(1)!),
        ...direkt.allMatches(text).map((m) => m.group(1)!),
      };
      for (final name in namen) {
        if (name.startsWith('vox_')) continue;
        if (name.contains(r'$')) continue; // zusammengesetzt aus Konstanten
        if (alteSchluessel.contains(name)) continue;
        if (keineSchluessel.contains(name)) continue;
        verstoesse.add('${f.path}: «$name»');
      }
    }
    expect(dateien, greaterThan(5), reason: 'Suche findet die Dateien nicht');
    expect(
      verstoesse,
      isEmpty,
      reason: 'Neuer Speicherschlüssel ohne vox_ (geteilter Browser-Speicher '
          'mit Root-in) — siehe Kopf dieser Datei',
    );
  });
}
