// FILE: lib/core/grammatikon/grammatikon_resolver.dart
// PURPOSE: Das "Gehirn" des Grammatikon-Systems (فاز V, Stufe ۱).
//          Nimmt eine Wort-Karte (SUPER-PROMPT Schema 2.0) + optionalen Kontext
//          (Kasus, Genus, Numerus, Form) und entscheidet AUTOMATISCH, welches
//          grammatische Symbol angezeigt wird. Das Symbol wird NIRGENDS in den
//          Daten gespeichert — immer zur Laufzeit aus wortart + details berechnet.
//          Design ändern = nur GrammatikonSpec / diese Datei, nie die ۲۵٬۰۰۰ JSONs.
//          (Port des früheren symbolResolver.js — React Native → Flutter.)
import 'package:flutter/material.dart';
import 'grammatikon_spec.dart';

/// Rendering-Kontext: in welcher flektierten Form soll das Symbol gezeigt werden?
/// Alle Felder optional — Standard ist die Grundform (Nominativ, Singular).
class GrammatikonContext {
  final String kasus; // 'nominativ' | 'akkusativ' | 'dativ' | 'genitiv'
  final String numerus; // 'singular' | 'plural'
  final String? genus; // 'maskulin'|'feminin'|'neutral' — für Artikel/Pronomen/Adjektiv
  final String? form; // 'partizip1' | 'partizip2' | 'imperativ' | null
  final bool attributiv; // Adjektiv attributiv (dekliniert) vs. prädikativ (Grundform)

  const GrammatikonContext({
    this.kasus = 'nominativ',
    this.numerus = 'singular',
    this.genus,
    this.form,
    this.attributiv = false,
  });
}

/// Ergebnis des Resolvers: alles, was der Painter zum Zeichnen braucht.
/// shape/fuellung/marker/innen sind Enum-Strings aus GrammatikonSpec.
class GrammatikonDescriptor {
  final String shape; // z. B. 'quadrat', 'raute', 'kapsel', 'blob_wellig'
  final String fuellung; // 'voll'|'hohl'|'halb_unten'|'streifen_vertikal'|'streifen_diagonal'|'doppel_voll'|'doppel_hohl'
  final Color color; // Genus-/Verb-Farbe
  final String? marker; // 'ausrufezeichen' | null (mittige Glyphe)
  final String? innen; // Kapsel-Innenform: 'raute'|'dreieck_links'|'ellipse'|'beide'|null

  const GrammatikonDescriptor({
    required this.shape,
    required this.fuellung,
    required this.color,
    this.marker,
    this.innen,
  });
}

class GrammatikonResolver {
  const GrammatikonResolver._();

  static const _genusMap = {'der': 'maskulin', 'die': 'feminin', 'das': 'neutral'};

  /// Kasus → Grundform (Farbe = Genus, FORM = Kasus).
  static const _kasusForm = {
    'nominativ': 'quadrat',
    'akkusativ': 'raute',
    'dativ': 'dreieck_links',
    'genitiv': 'ellipse',
  };

  static String _formFuerKasus(String? kasus) => _kasusForm[kasus] ?? 'quadrat';

