// FILE: lib/core/grammatikon/wort_text.dart
// PURPOSE: Farbige Wortendungen nach dem Duden-Bildsystem (فاز V, Stufe ۲).
//              WortText(wort: 'kleinem', color: GrammatikonSpec.maskulin, endung: 'em')
//          Stamm in Textfarbe (Theme!), Endung farbig + fett, Präfix fett + kursiv.
//          color = null → Endung nur fett (neutral, theme-sicher in Dark Mode).
//          Design-System-Regel: Screens definieren KEINE eigenen Endungs-Styles —
//          nur dieses Widget verwenden (Puzzling, wie vox_button.dart).
//          (Port von WortText.js — React Native → Flutter Text.rich.)
import 'package:flutter/material.dart';
import 'endung_resolver.dart';

class WortText extends StatelessWidget {
  final String wort;

  /// Explizite Endung. `null` = Automatik (Heuristik), `''` = keine Markierung.
  /// In Listen/Tabellen immer explizit übergeben, wenn die Form bekannt ist.
  final String? endung;

  /// z. B. 'ge' (Partizip II) oder trennbares Präfix ('auf' bei aufstehen).
  final String? praefix;

  /// Endungsfarbe (Genusfarbe aus GrammatikonSpec übergeben).
  /// `null` → Endung nur fett, in Theme-Textfarbe (sicher in Dark Mode).
  final Color? color;

  /// Präfixfarbe; `null` → Theme-Textfarbe.
  final Color? praefixColor;

  /// Basis-Stil (Größe/Font); Farben für Stamm kommen aus dem Theme.
  final TextStyle? style;

  /// `false` = ganz normale Anzeige ohne Markierung (z. B. in Fließtext).
  final bool markieren;

  const WortText({
    super.key,
    required this.wort,
    this.endung,
    this.praefix,
    this.color,
    this.praefixColor,
    this.style,
    this.markieren = true,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;

    if (!markieren) return Text(wort, style: base);

    final p = EndungResolver.splitPraefix(wort, praefix);
    final s = EndungResolver.splitEndung(p.rest, endung);

    return Text.rich(
      TextSpan(children: [
        if (p.praefix.isNotEmpty)
          TextSpan(
            text: p.praefix,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: praefixColor,
            ),
          ),
        TextSpan(
          text: s.stamm,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (s.endung.isNotEmpty)
          TextSpan(
            text: s.endung,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
      ]),
      style: base,
      // Deutsch ist immer LTR — auch wenn die App-Locale FA (RTL) ist.
      textDirection: TextDirection.ltr,
    );
  }
}
