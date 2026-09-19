// FILE: lib/core/widgets/deutsch_text.dart
// DEPS: -
// EXPORTS: DeutschText
// PURPOSE: Deutscher (lateinischer) Inhalt in einer Oberfläche, die als Ganzes
//          rechts-nach-links laufen kann.
//
// WARUM ES DAS GIBT (Fehlerbericht Lukas, 2026-09-18):
//   Ist die Oberflächensprache Persisch, setzt `MaterialApp.locale = fa` die
//   Directionality der ganzen App auf RTL. Ein schlichtes `Text('Ich komme.')`
//   erbt das: der Satz rutscht an den rechten Rand (links bleibt leer) und der
//   Schlusspunkt landet nach den Bidi-Regeln am linken Ende — also optisch am
//   Satzanfang. Die Wortfolge selbst bleibt heil, nur Ausrichtung und
//   Satzzeichen stimmen nicht.
//
//   Deutscher Text ist IMMER links-nach-rechts, egal welche Oberflächensprache
//   eingestellt ist. Darum bekommt er seine Richtung hier fest gesetzt statt
//   sie zu erben. `textDirection` rückt das Satzzeichen an die richtige Seite,
//   `textAlign` holt die Zeile zurück an den linken Rand.
//
// REGEL: Jeder deutsche Inhalt (Phrase, Beispielsatz, Aufgabenstellung,
//        Wortliste, Struktur-Muster) wird mit `DeutschText` gezeigt, nie mit
//        einem nackten `Text`. Übersetzungen (fa/en) bleiben beim normalen
//        `Text` — die sollen der Oberflächensprache folgen.
import 'package:flutter/material.dart';

class DeutschText extends StatelessWidget {
  const DeutschText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textAlign = TextAlign.left,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Standard ist links. Nur überschreiben, wenn eine Zeile bewusst zentriert
  /// werden soll (z. B. eine große Titelzeile) — niemals auf `right` setzen.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => Text(
        data,
        style        : style,
        maxLines     : maxLines,
        overflow     : overflow,
        softWrap     : softWrap,
        textAlign    : textAlign,
        // Fest, nicht geerbt: Deutsch läuft immer links-nach-rechts.
        textDirection: TextDirection.ltr,
      );
}
