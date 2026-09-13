// FILE: lib/features/modalverben/controllers/modalverben_controller.dart
// PURPOSE: Providers — Flashcard-Deck (7 Verben) + Grammatik A1–C2 aus JSON
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/modal_verb.dart';

final modalVerbenProvider = FutureProvider<List<ModalVerb>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/modalverben_data.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return (json['verbs'] as List)
      .cast<Map<String, dynamic>>()
      .map(ModalVerb.fromJson)
      .toList();
});

// Grammatik-Sektionen laufen über den generischen grammarTopicProvider
// (grammar_topic_screen.dart, topicId 'modalverben').
