// FILE: lib/features/vokabular/screens/wort_seite_screen.dart
// PURPOSE: Wort-Seite — vollständige Ansicht einer Karte (Schema 2.0, فاز V Stufe ۴).
//          Kopf (Symbol + Wort + IPA + Niveau) → Übersetzung (aktive Sprache) →
//          Actions → Beispiele → Details je Wortart → Synonyme/Antonyme/Komposita →
//          Wortnetz (klickbar: vorhanden → push nächste Wort-Seite, Ketten-Navigation;
//          fehlt → Dialog mit Suche). IDs der Wortnetz-Einträge werden über vokabId()
//          abgeleitet — Schema 2.0 speichert kein id_ref (deterministisch, Regel 5).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/grammatikon_painter.dart';
import '../../../core/grammatikon/grammatikon_resolver.dart';
import '../../../core/grammatikon/grammatikon_spec.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/vokabular_controller.dart';
import '../widgets/details_renderer.dart';
import '../widgets/kasus_beispiel_block.dart';
import '../widgets/wort_actions.dart';
import '../widgets/wort_notiz.dart';
import '../widgets/wortseite_bausteine.dart';

class WortSeiteScreen extends ConsumerWidget {
  final String wortId;
  const WortSeiteScreen({super.key, required this.wortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // V.2: die volle Karte wird erst hier geladen (eine Datei); für die
    // Wortnetz-Links genügt der Index (gibt es das Wort?).
    final karteAsync = ref.watch(vokabKarteProvider(wortId));
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};

    return karteAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (card) {
        if (card == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Text(AppL10n.t(context, 'no_words_found'),
                    style: Theme.of(context).textTheme.bodyMedium)),
          );
        }
        return _WortSeiteBody(card: card, byId: byId);
      },
    );
  }
}

class _WortSeiteBody extends StatelessWidget {
  final Map<String, dynamic> card;

