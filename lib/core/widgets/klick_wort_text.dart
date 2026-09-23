// FILE: lib/core/widgets/klick_wort_text.dart
// DEPS: klick_wort.dart (Zerlegen), wort_popup.dart (Klick-Verhalten)
// EXPORTS: KlickWortText
// PURPOSE: Deutscher Text, in dem JEDES Wort antippbar ist (L.5f). Ersetzt
//          `DeutschText` überall dort, wo ein Nutzer ein Wort nachschlagen
//          können soll (Lesen, Beispielsätze, Grammatik-Erklärungen,
//          Redemittel, Hören). Der Klick ist überall derselbe:
//          Wort → Popup (wort_popup.dart) → volle Wort-Seite.
//
// Wie `DeutschText`: Richtung fest links-nach-rechts, Ausrichtung standardmäßig
// links (siehe deutsch_text.dart — sonst rutscht in der persischen Oberfläche
// der Schlusspunkt an den Satzanfang).
//
// ⚠️ Nur in Detail-/Leseansichten benutzen, NICHT in Listenzeilen, die selbst
//    antippbar sind (Tippen auf ein Wort und Tippen auf die Zeile würden sich
//    im Weg stehen).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../wort/klick_wort.dart';
import 'deutsch_text.dart' show deutschLinksbuendig;
import 'wort_popup.dart';

class KlickWortText extends StatefulWidget {
  const KlickWortText(
    this.data, {
    super.key,
    this.style,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow,
    this.markiert = false,
    this.auswaehlbar = false,
    this.ganzeZeile = true,
  });

  final String data;
  final TextStyle? style;

  /// Standard links — wie bei `DeutschText`; niemals `right`.
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Wörter sichtbar als antippbar zeigen (Primärfarbe + Unterstreichung).
  /// Aus: der Text sieht normal aus, das Antippen funktioniert trotzdem.
  final bool markiert;

  /// Text lässt sich markieren/kopieren (Leser). Das Antippen eines Worts
  /// bleibt dasselbe.
  final bool auswaehlbar;

  /// Wie bei `DeutschText`: in RTL ganze Zeile, links (Nachtrag 2026-09-23).
  final bool ganzeZeile;

  @override
  State<KlickWortText> createState() => _KlickWortTextState();
}

class _KlickWortTextState extends State<KlickWortText> {
  late List<KlickToken> _tokens;

  /// Ein Erkenner je Wort, in Wortreihenfolge. Werden nur neu gebaut, wenn sich
  /// der TEXT ändert — und immer freigegeben (kein Speicherleck wie bei
  /// Erkennern, die in `build` entstehen).
  final List<TapGestureRecognizer> _erkenner = [];

  @override
  void initState() {
    super.initState();
    _aufbauen();
  }

  @override
  void didUpdateWidget(KlickWortText alt) {
    super.didUpdateWidget(alt);
    if (alt.data != widget.data) _aufbauen();
  }

  @override
  void dispose() {
    _freigeben();
    super.dispose();
  }

  void _freigeben() {
    for (final e in _erkenner) {
      e.dispose();
    }
    _erkenner.clear();
  }

  void _aufbauen() {
    _freigeben();
    _tokens = zerlegeText(widget.data);
    for (final t in _tokens) {
      if (!t.istWort) continue;
      final wort = t.text;
      _erkenner.add(TapGestureRecognizer()
        ..onTap = () {
          if (mounted) showWortPopup(context, wort);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wortStil = widget.markiert
        ? TextStyle(
            color: scheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: scheme.primary.withValues(alpha: 0.4),
          )
        : null;

    var wortNr = 0;
    final spans = <TextSpan>[
      for (final t in _tokens)
        if (t.istWort)
          TextSpan(
              text: t.text, style: wortStil, recognizer: _erkenner[wortNr++])
        else
          TextSpan(text: t.text),
    ];
    final wurzel = TextSpan(children: spans);

    return deutschLinksbuendig(context, _text(wurzel),
        ganzeZeile: widget.ganzeZeile, textAlign: widget.textAlign);
  }

  Widget _text(TextSpan wurzel) {
    if (widget.auswaehlbar) {
      return SelectableText.rich(
        wurzel,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: TextDirection.ltr, // Deutsch: immer links-nach-rechts
        maxLines: widget.maxLines,
        contextMenuBuilder: (ctx, editableState) =>
            AdaptiveTextSelectionToolbar.editableText(
          editableTextState: editableState,
        ),
      );
    }
    return Text.rich(
      wurzel,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
