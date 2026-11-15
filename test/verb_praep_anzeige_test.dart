// FILE: test/verb_praep_anzeige_test.dart
// PURPOSE: Wächter für den Bug «sich sich» (Lukas, 2026-11-15): in
//          «Verben mit Präpositionen» erschienen reflexive Verben als
//          «sich sich ärgern», weil «sich» schon im Infinitiv stand und
//          displayVerb es noch einmal voranstellte.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/verb_praep/models/verb_praep.dart';

List<VerbPraep> _echteDaten() {
  final roh = jsonDecode(
      File('assets/data/verb_praep_data.json').readAsStringSync());
  final liste = roh is List ? roh : (roh as Map).values.firstWhere((v) => v is List);
  return [
    for (final j in liste as List) VerbPraep.fromJson(j as Map<String, dynamic>)
  ];
}

void main() {
  test('kein Verb erscheint mit doppeltem «sich»', () {
    final verben = _echteDaten();
    expect(verben, isNotEmpty);
    final doppelt = [
      for (final v in verben)
        if (RegExp(r'\bsich\s+sich\b', caseSensitive: false)
            .hasMatch(v.displayVerb))
          v.displayVerb
    ];
    expect(doppelt, isEmpty, reason: 'doppeltes «sich»: $doppelt');
  });

  test('jedes reflexive Verb zeigt genau ein «sich» am Anfang', () {
    for (final v in _echteDaten().where((v) => v.reflexive)) {
      expect(v.displayVerb.toLowerCase().startsWith('sich '), isTrue,
          reason: v.displayVerb);
      expect('sich '.allMatches(v.displayVerb.toLowerCase()).length, 1,
          reason: v.displayVerb);
    }
  });

  test('nicht reflexive Verben bleiben unverändert', () {
    for (final v in _echteDaten().where((v) => !v.reflexive)) {
      expect(v.displayVerb, v.verbInfinitive);
    }
  });
}
