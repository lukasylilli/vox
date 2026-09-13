// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/constants/vox_typography.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Typography tokens — named text styles used across the app,
//          built on top of GoogleFonts.vazirmatnTextTheme()
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   abstract final class VoxTypography
//     — all styles reference Theme.of(context).textTheme internally
//     — or define static TextStyle constants for cases without context
//
//   HEADING STYLES:
//     screenTitle     — AppBar title (fontSize 18, w600)
//     sectionTitle    — list section header (fontSize 15, w700)
//     cardTitle       — card/tile main label (fontSize 14, w600)
//
//   BODY STYLES:
//     phraseGerman    — German phrase text (fontSize 15, w600, height 1.5)
//     phrasePersian   — Persian translation (fontSize 13, color onSurfaceVariant)
//     bodyText        — regular content (fontSize 14, height 1.6)
//     noteText        — smaller note/hint (fontSize 12, italic)
//
//   BADGE / CHIP STYLES:
//     cefrBadge       — CEFR level label (fontSize 10, w700)
//     chipLabel       — filter chip text (fontSize 13)
//     labelXS         — very small label (fontSize 10, w600, letterSpacing 1.2)
//
//   QUIZ STYLES:
//     questionPrompt  — quiz question text (fontSize 16, w600, center)
//     questionOption  — answer option text (fontSize 14)
//     resultScore     — big score number (fontSize 36, w900)
//
// NOTE: These tokens are intended to be used AS IS or composed into widgets.
//       Screens should NOT define their own TextStyle — reference tokens here.
