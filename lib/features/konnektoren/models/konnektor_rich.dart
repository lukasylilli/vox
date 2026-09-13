// FILE: lib/features/konnektoren/models/konnektor_rich.dart
import 'package:flutter/material.dart';

@immutable
class GrammarSummary {
  const GrammarSummary({
    required this.structureFa,
    required this.positionNoteFa,
    required this.commonMistakeFa,
    required this.structureEn,
    required this.positionNoteEn,
    required this.commonMistakeEn,
  });
  final String structureFa, positionNoteFa, commonMistakeFa;
  final String structureEn, positionNoteEn, commonMistakeEn;

  factory GrammarSummary.fromJson(Map<String, dynamic> j) => GrammarSummary(
    structureFa    : j['structure_fa'] as String,
    positionNoteFa : j['position_note_fa'] as String,
    commonMistakeFa: j['common_mistake_fa'] as String,
    structureEn    : j['structure_en'] as String? ?? j['structure_fa'] as String,
    positionNoteEn : j['position_note_en'] as String? ?? j['position_note_fa'] as String,
    commonMistakeEn: j['common_mistake_en'] as String? ?? j['common_mistake_fa'] as String,
  );
}

@immutable
class RichExample {
  const RichExample({
    required this.de,
    required this.fa,
    required this.en,
    required this.highlight,
  });
  final String de, fa, en, highlight;

  factory RichExample.fromJson(Map<String, dynamic> j) => RichExample(
    de       : j['de'] as String,
    fa       : j['fa'] as String,
    en       : j['en'] as String,
    highlight: j['highlight'] as String,
  );
}

@immutable
class ConfusableContrast {
  const ConfusableContrast({
    required this.connectorId,
    required this.connector,
    required this.differenceFa,
    required this.differenceEn,
  });
  final int    connectorId;
  final String connector, differenceFa, differenceEn;

  factory ConfusableContrast.fromJson(Map<String, dynamic> j) => ConfusableContrast(
    connectorId : j['connector_id'] as int,
    connector   : j['connector'] as String,
    differenceFa: j['difference_fa'] as String,
    differenceEn: j['difference_en'] as String? ?? j['difference_fa'] as String,
  );
}

// ─── exercise sealed hierarchy ───────────────────────────────────────────────

sealed class ExerciseItem {
  const ExerciseItem(this.type);
  final String type;

  factory ExerciseItem.fromJson(Map<String, dynamic> j) =>
      switch (j['type'] as String) {
        'fill_blank'      => FillBlankExercise.fromJson(j),
        'multiple_choice' => MultipleChoiceExercise.fromJson(j),
        'word_order'      => WordOrderExercise.fromJson(j),
        'translation'     => TranslationExercise.fromJson(j),
        _                 => FillBlankExercise.fromJson(j),
      };
}

@immutable
class FillBlankExercise extends ExerciseItem {
  const FillBlankExercise({
    required this.promptDe,
    required this.answer,
    required this.distractorIds,
  }) : super('fill_blank');
  final String    promptDe, answer;
  final List<int> distractorIds;

  factory FillBlankExercise.fromJson(Map<String, dynamic> j) =>
      FillBlankExercise(
        promptDe    : j['prompt_de'] as String,
        answer      : j['answer'] as String,
        distractorIds: (j['distractor_ids'] as List).cast<int>(),
      );
}

@immutable
class MultipleChoiceExercise extends ExerciseItem {
  const MultipleChoiceExercise({
    required this.promptDe,
    required this.options,
    required this.answerIndex,
  }) : super('multiple_choice');
  final String       promptDe;
  final List<String> options;
  final int          answerIndex;

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> j) =>
      MultipleChoiceExercise(
        promptDe   : j['prompt_de'] as String,
        options    : (j['options'] as List).cast<String>(),
        answerIndex: j['answer_index'] as int,
      );
}

@immutable
class WordOrderExercise extends ExerciseItem {
  const WordOrderExercise({
    required this.words,
    required this.correct,
    required this.context,
  }) : super('word_order');
  final List<String> words;
  final String       correct, context;

  factory WordOrderExercise.fromJson(Map<String, dynamic> j) =>
      WordOrderExercise(
        words  : (j['words'] as List).cast<String>(),
        correct: j['correct'] as String,
        context: (j['context'] as String?) ?? '',
      );
}

@immutable
class TranslationExercise extends ExerciseItem {
  const TranslationExercise({
    required this.promptFa,
    required this.promptEn,
    required this.answerDe,
  }) : super('translation');
  final String promptFa, promptEn, answerDe;

  factory TranslationExercise.fromJson(Map<String, dynamic> j) =>
      TranslationExercise(
        promptFa: j['prompt_fa'] as String,
        promptEn: j['prompt_en'] as String? ?? j['prompt_fa'] as String,
        answerDe: j['answer_de'] as String,
      );
}

// ─── KonnektorRich ───────────────────────────────────────────────────────────

@immutable
class KonnektorRich {
  const KonnektorRich({
    required this.id,
    required this.connector,
    required this.grammarSummary,
    required this.examples,
    required this.confusableContrast,
    required this.exercisePool,
  });

  final int              id;
  final String           connector;
  final GrammarSummary   grammarSummary;
  final List<RichExample>       examples;
  final List<ConfusableContrast> confusableContrast;
  final List<ExerciseItem>      exercisePool;

  factory KonnektorRich.fromJson(Map<String, dynamic> j) => KonnektorRich(
    id               : j['id'] as int,
    connector        : j['connector'] as String,
    grammarSummary   : GrammarSummary.fromJson(
        j['grammar_summary'] as Map<String, dynamic>),
    examples         : (j['examples'] as List)
        .map((e) => RichExample.fromJson(e as Map<String, dynamic>))
        .toList(),
    confusableContrast: (j['confusable_contrast'] as List)
        .map((e) => ConfusableContrast.fromJson(e as Map<String, dynamic>))
        .toList(),
    exercisePool     : (j['exercise_pool'] as List)
        .map((e) => ExerciseItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
