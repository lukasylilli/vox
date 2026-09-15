// FILE: lib/core/parsers/irregular_verb_parser.dart
// PURPOSE: Parses the Unregelmäßige Verben format (marker = "UV")
//
// FORMAT:
//   "gehen | UV | geht | ging | gegangen | رفتن | A1"
//   "sein  | UV | ist  | war  | gewesen  | بودن | A1 | Ich bin müde."
//
// Fields: infinitiv | UV | 3.Sg präsens | präteritum | partizip II | meaning_fa | [level] | [examples...]

import '../models/word_model.dart';

class IrregularVerbParser {
  static WordModel? parse(String input) {
    final fields = input.split('|').map((f) => f.trim()).toList();
    // Minimum: infinitiv | UV | präsens | prät | pp | meaning (6 fields)
    if (fields.length < 6) return null;
    if (fields[1].toUpperCase() != 'UV') return null;

    final infinitiv   = fields[0];
    final praesens    = fields[2];
    final praeteritum = fields[3];
    final partizip    = fields[4];
    final meaningFa   = fields[5];

    if (meaningFa.isEmpty) return null;

    GermanLevel? level;
    int nextIdx = 6;
    if (nextIdx < fields.length) {
      level = GermanLevel.fromString(fields[nextIdx]);
      if (level != null) nextIdx++;
    }

    final examples = fields.sublist(nextIdx).where((e) => e.isNotEmpty).toList();

    final conjugation = VerbConjugation(
      infinitiv  : infinitiv,
      praesens   : praesens,
      praeteritum: praeteritum,
      partizip   : partizip,
    );

    return WordModel(
      id          : 0,
      german      : infinitiv,
      wordType    : WordType.verb,
      meaningFa   : meaningFa,
      level       : level,
      examples    : examples,
      conjugation : conjugation,
      // فاز B-10: dieses Format nennt eigene Stammformen → per Definition
      // unregelmäßig. Trennbarkeit lässt sich aus dem reinen Infinitiv nicht
      // sicher ableiten (z. B. "verstehen" sieht trennbar aus, ist es nicht)
      // — deshalb bewusst null statt geraten (Regel „lieber kein Symbol als
      // ein falsches").
      regelmaessig: false,
    );
  }
}
