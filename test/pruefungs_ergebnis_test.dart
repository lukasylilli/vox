// FILE: test/pruefungs_ergebnis_test.dart
// PHASE: فاز T, Schritt T.1 (2026-09-25)
// PURPOSE: Testergebnisse — JSON, Nachsicht bei kaputten Daten, Vertrag
//          Fassung 5 (Sicherung, ältere Fassungen), Zusammenführen (nur
//          hinzufügen), Ablage über die Fassade und der Notifier.
import 'dart:convert';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/backup/pruefungs_ergebnis.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/features/pruefungen/controllers/pruefungs_ergebnisse_controller.dart';

PruefungsErgebnis erg(String id,
        {num punkte = 7, num max = 10, DateTime? am, String niveau = 'B1'}) =>
    PruefungsErgebnis(
      id: id,
      art: pruefungsArtGrammatikNiveau,
      niveau: niveau,
      am: am ?? DateTime.utc(2026, 9, 25, 10),
      dauerSekunden: 300,
      punkte: punkte,
      maxPunkte: max,
      bestanden: punkte / max >= 0.7,
      teile: {teilGrammatik: PruefungsTeil(punkte: punkte, maxPunkte: max)},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ergebnis', () {
    test('JSON hin und zurück', () {
      final e = erg('pr:#1');
      final z = PruefungsErgebnis.vonJson(jsonDecode(jsonEncode(e.toJson())))!;
      expect(z.toJson(), e.toJson());
      expect(z.anteil, closeTo(0.7, 1e-9));
      expect(z.teile[teilGrammatik]!.punkte, 7);
    });

    test('halbe Punkte bleiben erhalten (telc & Co.)', () {
      final e = erg('pr:#2', punkte: 37.5, max: 60);
      expect(PruefungsErgebnis.vonJson(e.toJson())!.punkte, 37.5);
    });

    test('Unbrauchbares wird still übergangen', () {
      final liste = PruefungsErgebnis.listeLesen([
        erg('pr:#ok').toJson(),
        'Unsinn',
        {'id': 'pr:#x'}, // ohne art, am, punkte
        {...erg('pr:#neg').toJson(), 'punkte': -1},
        {...erg('pr:#zuviel').toJson(), 'punkte': 11},
        {...erg('pr:#max0').toJson(), 'max': 0},
        {...erg('pr:#datum').toJson(), 'am': 'gestern'},
      ]);
      expect(liste.keys, ['pr:#ok']);
      expect(PruefungsErgebnis.listeLesen('keine Liste'), isEmpty);
    });

    test('kaputter Teil fällt heraus, der Rest bleibt', () {
      final j = erg('pr:#t').toJson()
        ..['teile'] = {
          'lesen': {'punkte': 5, 'max': 10},
          'hoeren': {'punkte': 12, 'max': 10},
        };
      expect(PruefungsErgebnis.vonJson(j)!.teile.keys, ['lesen']);
    });

    test('Zeitlimit und „Zeit abgelaufen" reisen mit', () {
      final e = PruefungsErgebnis(
        id: 'pr:#zeit',
        art: 'sim_oesd_a1',
        niveau: 'A1',
        am: DateTime.utc(2026, 9, 25),
        dauerSekunden: 3600,
        zeitLimitSekunden: 3600,
        zeitAbgelaufen: true,
        punkte: 20,
        maxPunkte: 60,
      );
      final z = PruefungsErgebnis.vonJson(jsonDecode(jsonEncode(e.toJson())))!;
      expect(z.zeitLimitSekunden, 3600);
      expect(z.zeitAbgelaufen, isTrue);
      // Ohne Ablauf und ohne Limit: keine Felder (Text bleibt schlank).
      expect(erg('pr:#1').toJson().containsKey('zeitAbgelaufen'), isFalse);
      expect(erg('pr:#1').toJson().containsKey('limit'), isFalse);
    });

    test('Teile: echte Zeugnis-Reihenfolge, dann Unbekanntes alphabetisch', () {
      final e = PruefungsErgebnis(
        id: 'pr:#t',
        art: 'sim',
        am: DateTime.utc(2026),
        punkte: 4,
        maxPunkte: 8,
        teile: const {
          'zmodul': PruefungsTeil(punkte: 1, maxPunkte: 2),
          teilSprechen: PruefungsTeil(punkte: 1, maxPunkte: 2),
          teilLesen: PruefungsTeil(punkte: 1, maxPunkte: 2),
          teilHoeren: PruefungsTeil(punkte: 1, maxPunkte: 2),
        },
      );
      expect(e.teileGeordnet.map((x) => x.key),
          [teilLesen, teilHoeren, teilSprechen, 'zmodul']);
    });

    test('vollständig: nur als Ganzes abgelegt', () {
      final e = erg('pr:#v');
      expect(e.vollstaendig([teilGrammatik]), isTrue);
      expect(e.vollstaendig([teilLesen, teilHoeren]), isFalse);
    });

    test('id: pr:# + 32 Hex, geräteunabhängig zufällig', () {
      final a = neuePruefungsId(Random(1));
      expect(a, matches(RegExp(r'^pr:#[0-9a-f]{32}$')));
      expect(neuePruefungsId(Random(2)), isNot(a));
    });
  });

  group('Vertrag Fassung 5', () {
    test('Version ist 5', () => expect(nutzerZustandVersion, 5));

    test('Ergebnisse reisen in der Sicherung mit', () {
      final z = NutzerZustand(pruefungen: {'pr:#1': erg('pr:#1')});
      final gelesen = sicherungLesen(sicherungSchreiben(z)).zustand;
      expect(gelesen.pruefungen['pr:#1']!.niveau, 'B1');
      expect(gelesen.istLeer, isFalse);
    });

    test('ohne Ergebnisse: kein Feld (Text bleibt wie Fassung 4)', () {
      expect(const NutzerZustand().toJson().containsKey('pruefungen'), isFalse);
    });

    test('Fassung 4 ohne Feld wird gelesen ⇒ keine Ergebnisse', () {
      final alt = jsonEncode({
        'version': 4,
        'app': 'vox',
        'payload': {'leitner': {}, 'kategorien': [], 'notizen': {}},
      });
      expect(sicherungLesen(alt).zustand.pruefungen, isEmpty);
    });

    test('Zusammenführen vereinigt — nichts geht verloren, nichts doppelt', () {
      final a = NutzerZustand(
          pruefungen: {'pr:#1': erg('pr:#1'), 'pr:#2': erg('pr:#2')});
      final b = NutzerZustand(
          pruefungen: {'pr:#2': erg('pr:#2'), 'pr:#3': erg('pr:#3')});
      expect(a.zusammenfuehren(b).pruefungen.keys.toSet(),
          {'pr:#1', 'pr:#2', 'pr:#3'});
      expect(b.zusammenfuehren(a).pruefungen.length, 3);
    });

    test('gleicher Inhalt ⇒ gleicher Text, egal in welcher Reihenfolge', () {
      final a = NutzerZustand(
          pruefungen: {'pr:#b': erg('pr:#b'), 'pr:#a': erg('pr:#a')});
      final b = NutzerZustand(
          pruefungen: {'pr:#a': erg('pr:#a'), 'pr:#b': erg('pr:#b')});
      expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
    });
  });

  group('Ablage', () {
    Future<UserStateRepository> geraet(
        {Map<String, Object> prefs = const {}}) async {
      SharedPreferences.setMockInitialValues(prefs);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      return UserStateRepository(db, await SharedPreferences.getInstance());
    }

    test('merken fügt hinzu, ändert nie Vorhandenes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await pruefungMerken(prefs, erg('pr:#1'));
      await pruefungMerken(prefs, erg('pr:#2', punkte: 3));
      await pruefungMerken(prefs, erg('pr:#1', punkte: 1)); // gleiche id
      final alle = pruefungenLesen(prefs);
      expect(alle.length, 2);
      expect(alle['pr:#1']!.punkte, 7);
    });

    test('unlesbarer Schlüssel ⇒ leer statt Absturz', () async {
      SharedPreferences.setMockInitialValues({kPruefungenKey: '{kaputt'});
      expect(pruefungenLesen(await SharedPreferences.getInstance()), isEmpty);
    });

    test('Gerätewechsel: Ergebnisse kommen an und vereinigen sich', () async {
      final alt = await geraet();
      await alt.anwenden(NutzerZustand(pruefungen: {'pr:#1': erg('pr:#1')}));
      final gesichert = await alt.lesen();
      expect(gesichert.pruefungen.keys, ['pr:#1']);

      final neu = await geraet(prefs: {
        kPruefungenKey: jsonEncode([erg('pr:#2').toJson()]),
      });
      final z = await neu.anwenden(gesichert);
      expect(z.pruefungen.keys.toSet(), {'pr:#1', 'pr:#2'});
      expect((await neu.lesen()).pruefungen.length, 2);
    });
  });

  group('Notifier', () {
    test('liest, merkt und liefert Neueste zuerst', () async {
      SharedPreferences.setMockInitialValues({
        kPruefungenKey: jsonEncode(
            [erg('pr:#alt', am: DateTime.utc(2026, 9, 1)).toJson()]),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect((await c.read(pruefungsErgebnisseProvider.future)).length, 1);
      await c
          .read(pruefungsErgebnisseProvider.notifier)
          .merken(erg('pr:#neu', am: DateTime.utc(2026, 9, 25)));
      final liste = c.read(pruefungsErgebnisseProvider).value!;
      expect(liste.map((e) => e.id), ['pr:#neu', 'pr:#alt']);
    });
  });
}
