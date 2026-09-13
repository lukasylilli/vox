// FILE: lib/features/konnektoren/models/konnektor.dart
import 'package:flutter/material.dart';

enum ConnectorType {
  nullposition,
  nebensatz,
  adverbial,
  doppelkonnektor,
  praeposition,
  relativsatz;

  static ConnectorType fromJson(String v) => switch (v) {
    'nullposition'    => nullposition,
    'nebensatz'       => nebensatz,
    'adverbial'       => adverbial,
    'doppelkonnektor' => doppelkonnektor,
    'praeposition'    => praeposition,
    'relativsatz'     => relativsatz,
    _                 => adverbial,
  };

  String get labelDe => switch (this) {
    nullposition    => 'Nullposition',
    nebensatz       => 'Nebensatz',
    adverbial       => 'Adverbial',
    doppelkonnektor => 'Doppelkonnektor',
    praeposition    => 'Präposition',
    relativsatz     => 'Relativsatz',
  };

  String get labelFa => switch (this) {
    nullposition    => 'ko_wo_none',
    nebensatz       => 'ko_wo_verb_end',
    adverbial       => 'Inversion',
    doppelkonnektor => 'ko_wo_two_part',
    praeposition    => 'ko_wo_preposition',
    relativsatz     => 'ko_wo_relative',
  };
}

enum WordOrderEffect {
  verbEnd,
  inversion,
  noChange,
  variable;

  static WordOrderEffect fromJson(String v) => switch (v) {
    'verb_end'  => verbEnd,
    'inversion' => inversion,
    'no_change' => noChange,
    'variable'  => variable,
    _           => noChange,
  };

  String get labelFa => switch (this) {
    verbEnd    => 'ko_pos_verb_end',
    inversion  => 'Inversion',
    noChange   => 'ko_pos_unchanged',
    variable   => 'ko_pos_variable',
  };

  String get jsonKey => switch (this) {
    verbEnd    => 'verb_end',
    inversion  => 'inversion',
    noChange   => 'no_change',
    variable   => 'variable',
  };
}

enum SemanticRole {
  causal,
  concessive,
  temporal,
  conditional,
  consecutive,
  adversative,
  additive,
  alternative,
  modal,
  relative,
  correlative;

  static SemanticRole fromJson(String v) => switch (v) {
    'causal'      => causal,
    'concessive'  => concessive,
    'temporal'    => temporal,
    'conditional' => conditional,
    'consecutive' => consecutive,
    'adversative' => adversative,
    'additive'    => additive,
    'alternative' => alternative,
    'modal'       => modal,
    'relative'    => relative,
    'correlative' => correlative,
    _             => causal,
  };

  String get labelFa => switch (this) {
    causal      => 'sr_causal',
    concessive  => 'sr_concessive',
    temporal    => 'sr_temporal',
    conditional => 'sr_conditional',
    consecutive => 'sr_consecutive',
    adversative => 'sr_adversative',
    additive    => 'sr_additive',
    alternative => 'sr_alternative',
    modal       => 'sr_modal',
    relative    => 'sr_relative',
    correlative => 'sr_correlative',
  };
}

@immutable
class Konnektor {
  const Konnektor({
    required this.id,
    required this.connector,
    required this.connectorType,
    required this.wordOrderEffect,
    required this.semanticRole,
    this.partA,
    this.partB,
    this.caseGovernance,
    required this.meaningFa,
    required this.meaningEn,
    required this.register,
    required this.cefrLevel,
    required this.topic,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
    required this.confusableWith,
    required this.note,
    this.noteEn = '',
  });

  final int    id;
  final String connector;
  final ConnectorType    connectorType;
  final WordOrderEffect  wordOrderEffect;
  final SemanticRole     semanticRole;
  final String? partA, partB, caseGovernance;
  final String  meaningFa, meaningEn;
  final String  register, cefrLevel, topic;
  final String  exampleDe, exampleFa, exampleEn;
  final List<int> confusableWith;
  final String  note;   // FA-Hinweis
  final String  noteEn; // EN-Hinweis (فاز L: nur EINE Sprache wird gezeigt)

  factory Konnektor.fromJson(Map<String, dynamic> j) => Konnektor(
    id             : j['id'] as int,
    connector      : j['connector'] as String,
    connectorType  : ConnectorType.fromJson(j['connector_type'] as String),
    wordOrderEffect: WordOrderEffect.fromJson(j['word_order_effect'] as String),
    semanticRole   : SemanticRole.fromJson(j['semantic_role'] as String),
    partA          : j['part_a'] as String?,
    partB          : j['part_b'] as String?,
    caseGovernance : j['case_governance'] as String?,
    meaningFa      : j['meaning_fa'] as String,
    meaningEn      : j['meaning_en'] as String,
    register       : j['register'] as String,
    cefrLevel      : j['cefr_level'] as String,
    topic          : j['topic'] as String,
    exampleDe      : j['example_de'] as String,
    exampleFa      : j['example_fa'] as String,
    exampleEn      : j['example_en'] as String,
    confusableWith : (j['confusable_with'] as List).cast<int>(),
    note           : (j['note'] as String?) ?? '',
    noteEn         : (j['note_en'] as String?) ?? '',
  );

  static Color colorFor(ConnectorType ct, BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (ct) {
      ConnectorType.nullposition    => dark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0),
      ConnectorType.nebensatz       => dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      ConnectorType.adverbial       => dark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      ConnectorType.doppelkonnektor => dark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A),
      ConnectorType.praeposition    => dark ? const Color(0xFFBCAAA4) : const Color(0xFF4E342E),
      ConnectorType.relativsatz     => dark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
    };
  }
}
