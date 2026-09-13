// FILE: lib/features/grammatik/models/grammar_catalog.dart
// PURPOSE: Master-Katalog des Grammatik-Bereichs (Stufe G1, GRAMMATIK_MAP.md).
//          EIN Katalog = Quelle der Wahrheit; die Ansichten (Niveau/Thema/
//          Lektionen/Satzglieder) sind nur verschiedene Sortierungen davon.
//          Neuer Inhalt = 1 Eintrag in assets/data/grammatik_katalog.json.
import 'package:flutter/material.dart';

@immutable
class KatalogThema {
  const KatalogThema({
    required this.id,
    required this.de,
    required this.fa,
    required this.en,
  });

  factory KatalogThema.fromJson(Map<String, dynamic> j) => KatalogThema(
        id: j['id'] as String,
        de: j['de'] as String,
        fa: j['fa'] as String,
        en: j['en'] as String? ?? '',
      );

  final String id;
  final String de;
  final String fa;
  final String en;

  IconData get icon => switch (id) {
        'verben'           => Icons.bolt_rounded,
        'tempus'           => Icons.schedule_rounded,
        'passiv'           => Icons.sync_alt_rounded,
        'konjunktiv'       => Icons.auto_awesome_rounded,
        'verbergaenzungen' => Icons.link_rounded,
        'ergaenzungssaetze'=> Icons.playlist_add_rounded,
        'nomen'            => Icons.text_fields_rounded,
        'artikel'          => Icons.font_download_rounded,
        'adjektive'        => Icons.palette_rounded,
        'adverbien'        => Icons.place_rounded,
        'pronomen'         => Icons.person_rounded,
        'praepositionen'   => Icons.swap_horiz_rounded,
        'satzlehre'        => Icons.view_list_rounded,
        'nebensaetze'      => Icons.account_tree_rounded,
        'wendungen'        => Icons.format_quote_rounded,
        _                  => Icons.menu_book_rounded,
      };

  Color get color => switch (id) {
        'verben'           => const Color(0xFF1565C0),
        'tempus'           => const Color(0xFF37474F),
        'passiv'           => const Color(0xFF880E4F),
        'konjunktiv'       => const Color(0xFF6A1B9A),
        'verbergaenzungen' => const Color(0xFF2E7D32),
        'ergaenzungssaetze'=> const Color(0xFFE65100),
        'nomen'            => const Color(0xFF00695C),
        'artikel'          => const Color(0xFF0277BD),
        'adjektive'        => const Color(0xFFAD1457),
        'adverbien'        => const Color(0xFF558B2F),
        'pronomen'         => const Color(0xFF4527A0),
        'praepositionen'   => const Color(0xFF00838F),
        'satzlehre'        => const Color(0xFF4E342E),
        'nebensaetze'      => const Color(0xFF283593),
        'wendungen'        => const Color(0xFF4A148C),
        _                  => const Color(0xFF546E7A),
      };
}

@immutable
class KatalogSatzglied {
  const KatalogSatzglied({
    required this.id,
    required this.de,
    required this.fa,
    required this.en,
  });

  factory KatalogSatzglied.fromJson(Map<String, dynamic> j) => KatalogSatzglied(
        id: j['id'] as String,
        de: j['de'] as String,
        fa: j['fa'] as String,
        en: j['en'] as String? ?? j['fa'] as String,
      );

  final String id;
  final String de;
  final String fa;
  final String en;

  IconData get icon => switch (id) {
        'praedikat'     => Icons.bolt_rounded,
        'ergaenzungen'  => Icons.link_rounded,
        'nominalgruppe' => Icons.text_fields_rounded,
        'attribute'     => Icons.palette_rounded,
        'angaben'       => Icons.place_rounded,
        'satzverbindung'=> Icons.account_tree_rounded,
        _               => Icons.format_quote_rounded,
      };
}

@immutable
class KatalogEintrag {
  const KatalogEintrag({
    required this.slug,
    required this.de,
    required this.fa,
    required this.en,
    required this.niveaus,
    required this.thema,
    required this.satzglied,
    required this.lektion,
    required this.route,
  });

  factory KatalogEintrag.fromJson(Map<String, dynamic> j) => KatalogEintrag(
        slug     : j['slug'] as String,
        de       : j['de'] as String,
        fa       : j['fa'] as String,
        en       : j['en'] as String? ?? j['fa'] as String,
        niveaus  : (j['niveaus'] as List<dynamic>).cast<String>(),
        thema    : j['thema'] as String,
        satzglied: j['satzglied'] as String,
        lektion  : j['lektion'] as int?,
        route    : j['route'] as String?,
      );

  final String  slug;
  final String  de;
  final String  fa;
  final String  en;
  final List<String> niveaus;   // lowercase: a1..c2
  final String  thema;          // KatalogThema.id
  final String  satzglied;      // KatalogSatzglied.id
  final int?    lektion;        // Position im linearen Lernpfad; null = Vertiefung
  final String? route;          // null = noch kein Inhalt → "به‌زودی"

  bool get isLive => route != null;
}

@immutable
class GrammatikKatalog {
  const GrammatikKatalog({
    required this.themen,
    required this.satzglieder,
    required this.eintraege,
  });

  factory GrammatikKatalog.fromJson(Map<String, dynamic> j) => GrammatikKatalog(
        themen: (j['themen'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(KatalogThema.fromJson)
            .toList(),
        satzglieder: (j['satzglieder'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(KatalogSatzglied.fromJson)
            .toList(),
        eintraege: (j['eintraege'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(KatalogEintrag.fromJson)
            .toList(),
      );

  final List<KatalogThema>     themen;
  final List<KatalogSatzglied> satzglieder;
  final List<KatalogEintrag>   eintraege;

  KatalogThema? thema(String id) {
    for (final t in themen) {
      if (t.id == id) return t;
    }
    return null;
  }

  KatalogSatzglied? satzglied(String id) {
    for (final s in satzglieder) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<KatalogEintrag> byNiveau(String level) =>
      eintraege.where((e) => e.niveaus.contains(level)).toList();

  List<KatalogEintrag> byThema(String id) =>
      eintraege.where((e) => e.thema == id).toList();

  List<KatalogEintrag> bySatzglied(String id) =>
      eintraege.where((e) => e.satzglied == id).toList();

  /// Kern-Lernpfad (Lektion 1..n), bereits sortiert im JSON abgelegt.
  List<KatalogEintrag> get lektionen =>
      eintraege.where((e) => e.lektion != null).toList();

  /// Unnummerierte Einträge — „Vertiefung & Überblick".
  List<KatalogEintrag> get vertiefung =>
      eintraege.where((e) => e.lektion == null).toList();
}