  /// Zentrale Entscheidung: Karte (+ Kontext) → Descriptor.
  static GrammatikonDescriptor resolve(
    Map<String, dynamic> card, [
    GrammatikonContext ctx = const GrammatikonContext(),
  ]) {
    final wortart = card['wortart'] as String?;
    final details = (card['details'] as Map?)?.cast<String, dynamic>() ?? const {};
    final kontur = GrammatikonSpec.kontur;

    switch (wortart) {
      case 'nomen':
        {
          final genus = ctx.numerus == 'plural'
              ? 'plural'
              : _genusMap[details['genus'] as String?];
          return GrammatikonDescriptor(
            shape: _formFuerKasus(ctx.kasus),
            fuellung: 'voll',
            color: GrammatikonSpec.genusFarbe(genus) ?? GrammatikonSpec.verb,
          );
        }

      case 'artikel':
        {
          final bestimmt = details['typ'] == 'bestimmt';
          return GrammatikonDescriptor(
            shape: _formFuerKasus(ctx.kasus),
            fuellung: bestimmt ? 'voll' : 'hohl',
            color: GrammatikonSpec.genusFarbe(ctx.genus) ?? GrammatikonSpec.neutral,
          );
        }

      case 'pronomen':
        return GrammatikonDescriptor(
          shape: _formFuerKasus(ctx.kasus),
          fuellung: 'doppel_voll', // Form-in-Form
          color: GrammatikonSpec.genusFarbe(ctx.genus) ?? GrammatikonSpec.neutral,
        );

      case 'adjektiv':
        {
          // attributiv/dekliniert = Kasusform in Genusfarbe; sonst Grundform (Umriss)
          if (ctx.attributiv) {
            return GrammatikonDescriptor(
              shape: _formFuerKasus(ctx.kasus),
              fuellung: 'voll',
              color: GrammatikonSpec.genusFarbe(ctx.genus) ?? GrammatikonSpec.neutral,
            );
          }
          return GrammatikonDescriptor(shape: 'quadrat', fuellung: 'hohl', color: kontur);
        }

      case 'verb':
        {
          final regelmaessig = details['regelmaessig'] == true;
          final trennbar = details['trennbar'] == true;
          final modalverb = details['modalverb'] == true;

          String shape;
          if (modalverb) {
            shape = 'blob_zahnrad';
          } else if (trennbar) {
            shape = regelmaessig ? 'doppel_kreis' : 'doppel_blob';
          } else {
            shape = regelmaessig ? 'kreis' : 'blob_wellig';
          }

          // Form-Marker: Partizip I/II als Streifen, Imperativ als Ausrufezeichen.
          if (ctx.form == 'partizip1') {
            return GrammatikonDescriptor(
                shape: shape, fuellung: 'streifen_vertikal', color: GrammatikonSpec.verb);
          }
          if (ctx.form == 'partizip2') {
            return GrammatikonDescriptor(
                shape: shape, fuellung: 'streifen_diagonal', color: GrammatikonSpec.verb);
          }
          if (ctx.form == 'imperativ') {
            return GrammatikonDescriptor(
                shape: shape,
                fuellung: 'voll',
                color: GrammatikonSpec.verb,
                marker: 'ausrufezeichen');
          }
          return GrammatikonDescriptor(
              shape: shape, fuellung: 'voll', color: GrammatikonSpec.verb);
        }

      case 'praeposition':
        {
          final kasus = details['kasus'] as String?;
          final innen = switch (kasus) {
            'wechsel' => 'beide',
            'akkusativ' => 'raute',
            'genitiv' => 'ellipse',
            _ => 'dreieck_links', // dativ (Standard)
          };
          return GrammatikonDescriptor(
              shape: 'kapsel', fuellung: 'hohl', color: kontur, innen: innen);
        }

      case 'konjunktion':
        {
          final untertyp = details['untertyp'] as String?;
          final shape = switch (untertyp) {
            'konjunktionaladverb' => 'kreis_mit_linie',
            'subordinierend' => 'kurve_welle',
            _ => 'kurve_u',
          };
          return GrammatikonDescriptor(shape: shape, fuellung: 'hohl', color: kontur);
        }

      case 'adverb':
        return GrammatikonDescriptor(shape: 'kreis', fuellung: 'hohl', color: kontur);

      case 'numerale':
        return GrammatikonDescriptor(shape: 'quadrat', fuellung: 'halb_unten', color: kontur);

      case 'partikel':
        return GrammatikonDescriptor(shape: 'stern', fuellung: 'voll', color: kontur);

      default:
        return GrammatikonDescriptor(shape: 'kreis', fuellung: 'hohl', color: GrammatikonSpec.verb);
    }
  }
}
