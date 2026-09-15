// FILE: test/nutzer_zustand_test.dart
// PHASE: فاز S, Schritt S.0a (2026-09-15)
// PURPOSE: Sichert den Vertrag ab, auf dem später Export/Import (S.2) und das
//          Konto (S.3) aufbauen. Was hier steht, darf sich nicht ändern, ohne
//          dass es jemandem auffällt.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';

NutzerZustand mitLeitner(Map<String, int> faecher) => NutzerZustand(
      leitner: {
        for (final e in faecher.entries)
          e.key: LeitnerStand(wortId: e.key, fach: e.value),
      },
    );

void main() {
  group('Hülle', () {
    test('schreiben und wieder lesen ergibt denselben Zustand', () {
      const zustand = NutzerZustand(
        leitner: {
          'adjektiv_stolz': LeitnerStand(wortId: 'adjektiv_stolz', fach: 3),
        },
        kategorien: [
          KategorieStand(id: 'kat_1', name: 'Prüfung', wortIds: ['verb_helfen']),
        ],
        notizen: {
          'verb_helfen': NotizStand(text: 'Dativ!', farben: {0: 'gelb'}),
        },
        einstellungen: {'ui_language': 'fa', 'daily_goal_min': 20},
        eigeneWoerter: [
          {'german': 'Feierabend', 'wordType': 'nomen', 'meaningFa': 'پایان کار'},
        ],
      );

      final gelesen = sicherungLesen(sicherungSchreiben(zustand)).zustand;

      expect(gelesen.leitner['adjektiv_stolz']!.fach, 3);
      expect(gelesen.kategorien.single.name, 'Prüfung');
      expect(gelesen.notizen['verb_helfen']!.farben[0], 'gelb');
      expect(gelesen.einstellungen['ui_language'], 'fa');
      expect(gelesen.eigeneWoerter.single['german'], 'Feierabend');
    });

    test('Kopfdaten stimmen', () {
      final s = sicherungLesen(sicherungSchreiben(const NutzerZustand(),
          jetzt: DateTime.utc(2026, 9, 15, 12)));
      expect(s.version, nutzerZustandVersion);
      expect(s.app, appKennung);
      expect(s.erstelltAm, DateTime.utc(2026, 9, 15, 12));
      expect(s.zustand.istLeer, isTrue);
    });

    test('unbrauchbare Dateien werfen einen erklärbaren Fehler', () {
      expect(() => sicherungLesen('kein json'), throwsA(isA<SicherungFehler>()));
      expect(() => sicherungLesen('[]'), throwsA(isA<SicherungFehler>()));
      expect(() => sicherungLesen('{"app":"vox","payload":{}}'),
          throwsA(isA<SicherungFehler>())); // ohne version
      expect(() => sicherungLesen('{"version":1,"app":"root-in","payload":{}}'),
          throwsA(isA<SicherungFehler>())); // falsche App
      expect(() => sicherungLesen('{"version":999,"app":"vox","payload":{}}'),
          throwsA(isA<SicherungFehler>())); // zu neu
    });

    test('fehlende Felder machen die Sicherung nicht unbrauchbar', () {
      final z = sicherungLesen('{"version":1,"app":"vox","payload":{}}').zustand;
      expect(z.istLeer, isTrue);
    });
  });

  group('Zusammenführen — höchstes Fach gewinnt', () {
    test('das höhere Fach setzt sich durch, in beide Richtungen', () {
      final a = mitLeitner({'w1': 4, 'w2': 1});
      final b = mitLeitner({'w1': 2, 'w2': 5});
      final ab = a.zusammenfuehren(b);
      final ba = b.zusammenfuehren(a);

      expect(ab.leitner['w1']!.fach, 4);
      expect(ab.leitner['w2']!.fach, 5);
      // Gleiches Ergebnis, egal wer zuerst kommt — sonst hinge der
      // Fortschritt davon ab, welches Gerät sich zuerst meldet.
      expect(ba.leitner['w1']!.fach, ab.leitner['w1']!.fach);
      expect(ba.leitner['w2']!.fach, ab.leitner['w2']!.fach);
    });

    test('Offline-Arbeit geht nicht verloren, auch wenn sie älter ist', () {
      // Das Gerät mit dem ÄLTEREN Zeitstempel hat das höhere Fach.
      final offline = NutzerZustand(leitner: {
        'w': LeitnerStand(
            wortId: 'w', fach: 5, letzteWiederholung: DateTime.utc(2026, 1, 1)),
      });
      final frisch = NutzerZustand(leitner: {
        'w': LeitnerStand(
            wortId: 'w', fach: 1, letzteWiederholung: DateTime.utc(2026, 9, 1)),
      });
      expect(frisch.zusammenfuehren(offline).leitner['w']!.fach, 5);
      // Die letzte Wiederholung ist trotzdem das jüngere Datum.
      expect(frisch.zusammenfuehren(offline).leitner['w']!.letzteWiederholung,
          DateTime.utc(2026, 9, 1));
    });

    test('Wörter, die nur eine Seite kennt, bleiben erhalten', () {
      final zusammen =
          mitLeitner({'nur_a': 2}).zusammenfuehren(mitLeitner({'nur_b': 3}));
      expect(zusammen.leitner.keys.toSet(), {'nur_a', 'nur_b'});
    });
  });

  group('Zusammenführen — Listen, Notizen, eigene Wörter', () {
    test('gleiche Kategorie: Wörter werden vereinigt, Name bleibt eigener', () {
      const a = NutzerZustand(kategorien: [
        KategorieStand(id: 'k', name: 'Mein Name', wortIds: ['x', 'y'])
      ]);
      const b = NutzerZustand(kategorien: [
        KategorieStand(id: 'k', name: 'Anderer Name', wortIds: ['y', 'z'])
      ]);
      final k = a.zusammenfuehren(b).kategorien.single;
      expect(k.name, 'Mein Name');
      expect(k.wortIds.toSet(), {'x', 'y', 'z'});
    });

    test('Notizen werden nie zusammengeklebt — eigene gewinnt', () {
      const a = NutzerZustand(notizen: {'w': NotizStand(text: 'meine')});
      const b = NutzerZustand(
          notizen: {'w': NotizStand(text: 'fremde'), 'v': NotizStand(text: 'neu')});
      final n = a.zusammenfuehren(b).notizen;
      expect(n['w']!.text, 'meine');
      expect(n['v']!.text, 'neu'); // Notiz zu einem Wort ohne eigene kommt dazu
    });

    test('eigene Wörter sind über wort+wortart eindeutig', () {
      const a = NutzerZustand(eigeneWoerter: [
        {'german': 'Bank', 'wordType': 'nomen', 'meaningFa': 'نیمکت'}
      ]);
      const b = NutzerZustand(eigeneWoerter: [
        {'german': 'Bank', 'wordType': 'nomen', 'meaningFa': 'بانک'},
        {'german': 'Bank', 'wordType': 'verb', 'meaningFa': 'دیگر'}
      ]);
      final w = a.zusammenfuehren(b).eigeneWoerter;
      expect(w.length, 2); // nomen + verb, nicht drei
      expect(
          w.firstWhere((e) => e['wordType'] == 'nomen')['meaningFa'], 'نیمکت');
    });

    test('Einstellungen sind Gerätesache — eigene gewinnen, leere übernehmen',
        () {
      const eigen = NutzerZustand(einstellungen: {'ui_language': 'fa'});
      const fremd = NutzerZustand(einstellungen: {'ui_language': 'en'});
      expect(eigen.zusammenfuehren(fremd).einstellungen['ui_language'], 'fa');
      expect(const NutzerZustand().zusammenfuehren(fremd)
          .einstellungen['ui_language'], 'en');
    });
  });

  test('ID für eigene Wörter ist geräteunabhängig', () {
    // Die drift-Nummer darf nie in einer Sicherung landen — auf einem anderen
    // Gerät bezeichnet dieselbe Nummer ein anderes Wort.
    expect(LeitnerStand.eigenesWort('Bank', 'nomen'), 'eigen:Bank|nomen');
    expect(LeitnerStand.eigenesWort('Bank', 'verb'),
        isNot(LeitnerStand.eigenesWort('Bank', 'nomen')));
  });
}
