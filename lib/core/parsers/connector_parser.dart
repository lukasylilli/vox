// FILE: lib/core/parsers/connector_parser.dart
// PURPOSE: Parses the Konnektor/Präposition format (marker = "K")
//
// FORMAT:
//   "weil | K | چون، زیرا | Ich gehe nicht, weil ich müde bin. | Er weint, weil..."
//   "damit | K | برای اینکه | Er lernt, damit er die Prüfung besteht."
//
// Fields: konnektor | K | meaning_fa | example1 | example2...

import '../models/word_model.dart';

class ConnectorParser {
  static WordModel? parse(String input) {
    final fields = input.split('|').map((f) => f.trim()).toList();
    if (fields.length < 3) return null;
    if (fields[1].toUpperCase() != 'K') return null;

    final konnektor = fields[0];
    final meaningFa = fields[2];
    if (meaningFa.isEmpty) return null;

    final examples = fields.sublist(3).where((e) => e.isNotEmpty).toList();

    return WordModel(
      id       : 0,
      german   : konnektor,
      wordType : WordType.konnektor,
      meaningFa: meaningFa,
      examples : examples,
    );
  }
}
