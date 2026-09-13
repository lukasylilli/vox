// FILE: lib/core/parsers/nvv_parser.dart
// PURPOSE: Parses Nomen-Verb-Verbindungen format (marker = "NVV")
//
// FORMAT:
//   "eine Rolle spielen | NVV | نقش ایفا کردن | B2 | Er spielt eine wichtige Rolle."
//   "Angst haben | NVV | ترس داشتن | B1 | Ich habe Angst vor Hunden."
//
// Fields: phrase | NVV | meaning_fa | [level] | example1...

import '../models/word_model.dart';

class NvvParser {
  static WordModel? parse(String input) {
    final fields = input.split('|').map((f) => f.trim()).toList();
    if (fields.length < 3) return null;
    if (fields[1].toUpperCase() != 'NVV') return null;

    final phrase    = fields[0];
    final meaningFa = fields[2];
    if (meaningFa.isEmpty) return null;

    GermanLevel? level;
    int nextIdx = 3;
    if (nextIdx < fields.length) {
      level = GermanLevel.fromString(fields[nextIdx]);
      if (level != null) nextIdx++;
    }

    final examples = fields.sublist(nextIdx).where((e) => e.isNotEmpty).toList();

    return WordModel(
      id       : 0,
      german   : phrase,
      wordType : WordType.sonstige,    // NVV stored under Sonstige; Auswendiglernen has its own section
      meaningFa: meaningFa,
      level    : level,
      examples : examples,
    );
  }
}
