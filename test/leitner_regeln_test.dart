// FILE: test/leitner_regeln_test.dart
// PHASE: X.2 (2026-11-17) — die Regeln des Leitner-Systems
//        (lib/core/leitner/leitner_regeln.dart), Entscheidungen Lukas
//        2026-11-03 in docs/zukunft/PHASE_X.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/leitner/leitner_regeln.dart';

void main() {
  final jetzt = DateTime.utc(2026, 11, 17, 8);

  test('7 Fächer mit 1 · 2 · 4 · 8 · 16 · 32 · 64 Tagen (Nr. 8)', () {
    expect(leitnerFaecher, 7);
    expect(leitnerFachTage, [1, 2, 4, 8, 16, 32, 64]);
    expect(leitnerGelerntFach, 8);
  });

  test('richtig: neues Wort ⇒ Fach 2; jedes Fach ⇒ das nächste mit seinem '
      'Abstand', () {
    LeitnerStand? stand;
    final faecher = <int>[];
    final tage = <int>[];
    for (var i = 0; i < 6; i++) {
      stand = nachRichtig('w', stand, jetzt);
      faecher.add(stand.fach);
      tage.add(stand.naechsteWiederholung!.difference(jetzt).inDays);
      expect(stand.letzteWiederholung, jetzt);
    }
    expect(faecher, [2, 3, 4, 5, 6, 7]);
    expect(tage, [2, 4, 8, 16, 32, 64]);
  });

  test('richtig im 7. Fach ⇒ gelernt, ohne Termin — und bleibt gelernt (Nr. 9)',
      () {
    const sieben = LeitnerStand(wortId: 'w', fach: 7);
    final raus = nachRichtig('w', sieben, jetzt);
    expect(raus.fach, leitnerGelerntFach);
    expect(raus.gelernt, isTrue);
    expect(raus.naechsteWiederholung, isNull);
    expect(lernZustand(raus), LernZustand.gelernt);
    expect(istFaellig(raus, jetzt.add(const Duration(days: 9999))), isFalse,
        reason: 'ein gelerntes Wort wird nie mehr wiederholt');
    expect(nachRichtig('w', raus, jetzt).fach, leitnerGelerntFach);
  });

  test('falsch ⇒ Fach 1, morgen wieder, mit Datum (Nr. 10)', () {
    final s = nachFalsch('w', jetzt);
    expect(s.fach, 1);
    expect(s.naechsteWiederholung, jetzt.add(const Duration(days: 1)));
    expect(s.letzteWiederholung, jetzt);
  });

  test('drei Zustände: neu · lernt · gelernt (Nr. 6)', () {
    expect(lernZustand(null), LernZustand.neu);
    expect(lernZustand(const LeitnerStand(wortId: 'w', fach: 1)),
        LernZustand.lernt);
    expect(lernZustand(const LeitnerStand(wortId: 'w', fach: 7)),
        LernZustand.lernt);
    expect(lernZustand(const LeitnerStand(wortId: 'w', fach: 8)),
        LernZustand.gelernt);
  });

  test('fällig: neu sofort; sonst ab dem Termin; ohne Termin sofort', () {
    expect(istFaellig(null, jetzt), isTrue);
    final morgen = jetzt.add(const Duration(days: 1));
    final s = LeitnerStand(wortId: 'w', fach: 3, naechsteWiederholung: morgen);
    expect(istFaellig(s, jetzt), isFalse);
    expect(istFaellig(s, morgen), isTrue);
    expect(istFaellig(const LeitnerStand(wortId: 'w', fach: 3), jetzt), isTrue);
    expect(anzeigeFach(null), 1);
  });

  test('von Hand zurück in Fach 1 schlägt «gelernt» beim Zusammenführen', () {
    final gelernt = LeitnerStand(
        wortId: 'w', fach: leitnerGelerntFach, letzteWiederholung: jetzt);
    final zurueck = nachFalsch('w', jetzt.add(const Duration(hours: 1)));
    expect(LeitnerStand.zusammen(gelernt, zurueck).fach, 1);
    expect(LeitnerStand.zusammen(zurueck, gelernt).fach, 1);
    // Ein ÄLTERES Fach 1 verliert gegen «gelernt».
    final frueher = nachFalsch('w', jetzt.subtract(const Duration(days: 1)));
    expect(LeitnerStand.zusammen(gelernt, frueher).fach, leitnerGelerntFach);
  });

  test('Anteil gelernt je Deck', () {
    const f = {
      'a': LeitnerStand(wortId: 'a', fach: 8),
      'b': LeitnerStand(wortId: 'b', fach: 7),
    };
    expect(anteilGelernt(['a', 'b', 'c', 'd'], f), 0.25);
    expect(anteilGelernt(const [], f), 0);
  });
}
