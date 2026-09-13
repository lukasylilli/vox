// FILE: lib/features/trennbar_verben/models/trennbar_verb.dart
import 'package:flutter/foundation.dart';

enum PrefixType {
  trennbar,
  untrennbar,
  wechselpraefix;

  static PrefixType fromJson(String v) => switch (v) {
        'trennbar'       => trennbar,
        'untrennbar'     => untrennbar,
        'wechselpraefix' => wechselpraefix,
        _                => trennbar,
      };

  String get labelDe => switch (this) {
        trennbar       => 'Trennbares Verb',
        untrennbar     => 'Untrennbares Verb',
        wechselpraefix => 'Wechselpraefix',
      };

  String get labelFa => switch (this) {
        trennbar       => 'vt_separable',
        untrennbar     => 'vt_inseparable',
        wechselpraefix => 'vt_dual_prefix',
      };

  String get shortLabel => switch (this) {
        trennbar       => 'Trennbar',
        untrennbar     => 'Untrennbar',
        wechselpraefix => 'Wechsel',
      };
}

@immutable
class TrennbarPrincipalParts {
  const TrennbarPrincipalParts({
    required this.praesens3sg,
    required this.praeteritum,
    required this.perfekt,
  });

  factory TrennbarPrincipalParts.fromJson(Map<String, dynamic> j) =>
      TrennbarPrincipalParts(
        praesens3sg: j['praesens_3sg'] as String,
        praeteritum: j['praeteritum']  as String,
        perfekt    : j['perfekt']      as String,
      );

  final String praesens3sg;
  final String praeteritum;
  final String perfekt;

  bool get isSeinVerb => perfekt.startsWith('ist ');
}

@immutable
class TrennbarVerb {
  const TrennbarVerb({
    required this.id,
    required this.verbInfinitive,
    required this.prefix,
    required this.prefixType,
    required this.baseVerb,
    required this.separable,
    required this.principalParts,
    required this.meaningFa,
    required this.meaningEn,
    required this.caseType,
    required this.preposition,
    required this.register,
    required this.cefrLevel,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.note,
    this.noteEn = '',
  });

  factory TrennbarVerb.fromJson(Map<String, dynamic> j) => TrennbarVerb(
        id            : j['id']             as int,
        verbInfinitive: j['verb_infinitive'] as String,
        prefix        : j['prefix']          as String,
        prefixType    : PrefixType.fromJson(j['prefix_type'] as String),
        baseVerb      : j['base_verb']       as String,
        separable     : j['separable']       as bool,
        principalParts: TrennbarPrincipalParts.fromJson(
            j['principal_parts'] as Map<String, dynamic>),
        meaningFa     : j['meaning_fa']      as String,
        meaningEn     : j['meaning_en']      as String,
        caseType      : j['case_type']       as String,
        preposition   : j['preposition']     as String?,
        register      : j['register']        as String,
        cefrLevel     : j['cefr_level']      as String,
        topic         : j['topic']           as String,
        exampleDe     : j['example_de']      as String,
        exampleFa     : j['example_fa']      as String,
        exampleEn     : j['example_en']      as String,
        note          : (j['note'] as String?) ?? '',
        noteEn        : (j['note_en'] as String?) ?? '',
      );

  final int                    id;
  final String                 verbInfinitive;
  final String                 prefix;
  final PrefixType             prefixType;
  final String                 baseVerb;
  final bool                   separable;
  final TrennbarPrincipalParts principalParts;
  final String                 meaningFa;
  final String                 meaningEn;
  final String                 caseType;
  final String?                preposition;
  final String                 register;
  final String                 cefrLevel;
  final String                 topic;
  final String                 exampleDe;
  final String                 exampleFa;
  final String                 exampleEn;
  final String                 note;   // FA-Hinweis
  final String                 noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)
}
