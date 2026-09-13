// FILE: lib/features/reflexiv_verben/models/reflexiv_verb.dart
import 'package:flutter/foundation.dart';

enum ReflexivityType {
  echte,
  unechte,
  dativReflexive;

  static ReflexivityType fromJson(String v) => switch (v) {
        'echte'           => echte,
        'unechte'         => unechte,
        'dativ_reflexive' => dativReflexive,
        _                 => echte,
      };

  String get labelDe => switch (this) {
        echte          => 'Echte Reflexivverben',
        unechte        => 'Unechte Reflexivverben',
        dativReflexive => 'Dativ-Reflexivverben',
      };

  String get labelFa => switch (this) {
        echte          => 'rf_true',
        unechte        => 'rf_untrue',
        dativReflexive => 'rf_dativ',
      };

  String get shortLabel => switch (this) {
        echte          => 'Echte',
        unechte        => 'Unechte',
        dativReflexive => 'Dativ',
      };
}

@immutable
class ReflexivPrincipalParts {
  const ReflexivPrincipalParts({
    required this.praesens3sg,
    required this.praeteritum,
    required this.perfekt,
  });

  factory ReflexivPrincipalParts.fromJson(Map<String, dynamic> j) =>
      ReflexivPrincipalParts(
        praesens3sg : j['praesens_3sg'] as String,
        praeteritum : j['praeteritum']  as String,
        perfekt     : j['perfekt']      as String,
      );

  final String praesens3sg;
  final String praeteritum;
  final String perfekt;

  bool get isSeinVerb => perfekt.startsWith('ist ');
}

@immutable
class ReflexivVerb {
  const ReflexivVerb({
    required this.id,
    required this.verbInfinitive,
    required this.reflexivityType,
    required this.pronounCase,
    required this.preposition,
    required this.prepositionCase,
    required this.dualUse,
    required this.separable,
    required this.principalParts,
    required this.meaningFa,
    required this.meaningEn,
    required this.cefrLevel,
    required this.register,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.nonReflexiveMeaningFa,
    required this.nonReflexiveMeaningEn,
    required this.note,
    this.noteEn = '',
  });

  factory ReflexivVerb.fromJson(Map<String, dynamic> j) => ReflexivVerb(
        id                   : j['id']               as int,
        verbInfinitive       : j['verb_infinitive']  as String,
        reflexivityType      : ReflexivityType.fromJson(
            j['reflexivity_type'] as String),
        pronounCase          : j['pronoun_case']     as String,
        preposition          : j['preposition']      as String?,
        prepositionCase      : j['preposition_case'] as String?,
        dualUse              : j['dual_use']         as bool,
        separable            : j['separable']        as bool,
        principalParts       : ReflexivPrincipalParts.fromJson(
            j['principal_parts'] as Map<String, dynamic>),
        meaningFa            : j['meaning_fa']       as String,
        meaningEn            : j['meaning_en']       as String,
        cefrLevel            : j['cefr_level']       as String,
        register             : j['register']         as String,
        topic                : j['topic']            as String,
        exampleDe            : j['example_de']       as String,
        exampleFa            : j['example_fa']       as String,
        exampleEn            : j['example_en']       as String,
        nonReflexiveMeaningFa: j['non_reflexive_meaning_fa'] as String?,
        nonReflexiveMeaningEn: j['non_reflexive_meaning_en'] as String?,
        note                 : j['note']             as String,
        noteEn               : (j['note_en'] as String?) ?? '',
      );

  final int                    id;
  final String                 verbInfinitive;
  final ReflexivityType        reflexivityType;
  final String                 pronounCase;
  final String?                preposition;
  final String?                prepositionCase;
  final bool                   dualUse;
  final bool                   separable;
  final ReflexivPrincipalParts principalParts;
  final String                 meaningFa;
  final String                 meaningEn;
  final String                 cefrLevel;
  final String                 register;
  final String                 topic;
  final String                 exampleDe;
  final String                 exampleFa;
  final String                 exampleEn;
  final String?                nonReflexiveMeaningFa;
  final String?                nonReflexiveMeaningEn;
  final String                 note;   // FA-Hinweis
  final String                 noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)
}
