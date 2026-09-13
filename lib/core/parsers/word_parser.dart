// FILE: lib/core/parsers/word_parser.dart
// PURPOSE: Parses the Standard format (pipe-separated)
//
// FORMAT RULES (separator = " | "):
//   Nomen:    "der Hund | die Hunde | سگ | A1 | مثال اول | مثال دوم"
//   Nomen–:   "die Angst | – | ترس | B1"          (no plural → use "–")
//   Verb:     "gehen | Verb | رفتن | A1 | Er geht."
//   Adjektiv: "groß | Adj | بزرگ | A1"
//   Präp:     "mit | Präp | با | A1 | Ich fahre mit dem Bus."
//   Simple:   "gern | خوشحال | A1"               (no type hint, FA in field[1])
//
// DETECTION: called by parser_registry when field[1] ≠ "UV" / "K" / "NVV"

import '../models/word_model.dart';

class WordParser {
  static const _articles = ['der', 'die', 'das'];

  static const _typeMap = {
    'verb'         : WordType.verb,
    'nomen'        : WordType.nomen,
    'nom'          : WordType.nomen,
    'adj'          : WordType.adjektiv,
    'adjektiv'     : WordType.adjektiv,
    'präp'         : WordType.praepositon,
    'praep'        : WordType.praepositon,
    'präposition'  : WordType.praepositon,
    'modal'        : WordType.modalpartikel,
    'modalpartikel': WordType.modalpartikel,
    'pron'         : WordType.pronomen,
    'pronomen'     : WordType.pronomen,
    'zahl'         : WordType.zahl,
  };

  static WordModel? parse(String input) {
    final fields = input.split('|').map((f) => f.trim()).toList();
    if (fields.length < 2) return null;

    // ── Detect article ───────────────────────────────────────────────────────
    String? article;
    String german = fields[0];

    for (final art in _articles) {
      if (german.toLowerCase().startsWith('$art ')) {
        article = art;
        german  = german.substring(art.length + 1).trim();
        break;
      }
    }

    // ── Nomen branch (has article) ───────────────────────────────────────────
    if (article != null) {
      if (fields.length < 3) return null;
      final plural    = fields[1] == '–' || fields[1] == '-' ? null : fields[1];
      final meaningFa = fields[2];
      if (meaningFa.isEmpty) return null;

      GermanLevel? level;
      int nextIdx = 3;
      if (nextIdx < fields.length) {
        level   = GermanLevel.fromString(fields[nextIdx]);
        if (level != null) nextIdx++;
      }
      final examples = _tail(fields, nextIdx);

      return WordModel(
        id: 0, german: german, wordType: WordType.nomen,
        meaningFa: meaningFa, article: article, plural: plural,
        level: level, examples: examples,
      );
    }

    // ── No article — check field[1] for Farsi (= no type hint) ──────────────
    if (_hasFarsi(fields[1])) {
      // Simple: "gern | خوشحال | A1"
      final meaningFa = fields[1];
      GermanLevel? level;
      int nextIdx = 2;
      if (nextIdx < fields.length) {
        level = GermanLevel.fromString(fields[nextIdx]);
        if (level != null) nextIdx++;
      }
      return WordModel(
        id: 0, german: german, wordType: WordType.sonstige,
        meaningFa: meaningFa, level: level, examples: _tail(fields, nextIdx),
      );
    }

    // ── Typed: "gehen | Verb | رفتن | A1" ───────────────────────────────────
    final typeKey = fields[1].toLowerCase().trim();
    final type    = _typeMap[typeKey] ?? WordType.sonstige;

    if (fields.length < 3) return null;
    final meaningFa = fields[2];
    if (meaningFa.isEmpty || !_hasFarsi(meaningFa)) return null;

    GermanLevel? level;
    int nextIdx = 3;
    if (nextIdx < fields.length) {
      level = GermanLevel.fromString(fields[nextIdx]);
      if (level != null) nextIdx++;
    }

    return WordModel(
      id: 0, german: german, wordType: type,
      meaningFa: meaningFa, level: level, examples: _tail(fields, nextIdx),
    );
  }

  static bool _hasFarsi(String s) =>
      s.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

  static List<String> _tail(List<String> fields, int from) =>
      fields.sublist(from).where((e) => e.isNotEmpty).toList();
}
