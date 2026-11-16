// FILE: lib/features/wortschatz/widgets/wortschatz_zeile.dart
// PHASE: G8 (2026-11-16)
// PURPOSE: EINE Zeile eines Worts — für «Alle Wörter» UND die globale Suche.
//          Vorher baute wortschatz_list_screen.dart die Zeile selbst; damit
//          ein Wort in der globalen Suche genau gleich aussieht (Symbol, Ton,
//          Leitner-Knopf — Entscheidung Lukas 2026-11-16), wohnt sie hier.
//            · altes Wort (drift)      ⇒ WordListItem → /wortschatz/word/:id
//            · Karte (Index-Eintrag)   ⇒ WortCard     → /vokabular/wort/:id
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/deutsch_text.dart';
import '../../vokabular/widgets/wort_actions.dart';
import '../data/such_rang.dart';
import 'word_list_item.dart';

class WortschatzZeile extends StatelessWidget {
  const WortschatzZeile({super.key, required this.treffer, this.suchText = ''});

  /// Zeile aus `wortschatzZeilen` — `wert` ist ein [WordModel] oder ein
  /// Index-Eintrag (Map).
  final SuchTreffer<Object> treffer;

  /// Die Suche, wie der Nutzer sie getippt hat — für die Zeile
  /// «Gebeugte Form: ging» unter Treffern aus einer Form.
  final String suchText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget? hinweis =
        treffer.rang == SuchRang.form && suchText.isNotEmpty
            ? DeutschMitEtikett(
                etikett: AppL10n.t(context, 'such_form_etikett'),
                wert: suchText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            : null;
    final eintrag = treffer.wert;
    if (eintrag is WordModel) {
      return WordListItem(
        word: eintrag,
        hinweis: hinweis,
        onTap: () => context.push(AppRoutes.wortschatzWordDetail
            .replaceFirst(':wordId', '${eintrag.id}')),
      );
    }
    final karte = eintrag as Map<String, dynamic>;
    return WortCard(
      card: karte,
      hinweis: hinweis,
      trailing: WortActions(card: karte, kompakt: true),
      onTap: () =>
          context.push(AppRoutes.vokabularWort(karte['id'] as String? ?? '')),
    );
  }
}
