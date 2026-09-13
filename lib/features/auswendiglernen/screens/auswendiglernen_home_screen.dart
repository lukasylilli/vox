// FILE: lib/features/auswendiglernen/screens/auswendiglernen_home_screen.dart
// PURPOSE: Auswendiglernen — flat deck list + PRÜFUNGEN section at bottom
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/services/feature_flags.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_snack_bar.dart';
import '../controllers/auswendiglernen_controller.dart';
import '../../../core/l10n/app_l10n.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class _Deck {
  const _Deck({
    required this.titleDe,
    required this.titleFa,
    required this.levels,
    required this.icon,
    required this.color,
    this.route,
    this.description,
    this.flag = '',
  });

  final String       titleDe;
  final String       titleFa;
  final List<String> levels;
  final IconData     icon;
  final Color        color;
  final String?      route;
  final String?      description;
  final String       flag;   // FeatureFlags key — '' = always live
}

// ─── Flat deck catalogue — learning decks ────────────────────────────────────

const _learningDecks = [
  _Deck(
    titleDe    : 'Satzkonnektoren',
    titleFa    : 'deck_konnektoren',
    levels     : ['C1', 'C2'],
    icon       : Icons.link_rounded,
    color      : Color(0xFF1565C0),
    route      : AppRoutes.konnektoren,
    description: 'deck_konn_sub',
  ),
  _Deck(
    titleDe    : 'Dativ und Akkusativ Verben',
    titleFa    : 'deck_dativ',
    levels     : ['A1', 'A2'],
    icon       : Icons.swap_horiz_rounded,
    color      : Color(0xFF6A1B9A),
    route      : AppRoutes.dativVerben,
    description: 'deck_dativ_sub',
  ),
  _Deck(
    titleDe    : 'Nomen-Verb-Verbindungen',
    titleFa    : 'deck_nvv',
    levels     : ['B2'],
    icon       : Icons.extension_rounded,
    color      : Color(0xFF00695C),
    route      : AppRoutes.nvv,
    description: 'deck_nvv_sub',
  ),
  _Deck(
    titleDe    : 'Nomen · Verb · Adjektiv + Präposition',
    titleFa    : 'deck_praep',
    levels     : ['B2'],
    icon       : Icons.category_rounded,
    color      : Color(0xFF2E7D32),
    route      : AppRoutes.praepositionen,
    description: 'deck_praep_sub',
  ),
  _Deck(
    titleDe    : 'Redewendungen',
    titleFa    : 'deck_idioms_sub',
    levels     : [],
    icon       : Icons.format_quote_rounded,
    color      : Color(0xFF6750A4),
    route      : '/auswendiglernen/0',
    description: 'deck_personal_sub',
  ),
  _Deck(
    titleDe: 'Relativsatz',
    titleFa: 'deck_relativ_sub',
    levels : ['B1', 'B2'],
    icon   : Icons.account_tree_rounded,
    color  : Color(0xFFC62828),
    flag   : 'deck.relativsatz',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe    : 'Unregelmäßige Verben',
    titleFa    : 'deck_unregelm',
    levels     : ['A1', 'A2', 'B1'],
    icon       : Icons.format_list_numbered_rounded,
    color      : Color(0xFF1565C0),
    route      : AppRoutes.unregelVerben,
    description: 'deck_unregelm_sub',
  ),
  _Deck(
    titleDe    : 'Trennbare und untrennbare Verben',
    titleFa    : 'deck_trennbar',
    levels     : ['A1', 'A2'],
    icon       : Icons.call_split_rounded,
    color      : Color(0xFF0277BD),
    route      : AppRoutes.trennbar,
    description: 'deck_trennbar_sub',
  ),
  _Deck(
    titleDe    : 'Reflexivverben',
    titleFa    : 'deck_reflexiv',
    levels     : ['A2', 'B1'],
    icon       : Icons.loop_rounded,
    color      : Color(0xFF558B2F),
    route      : AppRoutes.reflexiv,
    description: 'deck_reflexiv_sub',
  ),
  _Deck(
    titleDe    : 'Verben mit Präpositionen',
    titleFa    : 'deck_verbpraep',
    levels     : ['B1', 'B2'],
    icon       : Icons.merge_type_rounded,
    color      : Color(0xFF6A1B9A),
    route      : AppRoutes.verbPraep,
    description: 'deck_verbpraep_sub',
  ),
  _Deck(
    titleDe    : 'Modalverben',
    titleFa    : 'deck_modal',
    levels     : ['A1', 'A2', 'B1'],
    icon       : Icons.tune_rounded,
    color      : Color(0xFF00695C),
    route      : AppRoutes.modalverben,
    flag       : 'deck.modalverben',
    description: 'deck_modal_sub',
  ),
  _Deck(
    titleDe: 'Da + Präpositionen',
    titleFa: 'deck_dapraep',
    levels : ['B1', 'B2'],
    icon   : Icons.merge_rounded,
    color  : Color(0xFFBF360C),
    flag   : 'deck.da_praepositionen',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe: 'Adjektive',
    titleFa: 'deck_adjektive',
    levels : ['A2'],
    icon   : Icons.star_rounded,
    color  : Color(0xFFF9A825),
    flag   : 'deck.adjektive',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe: 'Adjektivdeklination (Mindmap)',
    titleFa: 'deck_adj_sub',
    levels : ['B1'],
    icon   : Icons.account_tree_rounded,
    color  : Color(0xFFFF8F00),
    flag   : 'deck.adjektivdeklination',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe: 'Tempusformen',
    titleFa: 'deck_tempus',
    levels : ['C2'],
    icon   : Icons.access_time_rounded,
    color  : Color(0xFF37474F),
    flag   : 'deck.tempusformen',           // comingSoon via FeatureFlags
  ),
];

