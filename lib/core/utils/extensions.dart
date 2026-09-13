// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/utils/extensions.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Small shared extensions — the only allowed place for them, so they
//          don't multiply per feature.
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   extension StringX on String {
//     String get capitalized;
//     String stripPreposition();     — 'das Engagement für' → 'das Engagement'
//                                      (today private in word_list_item.dart)
//   }
//   extension ContextX on BuildContext {
//     ColorScheme get cs;            — Theme.of(this).colorScheme shorthand
//     TextTheme  get tt;             — Theme.of(this).textTheme shorthand
//     bool get isDark;
//   }
//   extension ListX<T> on List<T> {
//     List<T> shuffledCopy([Random? rng]);   — quiz option shuffling
//   }
//
// WIRE INTO: everywhere gradually — never define local copies again.
