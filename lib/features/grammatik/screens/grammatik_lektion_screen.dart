// FILE: lib/features/grammatik/screens/grammatik_lektion_screen.dart
// DEPS: grammatik_lektion_controller.dart, app_l10n.dart
// PURPOSE: Rendert eine Grammatik-Lektion aus Content-JSON (Stufe G2).
//          Route /grammatik/lektion/:slug — Blocks + Beispiele + Tabellen +
//          verwandte Lektionen. Deutsch fest, FA/EN aus Settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../controllers/grammatik_lektion_controller.dart';
import '../models/grammatik_lektion.dart';

class GrammatikLektionScreen extends ConsumerWidget {
  const GrammatikLektionScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lektionAsync = ref.watch(grammatikLektionProvider(slug));

    return lektionAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body  : Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
      ),
      data: (lek) {
        if (lek == null) {
          return Scaffold(
            appBar: AppBar(),
            body  : const VoxEmptyState.comingSoon(),
          );
        }
        return _LektionView(lek: lek);
      },
    );
  }
}

class _LektionView extends ConsumerWidget {
  const _LektionView({required this.lek});
  final GrammatikLektion lek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(lek.titleDe)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Untertitel: aktive Zweitsprache
          Text(
            AppL10n.meaning(context, fa: lek.titleFa, en: lek.titleEn),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (lek.levels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: lek.levels
                  .map((n) => Chip(
                        label: Text(n),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSizes.md),

          // ── G7a: Übungen (oben kurz, unten groß) ─────────────────
          _UebungStart(slug: lek.slug, gross: false),

          // ── Erklärblöcke ─────────────────────────────────────────
          ...lek.explanationBlocks.map((b) => _Block(b)),

          // ── Tabellen ─────────────────────────────────────────────
          // Unstimmige Tabelle nie zeichnen (DataTable stürzt sonst ab) —
          // dass es keine gibt, prüft test/grammatik_lektionen_test.dart.
          ...lek.tables.where((t) => t.istStimmig).map((t) => _TableCard(t)),

          // ── Beispiele ────────────────────────────────────────────
          if (lek.examples.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'examples'),
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.sm),
            ...lek.examples.map((e) => _ExampleTile(e)),
          ],

          // ── G7a: Übungen nach dem Lesen ──────────────────────────
          _UebungStart(slug: lek.slug, gross: true),

          // ── Verwandte Lektionen ──────────────────────────────────
          if (lek.relatedSlugs.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            _RelatedSection(slugs: lek.relatedSlugs),
          ],
        ],
      ),
    );
  }
}

// ─── G7a: Einstieg in die Übungen ────────────────────────────────────────────

/// Knopf „Diese Lektion üben (n)" — nur, wenn die Lektion Übungen hat.
class _UebungStart extends ConsumerWidget {
  const _UebungStart({required this.slug, required this.gross});
  final String slug;
  final bool gross;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(grammatikLektionUebungenProvider(slug))
            .valueOrNull
            ?.length ??
        0;
    if (n == 0) return const SizedBox.shrink();
    final label = AppL10n.tf(context, 'uebung_start', {'n': '$n'});
    void los() => context.push(AppRoutes.grammatikLektionUebung(slug));
    return Padding(
      padding: EdgeInsets.only(
          top: gross ? AppSizes.md : 0, bottom: AppSizes.md),
      child: gross
          ? VoxButton.primary(
              label: label,
              icon: Icons.edit_note_rounded,
              expand: true,
              onPressed: los,
            )
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: VoxButton.tonal(
                label: label,
                icon: Icons.edit_note_rounded,
                onPressed: los,
              ),
            ),
    );
  }
}

// ─── Erklärblock ─────────────────────────────────────────────────────────────

class _Block extends StatelessWidget {
  const _Block(this.b);
  final GrammatikExplanationBlock b;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (b.hasHeading)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                b.headingDe!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          // Deutsch fest
          Text(b.bodyDe,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7)),
          const SizedBox(height: 6),
          // Aktive Zweitsprache
          Text(
            AppL10n.meaning(context, fa: b.bodyFa, en: b.bodyEn),
            style: theme.textTheme.bodySmall?.copyWith(
              color : theme.colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Beispiel ────────────────────────────────────────────────────────────────

class _ExampleTile extends StatelessWidget {
  const _ExampleTile(this.e);
  final GrammatikExample e;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.german,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600, height: 1.5)),
            const SizedBox(height: 2),
            Text(
              AppL10n.meaning(context, fa: e.meaningFa, en: e.meaningEn),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (e.hasNote) ...[
              const SizedBox(height: 4),
              Text(
                AppL10n.meaning(context,
                    fa: e.noteFa ?? '', en: e.noteEn ?? e.noteDe ?? ''),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tabelle ─────────────────────────────────────────────────────────────────

class _TableCard extends StatelessWidget {
  const _TableCard(this.t);
  final GrammatikTable t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.titleDe,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(AppL10n.meaning(context, fa: t.titleFa, en: t.titleEn),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: AppSizes.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 34,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 42,
                columns: [
                  for (final c in t.columns)
                    DataColumn(label: Text(c,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: [
                  for (final r in t.rows)
                    DataRow(cells: [
                      DataCell(Text(r.rowLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                      for (final cell in r.cells)
                        DataCell(Text(cell,
                            style: const TextStyle(fontSize: 12))),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Verwandte Lektionen ─────────────────────────────────────────────────────

class _RelatedSection extends ConsumerWidget {
  const _RelatedSection({required this.slugs});
  final List<String> slugs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(grammatikLektionenProvider);
    final all = allAsync.valueOrNull ?? {};
    // Nur bereits importierte verwandte Lektionen verlinken.
    final available = slugs.where(all.containsKey).toList();
    if (available.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppL10n.t(context, 'compare_similar'),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.sm),
        ...available.map((s) {
          final lek = all[s]!;
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            child: ListTile(
              title   : Text(lek.titleDe,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(AppL10n.meaning(context,
                  fa: lek.titleFa, en: lek.titleEn)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap   : () =>
                  context.push(AppRoutes.grammatikLektion(s)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          );
        }),
      ],
    );
  }
}