// ─── Prüfungen decks (below separator) ───────────────────────────────────────

const _pruefungenDecks = [
  _Deck(
    titleDe    : 'Goethe B2 Redemittel',
    titleFa    : 'deck_goethe',
    levels     : ['B2'],
    icon       : Icons.school_rounded,
    color      : Color(0xFF283593),
    route      : AppRoutes.redemittelGoetheB2,
    description: 'deck_goethe_sub',
  ),
  _Deck(
    titleDe    : 'ÖSD B2 Redemittel',
    titleFa    : 'deck_oesd_b2',
    levels     : ['B2'],
    icon       : Icons.school_rounded,
    color      : Color(0xFF1A237E),
    route      : AppRoutes.redemittelOesdB2,
    flag       : 'deck.oesd_b2',
    description: 'deck_oesd_sub',
  ),
  _Deck(
    titleDe: 'ÖSD C1 Redemittel',
    titleFa: 'deck_oesd_c1',
    levels : ['C1'],
    icon   : Icons.school_rounded,
    color  : Color(0xFF880E4F),
    flag   : 'deck.oesd_c1',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe    : '1010 Redemittel',
    titleFa    : 'deck_1010',
    levels     : ['B2', 'C1'],
    icon       : Icons.format_list_bulleted_rounded,
    color      : Color(0xFF4A148C),
    route      : AppRoutes.redemittel1010,
    description: 'deck_1010_sub',
  ),
  _Deck(
    titleDe: 'Redemittel für Zusammenfassung',
    titleFa: 'deck_zusammenfassung',
    levels : ['B2', 'C1'],
    icon   : Icons.summarize_rounded,
    color  : Color(0xFF00838F),
    flag   : 'deck.zusammenfassung',           // comingSoon via FeatureFlags
  ),
  _Deck(
    titleDe: 'A2 Zusammenfassung',
    titleFa: 'deck_a2_grammar',
    levels : ['A2'],
    icon   : Icons.auto_stories_rounded,
    color  : Color(0xFF0277BD),
    flag   : 'deck.a2_zusammenfassung',           // comingSoon via FeatureFlags
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AuswendiglernHomeScreen extends ConsumerWidget {
  const AuswendiglernHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(categoryCountsProvider);
    final redewendungenCount =
        countsAsync.valueOrNull?['Redewendungen'] ?? 0;

    void onTap(_Deck deck) {
      if (FeatureFlags.isComingSoon(deck.flag)) {
        VoxSnackBar.comingSoon(context, deck.titleDe);
        return;
      }
      if (deck.route != null) context.push(deck.route!);
    }

    // Build list items: learning decks + separator + Prüfungen decks
    final items = <Widget>[
      ..._learningDecks.map((d) {
        final desc = d.titleDe == 'Redewendungen' && redewendungenCount > 0
            ? Formatters.countLabel(redewendungenCount, AppL10n.t(context, 'card_unit'))
            : d.description;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.xs),
          child  : _DeckTile(deck: d, description: desc, onTap: () => onTap(d)),
        );
      }),
      const SizedBox(height: AppSizes.sm),
      _PruefungenDivider(),
      const SizedBox(height: AppSizes.xs),
      ..._pruefungenDecks.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.xs),
            child  : _DeckTile(deck: d, onTap: () => onTap(d)),
          )),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Auswendiglernen')),
      body: ListView(
        padding : const EdgeInsets.fromLTRB(
            AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
        children: items,
      ),
    );
  }
}

