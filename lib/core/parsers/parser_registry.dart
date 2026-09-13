// FILE: lib/core/parsers/parser_registry.dart
// DEPS: word_parser.dart, irregular_verb_parser.dart, connector_parser.dart, nvv_parser.dart
// PURPOSE: Auto-detects format from field[1] marker and delegates to correct parser
//
// MARKER TABLE:
//   field[1] == "UV"  → IrregularVerbParser   (Unregelmäßige Verben)
//   field[1] == "K"   → ConnectorParser        (Konnektor / Präposition)
//   field[1] == "NVV" → NvvParser              (Nomen-Verb-Verbindungen)
//   (default)         → WordParser             (Nomen / Verb / Adj / Simple)

import '../models/word_model.dart';
import 'connector_parser.dart';
import 'irregular_verb_parser.dart';
import 'nvv_parser.dart';
import 'word_parser.dart';

enum ParseFormat { standard, irregularVerb, konnektor, nvv }

class ParserRegistry {
  static WordModel? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final marker = _extractMarker(trimmed);

    return switch (marker) {
      'UV'  => IrregularVerbParser.parse(trimmed),
      'K'   => ConnectorParser.parse(trimmed),
      'NVV' => NvvParser.parse(trimmed),
      _     => WordParser.parse(trimmed),
    };
  }

  static ParseFormat detectFormat(String input) {
    return switch (_extractMarker(input.trim())) {
      'UV'  => ParseFormat.irregularVerb,
      'K'   => ParseFormat.konnektor,
      'NVV' => ParseFormat.nvv,
      _     => ParseFormat.standard,
    };
  }

  static String _extractMarker(String input) {
    final parts = input.split('|');
    if (parts.length < 2) return '';
    return parts[1].trim().toUpperCase();
  }

  // Format hint strings shown in AddWordScreen
  static String formatHint(ParseFormat format) => switch (format) {
    ParseFormat.standard     => 'der Hund | die Hunde | سگ | A1 | مثال\n'
                                'gehen | Verb | رفتن | A1 | مثال\n'
                                'groß | Adj | بزرگ | A1',
    ParseFormat.irregularVerb => 'gehen | UV | geht | ging | gegangen | رفتن | A1',
    ParseFormat.konnektor    => 'weil | K | چون | مثال اول | مثال دوم',
    ParseFormat.nvv          => 'eine Rolle spielen | NVV | نقش ایفا کردن | B2 | مثال',
  };
}
