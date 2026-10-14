// FILE: lib/features/wortschatz/screens/wortschatz_filter_screen.dart
// PHASE: فاز F.2 / F.2b (Lukas, 2026-10-14)
// PURPOSE: Eigene Filterseite für «Alle Wörter» (wie bei Amazon / Wohnungs-
//          suche): alle Filter als Drawer untereinander, unten fest
//          «Alle löschen» und «N Wörter anzeigen» (Zahl live). Jede Änderung
//          gilt sofort (wortschatzFilterProvider, auf dem Gerät gemerkt);
//          «anzeigen» schließt die Seite nur.
//          Knöpfe tragen ihre Zahl (F.2b) — wie viele Wörter sie mit den
//          übrigen Filtern zeigen würden; 0 ⇒ blass.
//          Die Suche aus der Liste kommt mit (?suche=…), damit alle Zahlen
//          genau zur Liste passen.
//          Drawer-Raster: filter_accordion.dart (F.3). Drawer: Bücher (nur
//          fertige VOX-Bücher), Wortart, Niveau, Meine Kategorien (F.4);
//          Berufe/Respekt/Veraltet (F.6) kommen als weitere Drawer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/filter_accordion.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/wortschatz_filter_controller.dart';
import '../data/wortschatz_filter.dart';

class WortschatzFilterScreen extends ConsumerWidget {
  const WortschatzFilterScreen({super.key, this.query = ''});

  /// Aktuelle Suche der Liste (klein, getrimmt; leer = keine).
  final String query;

  /// Beschriftung eines Werts — auch für die Chips über der Liste.
  /// Bücher/Kategorien: Name aus [z]; unbekannt ⇒ null (kein Chip).
  static String? beschriftung(
          FilterBereich b, String wert, WortschatzZugehoerigkeit z) =>
      switch (b) {
        FilterBereich.niveau => wert.toUpperCase(),
        FilterBereich.wortart => WordType.values
            .firstWhere((t) => t.name == wert,
                orElse: () => WordType.sonstige)
            .label,
        FilterBereich.buch || FilterBereich.kategorie => z.gruppe(b, wert)?.name,
      };

  /// Werte je Bereich, in fester Reihenfolge.
  static List<String> werte(FilterBereich b, WortschatzZugehoerigkeit z) =>
      switch (b) {
        FilterBereich.niveau => wortschatzNiveaus,
        FilterBereich.wortart => [for (final t in WordType.values) t.name],
        FilterBereich.buch ||
        FilterBereich.kategorie =>
          [for (final g in z.gruppen(b)) g.id],
      };

  /// Überschrift des Drawers — l10n-Schlüssel (Niveau/Wortart bleiben
  /// deutsch wie bisher: kein Schlüssel ⇒ AppL10n zeigt das Wort selbst).
  static String titel(FilterBereich b) => switch (b) {
        FilterBereich.buch => 'filter_buecher',
        FilterBereich.wortart => 'Wortart',
        FilterBereich.niveau => 'Niveau',
        FilterBereich.kategorie => 'filter_meine_kategorien',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(wortschatzFilterProvider.notifier);
    final basis = wortschatzBasisLesen(ref, query);
    final z = basis?.zugehoerigkeit ?? wortschatzZugehoerigkeitLesen(ref);
    final filter = ref.watch(wortschatzFilterProvider).bereinigt(z);
    final gesamt = basis == null ? null : wortschatzAnzahl(basis, filter);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'filter_title'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.sm, AppSizes.sm, AppSizes.sm, AppSizes.lg),
        children: [
          for (final b in FilterBereich.values) ...[
            FilterAccordion(
              key: ValueKey('filter_${b.name}'),
              label: titel(b),
              initiallyExpanded: true,
              selected: filter.werte(b),
              leerHinweis: b == FilterBereich.kategorie
                  ? AppL10n.t(context, 'filter_keine_kategorien')
                  : null,
              options: [
                for (final w in werte(b, z))
                  FilterOption(
                    value: w,
                    label: beschriftung(b, w, z) ?? w,
                    // Buchtitel und eigene Namen nie nachschlagen.
                    uebersetzen: false,
                    anzahl: basis == null
                        ? null
                        : wortschatzAnzahlMit(basis, filter, b, w),
                  ),
              ],
              onChanged: (w, _) => notifier.umschalten(b, w),
            ),
            const Divider(height: AppSizes.md),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: VoxButton.secondary(
                  key: const ValueKey('filter_alle_loeschen'),
                  label: AppL10n.t(context, 'filter_clear_all'),
                  expand: true,
                  onPressed: filter.istLeer ? null : notifier.allesLoeschen,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: VoxButton.primary(
                  key: const ValueKey('filter_anzeigen'),
                  label: gesamt == null
                      ? AppL10n.t(context, 'filter_show')
                      : AppL10n.tf(context, 'filter_show_n',
                          {'n': Formatters.digits(gesamt)}),
                  expand: true,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
