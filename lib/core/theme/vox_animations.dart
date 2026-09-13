// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/theme/vox_animations.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Animation tokens — durations and curves used across the app so
//          all transitions feel consistent and can be tuned in one place
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   abstract final class VoxDurations
//     instant     = Duration(milliseconds: 0)
//     fast        = Duration(milliseconds: 150)   — hover, chip select
//     normal      = Duration(milliseconds: 220)   — filter accordion open/close
//     medium      = Duration(milliseconds: 300)   — page transitions
//     slow        = Duration(milliseconds: 400)   — card flip (Leitner / Auswendiglernen)
//     verySlow    = Duration(milliseconds: 600)   — hero transitions
//
//   abstract final class VoxCurves
//     standard    = Curves.easeInOut              — general UI
//     enter       = Curves.easeOut               — elements appearing
//     exit        = Curves.easeIn                — elements disappearing
//     spring      = Curves.elasticOut            — bouncy badge appear
//
//   abstract final class VoxTransitions
//     static Widget fadeSlide(child, animation)  — fade + slide-up composite
//     static Widget scaleIn(child, animation)    — scale from 0.8 → 1.0
//
// CURRENTLY SCATTERED IN CODE:
//   Duration(milliseconds: 150) — filter_accordion.dart
//   Duration(milliseconds: 220) — filter_accordion.dart
//   Duration(milliseconds: 400) — flash_card_widget.dart, memorize_card_widget.dart
//   Curves.easeInOut            — filter_accordion.dart
