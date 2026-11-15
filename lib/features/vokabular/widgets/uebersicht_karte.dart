// FILE: lib/features/vokabular/widgets/uebersicht_karte.dart
// PHASE: Vier Fälle, Schritt M2 (Entwurf Lukas 2026-11-15)
// PURPOSE: Alles, was die Übersichtskarte «الف» und ihre Bedeutungskarten
//          «ب/ج …» anzeigen:
//            · BedeutungsRaster   — die Bedeutungen NEBENEINANDER (2 Spalten;
//                                   ab 3 Bedeutungen ein Raster, 4 = 2×2)
//            · UebersichtSeite    — Wort-Seite der Karte «الف»
//            · UebersichtZeile    — höhere Zeile der Karte «الف» in der Liste
//            · MehrdeutigBanner   — Hinweis oben auf «ب/ج» ⇒ immer zu «الف»
//            · mehrdeutigWarnung  — Text vorne auf der Lernkarte «ب/ج»
//
// Datenquelle: nur der Index. «الف» hat keine eigene Datei
// (vokab_index.dart → vokabUebersichtEintrag); Artikel, Farbe, Übersetzung
// und Niveau jeder Bedeutung kommen aus dem Index-Eintrag ihrer id.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/vox_badge.dart';
import '../controllers/vokabular_controller.dart';
import '../data/vokab_index.dart';
import 'wort_actions.dart';
import 'wortseite_bausteine.dart';

/// Index-Einträge der Bedeutungen einer Übersichtskarte, in ihrer Reihenfolge.
/// Fehlt eine id (sollte der Index-Bau verhindern), fällt sie still weg.
List<Map<String, dynamic>> uebersichtGlieder(
  Map<String, dynamic> uebersicht,
  Map<String, Map<String, dynamic>> byId,
) =>
    [
      for (final id in (uebersicht['bedeutungen_ids'] as List?) ?? const [])
        if (byId[id] != null) byId[id]!,
    ];

