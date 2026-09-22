// FILE: test/praep_vollform_test.dart
// PHASE: R-2.1 (2026-09-22)
// PURPOSE: Die Liste «Nomen · Verb · Adjektiv + Präpositionen» zeigt jedes
//          Wort MIT seiner Präposition (`PraepCluster.vollform`).
//          Wächter: keine Präposition an einem Wort, zu dem sie nicht gehört.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/praepositionen/models/praep_cluster.dart';

PraepMember _m(String lemma, String praep) => PraepMember(
      lemma: lemma,
      wordClass: 'verb',
      preposition: praep,
      grammaticalCase: 'dativ',
      note: '',
    );

PraepCluster _c(List<PraepMember> members) => PraepCluster(
      id: 1,
      clusterId: 'x',
      meaningFa: 'x',
      meaningEn: 'x',
      cefrLevel: 'B1',
      topic: 'general',
      members: members,
      examples: const [],
      confusableWith: const [],
    );

void main() {
  test('gleiche Präposition: einmal am Ende', () {
    expect(
      _c([
        _m('abhängen', 'von'),
        _m('abhängig', 'von'),
        _m('die Abhängigkeit', 'von'),
      ]).vollform,
      'abhängen · abhängig · die Abhängigkeit von',
    );
  });

  test('verschiedene Präpositionen: jedes Wort mit seiner eigenen', () {
    expect(
      _c([
        _m('arbeiten', 'an'),
        _m('arbeiten', 'bei'),
        _m('die Arbeit', 'an'),
      ]).vollform,
      'arbeiten an · arbeiten bei · die Arbeit an',
    );
  });

  test('doppeltes Paar erscheint einmal; leer bleibt leer', () {
    expect(_c([_m('warten', 'auf'), _m('warten', 'auf')]).vollform,
        'warten auf');
    expect(_c(const []).vollform, '');
  });

  test('echte Daten: jedes Wort und jede Präposition steht in der Liste', () {
    final daten = jsonDecode(
            File('assets/data/praepositionen_data.json').readAsStringSync())
        as List;
    expect(daten, isNotEmpty);
    for (final roh in daten) {
      final c = PraepCluster.fromJson(roh as Map<String, dynamic>);
      final v = c.vollform;
      expect(v.trim(), isNotEmpty, reason: '${c.clusterId}: leer');
      for (final m in c.members) {
        expect(v, contains(m.lemma), reason: '${c.clusterId}: ${m.lemma}');
        expect(v, contains(m.preposition),
            reason: '${c.clusterId}: ${m.preposition}');
      }
    }
  });
}
