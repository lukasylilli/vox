// FILE: lib/features/grammatik/models/grammar_topic.dart
// PURPOSE: Generisches Grammatik-Thema — EIN Schema + EIN Screen für alle
//          eigenständigen Themen (Passiv, zu/dass, Tempusformen, Kasus,
//          Modalverben, ...). Neues Thema = 1 JSON + 1 Registry-Zeile hier.
import 'package:flutter/foundation.dart';

@immutable
class GrammarTopicExample {
  const GrammarTopicExample({
    required this.de,
    required this.fa,
    required this.en,
  });

  factory GrammarTopicExample.fromJson(Map<String, dynamic> j) =>
      GrammarTopicExample(
        de: j['de'] as String? ?? '',
        fa: j['fa'] as String? ?? '',
        en: j['en'] as String? ?? '',
      );

  final String de;
  final String fa;
  final String en;
}

@immutable
class GrammarTopicSection {
  const GrammarTopicSection({
    required this.sectionId,
    required this.level,
    required this.titleFa,
    required this.titleEn,
    required this.explanationFa,
    required this.explanationEn,
    required this.examples,
  });

  factory GrammarTopicSection.fromJson(Map<String, dynamic> j) =>
      GrammarTopicSection(
        sectionId    : j['section_id'] as String,
        level        : j['level'] as String? ?? '',
        titleFa      : j['title_fa'] as String? ?? '',
        titleEn      : j['title_en'] as String? ?? '',
        explanationFa: j['explanation_fa'] as String? ?? '',
        explanationEn: j['explanation_en'] as String? ?? '',
        examples     : (j['examples'] as List<dynamic>? ?? [])
            .map((e) => GrammarTopicExample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String sectionId;
  final String level;
  final String titleFa;
  final String titleEn;
  final String explanationFa;
  final String explanationEn;
  final List<GrammarTopicExample> examples;
}

// ─── Themen-Register ───────────────────────────────────────────────────────────
// Neues Thema live schalten = eine Zeile hier + JSON in assets/data/.

@immutable
class GrammarTopicMeta {
  const GrammarTopicMeta({
    required this.titleDe,
    required this.titleFa,
    required this.assetPath,
  });

  final String titleDe;
  final String titleFa;
  final String assetPath;
}

const grammarTopics = <String, GrammarTopicMeta>{
  'passiv': GrammarTopicMeta(
    titleDe  : 'Passiv',
    titleFa  : 'gt_passiv',
    assetPath: 'assets/data/passiv_grammar.json',
  ),
  'zu-dass': GrammarTopicMeta(
    titleDe  : 'zu und dass',
    titleFa  : 'gt_zu_dass',
    assetPath: 'assets/data/zu_dass_grammar.json',
  ),
  'tempusformen': GrammarTopicMeta(
    titleDe  : 'Tempusformen',
    titleFa  : 'gt_tempus',
    assetPath: 'assets/data/tempusformen_grammar.json',
  ),
  'kasus': GrammarTopicMeta(
    titleDe  : 'Dativ oder Akkusativ',
    titleFa  : 'gt_kasus',
    assetPath: 'assets/data/kasus_grammar.json',
  ),
  'modalverben': GrammarTopicMeta(
    titleDe  : 'Modalverben',
    titleFa  : 'gt_modal',
    assetPath: 'assets/data/modalverben_grammar.json',
  ),
};
