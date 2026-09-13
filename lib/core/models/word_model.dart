// FILE: lib/core/models/word_model.dart
// PURPOSE: Domain model for a word — typed enums, conjugation class, JSON helpers
// INDEPENDENT of drift — controller converts drift Word ↔ WordModel
import 'dart:convert';

// ── Enums ────────────────────────────────────────────────────────────────────

enum WordType {
  nomen        ('Nomen'),
  verb         ('Verb'),
  adjektiv     ('Adjektiv'),
  praepositon  ('Präposition'),
  konnektor    ('Konnektor'),
  modalpartikel('Modalpartikel'),
  pronomen     ('Pronomen'),
  zahl         ('Zahl'),
  sonstige     ('Sonstige');

  const WordType(this.label);
  final String label;

  static WordType fromString(String s) =>
      WordType.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase() ||
               e.label.toLowerCase() == s.toLowerCase(),
        orElse: () => WordType.sonstige,
      );
}

enum GermanLevel {
  a1('A1'), a2('A2'), b1('B1'), b2('B2'), c1('C1'), c2('C2');

  const GermanLevel(this.label);
  final String label;

  static GermanLevel? fromString(String? s) {
    if (s == null) return null;
    return GermanLevel.values.firstWhere(
      (e) => e.label.toLowerCase() == s.toLowerCase(),
      orElse: () => GermanLevel.a1,
    );
  }
}

// ── Conjugation ──────────────────────────────────────────────────────────────

class VerbConjugation {
  const VerbConjugation({
    required this.infinitiv,
    required this.praesens,
    required this.praeteritum,
    required this.partizip,
  });

  final String infinitiv;
  final String praesens;
  final String praeteritum;
  final String partizip;

  factory VerbConjugation.fromJson(Map<String, dynamic> j) => VerbConjugation(
    infinitiv  : j['inf']  ?? '',
    praesens   : j['präs'] ?? '',
    praeteritum: j['prät'] ?? '',
    partizip   : j['pp']   ?? '',
  );

  Map<String, String> toJson() => {
    'inf' : infinitiv,
    'präs': praesens,
    'prät': praeteritum,
    'pp'  : partizip,
  };
}

// ── WordModel ────────────────────────────────────────────────────────────────

class WordModel {
  const WordModel({
    required this.id,
    required this.german,
    required this.wordType,
    required this.meaningFa,
    this.article,
    this.plural,
    this.level,
    this.meaningEn,
    this.pronunciation,
    this.examples = const [],
    this.conjugation,
    this.etymology,
    this.commonErrors,
    this.grammarNote,
  });

  final int              id;
  final String           german;
  final WordType         wordType;
  final String           meaningFa;
  final String?          article;
  final String?          plural;
  final GermanLevel?     level;
  final String?          meaningEn;
  final String?          pronunciation;
  final List<String>     examples;
  final VerbConjugation? conjugation;
  final String?          etymology;
  final String?          commonErrors;
  final String?          grammarNote;

  // Display helpers
  String get displayGerman => article != null ? '${article!} $german' : german;

  // JSON helpers for examples and conjugation
  static List<String> _parseExamples(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  static VerbConjugation? _parseConjugation(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return VerbConjugation.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Build from raw DB strings (called after drift fetches a row)
  factory WordModel.fromRaw({
    required int    id,
    required String german,
    required String wordType,
    required String meaningFa,
    String?  article,
    String?  plural,
    String?  level,
    String?  meaningEn,
    String?  pronunciation,
    String?  examplesJson,
    String?  conjugationJson,
    String?  etymology,
    String?  commonErrors,
    String?  grammarNote,
  }) =>
      WordModel(
        id          : id,
        german      : german,
        wordType    : WordType.fromString(wordType),
        meaningFa   : meaningFa,
        article     : article,
        plural      : plural,
        level       : GermanLevel.fromString(level),
        meaningEn   : meaningEn,
        pronunciation: pronunciation,
        examples    : _parseExamples(examplesJson),
        conjugation : _parseConjugation(conjugationJson),
        etymology   : etymology,
        commonErrors: commonErrors,
        grammarNote : grammarNote,
      );

  String get examplesJson =>
      examples.isEmpty ? '' : jsonEncode(examples);

  String? get conjugationJson =>
      conjugation == null ? null : jsonEncode(conjugation!.toJson());
}
