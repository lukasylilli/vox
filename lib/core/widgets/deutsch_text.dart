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
//
// NACHTRAG 2026-09-23 (Fund von Claude, Auftrag Lukas): `textAlign` allein
//   reicht nicht. Eine KURZE Zeile ist nur so breit wie ihr Text; in einer
//   persischen Oberfläche schiebt die Eltern-Spalte (`crossAxisAlignment:
//   start` = rechts) dieses schmale Kästchen an den RECHTEN Rand — der Satz
//   stand rechtsbündig, obwohl `textAlign: left` gesetzt war. Darum nimmt
//   deutscher Text in RTL jetzt die ganze verfügbare Zeile ein und steht darin
//   links ([ganzeZeile], siehe [deutschLinksbuendig]).
//   In LTR ändert sich nichts — dort ist „Anfang" schon links.
import 'package:flutter/material.dart';

/// Hält eine deutsche Zeile in einer RTL-Oberfläche am LINKEN Rand
/// (Nachtrag 2026-09-23). Eine Quelle für `DeutschText` und `KlickWortText`.
///
/// Wirkt nur, wenn (1) [ganzeZeile] gilt, (2) die Zeile linksbündig sein soll
/// und (3) die Umgebung RTL ist. Sonst kommt [kind] unverändert zurück.
/// `Align` nimmt nur die BREITE ein, die es bekommt (in einer Row ohne feste
/// Breite bleibt es so schmal wie der Text); `heightFactor: 1` lässt die Höhe
/// beim Text.
Widget deutschLinksbuendig(BuildContext context, Widget kind,
    {required bool ganzeZeile, required TextAlign textAlign}) {
  if (!ganzeZeile ||
      textAlign != TextAlign.left ||
      Directionality.of(context) != TextDirection.rtl) {
    return kind;
  }
  return Align(alignment: Alignment.centerLeft, heightFactor: 1, child: kind);
}

class DeutschText extends StatelessWidget {
  const DeutschText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textAlign = TextAlign.left,
    this.ganzeZeile = true,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Standard ist links. Nur überschreiben, wenn eine Zeile bewusst zentriert
  /// werden soll (z. B. eine große Titelzeile) — niemals auf `right` setzen.
  final TextAlign textAlign;

  /// In RTL die ganze Zeile einnehmen und links stehen (Standard).
  /// `false` nur, wo der Text bewusst nicht an den linken Rand gehört:
  /// AppBar-Titel, Chips, zentrierte Karten/Zeilen.
  final bool ganzeZeile;

  @override
  Widget build(BuildContext context) => deutschLinksbuendig(
        context,
        Text(
          data,
          style        : style,
          maxLines     : maxLines,
          overflow     : overflow,
          softWrap     : softWrap,
          textAlign    : textAlign,
          // Fest, nicht geerbt: Deutsch läuft immer links-nach-rechts.
          textDirection: TextDirection.ltr,
        ),
        ganzeZeile: ganzeZeile,
        textAlign : textAlign,
      );
}

/// Wie [DeutschText], aber für deutschen Text mit mehreren Stilen in einer
/// Zeile (hervorgehobene Präposition, farbiger Kasus, Lücke …).
///
/// Nachtrag 2026-09-23 (Fund Lukas, Auswendiglernen auf dem iPhone): Die
/// Beispielsätze mit Hervorhebung liefen über ein nacktes `Text.rich` /
/// `RichText` — in der persischen Oberfläche rechtsbündig und mit dem Punkt
/// am Satzanfang. `test/deutscher_text_waechter_test.dart` lässt in
/// `lib/features/` deshalb kein nacktes `Text.rich(`/`RichText(` mehr zu.
class DeutschRichText extends StatelessWidget {
  const DeutschRichText(
    this.span, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign = TextAlign.left,
    this.ganzeZeile = true,
  });

  final InlineSpan span;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Standard links — niemals `right` (siehe [DeutschText.textAlign]).
  final TextAlign textAlign;

  /// Siehe [DeutschText.ganzeZeile].
  final bool ganzeZeile;

  @override
  Widget build(BuildContext context) => deutschLinksbuendig(
        context,
        Text.rich(
          span,
          style        : style,
          maxLines     : maxLines,
          overflow     : overflow,
          textAlign    : textAlign,
          textDirection: TextDirection.ltr,
        ),
        ganzeZeile: ganzeZeile,
        textAlign : textAlign,
      );
}

/// Beschriftung in der Oberflächensprache + deutscher Wert, z. B.
/// «جمع: die Tische» oder «Synonym: sich verabschieden».
///
/// Nachtrag 2026-09-23: Beides in EINEM `Text` mischte die Richtungen — in
/// RTL landete der deutsche Teil verdreht. Jetzt: die Beschriftung folgt der
/// Oberfläche, der Wert läuft als `DeutschText` links-nach-rechts daneben.
class DeutschMitEtikett extends StatelessWidget {
  const DeutschMitEtikett({
    super.key,
    required this.etikett,
    required this.wert,
    this.style,
  });

  /// Übersetzte Beschriftung (ohne Doppelpunkt — der wird hier gesetzt,
  /// falls sie keinen hat).
  final String etikett;
  final String wert;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final e = etikett.trimRight();
    if (wert.isEmpty) return Text(e, style: style); // nur die Meldung
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(e.endsWith(':') ? '$e ' : '$e: ', style: style),
        Flexible(child: DeutschText(wert, style: style, ganzeZeile: false)),
      ],
    );
  }
}
