// FILE: lib/core/grammatikon/wort_card.dart
// PURPOSE: Listeneintrag der Vokabular-DB (فاز V, Stufe ۲):
//              WortCard(card: karte, onTap: ...)
//          Layout: Symbol | Artikel farbig + Wort (Endung farbig) + Übersetzung | Niveau/Fach.
//          Übersetzungssprache kommt AUSSCHLIESSLICH aus den Settings (AppL10n.isFa) —
//          فاز L: kein sprache-Parameter, kein Dual-Display (FA und EN nie gleichzeitig).
//          Endungsfarbe = GrammatikonResolver.resolve(card).color — dieselbe Quelle wie
//          das Symbol, keine zweite Genus→Farbe-Tabelle (Puzzling).
//          (Port von WortCard.js — React Native → Flutter, an VOX-Design-System angepasst.)
import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../utils/formatters.dart';
import '../widgets/vox_badge.dart';
import 'grammatikon_painter.dart';
import 'grammatikon_resolver.dart';
import 'grammatikon_spec.dart';
import 'wort_text.dart';

class WortCard extends StatelessWidget {
  /// Wort-Karte im SUPER-PROMPT Schema 2.0
  /// (Felder: wort, wortart, details, uebersetzung {fa, en}, niveau, box).
  final Map<String, dynamic> card;
  final VoidCallback? onTap;

  /// Optionaler Slot rechts (z. B. WortActions kompakt) — die Card selbst
  /// bleibt provider-frei; kein onUpdate-Callback nötig (State fließt Riverpod).
  final Widget? trailing;

  const WortCard({super.key, required this.card, this.onTap, this.trailing});

  /// FA- oder EN-Übersetzungen — Sprache nur aus Settings, nie beide.
  String _uebersetzung(BuildContext context) {
    final u = (card['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
    final list = (u[AppL10n.isFa(context) ? 'fa' : 'en'] as List?) ?? const [];
    return list.cast<String>().join(AppL10n.isFa(context) ? '، ' : ', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wort = card['wort'] as String? ?? '';
    final wortart = card['wortart'] as String?;
    final niveau = card['niveau'] as String?;
    final box = card['box'] as int?;

    // Genus-/Verb-Farbe aus derselben Quelle wie das Symbol.
    // kontur (schwarz) wäre im Dark Mode unlesbar → dann Theme-Farbe (null).
    final descriptorColor = GrammatikonResolver.resolve(card).color;
    final farbe =
        descriptorColor == GrammatikonSpec.kontur ? null : descriptorColor;

    // Nomen: Artikel komplett in Genusfarbe (in Listen schneller erfassbar
    // als nur die Endung), Lemma dahinter unmarkiert.
    final istNomen = wortart == 'nomen';
    final teile = wort.split(' ');
    final artikel = istNomen && teile.length > 1 ? teile.first : null;
    final lemma = artikel != null ? teile.sublist(1).join(' ') : wort;

    final uebersetzung = _uebersetzung(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Center(child: WortSymbol(card: card, size: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.ltr, // Deutsch immer LTR
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (artikel != null)
                          Text(
                            '$artikel ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: farbe,
                            ),
                          ),
                        Flexible(
                          child: WortText(
                            wort: lemma,
                            color: farbe,
                            // Verben: Infinitiv-Endung -en markiert (Duden:
                            // "lernen"); Nomen-Lemma unmarkiert.
                            endung: wortart == 'verb' ? 'en' : '',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    if (uebersetzung.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        uebersetzung,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (niveau != null) VoxBadge.level(niveau, small: true),
                  if (box != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      AppL10n.tf(context, 'leitner_fach',
                          {'n': Formatters.digits(box)}),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