  /// id → Index-Eintrag (NICHT volle Karten) — nur für „gibt es das Wort?".
  final Map<String, Map<String, dynamic>> byId;
  const _WortSeiteBody({required this.card, required this.byId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wort = card['wort'] as String? ?? '';
    final niveau = card['niveau'] as String?;
    final ipa = card['ipa'] as String?;
    final anmerkung = card['anmerkung'] as String?;
    final ueb = vokabUeb(context, card['uebersetzung']);
    // etymologie: zweisprachig {fa, en} → aktive Sprache; String = alte Karten.
    final etyRoh = card['etymologie'];
    final etymologie =
        etyRoh is Map ? vokabUeb(context, etyRoh) : etyRoh as String?;

    // Artikel in Genusfarbe — gleiche Quelle wie das Symbol (Puzzling).
    final descriptorColor = GrammatikonResolver.resolve(card).color;
    final farbe =
        descriptorColor == GrammatikonSpec.kontur ? null : descriptorColor;
    final teile = wort.split(' ');
    final artikel = card['wortart'] == 'nomen' && teile.length > 1
        ? teile.first
        : null;
    final lemma = artikel != null ? teile.sublist(1).join(' ') : wort;

    return Scaffold(
      appBar: AppBar(title: Text(lemma)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Kopf ──
          Row(children: [
            WortSymbol(card: card, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: [
                      if (artikel != null)
                        TextSpan(
                            text: '$artikel ',
                            style: TextStyle(color: farbe)),
                      TextSpan(text: lemma),
                    ]),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textDirection: TextDirection.ltr,
                  ),
                  if (ipa != null && ipa.isNotEmpty)
                    Text(ipa,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (niveau != null) VoxBadge.level(niveau),
          ]),
          if (ueb != null && ueb.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(ueb, style: theme.textTheme.titleMedium),
          ],
          if (anmerkung != null && anmerkung.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(anmerkung,
                style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 14),
          WortActions(card: card),

          // ── Beispiele ──
          _beispiele(context),

          // ── Kasus im Beispiel (Extra-Box, nur Dativ/Akkusativ-Verben) ──
          _kasusBeispiele(context),

          // ── Wortart-spezifische Details ──
          DetailsRenderer(card: card),

          // ── Synonyme / Gegenteil (antonyme) / Komposita ──
          _wortListe(context, 'Synonyme', card['synonyme']),
          _wortListe(context, 'Gegenteil', card['antonyme']),
          _wortListe(context, 'Komposita', card['komposita']),

          // ── Wortbildung (etymologie, Schema 3.0 — 1 Zeile) ──
          if (etymologie != null && etymologie.isNotEmpty)
            Sektion(titel: 'Wortbildung', children: [
              BeispielBlock(satz: etymologie),
            ]),

          // ── Wortnetz ──
          _wortnetz(context),

          // ── Meine Notiz (Freitext, Farbe pro Wort — user state) ──
          WortNotizSektion(wortId: card['id'] as String? ?? ''),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _beispiele(BuildContext context) {
    final beispiele = (card['beispiele'] as List?)?.cast<Map>() ?? const [];
    if (beispiele.isEmpty) return const SizedBox.shrink();
    return Sektion(titel: AppL10n.t(context, 'examples'), children: [
      for (final b in beispiele)
        BeispielBlock(
          badge: b['niveau'] as String?,
          satz: b['satz'] as String? ?? '',
          uebersetzung: vokabUeb(context, b['uebersetzung']),
        ),
    ]);
  }

  // Extra-Box NUR für Dativ/Akkusativ-Verben: farbige Kasus-Beispiele.
  // Feld kasus_beispiele = [{satz, dativ:[…], akkusativ:[…], uebersetzung}].
  Widget _kasusBeispiele(BuildContext context) {
    final list = (card['kasus_beispiele'] as List?)?.cast<Map>() ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    final hatDativ = list.any((b) => ((b['dativ'] as List?) ?? const []).isNotEmpty);
    final hatAkk   = list.any((b) => ((b['akkusativ'] as List?) ?? const []).isNotEmpty);
    return Sektion(titel: 'Kasus im Beispiel', children: [
      KasusLegende(showDativ: hatDativ, showAkkusativ: hatAkk),
      const SizedBox(height: 4),
      for (final b in list)
        KasusBeispielBlock(
          satz        : b['satz'] as String? ?? '',
          dativ       : ((b['dativ'] as List?) ?? const []).cast<String>(),
          akkusativ   : ((b['akkusativ'] as List?) ?? const []).cast<String>(),
          uebersetzung: vokabUeb(context, b['uebersetzung']),
        ),
    ]);
  }

  Widget _wortListe(BuildContext context, String titel, dynamic items) {
    final list = (items as List?)?.cast<Map>() ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Sektion(titel: titel, children: [
      for (final s in list)
        BeispielBlock(
          satz: s['wort'] as String? ?? '',
          uebersetzung: vokabUeb(context, s['uebersetzung']),
        ),
    ]);
  }

  Widget _wortnetz(BuildContext context) {
    final netz = (card['wortnetz'] as Map?)?.cast<String, dynamic>();
    if (netz == null) return const SizedBox.shrink();

    // Schema 3.0: flache woerter-Liste (genau 5, mit id_ref).
    // Fallback: altes 2.0-Format (gruppen) wird flachgeklopft.
    final woerter = (netz['woerter'] as List?)?.cast<Map>() ??
        [
          for (final g in (netz['gruppen'] as List?)?.cast<Map>() ?? const [])
            ...(g['woerter'] as List?)?.cast<Map>() ?? const [],
        ];
    if (woerter.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final grundwort = netz['grundwort'] as String?;

    return Sektion(
      titel: grundwort == null ? 'Wortnetz' : 'Wortnetz · $grundwort',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final w in woerter)
              _netzChip(context, w.cast<String, dynamic>()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(AppL10n.t(context, 'wortnetz_hint'),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.outline)),
        ),
      ],
    );
  }

  Widget _netzChip(BuildContext context, Map<String, dynamic> eintrag) {
    final theme = Theme.of(context);
    final wort = eintrag['wort'] as String? ?? '';
    final wortart = eintrag['wortart'] as String? ?? '';
    final niveau = eintrag['niveau'] as String?;
    final ueb = vokabUeb(context, eintrag['uebersetzung']);

    // Schema 3.0 liefert id_ref direkt; sonst deterministisch ableiten.
    final id = eintrag['id_ref'] as String? ?? vokabId(wortart, wort);
    final vorhanden = byId.containsKey(id);

    final rand = vorhanden
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _netzKlick(context, wort, id, vorhanden),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: rand, width: vorhanden ? 1.5 : 1),
          color: vorhanden
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(wort,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: vorhanden ? theme.colorScheme.primary : null)),
          if (ueb != null || niveau != null)
            Text([?niveau, ?ueb].join(' · '),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }

  void _netzKlick(
      BuildContext context, String wort, String id, bool vorhanden) {
    if (vorhanden) {
      // push (nicht go) → Ketten-Navigation Sicht → Ansicht → … und zurück.
      context.push(AppRoutes.vokabularWort(id));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(wort, textDirection: TextDirection.ltr),
        content: Text(AppL10n.t(dialogCtx, 'not_in_vokabular')),
        actions: [
          VoxButton.text(
            label: AppL10n.t(dialogCtx, 'cancel'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          VoxButton.text(
            label: AppL10n.t(dialogCtx, 'search_in_vokabular'),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Liste der Vokabular-Karten = «Alle Wörter» (mit Vorbefüllung).
              context.push(
                  '${AppRoutes.wortschatzList}?suche=${Uri.encodeComponent(wort)}');
            },
          ),
        ],
      ),
    );
  }
}
