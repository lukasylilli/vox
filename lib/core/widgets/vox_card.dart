// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_card.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Card container variants — single source of truth for all card
//          shapes, elevations, and padding across the app
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxCard (StatelessWidget) — generic card wrapper
//     props: child, onTap?, padding?, color?, border?
//     default: elevation 0, surfaceContainerLow color, radius = AppSizes.radiusMd
//
//   class VoxGradientCard — colored gradient card (home screen, level cards)
//     props: color, child, onTap
//     gradient: top-left→bottom-right, alpha 0.85→0.60
//     shadow: color.withValues(alpha:0.3), blur 8, offset (0,4)
//
//   class VoxInfoCard — highlighted info/tip card (grammar intro, tips)
//     props: icon, title, body, color
//     background: color.withValues(alpha:0.12)
//
//   class VoxDetailCard — content card used in detail screens
//     props: icon, iconColor, label, content, style?
//
// REPLACES: inline Card + Container decorations scattered in:
//   grammatik_home_screen.dart (_LevelCard)
//   redemittel_1010_grammar_screen.dart (_IntroCard, _GrammarCard)
//   redemittel_1010_detail_screen.dart (_Card, _ExampleCard)
//   unregelm_quiz_screen.dart (question Card)
//   (all feature screens using Card manually)
