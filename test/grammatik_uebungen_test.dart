// FILE: test/grammatik_uebungen_test.dart
// PHASE: فاز G → G7a (2026-09-16) · فاز LAUNCH → L.2e
// PURPOSE: Die 336 Übungen der Grammatik-Quelle sind vollständig, lösbar und
//          werden richtig bewertet — in beiden Oberflächensprachen.
//
// Wächter:
//   · jede Übung der Quelle wird gelesen (keine fällt still weg)
//   · jede Lektion hat genau die Übungen, die ihr `exerciseSlugs` nennt
//   · die eigene Lösung jeder Übung wird als richtig gewertet, falsche
//     Antworten als falsch — inklusive der Sonderfälle der Quelle
//   · jede Übung lässt sich in EN und FA wirklich bedienen und lösen
//   · eine Sitzung zählt richtig und zeigt das Ergebnis
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/features/grammatik/controllers/grammatik_lektion_controller.dart';
import 'package:vox/features/grammatik/models/beispiel_uebungen.dart';
import 'package:vox/features/grammatik/models/grammatik_lektion.dart';
import 'package:vox/features/grammatik/models/grammatik_uebung.dart';
import 'package:vox/features/grammatik/screens/grammatik_uebung_screen.dart';
import 'package:vox/features/grammatik/widgets/uebung_karte.dart';
import 'package:vox/features/grammatik/widgets/uebungs_sitzung.dart';

Map<String, dynamic> lies(String pfad) =>
    jsonDecode(File(pfad).readAsStringSync()) as Map<String, dynamic>;

Widget app(Widget kind, {String sprache = 'en', List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: Locale(sprache),
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: kind,
      ),
    );

/// Welche Kärtchen (Index) man in welcher Reihenfolge antippt, um die
/// Lösung zu legen — ohne Groß-/Kleinschreibung, jedes Kärtchen einmal.
List<int> kaertchenFuerLoesung(GrammatikUebung u) {
  final benutzt = <int>{};
  final out = <int>[];
  final vorgabe = GrammatikUebung.satzWoerter(u.vorgabe).length;
  for (final w in GrammatikUebung.satzWoerter(u.loesung).skip(vorgabe)) {
    final i = [
      for (var k = 0; k < u.woerter.length; k++)
        if (!benutzt.contains(k) &&
            u.woerter[k].toLowerCase() == w.toLowerCase())
          k,
    ].first;
    benutzt.add(i);
    out.add(i);
  }
  return out;
}