// ─── Prüfungen divider ────────────────────────────────────────────────────────

class _PruefungenDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        const SizedBox(width: 10),
        Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              'PRÜFUNGEN',
              style: tt.labelSmall?.copyWith(
                fontWeight  : FontWeight.w800,
                color       : cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

// ─── Deck tile ────────────────────────────────────────────────────────────────

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.deck,
    required this.onTap,
    this.description,
  });

  final _Deck        deck;
  final VoidCallback onTap;
  final String?      description;

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isSoon  = FeatureFlags.isComingSoon(deck.flag);
    final bgAlpha = isDark ? 0.22 : 0.1;
    final fgAlpha = isSoon ? 0.45 : 1.0;
    final color   = deck.color.withValues(alpha: fgAlpha);

    return Card(
      margin: EdgeInsets.zero,
      child : InkWell(
        onTap       : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: 10),
          child: Row(
            children: [
              // ── Icon ─────────────────────────────────────────────
              Container(
                width : 42,
                height: 42,
                decoration: BoxDecoration(
                  color       : deck.color.withValues(
                      alpha: isSoon ? 0.08 : bgAlpha),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(deck.icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.sm),
              // ── Title + description ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.titleDe,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color     : isSoon
                                ? scheme.onSurface.withValues(alpha: 0.45)
                                : null,
                          ),
                    ),
                    Text(
                      AppL10n.t(context, deck.titleFa),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant
                                .withValues(alpha: isSoon ? 0.45 : 1.0),
                          ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 11,
                          color   : color.withValues(
                              alpha: isSoon ? 0.35 : 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Level badges ──────────────────────────────────────
              if (deck.levels.isNotEmpty) ...[
                Wrap(
                  spacing : 3,
                  children: deck.levels
                      .map((l) => _LevelBadge(level: l, faded: isSoon))
                      .toList(),
                ),
                const SizedBox(width: 4),
              ],
              // ── Status icon ───────────────────────────────────────
              isSoon
                  ? Icon(Icons.lock_outline_rounded,
                      size : 16,
                      color: scheme.onSurface.withValues(alpha: 0.3))
                  : Icon(Icons.chevron_right_rounded,
                      size : 20,
                      color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Level badge ──────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, this.faded = false});
  final String level;
  final bool   faded;

  @override
  Widget build(BuildContext context) {
    final c = VoxColors.cefr(level).withValues(alpha: faded ? 0.35 : 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color       : c.withValues(alpha: faded ? 0.06 : 0.12),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(color: c.withValues(alpha: faded ? 0.2 : 0.4)),
      ),
      child: Text(
        level,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
