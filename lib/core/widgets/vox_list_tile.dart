// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_list_tile.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Standardized list item tiles — single source of truth for
//          all list rows across the app
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxListTile (StatelessWidget) — generic content row
//     props: title, subtitle?, leading?, trailing?, onTap, selected?
//
//   class VoxPhraseListTile — for Redemittel / NVV / Konnektoren rows
//     props: phraseDe, phraseFa?, cefrLevel?, register?, onTap
//
//   class VoxVerbListTile — for verb feature rows (reflexiv, trennbar, etc.)
//     props: infinitiv, meaningFa, badge widget, onTap
//
//   class VoxWordListTile — Wortschatz rows
//     props: german, article?, wordType, level, onTap
//
//   class VoxDeckListTile — Auswendiglernen deck rows
//     props: titleDe, titleFa, levels, icon, color, description?, status
//     (will replace _DeckTile in auswendiglernen_home_screen.dart)
//
// REPLACES: _PhraseCard, _VerbCard, _DeckTile, word_list_item.dart inline code
//           scattered across feature list screens
