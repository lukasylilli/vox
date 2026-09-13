// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_bottom_bar.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Bottom action bar patterns — persistent bars at the bottom of
//          detail screens, review screens, and quiz screens
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxBottomBar (StatelessWidget) — SafeArea-wrapped action bar
//     props: children (List<Widget>), padding?
//     layout: horizontal Row with evenly-spaced children
//     background: surfaceContainerLow with top border
//
//   class VoxWordDetailBar (StatelessWidget)
//     props: wordId, wordDe (for TTS), hasCategories (bool)
//     children: AudioPlayButton | LeitnerAddButton | AddToCategoryButton
//     (consolidates bottom BottomNavigationBar-style bar in word_detail_screen.dart)
//
//   class VoxQuizActionBar (StatelessWidget)
//     props: label (check/next/finish), onPressed, enabled
//     full-width FilledButton with correct/finish semantics
//     (consolidates action button pattern in all quiz screens)
//
//   class VoxReviewActionBar (StatelessWidget)
//     props: onCorrect, onWrong, correctLabel, wrongLabel
//     two-button bar for Leitner review (درست / نمی‌دونستم)
//     (consolidates _AnswerButtons in leitner_review_screen.dart)
//
// REPLACES: inline BottomNavigationBar and action Row/Column in:
//   word_detail_screen.dart
//   leitner_review_screen.dart
//   unregelm_quiz_screen.dart
//   redemittel_1010_quiz_screen.dart