/// Übersetzung einer Bedeutung in der eingestellten Sprache (nie beide).
String _bedeutungText(BuildContext context, Map<String, dynamic> k) {
  final fa = AppL10n.isFa(context);
  final u = (k['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
  final liste = ((u[fa ? 'fa' : 'en'] as List?) ?? const []).cast<String>();
  return liste.take(2).join(fa ? '، ' : ', ');
}

/// Die Bedeutungen nebeneinander — nie untereinander (Lukas): 2 Bedeutungen =
/// zwei Spalten; mehr = Raster mit gleich großen Feldern in zwei Spalten
/// (4 = 2×2). [onTap] = Bedeutung öffnen (Wort-Seite); null = nur zeigen.
class BedeutungsRaster extends StatelessWidget {
  const BedeutungsRaster({
    super.key,
    required this.glieder,
    this.onTap,
    this.gross = false,
  });

  final List<Map<String, dynamic>> glieder;
  final void Function(Map<String, dynamic> glied)? onTap;

  /// Größere Schrift (Wort-Seite, Rückseite der Lernkarte).
  final bool gross;

  @override
  Widget build(BuildContext context) {
    final zeilen = <List<Map<String, dynamic>>>[
      for (var i = 0; i < glieder.length; i += 2)
        glieder.sublist(i, i + 2 > glieder.length ? glieder.length : i + 2),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final zeile in zeilen)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: i < zeile.length
                        ? _Feld(
                            glied: zeile[i],
                            nummer: glieder.indexOf(zeile[i]) + 1,
                            gross: gross,
                            onTap: onTap == null ? null : () => onTap!(zeile[i]),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Feld extends StatelessWidget {
  const _Feld({
    required this.glied,
    required this.nummer,
    required this.gross,
    this.onTap,
  });

  final Map<String, dynamic> glied;
  final int nummer;
  final bool gross;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final niveau = glied['niveau'] as String?;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(gross ? 14 : 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vokabNr(context, nummer),
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: WortZeile(
                    card: glied,
                    zentriert: true,
                    eineZeile: true,
                    style: gross
                        ? theme.textTheme.titleLarge
                        : theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _bedeutungText(context, glied),
                  textAlign: TextAlign.center,
                  style: (gross
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (niveau != null) ...[
                  const SizedBox(height: 6),
                  VoxBadge.level(niveau, small: true),
                ],
                if (onTap != null) ...[
                  const SizedBox(height: 4),
                  Icon(
                    AppL10n.isFa(context)
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wort-Seite der Übersichtskarte «الف»: Aussprache, je Bedeutung Artikel in
/// seiner Farbe + Bedeutung + Niveau (antippen ⇒ Karte dieser Bedeutung),
/// Leitner-Knopf. Keine Beispiele, kein Wortnetz (Entwurf Lukas).
class UebersichtSeite extends ConsumerWidget {
  const UebersichtSeite({super.key, required this.karte});

  final Map<String, dynamic> karte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};
    final glieder = uebersichtGlieder(karte, byId);
    final wort = karte['wort'] as String? ?? '';
    final ipa = karte['ipa'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(wort)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              wort,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (ipa != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '/$ipa/',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Center(child: AudioPlayButton(text: wort, size: 28)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppL10n.tf(context, 'mehrdeutig_warnung',
                  {'n': vokabNr(context, glieder.length)}),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          BedeutungsRaster(
            glieder: glieder,
            gross: true,
            onTap: (g) =>
                context.push(AppRoutes.vokabularWort(g['id'] as String)),
          ),
          const SizedBox(height: 16),
          WortActions(card: karte),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Zeile der Übersichtskarte in «Alle Wörter» und in der Suche — etwas höher
/// als die übrigen: Wort, darunter «Dieses Wort hat mehrere Bedeutungen»,
/// darunter jede Bedeutung in einer eigenen Zeile (Artikel in seiner Farbe).
class UebersichtZeile extends ConsumerWidget {
  const UebersichtZeile({super.key, required this.karte, this.onTap});

  final Map<String, dynamic> karte;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};
    final glieder = uebersichtGlieder(karte, byId);
    final niveau = karte['niveau'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 34,
                child: Icon(Icons.call_split_rounded,
                    size: 24, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        karte['wort'] as String? ?? '',
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppL10n.t(context, 'mehrdeutig_liste'),
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w700),
                    ),
                    for (var i = 0; i < glieder.length; i++) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${vokabNr(context, i + 1)}. ',
                              style: theme.textTheme.bodyMedium),
                          WortZeile(
                            card: glieder[i],
                            eineZeile: true,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _bedeutungText(context, glieder[i]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (niveau != null) VoxBadge.level(niveau, small: true),
                  const SizedBox(height: 4),
                  WortActions(card: karte, kompakt: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oben auf der Seite einer Bedeutungskarte «ب/ج»: deutlicher Hinweis, dass
/// das Wort mehrere Bedeutungen hat — antippen ⇒ IMMER zur Übersicht «الف».
class MehrdeutigBanner extends ConsumerWidget {
  const MehrdeutigBanner({super.key, required this.id});

  /// id der gezeigten Bedeutungskarte.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};
    final uebersichtId = byId[id]?['uebersicht_id'] as String?;
    final uebersicht = uebersichtId == null ? null : byId[uebersichtId];
    if (uebersicht == null) return const SizedBox.shrink();
    final n = (uebersicht['bedeutungen_ids'] as List?)?.length ?? 2;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.tertiaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('mehrdeutig_banner'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppRoutes.vokabularWort(uebersichtId!)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.tertiary.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppL10n.tf(context, 'mehrdeutig_warnung',
                          {'n': vokabNr(context, n)}),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(AppL10n.t(context, 'mehrdeutig_alle'),
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                AppL10n.isFa(context)
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text vorne auf der Lernkarte einer Bedeutungskarte «ب/ج» — keine
/// Bedeutungshilfe, nur die Warnung (Lukas). null = keine Bedeutungskarte.
String? mehrdeutigWarnung(
  BuildContext context,
  Map<String, dynamic> eintrag,
  Map<String, Map<String, dynamic>> byId,
) {
  final uebersichtId = eintrag['uebersicht_id'] as String?;
  final n = (byId[uebersichtId]?['bedeutungen_ids'] as List?)?.length;
  if (uebersichtId == null || n == null) return null;
  return AppL10n.tf(context, 'mehrdeutig_warnung', {'n': vokabNr(context, n)});
}

/// Grund für [vokabIstUebersicht] hier wieder ausgeben, damit Bildschirme nur
/// diese Datei importieren müssen.
bool istUebersicht(Map<String, dynamic>? k) => vokabIstUebersicht(k);

/// Fall 4 der «Vier Fälle»: Nomen, das wie ein Adjektiv gebeugt wird
/// (der/die Abgeordnete, das Gute) — Prompt-Regel 21.
bool istAdjektivischesNomen(Map<String, dynamic> karte) {
  final d = karte['details'];
  return karte['wortart'] == 'nomen' &&
      d is Map &&
      d['deklinationstyp'] == 'adjektivisch';
}

/// Slug der Grammatik-Lektion für Fall 4 (assets/data/grammatik/nomen.json).
const adjektivNomenLektion = 'adjektive-als-nomen';

/// Erste Zeile der Wort-Seite bei Fall 4: Weg zur Grammatik-Lektion.
class AdjektivNomenVerweis extends StatelessWidget {
  const AdjektivNomenVerweis({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.secondaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('adjektiv_nomen_verweis'),
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            context.push(AppRoutes.grammatikLektion(adjektivNomenLektion)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: scheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppL10n.t(context, 'adjnomen_titel'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(AppL10n.t(context, 'adjnomen_text'),
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                AppL10n.isFa(context)
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
