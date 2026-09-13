// FILE: lib/features/redemittel/models/redemittel_item.dart
import 'package:flutter/foundation.dart';

@immutable
class RedemittelItem {
  const RedemittelItem({
    required this.id,
    required this.phraseDe,
    required this.phraseFa,
    required this.phraseEn,
    required this.sectionId,
    required this.sectionTitleDe,
    required this.sectionTitleFa,
    required this.sectionTitleEn,
    required this.grammarPattern,
    required this.function_,
    required this.register,
    required this.cefrLevel,
    required this.topic,
    required this.structureAfter,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.fillBlankTarget,
    required this.distractors,
    required this.note,
    this.noteEn = '',
    // legacy flat-format support
    this.category = '',
  });

  factory RedemittelItem.fromJson(Map<String, dynamic> j) {
    // Support both rich format (phrase_de / section_title_de) and legacy flat format
    final isRich = j.containsKey('section_title_de');
    return RedemittelItem(
      id             : j['id']               as int,
      phraseDe       : (j['phrase_de']        as String? ?? ''),
      phraseFa       : (j['phrase_fa']        as String? ?? ''),
      phraseEn       : (j['phrase_en']        as String? ?? ''),
      sectionId      : isRich ? (j['section_id'] as int? ?? 0) : 0,
      sectionTitleDe : isRich ? (j['section_title_de'] as String? ?? '') : (j['category'] as String? ?? ''),
      sectionTitleFa : isRich ? (j['section_title_fa'] as String? ?? '') : '',
      sectionTitleEn : isRich ? (j['section_title_en'] as String? ?? '') : '',
      grammarPattern : (j['grammar_pattern']  as String? ?? ''),
      function_      : (j['function']         as String? ?? ''),
      register       : (j['register']         as String? ?? 'neutral'),
      cefrLevel      : (j['cefr_level']       as String? ?? ''),
      topic          : (j['topic']            as String? ?? 'general'),
      structureAfter : (j['structure_after']  as String? ?? ''),
      exampleDe      : (j['example_de']       as String? ?? ''),
      exampleFa      : (j['example_fa']       as String? ?? ''),
      exampleEn      : (j['example_en']       as String? ?? ''),
      fillBlankTarget: (j['fill_blank_target'] as String? ?? ''),
      distractors    : (j['distractors']      as List<dynamic>?)
                           ?.map((e) => e as String).toList() ?? [],
      note           : (j['note']             as String? ?? ''),
      noteEn         : (j['note_en']          as String? ?? ''),
      category       : (j['category']         as String? ?? ''),
    );
  }

  final int          id;
  final String       phraseDe;
  final String       phraseFa;
  final String       phraseEn;
  final int          sectionId;
  final String       sectionTitleDe;
  final String       sectionTitleFa;
  final String sectionTitleEn;
  final String       grammarPattern;
  final String       function_;
  final String       register;
  final String       cefrLevel;
  final String       topic;
  final String       structureAfter;
  final String       exampleDe;
  final String       exampleFa;
  final String       exampleEn;
  final String       fillBlankTarget;
  final List<String> distractors;
  final String       note;   // FA-Hinweis
  final String       noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)
  final String       category;
}
