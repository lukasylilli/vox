// FILE: lib/features/grammatik/screens/grammatik_home_screen.dart
// DEPS: grammar_catalog_controller.dart, katalog_eintrag_tile.dart, app_routes.dart
// PURPOSE: Grammatik-Home (Stufe G1, GRAMMATIK_MAP.md) — EIN Katalog,
//          vier vom Nutzer umschaltbare Ansichten:
//          Niveau (A1–C2) · Thema · Lektionen (Lernpfad) · Satzglieder
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../controllers/grammar_catalog_controller.dart';
import '../models/grammar_catalog.dart';
import '../widgets/katalog_eintrag_tile.dart';
import '../../../core/l10n/app_l10n.dart';

class GrammatikHomeScreen extends ConsumerWidget {
  const GrammatikHomeScreen({super.key});

  static const _levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final katalogAsync = ref.watch(grammatikKatalogProvider);
    final mode         = ref.watch(grammatikSortModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grammatik')),
      body: katalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (katalog) => ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _SortModeChips(
              mode    : mode,
              onChanged: (m) =>
                  ref.read(grammatikSortModeProvider.notifier).set(m),
            ),
            const SizedBox(height: AppSizes.md),
            ...switch (mode) {
              GrammatikSortMode.niveau      => _niveauView(context, katalog),
              GrammatikSortMode.thema       => _themaView(context, katalog),
              GrammatikSortMode.lektionen   => _lektionenView(context, katalog),
              GrammatikSortMode.satzglieder =>
                  _satzgliederView(context, katalog),
            },
          ],
        ),
      ),
    );
  }

  // ── Ansicht: Niveau (A1–C2) ────────────────────────────────────────────────

  List<Widget> _niveauView(BuildContext context, GrammatikKatalog katalog) => [
        GridView.builder(
          shrinkWrap: true,
          physics   : const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount  : 2,
            mainAxisSpacing : AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1.3,
          ),
          itemCount  : _levels.length,
          itemBuilder: (_, i) {
            final level = _levels[i];
            return _LevelCard(
              level: level,
              count: katalog.byNiveau(level).length,
              color: VoxColors.cefr(level),
              onTap: () => context.push(
                AppRoutes.grammatikKatalog('niveau', level),
              ),
            );
          },
        ),
      ];

  // ── Ansicht: Thema ─────────────────────────────────────────────────────────

  List<Widget> _themaView(BuildContext context, GrammatikKatalog katalog) =>
      katalog.themen
          .map((t) => _GruppenTile(
                icon    : t.icon,
                color   : t.color,
                titleDe : t.de,
                titleFa : AppL10n.meaning(context, fa: t.fa, en: t.en),
                count   : katalog.byThema(t.id).length,
                onTap   : () => context.push(
                  AppRoutes.grammatikKatalog('thema', t.id),
                ),
              ))
          .toList();

  // ── Ansicht: Lektionen (linearer Lernpfad) ─────────────────────────────────

  List<Widget> _lektionenView(
          BuildContext context, GrammatikKatalog katalog) =>
      [
        ...katalog.lektionen.map((e) => KatalogEintragTile(eintrag: e)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Text(
            'Vertiefung & Überblick',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ...katalog.vertiefung.map((e) => KatalogEintragTile(
              eintrag     : e,
              leadingIcon : katalog.thema(e.thema)?.icon ??
                  Icons.menu_book_rounded,
              leadingColor: katalog.thema(e.thema)?.color,
            )),
      ];

  // ── Ansicht: Satzglieder ───────────────────────────────────────────────────

  List<Widget> _satzgliederView(
          BuildContext context, GrammatikKatalog katalog) =>
      katalog.satzglieder
          .map((s) => _GruppenTile(
                icon    : s.icon,
                color   : Theme.of(context).colorScheme.primary,
                titleDe : s.de,
                titleFa : AppL10n.meaning(context, fa: s.fa, en: s.en),
                count   : katalog.bySatzglied(s.id).length,
                onTap   : () => context.push(
                  AppRoutes.grammatikKatalog('satzglied', s.id),
                ),
              ))
          .toList();
}

// ─── Ansicht-Umschalter ──────────────────────────────────────────────────────

class _SortModeChips extends StatelessWidget {
  const _SortModeChips({required this.mode, required this.onChanged});

  final GrammatikSortMode mode;
  final ValueChanged<GrammatikSortMode> onChanged;

  static const _labels = {
    GrammatikSortMode.niveau     : 'Niveau',
    GrammatikSortMode.thema      : 'Thema',
    GrammatikSortMode.lektionen  : 'Lektionen',
    GrammatikSortMode.satzglieder: 'Satzglieder',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final m in GrammatikSortMode.values) ...[
            ChoiceChip(
              label   : Text(_labels[m]!),
              selected: mode == m,
              onSelected: (_) => onChanged(m),
            ),
            const SizedBox(width: AppSizes.sm),
          ],
        ],
      ),
    );
  }
}

// ─── Level-Karte (Niveau-Ansicht) ────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String       level;
  final int          count;
  final Color        color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin  : Alignment.topLeft,
            end    : Alignment.bottomRight,
            colors : [
              color.withValues(alpha: isDark ? 0.7 : 0.85),
              color.withValues(alpha: isDark ? 0.4 : 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color : color.withValues(alpha: 0.3),
              blurRadius: 8, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment : MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level.toUpperCase(),
                style: const TextStyle(
                  color     : Colors.white,
                  fontSize  : 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                count == 0 ? AppL10n.t(context, 'no_topics') : AppL10n.tf(context, 'n_topics', {'n': '$count'}),
                style: const TextStyle(
                  color  : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gruppen-Kachel (Thema-/Satzglieder-Ansicht) ─────────────────────────────

class _GruppenTile extends StatelessWidget {
  const _GruppenTile({
    required this.icon,
    required this.color,
    required this.titleDe,
    required this.titleFa,
    required this.count,
    required this.onTap,
  });

  final IconData     icon;
  final Color        color;
  final String       titleDe;
  final String       titleFa;
  final int          count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(titleDe,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(titleFa, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                color     : color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
