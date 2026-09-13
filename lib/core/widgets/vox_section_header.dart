// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/widgets/vox_section_header.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Section title / group header widget — single visual language
//          for every grouped list, accordion header, and page section
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class VoxSectionHeader (StatelessWidget)
//     variants:
//       VoxSectionHeader.simple(title)
//         — plain title, labelLarge style, w700
//       VoxSectionHeader.withIcon(title, icon, color)
//         — icon + title + optional subtitle, e.g. grammar sections
//       VoxSectionHeader.collapsible(titleDe, titleFa, count, expanded, onToggle)
//         — expand/collapse toggle with phrase count badge
//         — used in Redemittel 1010 section groups and NVV groups
//       VoxSectionHeader.labeled(label)
//         — all-caps label with horizontal dividers either side
//         — used for PRÜFUNGEN divider in Auswendiglernen
//
// REPLACES: inline Column(children: [Text(title), ...]) headers in
//   grammatik_home_screen.dart
//   nvv_home_screen.dart
//   redemittel_1010_list_screen.dart (_SectionGroup header)
//   auswendiglernen_home_screen.dart (_PruefungenDivider)
//   (and all future feature screens)
