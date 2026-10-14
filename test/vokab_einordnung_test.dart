// FILE: test/vokab_einordnung_test.dart
// PHASE: فاز F.5 (Lukas, 2026-10-14): Prompt-Regel 17 — berufe, anstoessig,
//        zeitlich, ersatz. Ein falsches Etikett ist schlimmer als keins:
//        unbekannte Werte ⇒ Karte wird NIE geschrieben.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

import 'vokab_schema_test.dart' show gueltigesVerb;

Map<String, dynamic> mit(Map<String, dynamic> extra) =>
    {...gueltigesVerb(), ...extra};

void main() {
  test('ohne Einordnung (ältere Karten): erlaubt, keine Warnung dazu', () {
    final p = vokabPruefeKarte(gueltigesVerb());
    expect(p.ok, isTrue);
    expect(p.warnungen.where((w) =>
        w.contains('berufe') || w.contains('anstoessig') ||
        w.contains('zeitlich') || w.contains('ersatz')), isEmpty);
  });

  test('vollständige Einordnung bleibt erhalten', () {
    final p = vokabPruefeKarte(mit({
      'berufe': ['pflege_medizin', 'reinigung'],
      'anstoessig': null,
      'zeitlich': null,
      'ersatz': null,
    }));
    expect(p.ok, isTrue);
    expect(p.karte!['berufe'], ['pflege_medizin', 'reinigung']);
    expect(p.warnungen, isEmpty);
  });

  test('unbekannter Beruf / falsche Stufe / falsches zeitlich ⇒ fatal', () {
    expect(vokabPruefeKarte(mit({'berufe': ['pflege']})).ok, isFalse);
    expect(vokabPruefeKarte(mit({'berufe': 'it'})).ok, isFalse);
    expect(
        vokabPruefeKarte(mit({
          'anstoessig': {'stufe': 'frech'},
        })).ok,
        isFalse);
    expect(vokabPruefeKarte(mit({'zeitlich': 'alt'})).ok, isFalse);
    expect(
        vokabPruefeKarte(mit({
          'ersatz': {'wort': 'gehen', 'wortart': 'tunwort'},
          'zeitlich': 'veraltet',
        })).ok,
        isFalse);
  });

  test('Berufe: Reihenfolge wie im Filter, doppelte weg (Warnung)', () {
    final p = vokabPruefeKarte(mit({
      'berufe': ['reinigung', 'pflege_medizin', 'reinigung'],
    }));
    expect(p.ok, isTrue);
    expect(p.karte!['berufe'], ['pflege_medizin', 'reinigung']);
    expect(p.warnungen.single, contains('berufe'));
  });

  test('veraltet ohne ersatz ⇒ Warnung; ersatz.id_ref wird korrigiert', () {
    expect(
        vokabPruefeKarte(mit({'zeitlich': 'veraltet'})).warnungen.single,
        contains('kein ersatz'));
    final p = vokabPruefeKarte(mit({
      'zeitlich': 'veraltet',
      'ersatz': {
        'wort': 'die Frau',
        'wortart': 'nomen',
        'uebersetzung': {'fa': 'خانم', 'en': 'Ms'},
        'id_ref': 'frau',
      },
    }));
    expect(p.ok, isTrue);
    expect((p.karte!['ersatz'] as Map)['id_ref'], 'nomen_frau');
  });

  test('anstößig ohne Erklärung in fa+en ⇒ Warnung', () {
    final p = vokabPruefeKarte(mit({
      'anstoessig': {'stufe': 'vulgaer', 'erklaerung': {'fa': 'خیلی زشت'}},
    }));
    expect(p.ok, isTrue);
    expect(p.warnungen.single, contains('erklaerung'));
  });

  test('Index: nur gesetzte Einordnung, anstoessig nur mit Stufe', () {
    final leer = vokabIndexEintrag(gueltigesVerb());
    expect(leer.containsKey('berufe'), isFalse);
    expect(leer.containsKey('anstoessig'), isFalse);
    expect(leer.containsKey('zeitlich'), isFalse);
    final e = vokabIndexEintrag(mit({
      'berufe': ['it'],
      'anstoessig': {
        'stufe': 'abwertend',
        'erklaerung': {'fa': '…', 'en': '…'},
      },
      'zeitlich': 'veraltend',
    }));
    expect(e['berufe'], ['it']);
    expect(e['anstoessig'], {'stufe': 'abwertend'});
    expect(e['zeitlich'], 'veraltend');
  });

  test('Prompt und Schema nennen dieselben Werte (Regel 17)', () {
    final prompt =
        File('old files Lukasalmani/Wort prompt').readAsStringSync();
    for (final b in vokabBerufe) {
      expect(prompt.contains(b), isTrue, reason: 'Beruf «$b» fehlt im Prompt');
    }
    for (final s in [...vokabAnstoessigStufen, ...vokabZeitlichWerte]) {
      expect(prompt.contains(s), isTrue, reason: '«$s» fehlt im Prompt');
    }
    expect(
        prompt.contains(
            '"berufe": ["<Regel 17: ${vokabBerufe.join(' | ')} — meist []>"]'),
        isTrue,
        reason: 'TEIL 1 muss die Berufe in Filter-Reihenfolge nennen');
  });
}
