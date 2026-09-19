// FILE: test/feature_flags_test.dart
// PURPOSE: Haelt fest, dass der Zustand `hidden` in FeatureFlags wirklich
//          wirkt (PLAN.md -> L.2d: "die finale Fassung hat keine
//          Kommt-bald-Knoepfe; ein Deck ohne Inhalt wird vor der
//          Veroeffentlichung versteckt").
//
//          Vorher war `FeatureState.hidden` zwar definiert, wurde aber von
//          keinem Bildschirm beachtet, und die Home-Kacheln Sprechen/Schreiben
//          lasen die Flags gar nicht. "Verstecken" waere also ein Einzeiler
//          gewesen, der nichts bewirkt. Dieser Test verhindert, dass das
//          still wieder passiert.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/services/feature_flags.dart';

void main() {
  group('FeatureFlags.resolve', () {
    const tabelle = {
      'a': FeatureState.live,
      'b': FeatureState.comingSoon,
      'c': FeatureState.hidden,
    };

    test('bekannte Schluessel liefern ihren Zustand', () {
      expect(FeatureFlags.resolve(tabelle, 'a'), FeatureState.live);
      expect(FeatureFlags.resolve(tabelle, 'b'), FeatureState.comingSoon);
      expect(FeatureFlags.resolve(tabelle, 'c'), FeatureState.hidden);
    });

    test('unbekannter und leerer Schluessel = live (fail open)', () {
      expect(FeatureFlags.resolve(tabelle, 'gibt-es-nicht'), FeatureState.live);
      expect(FeatureFlags.resolve(tabelle, ''), FeatureState.live);
    });
  });

  group('FeatureFlags: Pruedikate sind widerspruchsfrei', () {
    test('jeder ausgelieferte Schluessel ist genau live, comingSoon oder hidden',
        () {
      for (final key in FeatureFlags.keys) {
        final zustaende = [
          FeatureFlags.isLive(key),
          FeatureFlags.isComingSoon(key),
          FeatureFlags.isHidden(key),
        ].where((b) => b).length;
        expect(zustaende, 1, reason: key);
        expect(FeatureFlags.isVisible(key), !FeatureFlags.isHidden(key),
            reason: key);
      }
    });

    test('leerer Schluessel (immer live) ist sichtbar', () {
      expect(FeatureFlags.isVisible(''), isTrue);
    });
  });

  group('Bildschirme beachten `hidden`', () {
    // Quelltext-Waechter (gleiche Bauart wie deutscher_text_waechter_test):
    // Kein Widget-Test noetig, weil es nur darum geht, dass die Abfrage
    // ueberhaupt dasteht.
    String lies(String pfad) => File(pfad).readAsStringSync();

    test('Home-Kacheln Sprechen und Schreiben fragen die Flags ab', () {
      final home = lies('lib/features/home/screens/home_screen.dart');
      expect(home, contains("FeatureFlags.isVisible('feature.sprechen')"));
      expect(home, contains("FeatureFlags.isVisible('feature.schreiben')"));
    });

    test('Auswendiglernen-Liste blendet versteckte Decks aus', () {
      final s = lies(
          'lib/features/auswendiglernen/screens/auswendiglernen_home_screen.dart');
      expect(
          RegExp(r'_learningDecks\s*\.where\(\(d\) => FeatureFlags\.isVisible\(d\.flag\)\)')
              .hasMatch(s),
          isTrue);
      expect(
          RegExp(r'_pruefungenDecks\s*\.where\(\(d\) => FeatureFlags\.isVisible\(d\.flag\)\)')
              .hasMatch(s),
          isTrue);
    });
  });
}
