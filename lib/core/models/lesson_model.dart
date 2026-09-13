// FILE: lib/core/models/lesson_model.dart
// DEPS: dart:convert
// PURPOSE: Domain model for grammar lessons + exercises (parsed from DB content JSON)
import 'dart:convert';

enum ExerciseType { lueckentext, wortstellung }

class GrammarExercise {
  const GrammarExercise({
    required this.type,
    this.hint,
    // lueckentext
    this.template,
    this.answer,
    this.options,
    // wortstellung
    this.words,
    this.solution,
  });

  final ExerciseType   type;
  final String?        hint;
  // lueckentext: "Ich ___ nach Berlin."
  final String?        template;
  final String?        answer;
  final List<String>?  options;  // 4 choices for quiz mode (includes correct)
  // wortstellung: shuffled word list + correct sentence
  final List<String>?  words;
  final String?        solution;

  factory GrammarExercise.fromJson(Map<String, dynamic> j) {
    final t = j['type'] as String? ?? 'lueckentext';
    return GrammarExercise(
      type    : t == 'wortstellung' ? ExerciseType.wortstellung : ExerciseType.lueckentext,
      hint    : j['hint'] as String?,
      template: j['template'] as String?,
      answer  : j['answer'] as String?,
      options : (j['options'] as List<dynamic>?)?.cast<String>(),
      words   : (j['words'] as List<dynamic>?)?.cast<String>(),
      solution: j['solution'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type'    : type.name,
    if (hint     != null) 'hint'    : hint,
    if (template != null) 'template': template,
    if (answer   != null) 'answer'  : answer,
    if (options  != null) 'options' : options,
    if (words    != null) 'words'   : words,
    if (solution != null) 'solution': solution,
  };
}

// ── Domain model ──────────────────────────────────────────────────────────────

class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    required this.level,
    required this.body,
    required this.exercises,
    required this.sortOrder,
  });

  final int                    id;
  final String                 title;
  final String                 level;
  final String                 body;
  final List<GrammarExercise>  exercises;
  final int                    sortOrder;

  // Parse drift GrammarLesson.content JSON → LessonModel
  factory LessonModel.fromRaw({
    required int    id,
    required String title,
    required String level,
    required String content,
    required int    sortOrder,
  }) {
    String body       = content;
    List<GrammarExercise> exercises = [];

    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      body      = map['body'] as String? ?? content;
      final raw = map['exercises'] as List<dynamic>? ?? [];
      exercises = raw
          .cast<Map<String, dynamic>>()
          .map(GrammarExercise.fromJson)
          .toList();
    } catch (_) {
      // content is plain text (no exercises)
    }

    return LessonModel(
      id       : id,
      title    : title,
      level    : level,
      body     : body,
      exercises: exercises,
      sortOrder: sortOrder,
    );
  }

  String encodeContent() => jsonEncode({
    'body'     : body,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  });
}