void main() {
  // Rohdaten und Modelle aller Content-Dateien
  final roh = <Map<String, dynamic>>[];
  final lektionenRoh = <Map<String, dynamic>>[];
  for (final pfad in grammatikContentFiles) {
    final d = lies(pfad);
    roh.addAll((d['exercises'] as List).cast<Map<String, dynamic>>());
    lektionenRoh.addAll((d['lessons'] as List).cast<Map<String, dynamic>>());
  }
  final uebungen = [for (final r in roh) GrammatikUebung.ausJson(r)];
  final gueltig = uebungen.whereType<GrammatikUebung>().toList();
  final proLektion = <String, List<GrammatikUebung>>{};
  for (final u in gueltig) {
    (proLektion[u.lektionSlug] ??= []).add(u);
  }
  final lektionen = [
    for (final l in lektionenRoh) GrammatikLektion.fromJson(l),
  ];
  // G7c: erzeugte Übungen aus Beispielsätzen — mehrere Zufallsläufe, damit
  // jede Art vorkommt.
  final erzeugt = [
    for (final seed in const [1, 2, 3, 4, 5])
      for (final l in lektionen) ...BeispielUebungen.erzeuge(l, Random(seed)),
  ];

  bool eigeneLoesungRichtig(GrammatikUebung u) => switch (u.art) {
        UebungsArt.multipleChoice ||
        UebungsArt.fillBlank ||
        UebungsArt.bedeutung ||
        UebungsArt.satzWahl ||
        UebungsArt.richtigFalsch =>
          u.pruefeWahl(u.loesung),
        UebungsArt.wordOrder => u.pruefeReihenfolge(
            [for (final i in kaertchenFuerLoesung(u)) u.woerter[i]]),
        UebungsArt.transform => u.pruefeUmformung(u.loesung),
        UebungsArt.matching => u.pruefeZuordnung(
            {for (final p in u.paare) p.links: p.rechts}),
      };

  group('Daten', () {
    test('alle 336 Übungen werden gelesen, keine fällt weg', () {
      expect(roh.length, 336);
      final fehlend = [
        for (var i = 0; i < roh.length; i++)
          if (uebungen[i] == null) roh[i]['id'],
      ];
      expect(fehlend, isEmpty, reason: 'nicht lesbar: $fehlend');
      expect(gueltig.map((u) => u.schluessel).toSet().length, 336,
          reason: 'Lektion + id doppelt');
    });

    test('bekannte Doppel-ids der Quelle: ex-komp-1…4 in zwei Lektionen', () {
      final doppelt = <String, Set<String>>{};
      for (final u in gueltig) {
        (doppelt[u.id] ??= {}).add(u.lektionSlug);
      }
      doppelt.removeWhere((_, l) => l.length < 2);
      expect(doppelt, {
        for (var i = 1; i <= 4; i++)
          'ex-komp-$i': {'komparativ-superlativ', 'komposita'},
      });
    });

    test('fünf Arten wie in der Quelle', () {
      int zahl(UebungsArt a) => gueltig.where((u) => u.art == a).length;
      expect(zahl(UebungsArt.multipleChoice), 85);
      expect(zahl(UebungsArt.fillBlank), 82);
      expect(zahl(UebungsArt.wordOrder), 67);
      expect(zahl(UebungsArt.transform), 51);
      expect(zahl(UebungsArt.matching), 51);
    });

    test('jede Lektion hat genau ihre exerciseSlugs', () {
      expect(lektionenRoh.length, 84);
      for (final l in lektionenRoh) {
        final slug = l['slug'] as String;
        final erwartet = (l['exerciseSlugs'] as List).cast<String>();
        expect(erwartet, isNotEmpty, reason: '$slug ohne Übungen');
        expect(proLektion[slug]?.map((u) => u.id).toList(), erwartet,
            reason: slug);
      }
      final slugs = lektionenRoh.map((l) => l['slug']).toSet();
      expect(proLektion.keys.where((s) => !slugs.contains(s)), isEmpty,
          reason: 'Übung zeigt auf unbekannte Lektion');
    });

    test('Texte dreisprachig vorhanden', () {
      for (final u in gueltig) {
        for (final t in [u.aufgabeDe, u.aufgabeFa, u.aufgabeEn]) {
          expect(t.trim(), isNotEmpty, reason: '${u.id}: Auftrag leer');
        }
        if (u.hatErklaerung) {
          expect(u.erklaerungFa.trim(), isNotEmpty, reason: u.id);
          expect(u.erklaerungEn.trim(), isNotEmpty, reason: u.id);
        }
      }
    });
  });

  group('Bewertung', () {
    test('die eigene Lösung jeder Übung ist richtig', () {
      for (final u in [...gueltig, ...erzeugt]) {
        expect(eigeneLoesungRichtig(u), isTrue, reason: u.schluessel);
      }
    });

    test('falsche Antworten sind falsch', () {
      for (final u in [...gueltig, ...erzeugt]) {
        switch (u.art) {
          case UebungsArt.multipleChoice:
          case UebungsArt.fillBlank:
          case UebungsArt.bedeutung:
          case UebungsArt.satzWahl:
          case UebungsArt.richtigFalsch:
            for (final o in u.optionen.where((o) => o != u.loesung)) {
              expect(u.pruefeWahl(o), isFalse, reason: '${u.id}: $o');
            }
          case UebungsArt.wordOrder:
            final richtig = [
              for (final i in kaertchenFuerLoesung(u)) u.woerter[i]
            ];
            final rueck = richtig.reversed.toList();
            if (rueck.join(' ').toLowerCase() !=
                richtig.join(' ').toLowerCase()) {
              expect(u.pruefeReihenfolge(rueck), isFalse, reason: u.id);
            }
            expect(u.pruefeReihenfolge(richtig.sublist(1)), isFalse,
                reason: '${u.id}: unvollständig');
          case UebungsArt.transform:
            expect(u.pruefeUmformung(u.satz) && u.satz != u.loesung, isFalse,
                reason: '${u.id}: Ausgangssatz gilt als Lösung');
          case UebungsArt.matching:
            final werte = u.rechteWerte;
            if (werte.length >= 2) {
              final p = u.paare.first;
              final anders = werte.firstWhere((w) => w != p.rechts);
              expect(
                u.pruefeZuordnung({
                  for (final q in u.paare) q.links: q.rechts,
                  p.links: anders,
                }),
                isFalse,
                reason: u.id,
              );
            }
        }
      }
    });

    GrammatikUebung hole(String id) => gueltig.firstWhere((u) => u.id == id);
    // (ex-komp-* nie über hole() — die id ist dort nicht eindeutig)

    test('fillBlank: alternatives sind Ablenker, Lösung ist Option', () {
      for (final u in gueltig.where((u) => u.art == UebungsArt.fillBlank)) {
        expect(u.optionen, contains(u.loesung), reason: u.id);
        expect(u.optionen.length, greaterThanOrEqualTo(2), reason: u.id);
      }
    });

    test('wordOrder: überzählige Kärtchen und Großschreibung', () {
      // „am" bleibt übrig
      final interr = hole('ex-interr-4');
      expect(interr.woerter, contains('am'));
      expect(interr.pruefeReihenfolge(
              ['Welches', 'Buch', 'hast', 'du', 'gerade', 'gelesen']),
          isTrue);
      // „Wir" großgeschrieben mitten im Satz
      final gen = hole('ex-genitiv-4');
      expect(gen.pruefeReihenfolge(
              ['Wegen', 'der', 'Verspätung', 'haben', 'Wir', 'den', 'Zug', 'verpasst']),
          isTrue);
      expect(gen.pruefeReihenfolge(
              ['Wir', 'haben', 'wegen', 'der', 'Verspätung', 'den', 'Zug', 'verpasst']),
          isFalse);
    });

    test('matching: gleiche rechte Werte', () {
      final dat = hole('ex-dat-3');
      expect(dat.rechteWerte, ['Dativ']);
      expect(dat.pruefeZuordnung({for (final p in dat.paare) p.links: 'Dativ'}),
          isTrue);
      final wennals = hole('ex-wennals-3');
      expect(wennals.rechteWerte, ['als', 'wenn']);
    });

    test('transform: Leerzeichen, Anführungszeichen, Schlusszeichen', () {
      const u = 'Könntest du mir das Salz geben?';
      expect(GrammatikUebung.normalisiereSatz('  Könntest du  mir das Salz geben ?'),
          GrammatikUebung.normalisiereSatz(u));
      expect(GrammatikUebung.normalisiereSatz('Könntest du mir das Salz geben'),
          GrammatikUebung.normalisiereSatz(u));
      expect(GrammatikUebung.normalisiereSatz('könntest du mir das Salz geben?'),
          isNot(GrammatikUebung.normalisiereSatz(u)));
      expect(GrammatikUebung.normalisiereSatz('Er sagt: „Ja.“'),
          GrammatikUebung.normalisiereSatz('Er sagt: "Ja."'));
    });

    test('unvollständige Übungen werden nie halb gezeigt', () {
      Map<String, dynamic> mit(String typ, Map<String, dynamic> p) => {
            'id': 'x',
            'lessonSlug': 'y',
            'type': typ,
            'payload': {'type': typ, ...p},
          };
      expect(GrammatikUebung.ausJson(mit('multipleChoice',
          {'options': ['a', 'b'], 'correctIndex': 2})), isNull);
      expect(GrammatikUebung.ausJson(mit('fillBlank',
          {'sentenceWithBlank': 'ohne Lücke', 'correctAnswer': 'a',
           'alternatives': ['b']})), isNull);
      expect(GrammatikUebung.ausJson(mit('fillBlank',
          {'sentenceWithBlank': 'a ___', 'correctAnswer': 'a',
           'alternatives': ['a']})), isNull);
      expect(GrammatikUebung.ausJson(mit('wordOrder',
          {'shuffledWords': ['Ich', 'gehe'], 'correctSentence': 'Ich gehe heim.'})),
          isNull);
      expect(GrammatikUebung.ausJson(mit('matching',
          {'pairs': [{'left': 'a', 'right': 'b'}]})), isNull);
      expect(GrammatikUebung.ausJson(mit('unbekannt', {})), isNull);
    });
  });

  group('Übungen aus Beispielsätzen (G7c)', () {
    test('je Beispielsatz genau eine Übung, jede Art kommt vor', () {
      for (final l in lektionen) {
        expect(l.examples, isNotEmpty, reason: l.slug);
        expect(BeispielUebungen.anzahl(l), l.examples.length, reason: l.slug);
        for (final seed in const [1, 2, 3]) {
          final liste = BeispielUebungen.erzeuge(l, Random(seed));
          expect(liste.length, l.examples.length, reason: l.slug);
          expect(liste.map((u) => u.schluessel).toSet().length, liste.length,
              reason: '${l.slug}: doppelt');
          for (final u in liste) {
            expect(u.ausBeispiel, isTrue);
            expect(u.lektionSlug, l.slug);
            expect(u.aufgabeKey, isNotNull);
            expect(u.beispielDe, isNotEmpty);
          }
        }
      }
      final arten = erzeugt.map((u) => u.art).toSet();
      expect(arten, {
        UebungsArt.bedeutung,
        UebungsArt.satzWahl,
        UebungsArt.richtigFalsch,
        UebungsArt.matching,
        UebungsArt.wordOrder,
      });
      // richtig/falsch kommt in beiden Ausprägungen vor
      final rf = erzeugt.where((u) => u.art == UebungsArt.richtigFalsch);
      expect(rf.map((u) => u.loesung).toSet(),
          {BeispielUebungen.richtig, BeispielUebungen.falsch});
    });

    test('Zufall wechselt die Arten', () {
      final l = lektionen.first;
      final a = BeispielUebungen.erzeuge(l, Random(1)).map((u) => u.art);
      final b = [
        for (var s = 2; s < 20; s++)
          BeispielUebungen.erzeuge(l, Random(s)).map((u) => u.art).toList(),
      ];
      expect(b.any((x) => x.toString() != a.toList().toString()), isTrue);
    });

    test('Wahlmöglichkeiten sind in DE, FA und EN verschieden', () {
      for (final u in erzeugt.where((u) =>
          u.art == UebungsArt.bedeutung || u.art == UebungsArt.satzWahl)) {
        expect(u.optionen.length, 4, reason: u.schluessel);
        expect(u.optionen.toSet().length, 4, reason: u.schluessel);
        expect(u.optionen, contains(u.loesung));
        if (u.art == UebungsArt.bedeutung) {
          expect(u.optionenFa.toSet().length, 4, reason: u.schluessel);
          expect(u.optionenEn.toSet().length, 4, reason: u.schluessel);
          final i = u.optionen.indexOf(u.loesung);
          expect(u.optionenFa[i], u.beispielFa);
          expect(u.optionenEn[i], u.beispielEn);
        }
      }
    });

    test('richtig/falsch sagt die Wahrheit', () {
      for (final u in erzeugt.where((u) => u.art == UebungsArt.richtigFalsch)) {
        final stimmt =
            u.bedeutungFa == u.beispielFa && u.bedeutungEn == u.beispielEn;
        expect(u.loesung,
            stimmt ? BeispielUebungen.richtig : BeispielUebungen.falsch,
            reason: u.schluessel);
        if (!stimmt) {
          expect(u.bedeutungFa, isNot(u.beispielFa), reason: u.schluessel);
          expect(u.bedeutungEn, isNot(u.beispielEn), reason: u.schluessel);
        }
      }
    });

    test('Zuordnung: 3 Paare, rechte Seite nie in linker Reihenfolge', () {
      for (final u in erzeugt.where((u) => u.art == UebungsArt.matching)) {
        expect(u.paare.length, 3, reason: u.schluessel);
        expect(u.rechteWerte.toSet(), u.paare.map((p) => p.rechts).toSet());
        expect(u.rechteWerte, isNot(u.paare.map((p) => p.rechts).toList()),
            reason: u.schluessel);
        expect(u.paare.map((p) => p.links), contains(u.beispielDe));
        expect(u.paare.every((p) => p.rechtsUebersetzt), isTrue);
      }
    });

    test('Satzbau: nur einfache Sätze, Anfang vorgegeben, gemischt', () {
      for (final u in erzeugt.where((u) => u.art == UebungsArt.wordOrder)) {
        expect(BeispielUebungen.istEinfach(u.loesung), isTrue,
            reason: u.schluessel);
        final w = GrammatikUebung.satzWoerter(u.loesung);
        expect(u.vorgabe, w.first);
        expect([...u.woerter]..sort(), [...w.skip(1)]..sort());
        expect(u.woerter.join(' ').toLowerCase(),
            isNot(w.skip(1).join(' ').toLowerCase()),
            reason: '${u.schluessel}: nicht gemischt');
        expect(u.testTauglich, isFalse);
      }
      expect(BeispielUebungen.istEinfach('der Tisch → die Tische'), isFalse);
      expect(BeispielUebungen.istEinfach('Ich sehe einen Hund. Der Hund ist braun.'),
          isFalse);
      expect(BeispielUebungen.istEinfach('Er besitzt ein großes Haus. (kein Passiv möglich)'),
          isFalse);
      expect(BeispielUebungen.istEinfach('Ich gehe heute ins Kino.'), isTrue);
      expect(BeispielUebungen.istEinfach('Ich gehe.'), isFalse);
    });
  });

  group('Bedienung', () {
    Future<bool?> loese(WidgetTester tester, GrammatikUebung u, String sprache) async {
      bool? ergebnis;
      var aufrufe = 0;
      await tester.pumpWidget(app(
        Scaffold(
          body: SingleChildScrollView(
            child: UebungKarte(
              key: ValueKey('${u.schluessel}-$sprache'),
              uebung: u,
              onGeprueft: (ok) {
                aufrufe++;
                ergebnis = ok;
              },
            ),
          ),
        ),
        sprache: sprache,
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${u.id}: Aufbau');

      switch (u.art) {
        case UebungsArt.multipleChoice:
        case UebungsArt.fillBlank:
        case UebungsArt.bedeutung:
        case UebungsArt.satzWahl:
        case UebungsArt.richtigFalsch:
          await tester.tap(find.byKey(uebungOptionKey(u.loesung)));
        case UebungsArt.wordOrder:
          for (final i in kaertchenFuerLoesung(u)) {
            await tester.tap(find.byKey(ValueKey('frei-$i')));
            await tester.pump();
          }
          await tester.tap(find.byKey(uebungPruefenKey));
        case UebungsArt.transform:
          await tester.enterText(find.byType(TextField), u.loesung);
          await tester.pump();
          await tester.tap(find.byKey(uebungPruefenKey));
        case UebungsArt.matching:
          for (final (i, p) in u.paare.indexed) {
            await tester.tap(find.byKey(ValueKey('wahl-$i-${p.rechts}')));
            await tester.pump();
          }
          await tester.tap(find.byKey(uebungPruefenKey));
      }
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${u.id}: nach Prüfen');
      expect(aufrufe, 1, reason: '${u.id}: genau eine Bewertung');
      return ergebnis;
    }

    for (final sprache in const ['en', 'fa']) {
      testWidgets('jede Übung lässt sich lösen ($sprache)', (tester) async {
        tester.view.physicalSize = const Size(900, 6000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final u in gueltig) {
          expect(await loese(tester, u, sprache), isTrue, reason: u.id);
        }
      });

      testWidgets('jede erzeugte Übung lässt sich lösen ($sprache)',
          (tester) async {
        tester.view.physicalSize = const Size(900, 6000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final l in lektionen) {
          for (final u in BeispielUebungen.erzeuge(l, Random(l.slug.length))) {
            expect(await loese(tester, u, sprache), isTrue,
                reason: u.schluessel);
          }
        }
        // jede Art einmal ausdrücklich
        for (final art in UebungsArt.values) {
          final u = erzeugt.where((x) => x.art == art);
          if (u.isEmpty) continue;
          expect(await loese(tester, u.first, sprache), isTrue,
              reason: '${art.name} ${u.first.schluessel}');
        }
      });

      testWidgets('erzeugte Übung: falsche Antwort zeigt Satz und Bedeutung '
          '($sprache)', (tester) async {
        final u = erzeugt.firstWhere((x) => x.art == UebungsArt.satzWahl);
        bool? ergebnis;
        await tester.pumpWidget(app(
          Scaffold(
            body: SingleChildScrollView(
              child: UebungKarte(uebung: u, onGeprueft: (ok) => ergebnis = ok),
            ),
          ),
          sprache: sprache,
        ));
        final falsch = u.optionen.firstWhere((o) => o != u.loesung);
        await tester.tap(find.byKey(uebungOptionKey(falsch)));
        await tester.pump();
        expect(ergebnis, isFalse);
        final bedeutung = sprache == 'fa' ? u.beispielFa : u.beispielEn;
        // Bedeutung steht oben als Frage und unten in der Rückmeldung
        expect(find.text(bedeutung), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Umformung: „Lösung zeigen" zählt als falsch und zeigt sie',
        (tester) async {
      final u = gueltig.firstWhere((u) => u.art == UebungsArt.transform);
      bool? ergebnis;
      await tester.pumpWidget(app(Scaffold(
        body: SingleChildScrollView(
          child: UebungKarte(uebung: u, onGeprueft: (ok) => ergebnis = ok),
        ),
      )));
      await tester.tap(find.text('Show Answer'));
      await tester.pump();
      expect(ergebnis, isFalse);
      expect(find.text(u.loesung), findsOneWidget);
    });

    testWidgets('Sitzung zählt und zeigt das Ergebnis', (tester) async {
      final zwei = gueltig
          .where((u) => u.art == UebungsArt.multipleChoice)
          .take(2)
          .toList();
      var zurueck = false;
      await tester.pumpWidget(app(Scaffold(
        body: UebungsSitzung(uebungen: zwei, onZurueck: () => zurueck = true),
      )));
      expect(find.text('Exercise 1 of 2'), findsOneWidget);

      // 1. richtig
      await tester.tap(find
          .descendant(
              of: find.byType(OutlinedButton),
              matching: find.text(zwei[0].loesung))
          .first);
      await tester.pump();
      await tester.tap(find.byKey(uebungWeiterKey));
      await tester.pump();
      expect(find.text('Exercise 2 of 2'), findsOneWidget);

      // 2. falsch
      final falsch = zwei[1].optionen.firstWhere((o) => o != zwei[1].loesung);
      await tester.tap(find
          .descendant(of: find.byType(OutlinedButton), matching: find.text(falsch))
          .first);
      await tester.pump();
      await tester.tap(find.byKey(uebungWeiterKey));
      await tester.pump();
      expect(find.text('1 of 2 correct'), findsOneWidget);

      await tester.tap(find.text('Start again'));
      await tester.pump();
      expect(find.text('Exercise 1 of 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(zurueck, isFalse);
    });

    testWidgets('Übungsseite einer Lektion baut auf (en/fa)', (tester) async {
      for (final sprache in const ['en', 'fa']) {
        await tester.pumpWidget(app(
          const GrammatikUebungScreen(slug: 'konjugation-praesens'),
          sprache: sprache,
          overrides: [
            grammatikLektionenProvider.overrideWith((ref) async => {}),
            grammatikUebungenProvider.overrideWith((ref) async => proLektion),
          ],
        ));
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(UebungKarte), findsOneWidget, reason: sprache);
      }
    });
  });
}
