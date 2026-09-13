// FILE: lib/features/praepositionen/models/praep_cluster.dart
import 'package:flutter/foundation.dart';

@immutable
class PraepMember {
  const PraepMember({
    required this.lemma,
    required this.wordClass,
    required this.preposition,
    required this.grammaticalCase,
    required this.note,
  });

  factory PraepMember.fromJson(Map<String, dynamic> j) => PraepMember(
        lemma          : j['lemma']       as String,
        wordClass      : j['word_class']  as String,
        preposition    : j['preposition'] as String,
        grammaticalCase: j['case']        as String,
        note           : (j['note'] as String?) ?? '',
      );

  final String lemma;
  final String wordClass;
  final String preposition;
  final String grammaticalCase;
  final String note;
}

@immutable
class PraepExample {
  const PraepExample({
    required this.memberLemma,
    required this.memberPreposition,
    required this.de,
    required this.fa,
    required this.en,
  });

  factory PraepExample.fromJson(Map<String, dynamic> j) => PraepExample(
        memberLemma       : j['member_lemma']        as String,
        memberPreposition : j['member_preposition']  as String,
        de                : j['de']                  as String,
        fa                : j['fa']                  as String,
        en                : j['en']                  as String,
      );

  final String memberLemma;
  final String memberPreposition;
  final String de, fa, en;
}

@immutable
class PraepCluster {
  const PraepCluster({
    required this.id,
    required this.clusterId,
    required this.meaningFa,
    required this.meaningEn,
    required this.cefrLevel,
    required this.topic,
    required this.members,
    required this.examples,
    required this.confusableWith,
  });

  factory PraepCluster.fromJson(Map<String, dynamic> j) => PraepCluster(
        id          : j['id']          as int,
        clusterId   : j['cluster_id']  as String,
        meaningFa   : j['meaning_fa']  as String,
        meaningEn   : j['meaning_en']  as String,
        cefrLevel   : j['cefr_level']  as String,
        topic       : j['topic']       as String,
        members     : (j['members'] as List)
            .map((m) => PraepMember.fromJson(m as Map<String, dynamic>))
            .toList(),
        examples    : (j['examples'] as List)
            .map((e) => PraepExample.fromJson(e as Map<String, dynamic>))
            .toList(),
        confusableWith: (j['confusable_with'] as List).cast<int>(),
      );

  final int              id;
  final String           clusterId;
  final String           meaningFa;
  final String           meaningEn;
  final String           cefrLevel;
  final String           topic;
  final List<PraepMember>  members;
  final List<PraepExample> examples;
  final List<int>          confusableWith;

  // All unique prepositions in this cluster
  List<String> get prepositions =>
      members.map((m) => m.preposition).toSet().toList();
}
