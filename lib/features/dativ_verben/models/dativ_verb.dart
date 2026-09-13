// FILE: lib/features/dativ_verben/models/dativ_verb.dart
import 'package:flutter/foundation.dart';

enum CaseType {
  datumOnly,
  dativAkkusativ,
  akkusativOnlyConfusable;

  static CaseType fromJson(String v) => switch (v) {
        'dativ_only'                 => datumOnly,
        'dativ_akkusativ'            => dativAkkusativ,
        'akkusativ_only_confusable'  => akkusativOnlyConfusable,
        _                            => datumOnly,
      };

  String get labelDe => switch (this) {
        datumOnly                  => 'Dativ',
        dativAkkusativ             => 'Dativ + Akkusativ',
        akkusativOnlyConfusable    => 'Akkusativ (!)',
      };

  String get labelFa => switch (this) {
        datumOnly                  => 'case_dativ_only',
        dativAkkusativ             => 'Dativ + Akkusativ',
        akkusativOnlyConfusable    => 'case_akk_common',
      };
}

/// Explizite Kasus-Rollen im Beispielsatz (Datengetriebene Färbung).
/// Ersetzt die frühere Heuristik: die Phrasen stehen wörtlich so im Satz,
/// wie sie gefärbt werden sollen (Dativ = blau, Akkusativ = lila).
@immutable
class CaseRoles {
  const CaseRoles({this.dativ = const [], this.akkusativ = const []});

  factory CaseRoles.fromJson(Map<String, dynamic> j) => CaseRoles(
        dativ    : ((j['dativ']     as List?) ?? const []).cast<String>(),
        akkusativ: ((j['akkusativ'] as List?) ?? const []).cast<String>(),
      );

  final List<String> dativ;
  final List<String> akkusativ;

  bool get isEmpty => dativ.isEmpty && akkusativ.isEmpty;
}

@immutable
class PrincipalParts {
  const PrincipalParts({
    required this.praesens3sg,
    required this.praeteritum,
    required this.perfekt,
  });

  factory PrincipalParts.fromJson(Map<String, dynamic> j) => PrincipalParts(
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
class DativVerb {
  const DativVerb({
    required this.id,
    required this.verbInfinitive,
    required this.caseType,
    required this.separable,
    required this.reflexive,
    required this.principalParts,
    required this.meaningFa,
    required this.meaningEn,
    required this.register,
    required this.cefrLevel,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.note,
    this.noteEn = '',
    this.caseRoles,
  });

  factory DativVerb.fromJson(Map<String, dynamic> j) => DativVerb(
        id              : j['id']             as int,
        verbInfinitive  : j['verb_infinitive'] as String,
        caseType        : CaseType.fromJson(j['case_type'] as String),
        separable       : j['separable']      as bool,
        reflexive       : j['reflexive']      as bool,
        principalParts  : PrincipalParts.fromJson(
            j['principal_parts'] as Map<String, dynamic>),
        meaningFa       : j['meaning_fa']     as String,
        meaningEn       : j['meaning_en']     as String,
        register        : j['register']       as String,
        cefrLevel       : j['cefr_level']     as String,
        topic           : j['topic']          as String,
        exampleDe       : j['example_de']     as String,
        exampleFa       : j['example_fa']     as String,
        exampleEn       : j['example_en']     as String,
        note            : j['note']           as String,
        noteEn          : (j['note_en'] as String?) ?? '',
        caseRoles       : j['case_roles'] == null
            ? null
            : CaseRoles.fromJson(j['case_roles'] as Map<String, dynamic>),
      );

  final int            id;
  final String         verbInfinitive;
  final CaseType       caseType;
  final bool           separable;
  final bool           reflexive;
  final PrincipalParts principalParts;
  final String         meaningFa;
  final String         meaningEn;
  final String         register;
  final String         cefrLevel;
  final String         topic;
  final String         exampleDe;
  final String         exampleFa;
  final String         exampleEn;
  final String         note;   // FA-Hinweis
  final String         noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)
  final CaseRoles?     caseRoles; // explizite Kasus-Rollen; null → Heuristik-Fallback
}
