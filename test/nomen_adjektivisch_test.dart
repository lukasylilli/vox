// FILE: test/nomen_adjektivisch_test.dart
// PHASE: L.4 (2026-10-19) — Entscheidung Lukas: substantivierte Adjektive
//        (der/die Abgeordnete, der/die Angestellte, das Gute) = EINE Karte,
//        beide Geschlechter darauf; die gebeugten Formen (ein Abgeordneter)
//        rechnet die App (Prompt-Regel 21). Prüft id, Schema, Formen für die
//        Suche, Farben der Artikel und das Symbol (kein geratenes Genus).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/grammatikon/grammatikon_resolver.dart';
import 'package:vox/core/grammatikon/grammatikon_spec.dart';
import 'package:vox/core/grammatikon/wort_card.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';
import 'package:vox/features/vokabular/data/vokab_schema.dart';

Map<String, dynamic> abgeordnete({String genus = 'der/die'}) => {
      'schema': '3.0',
      'id': 'nomen_abgeordnete',
      'wort': '$genus Abgeordnete',
      'wortart': 'nomen',
      'uebersetzung': {
        'fa': ['نماینده‌ی مجلس'],
        'en': ['member of parliament'],
      },
      'niveau': 'B2',
      'beispiele': [
        {'niveau': 'A2', 'satz': 'Der Abgeordnete spricht.'},
        {'niveau': 'B2', 'satz': 'Viele Abgeordnete stimmten dagegen.'},
      ],
      'details': {
        'genus': genus,
        'plural': 'die Abgeordneten',
        'deklinationstyp': 'adjektivisch',
        'zaehlbar': true,
      },
      'wortnetz': {
        'grundwort': null,
        'woerter': [
          for (final w in ['Parlament', 'Gesetz', 'Amt', 'Volk', 'Land'])
            {
              'wort': 'das $w',
              'wortart': 'nomen',
              'id_ref': vokabId('nomen', 'das $w'),
            },
        ],
      },
      'box': 1,
      'nextReviewDate': null,
    };

void main() {
  test('id: «der/die» wird wie ein Artikel abgezogen', () {
    expect(vokabId('nomen', 'der/die Abgeordnete'), 'nomen_abgeordnete');
  });

  test('Schema: adjektivisch mit der/die ok, ohne Warnung', () {
    final p = vokabPruefeKarte(abgeordnete());
    expect(p.fehler, isEmpty);
    expect(p.warnungen, isEmpty);
  });

  test('Schema: «der/die» ohne adjektivisch ⇒ fatal (Genus wäre geraten)',
      () {
    final roh = abgeordnete();
    (roh['details'] as Map)['deklinationstyp'] = 'normal';
    expect(vokabPruefeKarte(roh).ok, isFalse);
  });

  test('Formen: Tabelle für die Karte und Suche nach «Abgeordneter»', () {
    expect(vokabAdjektivischeFormen(abgeordnete()), [
      ('der', 'der Abgeordnete · ein Abgeordneter'),
      ('die', 'die Abgeordnete · eine Abgeordnete'),
      ('Plural', 'die Abgeordneten · Abgeordnete'),
    ]);
    final f = formenAusKarte(abgeordnete());
    expect(f, containsAll(['abgeordneter', 'abgeordneten']));

    final gute = abgeordnete(genus: 'das')
      ..['wort'] = 'das Gute'
      ..['details'] = {'genus': 'das', 'deklinationstyp': 'adjektivisch'};
    expect(vokabAdjektivischeFormen(gute), [('das', 'das Gute · ein Gutes')]);
  });

  test('Symbol: «der/die» ⇒ neutraler Umriss, kein geratenes Genus', () {
    final d = GrammatikonResolver.resolve(abgeordnete());
    expect(d.fuellung, 'hohl');
    expect(d.color, GrammatikonSpec.kontur);
    // Ein Geschlecht ⇒ normale Genusfarbe.
    expect(GrammatikonResolver.resolve(abgeordnete(genus: 'der')).color,
        GrammatikonSpec.maskulin);
  });

  test('Artikel: jeder Teil von «der/die» in seiner eigenen Farbe', () {
    final spans = artikelSpans('der/die', null).cast<TextSpan>();
    expect(spans.map((s) => s.text), ['der', '/', 'die']);
    expect(spans[0].style?.color, GrammatikonSpec.maskulin);
    expect(spans[2].style?.color, GrammatikonSpec.feminin);
  });
}
