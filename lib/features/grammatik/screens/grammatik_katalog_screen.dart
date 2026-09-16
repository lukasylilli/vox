// FILE: lib/features/grammatik/screens/grammatik_katalog_screen.dart
// DEPS: grammar_catalog_controller.dart, katalog_eintrag_tile.dart
// PURPOSE: EIN parametrischer Listen-Screen für alle Katalog-Ansichten (G1).
//          /grammatik/katalog/:view/:key
//          view = niveau|thema|satzglied · key = a1|verben|praedikat|...
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../controllers/grammar_catalog_controller.dart';
import '../models/grammar_catalog.dart';
import '../widgets/katalog_eintrag_tile.dart';
import 'grammatik_niveautest_screen.dart';
import '../../../core/l10n/app_l10n.dart';

class GrammatikKatalogScreen extends ConsumerWidget {
  const GrammatikKatalogScreen({
    super.key,
    required this.view,
    required this.keyId,
  });

  final String view;   // niveau | thema | satzglied
  final String keyId;  // a1..c2 | verben.. | praedikat..

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final katalogAsync = ref.watch(grammatikKatalogProvider);

    return katalogAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Grammatik')),
        body  : Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
      ),
      data: (katalog) {
        final title = switch (view) {
          'niveau'    => 'Grammatik · ${keyId.toUpperCase()}',
          'thema'     => katalog.thema(keyId)?.de ?? 'Grammatik',
          'satzglied' => katalog.satzglied(keyId)?.de ?? 'Grammatik',
          _           => 'Grammatik',
        };
        final eintraege = switch (view) {
          'niveau'    => katalog.byNiveau(keyId),
          'thema'     => katalog.byThema(keyId),
          'satzglied' => katalog.bySatzglied(keyId),
          _           => <KatalogEintrag>[],
        };

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // G7b: Niveau-Test oben in der Niveau-Ansicht
              if (view == 'niveau') NiveauTestKarte(level: keyId),
              // Thema-Ansicht: flache Liste · sonst nach Thema gruppiert
              if (view == 'thema')
                ...eintraege.map((e) => KatalogEintragTile(eintrag: e))
              else
                ..._grouped(context, katalog, eintraege),
              if (view == 'niveau') ...[
                const SizedBox(height: AppSizes.sm),
                _DbLektionenCard(level: keyId),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Einträge nach Thema gruppiert (Reihenfolge der Themen aus dem Katalog).
  List<Widget> _grouped(
    BuildContext context,
    GrammatikKatalog katalog,
    List<KatalogEintrag> eintraege,
  ) {
    final widgets = <Widget>[];
    for (final thema in katalog.themen) {
      final group = eintraege.where((e) => e.thema == thema.id).toList();
      if (group.isEmpty) continue;
      widgets.add(Padding(
        padding: const EdgeInsets.only(
            top: AppSizes.sm, bottom: AppSizes.sm),
        child: Row(
          children: [
            Icon(thema.icon, size: 18, color: thema.color),
            const SizedBox(width: AppSizes.sm),
            Text(
              thema.de,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${group.length}',
              style: TextStyle(
                color: thema.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ));
      widgets.addAll(group.map((e) => KatalogEintragTile(
            eintrag     : e,
            leadingIcon : thema.icon,
            leadingColor: thema.color,
          )));
    }
    return widgets;
  }
}

/// Zugang zu den DB-Lektionen + Übungen des Alt-Systems (pro Niveau).
class _DbLektionenCard extends StatelessWidget {
  const _DbLektionenCard({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final color = VoxColors.cefr(level);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.quiz_rounded, color: color, size: 20),
        ),
        title: const Text(
          'Lektionen & Übungen',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(AppL10n.t(context, 'db_lektionen_sub')),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('${AppRoutes.grammatik}/$level'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
