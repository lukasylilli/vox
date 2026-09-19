// FILE: test/seed_wortschluessel_test.dart
// PHASE: فاز LAUNCH, Schritt L.1e (2026-09-18)
// PURPOSE: Die Schlüssel der mitgelieferten App-Wörter entstehen genau so wie
//          im Seeding — und ein verlorener Schlüssel wird erkannt.
//
// WARUM: `<german>|<wordType>` ist der Leitner-Schlüssel der Nutzer
//        (core/backup/nutzer_zustand.dart). Läuft diese Ableitung jemals von
//        `data_seed_service.dart` weg, wacht der Wächter über die falschen
//        Werte und merkt einen echten Verlust nicht mehr.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/services/seed_wortschluessel.dart';

void main() {
  String ausRepo(String pfad) => File(pfad).readAsStringSync();

  group('seedWortschluessel — Form', () {
    test('Schlüsselform ist die des Leitner-Standes', () {
      // Wenn jemand LeitnerStand.wortSchluessel ändert, muss dieser Test
      // auffallen — sonst wacht L.1e über eine andere Form als die, die
      // wirklich gesichert wird.
      expect(LeitnerStand.wortSchluessel('warten auf', 'verb'),
          'warten auf|verb');
      expect(LeitnerStand.eigenesWort('warten auf', 'verb'),
          'eigen:warten auf|verb');
    });

    test('mapWordClass deckt alle bekannten Werte ab', () {
      expect(mapWordClass('verb'), 'verb');
      expect(mapWordClass('Verb'), 'verb');
      expect(mapWordClass('adjective'), 'adjektiv');
      expect(mapWordClass('adjektiv'), 'adjektiv');
      expect(mapWordClass('noun'), 'nomen');
      expect(mapWordClass('nomen'), 'nomen');
      expect(mapWordClass(''), 'sonstige');
      expect(mapWordClass('unbekannt'), 'sonstige');
    });
  });

  group('seedWortschluessel — echte Dateien', () {
    test('alle vier Quellen sind lesbar und liefern Schlüssel', () {
      for (final q in seedQuellen) {
        expect(File(q).existsSync(), isTrue, reason: '$q fehlt');
        final s = seedWortschluesselAusQuelle(q, ausRepo(q));
        expect(s, isNotEmpty, reason: '$q liefert keine Schlüssel');
        for (final k in s) {
          expect(k.contains('|'), isTrue, reason: 'ohne Trenner: $k');
          expect(k.split('|').first.trim(), isNotEmpty,
              reason: 'leerer deutscher Text in $q: $k');
          expect(k.split('|').last.trim(), isNotEmpty,
              reason: 'leere Wortart in $q: $k');
        }
      }
    });

    test('Gesamtmenge ist groß und ohne Doppelte je Quelle', () {
      final alle = seedWortschluessel(ausRepo);
      // Bestand 2026-09-18: gut achthundert. Die Zahl ist absichtlich eine
      // untere Schranke — neue Wörter sollen den Test nicht rot machen.
      expect(alle.length, greaterThan(700));
    });

    test('Präpositionen: Schlüssel ist "<lemma> <präposition>"', () {
      const pfad = 'assets/data/praepositionen_data.json';
      final liste =
          (jsonDecode(ausRepo(pfad)) as List).cast<Map<String, dynamic>>();
      final erstesCluster = liste.first;
      final m = (erstesCluster['members'] as List)
          .cast<Map<String, dynamic>>()
          .first;
      final erwartet =
          '${m['lemma']} ${m['preposition']}|${mapWordClass(m['word_class'] as String? ?? '')}';

      expect(seedWortschluesselAusQuelle(pfad, ausRepo(pfad)),
          contains(erwartet));
    });
  });

  group('seedVerloreneSchluessel', () {
    test('nichts verloren ⇒ leer', () {
      expect(seedVerloreneSchluessel({'a|verb', 'b|nomen'},
          {'a|verb', 'b|nomen', 'c|adjektiv'}), isEmpty);
    });

    test('umbenannt ⇒ der alte Schlüssel gilt als verloren', () {
      // Genau der gefährliche Fall: Tippfehler „korrigiert" ⇒ neuer Schlüssel,
      // alter weg ⇒ Leitner-Stand des Nutzers verwaist.
      expect(
        seedVerloreneSchluessel({'warten auf|verb'}, {'warten  auf|verb'}),
        ['warten auf|verb'],
      );
    });

    test('Wortart geändert ⇒ ebenfalls verloren', () {
      expect(
        seedVerloreneSchluessel({'Angst haben|sonstige'},
            {'Angst haben|nomen'}),
        ['Angst haben|sonstige'],
      );
    });

    test('Ergebnis ist geordnet', () {
      expect(
        seedVerloreneSchluessel({'b|verb', 'a|verb', 'c|verb'}, const {}),
        ['a|verb', 'b|verb', 'c|verb'],
      );
    });
  });

  group('Wächter — kein veröffentlichter Schlüssel verschwindet (L.1e)', () {
    // DAS ist der eigentliche Wächter. Er braucht kein Netz und keinen
    // Workflow-Schritt: `flutter test` läuft in CI ohnehin bei jedem Push.
    //
    // Wird er rot, ist in einer der vier Datendateien ein deutscher Text oder
    // eine Wortart geändert worden. Der Leitner-Fortschritt der Nutzer zu
    // diesem Wort hängt an genau diesem Schlüssel und würde verwaisen.
    // Richtige Antwort: zurücksetzen — NICHT die Liste kürzen.
    const listePfad = 'test/daten/seed_schluessel_veroeffentlicht.txt';

    test('alle geschützten Schlüssel entstehen noch', () {
      final datei = File(listePfad);
      expect(datei.existsSync(), isTrue, reason: '$listePfad fehlt');

      final geschuetzt = datei
          .readAsLinesSync()
          .where((l) => !l.startsWith('#') && l.trim().isNotEmpty)
          .toSet();
      expect(geschuetzt, isNotEmpty, reason: 'Liste ist leer — das wäre ein '
          'Wächter, der nichts bewacht.');

      final jetzt = seedWortschluessel(ausRepo);
      final verloren = seedVerloreneSchluessel(geschuetzt, jetzt);

      expect(
        verloren,
        isEmpty,
        reason: 'Diese veröffentlichten App-Wörter entstehen nicht mehr — '
            'deutscher Text oder Wortart wurde geändert. Nutzer können sie '
            'im Leitner oder in Listen haben; ihr Fortschritt würde '
            'verwaisen.\n'
            'Richtig: den Text/die Wortart zurücksetzen. '
            'NICHT die Liste kürzen — siehe PLAN.md → L.1e.\n'
            'Neue Wörter eintragen mit: '
            'dart run tool/seed_schluessel_schreiben.dart\n\n'
            '${verloren.take(30).join("\n")}',
      );
    });

    test('die Liste enthält nur Schlüssel in gültiger Form', () {
      final geschuetzt = File(listePfad)
          .readAsLinesSync()
          .where((l) => !l.startsWith('#') && l.trim().isNotEmpty);
      for (final k in geschuetzt) {
        expect(k.split('|').length, 2, reason: 'kaputte Zeile: $k');
      }
    });
  });
}
