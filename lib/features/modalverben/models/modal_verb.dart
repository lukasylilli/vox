// FILE: lib/features/modalverben/models/modal_verb.dart
// PURPOSE: ModalVerb — flashcard model with all tense forms + examples
import 'package:flutter/foundation.dart';

@immutable
class ModalVerbExample {
  const ModalVerbExample({
    required this.de,
    required this.fa,
    required this.en,
    required this.tense,
  });

  factory ModalVerbExample.fromJson(Map<String, dynamic> j) => ModalVerbExample(
        de   : j['de'] as String? ?? '',
        fa   : j['fa'] as String? ?? '',
        en   : j['en'] as String? ?? '',
        tense: j['tense'] as String? ?? '',
      );

  final String de;
  final String fa;
  final String en;
  final String tense;
}

@immutable
class ModalVerb {
  const ModalVerb({
    required this.id,
    required this.infinitive,
    required this.meaningFa,
    required this.meaningEn,
    required this.praesens,
    required this.praeteritum,
    required this.partizip2,
    required this.perfekt,
    required this.perfektErsatz,
    required this.plusquamperfekt,
    required this.futur1,
    required this.konjunktiv2,
    required this.examples,
    required this.noteFa,
    required this.noteEn,
  });

  factory ModalVerb.fromJson(Map<String, dynamic> j) => ModalVerb(
        id             : j['id'] as String,
        infinitive     : j['infinitive'] as String,
        meaningFa      : j['meaning_fa'] as String? ?? '',
        meaningEn      : j['meaning_en'] as String? ?? '',
        praesens       : Map<String, String>.from(j['praesens'] as Map),
        praeteritum    : Map<String, String>.from(j['praeteritum'] as Map),
        partizip2      : j['partizip2'] as String? ?? '',
        perfekt        : j['perfekt'] as String? ?? '',
        perfektErsatz  : j['perfekt_ersatzinfinitiv'] as String? ?? '',
        plusquamperfekt: j['plusquamperfekt'] as String? ?? '',
        futur1         : j['futur1'] as String? ?? '',
        konjunktiv2    : j['konjunktiv2'] as String? ?? '',
        examples       : (j['examples'] as List<dynamic>? ?? [])
            .map((e) => ModalVerbExample.fromJson(e as Map<String, dynamic>))
            .toList(),
        noteFa         : j['note_fa'] as String? ?? '',
        noteEn         : j['note_en'] as String? ?? '',
      );

  final String              id;
  final String              infinitive;
  final String              meaningFa;
  final String              meaningEn;
  final Map<String, String> praesens;
  final Map<String, String> praeteritum;
  final String              partizip2;
  final String              perfekt;
  final String              perfektErsatz;
  final String              plusquamperfekt;
  final String              futur1;
  final String              konjunktiv2;
  final List<ModalVerbExample> examples;
  final String              noteFa;
  final String              noteEn;
}

// ModalGrammarSection wurde durch das generische GrammarTopicSection ersetzt
// (lib/features/grammatik/models/grammar_topic.dart).
