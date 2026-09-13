// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_app_bar.dart
// STATUS: [ ] stub — code pending
// PURPOSE: AppBar patterns — standardized app bar configurations used
//          across all screens (list bars, detail bars, quiz progress bars)
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxListAppBar (PreferredSizeWidget)
//     props: title, actions? (grammar icon, quiz icon)
//     standard AppBar for all feature list screens
//
//   class VoxDetailAppBar (PreferredSizeWidget)
//     props: title, subtitle?, actions?
//     standard AppBar for detail screens — smaller font for subtitle
//
//   class VoxQuizAppBar (PreferredSizeWidget)
//     props: current (int), total (int)
//     title: "$current / $total"
//     bottom: LinearProgressIndicator (value: current/total)
//     (consolidates AppBar + bottom in all quiz screens)
//
//   class VoxSliverListAppBar (SliverAppBar config)
//     props: title, icon, color (for home-style sliver bars)
//     used in: wortschatz_home_screen.dart, grammatik_home_screen.dart
//
// NOTE: Does NOT replace AppBar entirely — only provides pre-configured
//       factories for the most common AppBar shapes in this app.
//
// REPLACES: repeated AppBar(title: ..., bottom: PreferredSize(...)) patterns in:
//   unregelm_quiz_screen.dart
//   reflexiv_quiz_screen.dart
//   trennbar_quiz_screen.dart
//   nvv_quiz_screen.dart
//   redemittel_1010_quiz_screen.dart
//   (all future quiz screens)
