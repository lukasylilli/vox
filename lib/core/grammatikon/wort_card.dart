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
import '../../features/vokabular/widgets/wortseite_bausteine.dart'
    show vokabBedeutungenTexte, vokabBedeutungenZeile;
import '../../features/vokabular/widgets/uebersicht_karte.dart'
    show UebersichtZeile, istUebersicht;

class WortCard extends StatelessWidget {
  /// Wort-Karte im SUPER-PROMPT Schema 2.0
  /// (Felder: wort, wortart, details, uebersetzung {fa, en}, niveau, box).
  final Map<String, dynamic> card;
  final VoidCallback? onTap;

  /// Optionaler Slot rechts (z. B. WortActions kompakt) — die Card selbst
  /// bleibt provider-frei; kein onUpdate-Callback nötig (State fließt Riverpod).
  final Widget? trailing;

  /// Optionale Zusatzzeile unter der Übersetzung (z. B. «Gebeugte Form: ging»
  /// in der Suche, فاز F.1b) — vom Screen gebaut, die Card bleibt neutral.
  final Widget? hinweis;

  const WortCard(
      {super.key, required this.card, this.onTap, this.trailing, this.hinweis});

  /// FA- oder EN-Übersetzungen — Sprache nur aus Settings, nie beide.
  String _uebersetzung(BuildContext context) {
    // Mehrere Bedeutungen (Regel 20): nummeriert («۱. گلابی   ۲. لامپ»).
    final bedeutungen = vokabBedeutungenTexte(context, card);
    if (bedeutungen != null) return vokabBedeutungenZeile(context, bedeutungen);
    final u = (card['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
    final list = (u[AppL10n.isFa(context) ? 'fa' : 'en'] as List?) ?? const [];
    return list.cast<String>().join(AppL10n.isFa(context) ? '، ' : ', ');
  }

  @override
  Widget build(BuildContext context) {
    // Übersicht «الف» (Vier Fälle, Lukas 2026-11-15): überall dieselbe höhere
    // Zeile mit allen Bedeutungen — Liste, Suche und Popup gleich.
    if (istUebersicht(card)) return UebersichtZeile(karte: card, onTap: onTap);
    final theme = Theme.of(context);
    final niveau = card['niveau'] as String?;
    final box = card['box'] as int?;

    final uebersetzung = _uebersetzung(context);

    // Aufbau (2026-11-15, Lukas: nichts darf halb abgeschnitten sein):
    //   Symbol | Wort (immer EINE Zeile, notfalls kleiner) + Bedeutung (bis
    //   zwei Zeilen) | Niveau, darunter Aussprache + Leitner.
    // Die Knöpfe stehen UNTER dem Niveau statt daneben — so bleibt dem Wort
    // die ganze Breite. In Phase X ersetzt der Deck-Knopf den Leitner-Knopf
    // an derselben Stelle.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: WortZeile(
                        card: card,
                        style: theme.textTheme.titleMedium,
                        eineZeile: true,
                      ),
                    ),
                    if (uebersetzung.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        uebersetzung,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (hinweis != null) ...[
                      const SizedBox(height: 4),
                      hinweis!,
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
                  if (trailing != null) ...[
                    const SizedBox(height: 4),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Das Wort selbst — Artikel + Lemma in der Farbe aus dem Grammatikon.
///
/// Aus [WortCard] herausgelöst (B-13, 2026-09-23), damit die Lernkarte im
/// Leitner (`ArchivFlashCard`) das Wort **genau so** färbt wie die Liste —
/// eine Stelle, keine zweite Genus→Farbe-Regel. [style] ist die Grundschrift
/// (Größe); Gewichte und Farbe setzt dieses Widget.
class WortZeile extends StatelessWidget {
  final Map<String, dynamic> card;
  final TextStyle? style;

  /// Mittig statt linksbündig (Lernkarte).
  final bool zentriert;

  /// Nie umbrechen: das Wort bleibt in EINER Zeile (Liste, 2026-11-15). Der
  /// Aufrufer verkleinert es bei Bedarf (FittedBox), statt es abzuschneiden.
  final bool eineZeile;

  const WortZeile({
    super.key,
    required this.card,
    this.style,
    this.zentriert = false,
    this.eineZeile = false,
  });

  @override
  Widget build(BuildContext context) {
    final wort = card['wort'] as String? ?? '';
    final wortart = card['wortart'] as String?;

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

    final lemmaText = WortText(
      wort: lemma,
      color: farbe,
      // Verben: Infinitiv-Endung -en markiert (Duden: "lernen");
      // Nomen-Lemma unmarkiert.
      endung: wortart == 'verb' ? 'en' : '',
      style: style?.copyWith(fontWeight: FontWeight.w700) ??
          const TextStyle(fontWeight: FontWeight.w700),
    );

    // Fall 4 (substantiviertes Adjektiv, «der/die Abgeordnete», Lukas
    // 2026-11-15): alle drei Artikel in der Zeile DARÜBER, jeder in seiner
    // Genusfarbe aus GrammatikonSpec (der = maskulin, die = feminin,
    // die = Plural); das Wort darunter.
    if (artikel != null && artikel.contains('/')) {
      final klein = (style ?? DefaultTextStyle.of(context).style).copyWith(
        fontWeight: FontWeight.w800,
        fontSize: ((style?.fontSize ?? 14) * 0.78),
      );
      return Column(
        key: const ValueKey('wortzeile_drei_artikel'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            zentriert ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              for (final (i, (a, f)) in [
                ('der', GrammatikonSpec.maskulin),
                ('die', GrammatikonSpec.feminin),
                ('die', GrammatikonSpec.plural),
              ].indexed) ...[
                if (i > 0) const TextSpan(text: ' · '),
                TextSpan(text: a, style: TextStyle(color: f)),
              ],
            ]),
            style: klein,
            textDirection: TextDirection.ltr,
          ),
          lemmaText,
        ],
      );
    }

    return Row(
      textDirection: TextDirection.ltr, // Deutsch immer LTR
      mainAxisSize:
          zentriert || eineZeile ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (artikel != null)
          Text.rich(
            TextSpan(children: [
              ...artikelSpans(artikel, farbe),
              const TextSpan(text: ' '),
            ]),
            style: style?.copyWith(fontWeight: FontWeight.w800) ??
                const TextStyle(fontWeight: FontWeight.w800),
            // Deutsch immer LTR. Ohne diese Angabe erbt der Artikel in FA die
            // Richtung RTL, das Leerzeichen dahinter rutscht auf die andere
            // Seite und es erscheint «diefrau» (Bug, Lukas 2026-11-15).
            textDirection: TextDirection.ltr,
          ),
        if (eineZeile) lemmaText else Flexible(child: lemmaText),
        // Homograph-Nummer (Regel 19) hochgestellt wie im Duden: See¹, See².
        if (homographHoch(card['homograph_nr']) case final hoch?)
          Text(
            hoch,
            textDirection: TextDirection.ltr,
            style: style?.copyWith(fontWeight: FontWeight.w700) ??
                const TextStyle(fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}

/// Artikel eines Nomens als farbige Teile. Normal EIN Artikel in [farbe]
/// (Genusfarbe der Karte). «der/die» (Prompt-Regel 21) ⇒ jeder Artikel in
/// seiner eigenen Genusfarbe, der Schrägstrich ohne Farbe.
List<InlineSpan> artikelSpans(String artikel, Color? farbe) {
  final teile = artikel.split('/');
  if (teile.length < 2) {
    return [TextSpan(text: artikel, style: TextStyle(color: farbe))];
  }
  return [
    for (var i = 0; i < teile.length; i++) ...[
      if (i > 0) const TextSpan(text: '/'),
      TextSpan(
        text: teile[i],
        style: TextStyle(color: GrammatikonResolver.artikelFarbe(teile[i])),
      ),
    ],
  ];
}

/// Homograph-Nummer → hochgestellte Ziffer (1 → «¹»). Keine Familie ⇒ null.
String? homographHoch(Object? nr) {
  if (nr is! int || nr < 1 || nr > 9) return null;
  return const ['¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'][nr - 1];
}
