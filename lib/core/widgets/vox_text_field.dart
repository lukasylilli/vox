// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_text_field.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Text input field variants — single source of truth for all
//          text inputs across the app (forms, quizzes, cloze tests)
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxTextField (StatelessWidget) — standard single-line input
//     props: controller, hintText, label?, prefixIcon?, suffix?,
//            enabled, onChanged, onSubmitted, textInputAction,
//            keyboardType, maxLength?
//     style: OutlineInputBorder, radius 12, isDense
//
//   class VoxMultilineField (StatelessWidget) — multi-line textarea
//     props: controller, hintText, minLines(3), maxLines(10), maxLength?
//     used for: import screen, schreiben templates
//
//   class VoxClozeField (StatelessWidget) — inline fill-in-blank field
//     props: controller, width (sized to expected answer), enabled,
//            correct?, onSubmitted
//     used for: cloze_practice_screen, hoeren_quiz_screen, grammar exercises
//     style: compact underline border, colored border on correct/wrong
//
// REPLACES: inline TextField in:
//   add_word_screen.dart
//   import_screen.dart
//   grammar_exercise_screen.dart (cloze)
//   hoeren_quiz_screen.dart
//   cloze_practice_screen.dart
//   unregelm_quiz_screen.dart (cloze type)
//   (all future screens with text input)
