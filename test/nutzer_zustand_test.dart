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

  group('Zusammenführen — höchstes Fach gewinnt, außer nach falscher Antwort', () {
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
      // Das Gerät mit dem ÄLTEREN Zeitstempel hat das höhere Fach; auf dem
      // neuen Gerät wurde die Karte seither einmal RICHTIG beantwortet.
      final offline = NutzerZustand(leitner: {
        'w': LeitnerStand(
            wortId: 'w', fach: 5, letzteWiederholung: DateTime.utc(2026, 1, 1)),
      });
      final frisch = NutzerZustand(leitner: {
        'w': LeitnerStand(
            wortId: 'w', fach: 2, letzteWiederholung: DateTime.utc(2026, 9, 1)),
      });
      expect(frisch.zusammenfuehren(offline).leitner['w']!.fach, 5);
      // Die letzte Wiederholung ist trotzdem das jüngere Datum.
      expect(frisch.zusammenfuehren(offline).leitner['w']!.letzteWiederholung,
          DateTime.utc(2026, 9, 1));
    });

    // ── Regel «الف+» (Lukas, 2026-11-10) ────────────────────────────────
    LeitnerStand karte(int fach, [DateTime? letzte, DateTime? naechste]) =>
        LeitnerStand(
            wortId: 'w',
            fach: fach,
            letzteWiederholung: letzte,
            naechsteWiederholung: naechste);
    LeitnerStand beide(LeitnerStand a, LeitnerStand b) {
      final ab = NutzerZustand(leitner: {'w': a})
          .zusammenfuehren(NutzerZustand(leitner: {'w': b}))
          .leitner['w']!;
      final ba = NutzerZustand(leitner: {'w': b})
          .zusammenfuehren(NutzerZustand(leitner: {'w': a}))
          .leitner['w']!;
      // Reihenfolge der Geräte darf keine Rolle spielen.
      expect(ba.fach, ab.fach);
      expect(ba.naechsteWiederholung, ab.naechsteWiederholung);
      expect(ba.letzteWiederholung, ab.letzteWiederholung);
      return ab;
    }

    test('eine spätere falsche Antwort bleibt nach dem Abgleich in Fach 1', () {
      // Cloud: Fach 4 vom 1.11. — Gerät: am 10.11. falsch ⇒ Fach 1.
      final cloud = karte(4, DateTime.utc(2026, 11, 1), DateTime.utc(2026, 11, 9));
      final falsch =
          karte(1, DateTime.utc(2026, 11, 10), DateTime.utc(2026, 11, 11));
      final z = beide(falsch, cloud);
      expect(z.fach, 1);
      expect(z.naechsteWiederholung, DateTime.utc(2026, 11, 11));
      expect(z.letzteWiederholung, DateTime.utc(2026, 11, 10));
    });

    test('eine ÄLTERE falsche Antwort nimmt späteren Fortschritt nicht weg', () {
      final frueherFalsch = karte(1, DateTime.utc(2026, 11, 1));
      final spaeterGelernt = karte(3, DateTime.utc(2026, 11, 10));
      expect(beide(frueherFalsch, spaeterGelernt).fach, 3);
    });

    test('frisch aufgenommene Karte (Fach 1 ohne Datum) nimmt nichts weg', () {
      expect(beide(karte(1), karte(5, DateTime.utc(2026, 1, 1))).fach, 5);
    });

    test('höheres Fach ohne Datum bleibt — im Zweifel kein Verlust', () {
      expect(beide(karte(1, DateTime.utc(2026, 11, 10)), karte(5)).fach, 5);
    });

    test('gleicher Zeitpunkt: das höhere Fach bleibt', () {
      final t = DateTime.utc(2026, 11, 10);
      expect(beide(karte(1, t), karte(4, t)).fach, 4);
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

  // ── S.5: Entfernungen ─────────────────────────────────────────────────
  group('S.5 — letzte Handlung entscheidet über „drin"', () {
    final t1 = DateTime.utc(2026, 9, 15, 10);
    final t2 = DateTime.utc(2026, 9, 15, 12);
    const karte = LeitnerStand(wortId: 'verb_helfen', fach: 4);

    Mitgliedschaft ev(String art, String id, bool drin, DateTime am,
            [String wort = '']) =>
        Mitgliedschaft(art: art, id: id, wort: wort, drin: drin, am: am);

    NutzerZustand mitEreignis(Mitgliedschaft m,
            {Map<String, LeitnerStand> leitner = const {},
            List<KategorieStand> kategorien = const [],
            List<Map<String, dynamic>> eigeneWoerter = const []}) =>
        NutzerZustand(
          leitner: leitner,
          kategorien: kategorien,
          eigeneWoerter: eigeneWoerter,
          mitgliedschaften: {m.schluessel: m},
        );

    // X.2: «im Leitner» = Mitglied des Decks «Leitner»; der Fortschritt
    // bleibt, auch wenn das Wort den Leitner verlässt.
    const stapel = KategorieStand(
        id: standardDeckId,
        name: standardDeckName,
        modus: deckModusWiederholen,
        wortIds: ['verb_helfen']);
    Mitgliedschaft imStapel(bool drin, DateTime am) =>
        ev(artListenwort, standardDeckId, drin, am, 'verb_helfen');

    test('spätere Entfernung nimmt das Wort aus dem Leitner — der Fortschritt '
        'bleibt, in beide Richtungen', () {
      final a = mitEreignis(imStapel(true, t1),
          leitner: {'verb_helfen': karte}, kategorien: [stapel]);
      final b = mitEreignis(imStapel(false, t2));
      for (final z in [a.zusammenfuehren(b), b.zusammenfuehren(a)]) {
        expect(z.imLeitner, isEmpty);
        expect(z.leitner['verb_helfen']!.fach, 4,
            reason: 'Entfernen kostet nie Fortschritt');
      }
    });

    test('späteres Wiederaufnehmen schlägt eine ältere Entfernung', () {
      final a = mitEreignis(imStapel(true, t2),
          leitner: {'verb_helfen': karte}, kategorien: [stapel]);
      final b = mitEreignis(imStapel(false, t1));
      for (final z in [a.zusammenfuehren(b), b.zusammenfuehren(a)]) {
        expect(z.imLeitner, {'verb_helfen'});
        expect(z.leitner['verb_helfen']!.fach, 4);
      }
    });

    test('Eintrag ohne Ereignis ist älter als jede Entfernung', () {
      const alt = NutzerZustand(
          leitner: {'verb_helfen': karte}, kategorien: [stapel]);
      final weg = mitEreignis(imStapel(false, t1));
      expect(alt.zusammenfuehren(weg).imLeitner, isEmpty);
    });

    test('ohne jedes Ereignis bleibt es beim Vereinigen (Fassung 1)', () {
      const a = NutzerZustand(leitner: {'verb_helfen': karte});
      const b = NutzerZustand(
          leitner: {'adjektiv_stolz': LeitnerStand(wortId: 'adjektiv_stolz', fach: 1)});
      expect(a.zusammenfuehren(b).leitner.keys.toSet(),
          {'verb_helfen', 'adjektiv_stolz'});
    });

    test('Gleichstand: „drin" gewinnt', () {
      final rein = ev(artListenwort, 'x', true, t1);
      final raus = ev(artListenwort, 'x', false, t1);
      expect(Mitgliedschaft.spaetere(rein, raus).drin, isTrue);
      expect(Mitgliedschaft.spaetere(raus, rein).drin, isTrue);
    });

    test('Listen: Wort entfernt und Liste gelöscht', () {
      const liste = KategorieStand(
          id: 'kat_1', name: 'B1', wortIds: ['verb_helfen', 'adjektiv_stolz']);
      final wortRaus = mitEreignis(
          ev(artListenwort, 'kat_1', false, t2, 'verb_helfen'));
      const mitListe = NutzerZustand(kategorien: [liste]);
      expect(mitListe.zusammenfuehren(wortRaus).kategorien.single.wortIds,
          ['adjektiv_stolz']);

      final listeWeg = mitEreignis(ev(artListe, 'kat_1', false, t2));
      expect(mitListe.zusammenfuehren(listeWeg).kategorien, isEmpty);
    });

    test('entferntes eigenes Wort nimmt Leitner-Karte und Listenplatz mit', () {
      final id = LeitnerStand.eigenesWort('Bank', 'nomen');
      final lokal = NutzerZustand(
        leitner: {id: LeitnerStand(wortId: id, fach: 2)},
        kategorien: [KategorieStand(id: 'eigen:Alltag', name: 'Alltag', wortIds: [id])],
        eigeneWoerter: const [
          {'german': 'Bank', 'wordType': 'nomen', 'meaningFa': 'بانک'},
        ],
      );
      final weg = mitEreignis(ev(artWort, 'Bank|nomen', false, t2));
      final z = lokal.zusammenfuehren(weg);
      expect(z.eigeneWoerter, isEmpty);
      expect(z.leitner, isEmpty);
      expect(z.kategorien.single.wortIds, isEmpty);
    });

    test('Ereignisse überleben die Hülle; Fassung 1 bleibt lesbar', () {
      final z = mitEreignis(ev(artListenwort, 'kat_1', false, t2, 'verb_helfen'));
      final zurueck = sicherungLesen(sicherungSchreiben(z)).zustand;
      final m = zurueck.mitgliedschaften.values.single;
      expect(m.art, artListenwort);
      expect(m.wort, 'verb_helfen');
      expect(m.drin, isFalse);
      expect(m.am.isAtSameMomentAs(t2), isTrue);

      final v1 = sicherungLesen(
          '{"version":1,"app":"vox","payload":{"leitner":{}}}').zustand;
      expect(v1.mitgliedschaften, isEmpty);
    });
  });

  // ── S.6: feste Listen-id ──────────────────────────────────────────────
  group('S.6 — feste Listen-id, später vergebener Name gewinnt', () {
    final t1 = DateTime.utc(2026, 9, 16, 10);
    final t2 = DateTime.utc(2026, 9, 16, 12);

    test('neue ids haben die feste Form und sind verschieden', () {
      final a = neueEigeneListenId();
      final b = neueEigeneListenId();
      expect(a, matches(RegExp(r'^eigen:#[0-9a-f]{32}$')));
      expect(a, isNot(b));
    });

    test('der später vergebene Name gewinnt — in beide Richtungen', () {
      final alt = NutzerZustand(kategorien: [
        KategorieStand(
            id: 'eigen:#1', name: 'Reise', nameAm: t1, wortIds: const ['x']),
      ]);
      final neu = NutzerZustand(kategorien: [
        KategorieStand(
            id: 'eigen:#1', name: 'Urlaub', nameAm: t2, wortIds: const ['y']),
      ]);
      for (final k in [
        alt.zusammenfuehren(neu).kategorien.single,
        neu.zusammenfuehren(alt).kategorien.single,
      ]) {
        expect(k.name, 'Urlaub');
        expect(k.nameAm, t2);
        expect(k.wortIds.toSet(), {'x', 'y'},
            reason: 'Umbenennen darf keine Wörter kosten');
      }
    });

    test('ein Name mit Zeitpunkt schlägt einen ohne (Fassung 2)', () {
      const ohne = NutzerZustand(
          kategorien: [KategorieStand(id: 'eigen:Reise', name: 'Reise')]);
      final mit = NutzerZustand(kategorien: [
        KategorieStand(id: 'eigen:Reise', name: 'Urlaub', nameAm: t1),
      ]);
      expect(ohne.zusammenfuehren(mit).kategorien.single.name, 'Urlaub');
      expect(mit.zusammenfuehren(ohne).kategorien.single.name, 'Urlaub');
    });

    test('nameAm übersteht die Hülle; ohne nameAm bleibt der Text wie in '
        'Fassung 2; Fassung 2 bleibt lesbar', () {
      final z = NutzerZustand(kategorien: [
        KategorieStand(id: 'eigen:#1', name: 'Urlaub', nameAm: t2),
      ]);
      final zurueck =
          sicherungLesen(sicherungSchreiben(z)).zustand.kategorien.single;
      expect(zurueck.nameAm!.isAtSameMomentAs(t2), isTrue);

      const ohne = KategorieStand(id: 'eigen:Reise', name: 'Reise');
      expect(ohne.toJson().containsKey('nameAm'), isFalse);

      final v2 = sicherungLesen('{"version":2,"app":"vox","payload":'
              '{"kategorien":[{"id":"eigen:Reise","name":"Reise","wortIds":[]}]}}')
          .zustand;
      expect(v2.kategorien.single.nameAm, isNull);
    });
  });

  // ── X.2: Fassung 6 — Leitner wie Anki ─────────────────────────────────
  group('X.2 — Fassung 6: Fortschritt je Übung, Decks', () {
    final t1 = DateTime.utc(2026, 11, 1);
    final t2 = DateTime.utc(2026, 11, 2);

    // Eine Sicherung, wie Fassung 5 sie schrieb: «steht in leitner» hieß
    // «ist im Stapel»; Entfernen war ein `leitner`-Ereignis.
    const v5 = '''
{"version":5,"app":"vox","payload":{
  "leitner":{
    "adjektiv_stolz":{"wortId":"adjektiv_stolz","fach":4,
      "naechsteWiederholung":"2026-11-20T00:00:00.000","letzteWiederholung":"2026-11-12T00:00:00.000"},
    "eigen:Bank|nomen":{"wortId":"eigen:Bank|nomen","fach":1,"naechsteWiederholung":null,"letzteWiederholung":null}},
  "kategorien":[{"id":"kat_1","name":"Prüfung","wortIds":["adjektiv_stolz"]}],
  "mitgliedschaften":[
    {"art":"leitner","id":"adjektiv_stolz","wort":"","drin":true,"am":"2026-11-01T00:00:00.000Z"},
    {"art":"leitner","id":"verb_fort","wort":"","drin":false,"am":"2026-11-02T00:00:00.000Z"},
    {"art":"liste","id":"kat_1","wort":"","drin":true,"am":"2026-11-01T00:00:00.000Z"}]}}''';

    test('Fassung 5 lesen: Stapel ⇒ Deck «Leitner», Ereignisse ⇒ am Deck, '
        'Fächer unverändert', () {
      final z = sicherungLesen(v5).zustand;
      expect(z.leitner['adjektiv_stolz']!.fach, 4);
      expect(z.leitner['adjektiv_stolz']!.naechsteWiederholung,
          DateTime(2026, 11, 20));
      final stapel = z.kategorien.singleWhere((k) => k.id == standardDeckId);
      expect(stapel.wiederholen, isTrue);
      expect(stapel.wortIds.toSet(), {'adjektiv_stolz', 'eigen:Bank|nomen'});
      expect(z.imLeitner, {'adjektiv_stolz', 'eigen:Bank|nomen'});
      final pruefung = z.kategorien.singleWhere((k) => k.id == 'kat_1');
      expect(pruefung.wiederholen, isFalse,
          reason: 'alte Listen sind Notizbücher');
      expect(z.mitgliedschaften.keys.toSet(), {
        mitgliedschaftsSchluessel(
            artListenwort, standardDeckId, 'adjektiv_stolz'),
        mitgliedschaftsSchluessel(artListenwort, standardDeckId, 'verb_fort'),
        mitgliedschaftsSchluessel(artListe, 'kat_1'),
      });
      expect(
          z.mitgliedschaften.values.any((m) => m.art == artLeitnerAlt), isFalse);
    });

    test('Fassung 5 + Fassung 5 zusammen = dasselbe wie vorher: Vereinigung, '
        'spätere Entfernung gewinnt', () {
      final a = sicherungLesen(v5).zustand;
      final b = sicherungLesen(v5
              .replaceFirst('"drin":true,"am":"2026-11-01T00:00:00.000Z"},\n    {"art":"leitner","id":"verb_fort"',
                  '"drin":false,"am":"2026-11-05T00:00:00.000Z"},\n    {"art":"leitner","id":"verb_fort"'))
          .zustand;
      for (final z in [a.zusammenfuehren(b), b.zusammenfuehren(a)]) {
        expect(z.imLeitner, {'eigen:Bank|nomen'},
            reason: 'adjektiv_stolz wurde später entfernt');
        expect(z.leitner['adjektiv_stolz']!.fach, 4,
            reason: 'sein Fortschritt bleibt');
      }
    });

    test('Fassung 6 schreibt und liest sich selbst: Übungen, Deck-Baum, '
        'gelernt', () {
      final z = NutzerZustand(
        leitner: const {'a': LeitnerStand(wortId: 'a', fach: 8)},
        uebungen: {
          'artikel': {
            'a': LeitnerStand(
                wortId: 'a', fach: 2, naechsteWiederholung: t2, letzteWiederholung: t1),
          },
          'leer': const {},
        },
        kategorien: [
          KategorieStand(
              id: 'eigen:#1',
              name: 'Deutsch',
              modus: deckModusWiederholen,
              neuProTag: 30,
              standAm: t1),
          KategorieStand(
              id: 'eigen:#2',
              name: 'A1',
              eltern: 'eigen:#1',
              modus: deckModusWiederholen,
              ordnung: 2,
              wortIds: const ['a'],
              standAm: t2),
        ],
      );
      final text = sicherungSchreiben(z);
      final s = sicherungLesen(text);
      expect(s.version, 6);
      final g = s.zustand;
      expect(g.leitner['a']!.gelernt, isTrue);
      expect(g.uebungen.keys, ['artikel'], reason: 'leere Übung steht nicht drin');
      expect(g.fortschritt('artikel')['a']!.fach, 2);
      expect(g.fortschritt(uebungBedeutung)['a']!.fach, 8);
      expect(g.fortschritt('gibt_es_nicht'), isEmpty);
      final a1 = g.kategorien.singleWhere((k) => k.id == 'eigen:#2');
      expect((a1.eltern, a1.modus, a1.ordnung, a1.neuProTag, a1.standAm),
          ('eigen:#1', deckModusWiederholen, 2, null, t2));
      expect(g.kategorien.singleWhere((k) => k.id == 'eigen:#1').neuProTag, 30);
      expect(sicherungSchreiben(g, jetzt: DateTime(2026)),
          sicherungSchreiben(z, jetzt: DateTime(2026)));
    });

    test('eine Liste von vor Fassung 6 ergibt denselben Text wie früher', () {
      const liste = KategorieStand(id: 'kat_1', name: 'Prüfung', wortIds: ['x']);
      expect(liste.toJson(), {'id': 'kat_1', 'name': 'Prüfung', 'wortIds': ['x']});
      expect(const NutzerZustand().toJson().containsKey('uebungen'), isFalse);
    });

    test('unbekannter Modus ⇒ Notizbuch (nie ungewollte Wiederholung)', () {
      final k = KategorieStand.vonJson(
          {'id': 'x', 'name': 'X', 'modus': 'irgendwas'});
      expect(k.wiederholen, isFalse);
    });

    test('Fortschritt jeder Übung: höchstes Fach gewinnt, je Übung getrennt',
        () {
      const a = NutzerZustand(leitner: {
        'w': LeitnerStand(wortId: 'w', fach: 2)
      }, uebungen: {
        'artikel': {'w': LeitnerStand(wortId: 'w', fach: 6)},
      });
      const b = NutzerZustand(leitner: {
        'w': LeitnerStand(wortId: 'w', fach: 5)
      }, uebungen: {
        'artikel': {'w': LeitnerStand(wortId: 'w', fach: 3)},
        'schreiben': {'v': LeitnerStand(wortId: 'v', fach: 1)},
      });
      for (final z in [a.zusammenfuehren(b), b.zusammenfuehren(a)]) {
        expect(z.leitner['w']!.fach, 5);
        expect(z.uebungen['artikel']!['w']!.fach, 6);
        expect(z.uebungen['schreiben']!['v']!.fach, 1);
      }
    });

    test('Einstellungen eines Decks: die später geänderte Seite gewinnt '
        'als Ganzes; Wörter werden vereinigt', () {
      final alt = NutzerZustand(kategorien: [
        KategorieStand(
            id: 'd',
            name: 'D',
            modus: deckModusNotiz,
            neuProTag: 5,
            wortIds: const ['a'],
            standAm: t1),
      ]);
      final neu = NutzerZustand(kategorien: [
        KategorieStand(
            id: 'd',
            name: 'D',
            modus: deckModusWiederholen,
            ordnung: 3,
            wortIds: const ['b'],
            standAm: t2),
      ]);
      for (final z in [alt.zusammenfuehren(neu), neu.zusammenfuehren(alt)]) {
        final d = z.kategorien.single;
        expect((d.modus, d.neuProTag, d.ordnung, d.standAm),
            (deckModusWiederholen, null, 3, t2));
        expect(d.wortIds.toSet(), {'a', 'b'});
      }
    });

    test('übergeordnetes Deck gelöscht ⇒ Subdeck rückt auf die oberste Ebene',
        () {
      final a = NutzerZustand(kategorien: const [
        KategorieStand(id: 'oben', name: 'Oben'),
        KategorieStand(id: 'unten', name: 'Unten', eltern: 'oben'),
      ]);
      final b = NutzerZustand(mitgliedschaften: {
        mitgliedschaftsSchluessel(artListe, 'oben'):
            Mitgliedschaft(art: artListe, id: 'oben', drin: false, am: t2),
      });
      final z = a.zusammenfuehren(b);
      expect(z.kategorien.single.id, 'unten');
      expect(z.kategorien.single.eltern, isNull);
    });

    test('ein gelöschtes eigenes Wort nimmt seinen Fortschritt in JEDER Übung '
        'und seine Deck-Plätze mit', () {
      const a = NutzerZustand(leitner: {
        'eigen:Bank|nomen': LeitnerStand(wortId: 'eigen:Bank|nomen', fach: 3),
      }, uebungen: {
        'artikel': {
          'eigen:Bank|nomen': LeitnerStand(wortId: 'eigen:Bank|nomen', fach: 2),
        },
      }, kategorien: [
        KategorieStand(id: 'd', name: 'D', wortIds: ['eigen:Bank|nomen', 'x']),
      ]);
      final b = NutzerZustand(mitgliedschaften: {
        mitgliedschaftsSchluessel(artWort, 'Bank|nomen'):
            Mitgliedschaft(art: artWort, id: 'Bank|nomen', drin: false, am: t2),
      });
      final z = a.zusammenfuehren(b);
      expect(z.leitner, isEmpty);
      expect(z.uebungen, isEmpty);
      expect(z.kategorien.single.wortIds, ['x']);
    });
  });
}
