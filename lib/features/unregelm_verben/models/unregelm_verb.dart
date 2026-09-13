// FILE: lib/features/unregelm_verben/models/unregelm_verb.dart
// PURPOSE: Data model for Unregelmäßige Verben (170 verbs)

enum VerbClass {
  stark,
  gemischt,
  modal,
  irregular;

  static VerbClass fromJson(String v) => switch (v) {
        'stark'     => VerbClass.stark,
        'gemischt'  => VerbClass.gemischt,
        'modal'     => VerbClass.modal,
        'irregular' => VerbClass.irregular,
        _           => VerbClass.stark,
      };

  String get labelDe => switch (this) {
        VerbClass.stark     => 'stark',
        VerbClass.gemischt  => 'gemischt',
        VerbClass.modal     => 'modal',
        VerbClass.irregular => 'irregulär',
      };

  String get labelFa => switch (this) {
        VerbClass.stark     => 'vc_strong',
        VerbClass.gemischt  => 'vc_mixed',
        VerbClass.modal     => 'vc_modal',
        VerbClass.irregular => 'vc_irregular',
      };
}

enum PerfektAuxiliary {
  haben,
  sein;

  static PerfektAuxiliary fromJson(String v) => switch (v) {
        'sein'  => PerfektAuxiliary.sein,
        'haben' => PerfektAuxiliary.haben,
        _       => PerfektAuxiliary.haben,
      };

  String get label => switch (this) {
        PerfektAuxiliary.haben => 'haben',
        PerfektAuxiliary.sein  => 'sein',
      };
}

class UnregelmParts {
  const UnregelmParts({
    required this.praesens3sg,
    required this.praeteritum,
    required this.partizipIi,
  });

  final String praesens3sg;
  final String praeteritum;
  final String partizipIi;

  factory UnregelmParts.fromJson(Map<String, dynamic> j) => UnregelmParts(
        praesens3sg: j['praesens_3sg'] as String? ?? '',
        praeteritum: j['praeteritum']  as String? ?? '',
        partizipIi : j['partizip_ii']  as String? ?? '',
      );
}

class UnregelmVerb {
  const UnregelmVerb({
    required this.id,
    required this.verbInfinitive,
    this.prefix,
    this.prefixType,
    required this.baseVerb,
    required this.separable,
    required this.reflexive,
    required this.principalParts,
    required this.perfektAuxiliary,
    required this.ablautPattern,
    this.praesensVowelChange,
    required this.verbClass,
    required this.meaningFa,
    required this.meaningEn,
    required this.cefrLevel,
    required this.register,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.note,
    this.noteEn = '',
  });

  final int               id;
  final String            verbInfinitive;
  final String?           prefix;
  final String?           prefixType;
  final String            baseVerb;
  final bool              separable;
  final bool              reflexive;
  final UnregelmParts     principalParts;
  final PerfektAuxiliary  perfektAuxiliary;
  final String            ablautPattern;
  final String?           praesensVowelChange;
  final VerbClass         verbClass;
  final String            meaningFa;
  final String            meaningEn;
  final String            cefrLevel;
  final String            register;
  final String            topic;
  final String            exampleDe;
  final String            exampleFa;
  final String            exampleEn;
  final String            note;   // FA-Hinweis
  final String            noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)

  factory UnregelmVerb.fromJson(Map<String, dynamic> j) => UnregelmVerb(
        id                 : j['id']                  as int,
        verbInfinitive     : j['verb_infinitive']      as String,
        prefix             : j['prefix']               as String?,
        prefixType         : j['prefix_type']          as String?,
        baseVerb           : j['base_verb']            as String? ?? '',
        separable          : j['separable']            as bool? ?? false,
        reflexive          : j['reflexive']            as bool? ?? false,
        principalParts     : UnregelmParts.fromJson(
                               j['principal_parts'] as Map<String, dynamic>),
        perfektAuxiliary   : PerfektAuxiliary.fromJson(
                               j['perfekt_auxiliary'] as String? ?? 'haben'),
        ablautPattern      : j['ablaut_pattern']       as String? ?? '',
        praesensVowelChange: j['praesens_vowel_change'] as String?,
        verbClass          : VerbClass.fromJson(j['verb_class'] as String? ?? 'stark'),
        meaningFa          : j['meaning_fa']           as String,
        meaningEn          : j['meaning_en']           as String,
        cefrLevel          : j['cefr_level']           as String,
        register           : j['register']             as String? ?? 'neutral',
        topic              : j['topic']                as String? ?? 'general',
        exampleDe          : j['example_de']           as String? ?? '',
        exampleFa          : j['example_fa']           as String? ?? '',
        exampleEn          : j['example_en']           as String? ?? '',
        note               : j['note']                 as String? ?? '',
        noteEn             : j['note_en']              as String? ?? '',
      );
}
