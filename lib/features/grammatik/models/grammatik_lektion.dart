// FILE: lib/features/grammatik/models/grammatik_lektion.dart
// PURPOSE: Content-Modell einer Grammatik-Lektion (Stufe G2, GRAMMATIK_MAP.md).
//          Quelle: assets/data/grammatik/<thema>.json (dreisprachig DE/FA/EN).
//          Deutsch (DE) unantastbar; FA/EN über AppL10n.meaning gerendert.
import 'package:flutter/foundation.dart';

@immutable
class GrammatikExplanationBlock {
  const GrammatikExplanationBlock({
    this.headingDe,
    this.headingFa,
    this.headingEn,
    required this.bodyDe,
    required this.bodyFa,
    required this.bodyEn,
  });

  factory GrammatikExplanationBlock.fromJson(Map<String, dynamic> j) =>
      GrammatikExplanationBlock(
        headingDe: j['headingDE'] as String?,
        headingFa: j['headingFA'] as String?,
        headingEn: j['headingEN'] as String?,
        bodyDe   : j['bodyDE'] as String? ?? '',
        bodyFa   : j['bodyFA'] as String? ?? '',
        bodyEn   : j['bodyEN'] as String? ?? '',
      );

  final String? headingDe, headingFa, headingEn;
  final String  bodyDe, bodyFa, bodyEn;

  bool get hasHeading => (headingDe ?? '').isNotEmpty;
}

@immutable
class GrammatikExample {
  const GrammatikExample({
    required this.german,
    required this.meaningFa,
    required this.meaningEn,
    this.noteDe,
    this.noteFa,
    this.noteEn,
  });

  factory GrammatikExample.fromJson(Map<String, dynamic> j) => GrammatikExample(
        german   : j['german'] as String? ?? '',
        meaningFa: j['meaningFA'] as String? ?? '',
        meaningEn: j['meaningEN'] as String? ?? '',
        noteDe   : j['noteDE'] as String?,
        noteFa   : j['noteFA'] as String?,
        noteEn   : j['noteEN'] as String?,
      );

  final String  german, meaningFa, meaningEn;
  final String? noteDe, noteFa, noteEn;

  bool get hasNote => (noteDe ?? '').isNotEmpty;
}

@immutable
class GrammatikTableRow {
  const GrammatikTableRow({required this.rowLabel, required this.cells});

  factory GrammatikTableRow.fromJson(Map<String, dynamic> j) =>
      GrammatikTableRow(
        rowLabel: j['rowLabel'] as String? ?? '',
        cells   : (j['cells'] as List<dynamic>? ?? []).cast<String>(),
      );

  final String       rowLabel;
  final List<String> cells;
}

@immutable
class GrammatikTable {
  const GrammatikTable({
    required this.titleDe,
    required this.titleFa,
    required this.titleEn,
    required this.columns,
    required this.rows,
  });

  /// ⚠️ L.2c (2026-09-16): Die Quelle kennt ZWEI Schreibweisen für
  /// `columns` — mit einer Überschrift für die Spalte der Zeilenbeschriftung
  /// (`["Person", "Endung", "Beispiel"]`) oder ohne (`["sein", "haben"]`,
  /// Zeilen `ich`/`du` …). Hier wird beides auf EINE Form gebracht:
  /// [columns] hat immer die volle Breite (Beschriftung + Zellen); fehlt die
  /// erste Überschrift, bleibt sie leer. Vorher stürzte die Tabelle von
  /// „verb-sein"/„verb-haben" ab (DataTable verlangt gleich viele Zellen wie
  /// Spalten).
  factory GrammatikTable.fromJson(Map<String, dynamic> j) {
    final spalten = (j['columns'] as List<dynamic>? ?? []).cast<String>();
    final zeilen = (j['rows'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(GrammatikTableRow.fromJson)
        .toList();
    final ohneBeschriftung =
        zeilen.isNotEmpty && spalten.length == zeilen.first.cells.length;
    return GrammatikTable(
      titleDe: j['titleDE'] as String? ?? '',
      titleFa: j['titleFA'] as String? ?? '',
      titleEn: j['titleEN'] as String? ?? '',
      columns: ohneBeschriftung ? ['', ...spalten] : spalten,
      rows   : zeilen,
    );
  }

  final String              titleDe, titleFa, titleEn;
  final List<String>        columns;
  final List<GrammatikTableRow> rows;

  /// Jede Zeile hat genau so viele Felder (Beschriftung + Zellen) wie es
  /// Spalten gibt. Nur dann darf die Tabelle gezeichnet werden;
  /// test/grammatik_lektionen_test.dart stellt es für alle Lektionen sicher.
  bool get istStimmig =>
      columns.isNotEmpty &&
      rows.every((r) => r.cells.length + 1 == columns.length);
}

@immutable
class GrammatikLektion {
  const GrammatikLektion({
    required this.slug,
    required this.titleDe,
    required this.titleFa,
    required this.titleEn,
    required this.levels,
    required this.category,
    required this.explanationBlocks,
    required this.examples,
    required this.tables,
    required this.relatedSlugs,
  });

  factory GrammatikLektion.fromJson(Map<String, dynamic> j) => GrammatikLektion(
        slug   : j['slug'] as String,
        titleDe: j['titleDE'] as String? ?? '',
        titleFa: j['titleFA'] as String? ?? '',
        titleEn: j['titleEN'] as String? ?? '',
        levels : (j['levels'] as List<dynamic>? ?? []).cast<String>(),
        category: j['category'] as String? ?? '',
        explanationBlocks: (j['explanationBlocks'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(GrammatikExplanationBlock.fromJson)
            .toList(),
        examples: (j['examples'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(GrammatikExample.fromJson)
            .toList(),
        tables  : (j['tables'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(GrammatikTable.fromJson)
            .toList(),
        relatedSlugs: (j['relatedSlugs'] as List<dynamic>? ?? []).cast<String>(),
      );

  final String  slug, titleDe, titleFa, titleEn, category;
  final List<String> levels;
  final List<GrammatikExplanationBlock> explanationBlocks;
  final List<GrammatikExample> examples;
  final List<GrammatikTable> tables;
  final List<String> relatedSlugs;
}
