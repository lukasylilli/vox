// FILE: lib/features/verb_praep/models/verb_praep.dart
// PURPOSE: Data model for Verben mit Präpositionen (72 verbs)

enum PrepositionCase {
  akkusativ,
  dativ;

  static PrepositionCase fromJson(String v) => switch (v) {
        'akkusativ' => PrepositionCase.akkusativ,
        'dativ'     => PrepositionCase.dativ,
        _           => PrepositionCase.akkusativ,
      };

  String get labelFa => switch (this) {
        PrepositionCase.akkusativ => 'Akkusativ',
        PrepositionCase.dativ     => 'Dativ',
      };
}

class VerbPraepParts {
  const VerbPraepParts({
    required this.praesens3sg,
    required this.praeteritum,
    required this.partizipIi,
  });

  final String praesens3sg;
  final String praeteritum;
  final String partizipIi;

  factory VerbPraepParts.fromJson(Map<String, dynamic> j) => VerbPraepParts(
        praesens3sg: j['praesens_3sg'] as String,
        praeteritum: j['praeteritum']  as String,
        partizipIi : j['partizip_ii']  as String,
      );
}

class VerbPraep {
  const VerbPraep({
    required this.id,
    required this.verbInfinitive,
    required this.reflexive,
    required this.preposition,
    required this.prepositionCase,
    required this.woCompound,
    required this.prepositionWithPerson,
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
    required this.note,
    this.noteEn = '',
  });

  final int              id;
  final String           verbInfinitive;
  final bool             reflexive;
  final String           preposition;
  final PrepositionCase  prepositionCase;
  final String           woCompound;
  final String           prepositionWithPerson;
  final bool             separable;
  final VerbPraepParts   principalParts;
  final String           meaningFa;
  final String           meaningEn;
  final String           cefrLevel;
  final String           register;
  final String           topic;
  final String           exampleDe;
  final String           exampleFa;
  final String           exampleEn;
  final String           note;   // FA-Hinweis
  final String           noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)

  String get displayVerb => reflexive ? 'sich $verbInfinitive' : verbInfinitive;

  factory VerbPraep.fromJson(Map<String, dynamic> j) => VerbPraep(
        id                   : j['id']                    as int,
        verbInfinitive       : j['verb_infinitive']       as String,
        reflexive            : j['reflexive']             as bool? ?? false,
        preposition          : j['preposition']           as String,
        prepositionCase      : PrepositionCase.fromJson(j['preposition_case'] as String),
        woCompound           : j['wo_compound']           as String? ?? '',
        prepositionWithPerson: j['preposition_with_person'] as String? ?? '',
        separable            : j['separable']             as bool? ?? false,
        principalParts       : VerbPraepParts.fromJson(
                                 j['principal_parts'] as Map<String, dynamic>),
        meaningFa  : j['meaning_fa']  as String,
        meaningEn  : j['meaning_en']  as String,
        cefrLevel  : j['cefr_level']  as String,
        register   : j['register']    as String? ?? 'neutral',
        topic      : j['topic']       as String? ?? 'general',
        exampleDe  : j['example_de']  as String? ?? '',
        exampleFa  : j['example_fa']  as String? ?? '',
        exampleEn  : j['example_en']  as String? ?? '',
        note       : j['note']        as String? ?? '',
        noteEn     : j['note_en']     as String? ?? '',
      );
}
