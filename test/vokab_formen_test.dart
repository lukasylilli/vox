// FILE: test/vokab_formen_test.dart
// PHASE: L.5f-Nachtrag (2026-09-23) — Wunsch Lukas: «aalartige» antippen ⇒
//        Karte «aalartig». Prüft die Formen-Ableitung und den Popup-Weg.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/wort/klick_wort_provider.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';

void main() {
  group('formenAusKarte', () {
    test('Adjektiv: Deklination, Komparativ, Superlativ', () {
      final f = formenAusKarte({
        'wort': 'aalartig',
        'wortart': 'adjektiv',
        'details': {
          'steigerung': {
            'positiv': 'aalartig',
            'komparativ': 'aalartiger',
            'superlativ': 'am aalartigsten',
          },
        },
      });
      expect(f, containsAll(['aalartige', 'aalartigen', 'aalartigem',
          'aalartiger', 'aalartigere', 'aalartigsten', 'aalartigste']));
      expect(f, isNot(contains('aalartig')), reason: 'Grundform steht im Index');
    });

    test('Adjektiv: e-Ausfall (dunkel, teuer) und -e (leise)', () {
      Set<String> f(String w) => formenAusKarte({
            'wort': w, 'wortart': 'adjektiv', 'details': const {}});
      expect(f('dunkel'), contains('dunkle'));
      expect(f('teuer'), contains('teure'));
      expect(f('leise'), containsAll(['leisen', 'leiser']));
      expect(f('leise'), isNot(contains('leisee')));
    });

    test('Verb: nur das erste Wort jeder Form (keine Partikel, kein Hilfsverb)',
        () {
      final f = formenAusKarte({
        'wort': 'anbieten',
        'wortart': 'verb',
        'details': {
          'stammformen': {'praeteritum': 'bot an', 'partizip2': 'angeboten'},
          'konjugation': {
            'praesens': {'ich': 'biete an', 'er_sie_es': 'bietet an'},
            'imperativ': {'du': 'Biete an!'},
          },
        },
      });
      expect(f, containsAll(['biete', 'bietet', 'bot', 'angeboten']));
      expect(f, isNot(contains('an')));
    });

    test('Nomen: Plural ohne Artikel, Dativ Plural, Genitiv', () {
      final f = formenAusKarte({
        'wort': 'der Tisch',
        'wortart': 'nomen',
        'details': {'genus': 'der', 'plural': 'die Tische',
            'deklinationstyp': 'normal'},
      });
      expect(f, containsAll(['tische', 'tischen', 'tisches', 'tischs']));
      expect(f, isNot(contains('die')));
    });
  });

  test('vokabFormenBauen: Stücke nach erstem Buchstaben + Liste', () {
    final b = vokabFormenBauen([
      {'id': 'adjektiv_aalartig', 'wort': 'aalartig', 'wortart': 'adjektiv',
       'details': const {}},
    ]);
    final liste = (jsonDecode(b[vokabFormenStueckeDatei]!) as List);
    expect(liste, [vokabFormenDatei('aalartige')]);
    expect(jsonDecode(b[vokabFormenDatei('aalartige')]!)['aalartige'],
        ['adjektiv_aalartig']);
  });

  test('Popup: «aalartige» findet die Karte «aalartig»', () async {
    final karte = {'id': 'adjektiv_aalartig', 'wort': 'aalartig',
        'wortart': 'adjektiv'};
    final c = ProviderContainer(overrides: [
      vokabIndexProvider.overrideWith((ref) async => [karte]),
      vokabFormenStueckeProvider
          .overrideWith((ref) async => {vokabFormenDatei('aalartige')}),
      vokabFormenStueckProvider.overrideWith((ref, datei) async => {
            'aalartige': ['adjektiv_aalartig'],
          }),
    ]);
    addTearDown(c.dispose);
    final t = await c.read(klickWortTrefferProvider('aalartige').future);
    expect(t.single.karte!['id'], 'adjektiv_aalartig');
  });
}
