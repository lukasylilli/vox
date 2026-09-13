// FILE: lib/features/nvv/models/nvv_phrase.dart
import 'package:flutter/foundation.dart';

@immutable
class NvvPhrase {
  const NvvPhrase({
    required this.id,
    required this.phraseDe,
    required this.nounPhrase,
    required this.verbInfinitive,
    this.preposition,
    required this.meaningFa,
    required this.meaningEn,
    required this.synonymDe,
    required this.register,
    required this.cefrLevel,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.note,
    this.noteEn = '',
  });

  factory NvvPhrase.fromJson(Map<String, dynamic> j) => NvvPhrase(
        id             : j['id']               as int,
        phraseDe       : j['phrase_de']         as String,
        nounPhrase     : j['noun_phrase']        as String,
        verbInfinitive : j['verb_infinitive']    as String,
        preposition    : j['preposition']        as String?,
        meaningFa      : j['meaning_fa']         as String,
        meaningEn      : j['meaning_en']         as String,
        synonymDe      : (j['synonym_de'] as String?) ?? '',
        register       : j['register']           as String,
        cefrLevel      : j['cefr_level']         as String,
        topic          : j['topic']              as String,
        exampleDe      : j['example_de']         as String,
        exampleFa      : j['example_fa']         as String,
        exampleEn      : j['example_en']         as String,
        note           : (j['note'] as String?) ?? '',
        noteEn         : (j['note_en'] as String?) ?? '',
      );

  final int     id;
  final String  phraseDe;
  final String  nounPhrase;
  final String  verbInfinitive;
  final String? preposition;
  final String  meaningFa;
  final String  meaningEn;
  final String  synonymDe;
  final String  register;
  final String  cefrLevel;
  final String  topic;
  final String  exampleDe;
  final String  exampleFa;
  final String  exampleEn;
  final String  note;   // FA-Hinweis
  final String  noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)

  bool get hasPreposition => preposition != null && preposition!.isNotEmpty;
}
