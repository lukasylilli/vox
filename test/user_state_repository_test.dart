// FILE: test/user_state_repository_test.dart
// PHASE: فاز S, Schritt S.0a-2 (2026-09-15)
// PURPOSE: Prüft die Fassade gegen eine ECHTE Datenbank im Speicher
//          (AppDatabase.forTesting, wie test/data_seed_test.dart) plus
//          nachgebildete SharedPreferences.
//
// Die wichtigste Zusicherung: eine Sicherung überlebt den Gerätewechsel.
// Dafür wird ein zweites, leeres „Gerät" gebaut und der Zustand dorthin
// übertragen — genau dort fiele eine gerätelokale Nummer auf.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<UserStateRepository> geraet(
      {Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return UserStateRepository(db, await SharedPreferences.getInstance());
  }

  test('leeres Gerät liefert einen leeren Zustand', () async {
    final repo = await geraet();
    expect((await repo.lesen()).istLeer, isTrue);
  });

  test('liest alle Quellen in EINEN Zustand '
      '(Notizen aus prefs, Archiv-Leitner via Übergangspfad)', () async {
    final repo = await geraet(prefs: {
      'vokab_user_leitner_v1':
          '{"adjektiv_stolz":{"box":3,"nextReviewDate":"2026-10-01T00:00:00.000"}}',
      'vokab_user_notizen_v1': '{"verb_helfen":{"text":"Dativ!","farben":{}}}',
      'ui_language': 'fa',
      'daily_goal_min': 20,
    });
    await repo.anwenden(const NutzerZustand(eigeneWoerter: [
      {'german': 'Feierabend', 'wordType': 'nomen', 'meaningFa': 'پایان کار'},
    ]));

    final z = await repo.lesen();
    expect(z.leitner['adjektiv_stolz']!.fach, 3); // aus den Einstellungen
    expect(z.notizen['verb_helfen']!.text, 'Dativ!');
    expect(z.einstellungen['ui_language'], 'fa');
    expect(z.einstellungen['daily_goal_min'], 20);
    expect(z.eigeneWoerter.single['german'], 'Feierabend'); // aus der Datenbank
  });

  test('gesicherte eigene Wörter tragen KEINE gerätelokale Nummer', () async {
    final repo = await geraet();
    await repo.anwenden(const NutzerZustand(eigeneWoerter: [
      {'german': 'Bank', 'wordType': 'nomen', 'meaningFa': 'نیمکت'},
    ]));
    final wort = (await repo.lesen()).eigeneWoerter.single;
    expect(wort.containsKey('id'), isFalse,
        reason: 'Die drift-Nummer bezeichnet auf einem anderen Gerät ein '
            'anderes Wort und darf eine Sicherung nie verlassen.');
    expect(wort.containsKey('createdAt'), isFalse);
  });

  test('Gerätewechsel: Sicherung schreiben, auf leerem Gerät einspielen',
      () async {
    final alt = await geraet(prefs: {
      'vokab_user_leitner_v1': '{"adjektiv_stolz":{"box":4}}',
      'ui_language': 'en',
    });
    await alt.anwenden(const NutzerZustand(
      eigeneWoerter: [
        {'german': 'Feierabend', 'wordType': 'nomen', 'meaningFa': 'پایان کار'},
      ],
      kategorien: [
        KategorieStand(
            id: 'eigen:Prüfung',
            name: 'Prüfung',
            wortIds: ['eigen:Feierabend|nomen']),
      ],
    ));
    // Eigenes Wort zusätzlich in den Leitner-Stapel legen.
    await alt.anwenden(NutzerZustand(leitner: {
      'eigen:Feierabend|nomen': const LeitnerStand(
          wortId: 'eigen:Feierabend|nomen', fach: 2),
    }));

    final datei = sicherungSchreiben(await alt.lesen());

    final neu = await geraet();
    await neu.anwenden(sicherungLesen(datei).zustand);
    final z = await neu.lesen();

    expect(z.leitner['adjektiv_stolz']!.fach, 4);
    expect(z.leitner['eigen:Feierabend|nomen']!.fach, 2);
    expect(z.eigeneWoerter.single['german'], 'Feierabend');
    expect(z.einstellungen['ui_language'], 'en');
    final kat = z.kategorien.firstWhere((k) => k.name == 'Prüfung');
    expect(kat.wortIds, ['eigen:Feierabend|nomen']);
  });

  test('Einspielen nimmt nichts weg und das höhere Fach gewinnt', () async {
    final repo = await geraet(prefs: {
      'vokab_user_leitner_v1': '{"a":{"box":5},"nur_hier":{"box":2}}',
    });
    await repo.anwenden(NutzerZustand(leitner: {
      'a': const LeitnerStand(wortId: 'a', fach: 1), // niedriger — verliert
      'neu': const LeitnerStand(wortId: 'neu', fach: 3),
    }));
    final z = await repo.lesen();
    expect(z.leitner['a']!.fach, 5);
    expect(z.leitner['nur_hier']!.fach, 2, reason: 'darf nicht verschwinden');
    expect(z.leitner['neu']!.fach, 3);
  });

  test('zweimal einspielen ändert beim zweiten Mal nichts', () async {
    final repo = await geraet();
    const zustand = NutzerZustand(
      eigeneWoerter: [
        {'german': 'Bank', 'wordType': 'nomen', 'meaningFa': 'نیمکت'},
      ],
      kategorien: [
        KategorieStand(
            id: 'eigen:Liste', name: 'Liste', wortIds: ['eigen:Bank|nomen']),
      ],
    );
    await repo.anwenden(zustand);
    final ersteLesung = await repo.lesen();
    await repo.anwenden(zustand);
    final zweiteLesung = await repo.lesen();

    expect(zweiteLesung.eigeneWoerter.length, ersteLesung.eigeneWoerter.length);
    expect(zweiteLesung.kategorien.length, ersteLesung.kategorien.length);
    expect(zweiteLesung.kategorien.single.wortIds,
        ersteLesung.kategorien.single.wortIds);
  });

  test('nur bekannte Einstellungen werden gesichert', () async {
    final repo = await geraet(prefs: {
      'ui_language': 'fa',
      'vocab_seed_version': 7, // technischer Marker — gehört dem Nutzer nicht
    });
    final z = await repo.lesen();
    expect(z.einstellungen.containsKey('ui_language'), isTrue);
    expect(z.einstellungen.containsKey('vocab_seed_version'), isFalse);
  });

  test('S.0b Übergang: Archiv-Leitner aus SharedPreferences wandert nach '
      'drift, der alte Schlüssel wird danach geleert', () async {
    final repo = await geraet(prefs: {
      'vokab_user_leitner_v1': '{"adjektiv_stolz":{"box":3}}',
    });
    await repo.anwenden(const NutzerZustand()); // stößt die Übernahme an

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vokab_user_leitner_v1'), isNull,
        reason: 'nach der Übernahme ist der alte Schlüssel überflüssig');

    final z = await repo.lesen();
    expect(z.leitner['adjektiv_stolz']!.fach, 3,
        reason: 'der Stand selbst darf beim Umzug nicht verloren gehen');
  });

  test('S.0b Übergang: drift-Stand gewinnt, wenn er neuer ist als der alte '
      'Schlüssel', () async {
    final repo = await geraet(prefs: {
      'vokab_user_leitner_v1': '{"adjektiv_stolz":{"box":1}}',
    });
    // Ein Gerät hat den Stand schon nach drift gebracht, mit höherem Fach.
    await repo.anwenden(NutzerZustand(leitner: {
      'adjektiv_stolz':
          const LeitnerStand(wortId: 'adjektiv_stolz', fach: 5),
    }));
    expect((await repo.lesen()).leitner['adjektiv_stolz']!.fach, 5);
  });

  test('S.0c: Archiv-Listen liegen in drift und überstehen einen '
      'Gerätewechsel wie eigene Wörter', () async {
    final alt = await geraet();
    await alt.anwenden(const NutzerZustand(kategorien: [
      KategorieStand(
          id: 'archiv_1', name: 'Prüfung', wortIds: ['adjektiv_stolz']),
    ]));

    final datei = sicherungSchreiben(await alt.lesen());
    final neu = await geraet();
    await neu.anwenden(sicherungLesen(datei).zustand);

    final kat = (await neu.lesen()).kategorien.single;
    expect(kat.id, 'archiv_1');
    expect(kat.wortIds, ['adjektiv_stolz']);
  });

  test('S.0c Übergang: Archiv-Listen aus SharedPreferences wandern nach '
      'drift, der alte Schlüssel wird danach geleert', () async {
    final repo = await geraet(prefs: {
      'vokab_user_kategorien_v1':
          '[{"id":"archiv_1","name":"Prüfung","wortIds":["adjektiv_stolz"]}]',
    });
    await repo.anwenden(const NutzerZustand()); // stößt die Übernahme an

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vokab_user_kategorien_v1'), isNull);

    final kat = (await repo.lesen()).kategorien.single;
    expect(kat.name, 'Prüfung');
    expect(kat.wortIds, ['adjektiv_stolz']);
  });

  test('S.0c: mehrere Wörter in derselben Archiv-Liste bleiben getrennt '
      'zählbar (n:m, nicht überschrieben)', () async {
    final repo = await geraet();
    await repo.anwenden(const NutzerZustand(kategorien: [
      KategorieStand(
          id: 'archiv_1',
          name: 'Prüfung',
          wortIds: ['adjektiv_stolz', 'verb_helfen']),
    ]));
    final kat = (await repo.lesen()).kategorien.single;
    expect(kat.wortIds.toSet(), {'adjektiv_stolz', 'verb_helfen'});
  });

  test('B-12: Grammatikfelder eigener Wörter überleben den Gerätewechsel',
      () async {
    final alt = await geraet();
    await alt.anwenden(const NutzerZustand(eigeneWoerter: [
      {
        'german': 'aufstehen',
        'wordType': 'verb',
        'meaningFa': 'بلند شدن',
        'regelmaessig': false,
        'trennbar': true,
      },
      {
        'german': 'wegen',
        'wordType': 'praeposition',
        'meaningFa': 'به خاطر',
        'grammatikDetail': 'genitiv',
      },
    ]));
    final sicherung = await alt.lesen();

    final neu = await geraet();
    await neu.anwenden(sicherung);
    final woerter = {
      for (final w in (await neu.lesen()).eigeneWoerter) w['german']: w,
    };
    expect(woerter['aufstehen']!['regelmaessig'], isFalse);
    expect(woerter['aufstehen']!['trennbar'], isTrue);
    expect(woerter['wegen']!['grammatikDetail'], 'genitiv');
    expect(woerter['wegen']!['trennbar'], isNull,
        reason: 'Unbekanntes bleibt unbekannt — nie geraten.');
  });
}
