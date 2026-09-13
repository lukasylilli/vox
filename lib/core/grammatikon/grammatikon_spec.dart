// FILE: lib/core/grammatikon/grammatikon_spec.dart
// PURPOSE: Zentrale Render-Spezifikation des Grammatikon-Icon-Systems (فاز V).
//          Prinzip wie vox_button.dart (Puzzling): das gespeicherte Wort-JSON
//          trägt nur die BEDEUTUNG (shape: "raute"), diese Spec die DARSTELLUNG
//          (wie eine Raute aussieht). Design ändern = nur diese Datei anfassen,
//          nie tausende JSONs. Entspricht render_tokens aus SUPER-PROMPT v1.0.
import 'package:flutter/material.dart';

/// Zentrale Render-Spezifikation des Grammatikon-Icon-Systems.
class GrammatikonSpec {
  GrammatikonSpec._();

  // ── Zeichenfläche ────────────────────────────────────────────
  static const double viewBox = 100;        // "0 0 100 100", Icon zentriert

  // ── Farben (fix) ─────────────────────────────────────────────
  static const Color maskulin = Color(0xFF5DA283); // grün
  static const Color feminin  = Color(0xFFE39F4E); // orange
  static const Color neutral  = Color(0xFF7A4B96); // lila
  static const Color plural   = Color(0xFFD85E5C); // rot
  static const Color verb     = Color(0xFFBEB8B0); // grau
  static const Color kontur   = Color(0xFF1A1A1A); // schwarz
  static const Color weiss    = Color(0xFFFFFFFF);

  /// Genus/Numerus-Enum ("maskulin"|"feminin"|"neutral"|"plural") → Farbe.
  static Color? genusFarbe(String? genus) => switch (genus) {
        'maskulin' => maskulin,
        'feminin'  => feminin,
        'neutral'  => neutral,
        'plural'   => plural,
        _          => null,
      };

  // ── Grundformen (shape-Enum → Geometrie) ─────────────────────
  // quadrat        ■  56 × 56, zentriert
  // raute          ◆  = Quadrat um 45° gedreht
  // dreieck_links  ◀  Höhe 56, Spitze zeigt nach links
  // ellipse        ⬬  rx 34, ry 22 (horizontal)
  // kreis          ○  r 28
  // kapsel             rx 45, ry 22 (Präpositions-Hülle)
  // blob_wellig        Kreis r 28 mit welligem Rand (unregelm. Verb)
  // blob_zahnrad       Kreis r 28 mit Zahnrad-Rand (Modalverb)
  // doppel_kreis       zwei konzentrische Kreise (trennbar regelm.)
  // doppel_blob        zwei konzentrische Blobs (trennbar unregelm.)
  // kurve_u        ‿   offene U-Kurve (Konjunktion)
  // kurve_welle    ~   Wellenlinie (Subjunktion)
  // kreis_mit_linie ○— Kreis mit horizontaler Linie (Konjunktionaladverb)
  // stern          *   (Partikel)
  static const double quadratSeite   = 56;
  static const double dreieckHoehe   = 56;
  static const double ellipseRx      = 34, ellipseRy = 22;
  static const double kreisRadius    = 28;
  static const double kapselRx       = 45, kapselRy = 22;

  // ── Größenverhältnisse ───────────────────────────────────────
  static const double kleinFaktor        = 0.60; // size "klein" = 60 % der großen Form
  static const double doppelInnenFaktor  = 0.50; // Innenform bei doppel_* = 50 %, zentriert
  static const double kapselInnenFaktor  = 0.40; // innenform = 40 % der Kapsellänge, zentriert

  // ── Rahmen (Steigerung) ──────────────────────────────────────
  static const double rahmenNormal   = 2.5; // positiv
  static const double rahmenDick     = 5.0; // komparativ
  static const double rahmenSehrDick = 8.0; // superlativ

  /// rahmen-Enum ("normal"|"dick"|"sehr_dick") → Konturbreite.
  static double rahmenBreite(String? rahmen) => switch (rahmen) {
        'dick'      => rahmenDick,
        'sehr_dick' => rahmenSehrDick,
        _           => rahmenNormal,
      };

  // ── Streifen (Füllung streifen_* und Marker) ─────────────────
  static const int    streifenAnzahl  = 3;
  static const double streifenBreite  = 3;
  static const double streifenAbstand = 14;
  static const double diagonalGrad    = 135; // für streifen_diagonal

  // ── Füllungen (fuellung-Enum → Darstellung) ──────────────────
  // voll               : Form komplett in farbe_hex gefüllt
  // hohl               : nur Kontur, innen weiß/transparent
  // halb_unten         : horizontale Trennlinie in der Mitte,
  //                      untere Hälfte farbig, obere hohl
  // streifen_vertikal  : 3 vertikale Streifen (s. o.)
  // streifen_diagonal  : 3 Streifen, 135°
  // doppel_hohl        : Form-in-Form (50 %), beide hohl
  // doppel_voll        : Form-in-Form (50 %), beide farbig

  // ── Marker (marker-Enum → Glyphe, mittig auf dem Icon) ──────
  // strich_vertikal    |   Präsens
  // strich_diagonal    /   Präteritum
  // streifen_diagonal  ⑊⑊⑊ Partizip II
  // ausrufezeichen     !   Imperativ
}
