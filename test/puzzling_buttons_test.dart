// FILE: test/puzzling_buttons_test.dart
// PHASE: B (Puzzling-Prinzip) — Wächter nachgerüstet 2026-09-15
// PURPOSE: Hält die Regel aus PLAN.md → فاز B fest: In `lib/features` gibt es
//          keine rohen Material-Buttons; jeder Button ist eine Referenz auf
//          `core/widgets/vox_button.dart` (VoxButton / VoxIconButton / VoxFab /
//          VoxOptionButton).
//
//          Bisher stand die Regel nur als grep-Befehl im PLAN — und fiel prompt
//          durch: S.2 und S.3 Schritt 2 haben in `settings_screen.dart` fünf
//          rohe Buttons eingeführt, ohne dass CI es bemerkte. Dieser Test macht
//          aus der Regel eine Prüfung.
//
// ⚠️ Erlaubt bleiben Buttons in `lib/core/widgets/` — dort WIRD das Design
//    System gebaut. Geprüft wird nur `lib/features/`.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/features enthält keine rohen Material-Buttons', () {
    // `\b` sorgt dafür, dass `VoxIconButton(` NICHT als `IconButton(` zählt.
    final roh = RegExp(
      r'\b(IconButton|TextButton|OutlinedButton|FilledButton|'
      r'ElevatedButton|FloatingActionButton)(\.[A-Za-z]+)?\(',
    );

    final funde = <String>[];
    final dateien = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final datei in dateien) {
      final zeilen = datei.readAsLinesSync();
      for (var i = 0; i < zeilen.length; i++) {
        final zeile = zeilen[i].trimLeft();
        if (zeile.startsWith('//')) continue;
        if (roh.hasMatch(zeile)) {
          funde.add('${datei.path}:${i + 1}: $zeile');
        }
      }
    }

    expect(
      funde,
      isEmpty,
      reason: 'Rohe Buttons gefunden — stattdessen VoxButton / VoxIconButton / '
          'VoxFab aus core/widgets/vox_button.dart verwenden:\n'
          '${funde.join('\n')}',
    );
  });
}
