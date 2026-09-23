// FILE: lib/features/vokabular/data/vokab_formen.dart
// PHASE: L.5f-Nachtrag (2026-09-23) — Wunsch Lukas: «aalartige» antippen ⇒
//        Karte «aalartig» zeigen.
// PURPOSE: Aus jeder Archivkarte alle GEBEUGTEN Formen ableiten und daraus
//          die Formen-Tabelle `assets/vocab_formen.json` bauen:
//              { "<wortSchluessel der Form>": ["<karten-id>", …], … }
//          Das Wort-Popup (klick_wort_provider.dart) schlägt dort nach, wenn
//          das angetippte Wort selbst keine Grundform im Archiv ist.
//          Aufgeteilt nach dem ERSTEN Buchstaben des Schlüssels
//          (`assets/vocab_formen/<Unicode-hex>.json`): bei ~26.000 Wörtern
//          wären es sonst mehrere MB — so lädt ein Antippen nur ein Stück.
//
// QUELLEN — nur was die Karte selbst sagt, plus feste Grammatikregeln:
//   · Verb:  details.konjugation (praesens / praeteritum / imperativ …) und
//            details.stammformen (praeteritum, partizip2). Von jeder Form
//            zählt nur das ERSTE Wort — «biete an» ⇒ «biete»; die Partikel
//            «an» und Hilfsverben («hat angeboten») würden sonst auf jedes
//            Verb zeigen.
//   · Nomen: details.plural (ohne Artikel); dazu die festen Endungen
//            Genitiv Singular -s/-es (der/das, deklinationstyp normal) und
//            Dativ Plural -n (Plural nicht auf -n/-s).
//   · Adjektiv: details.steigerung (Komparativ, Superlativ ohne «am») und die
//            festen Deklinationsendungen -e/-en/-er/-es/-em an Positiv,
//            Komparativ und Superlativstamm (dunkel ⇒ dunkle…, teuer ⇒ teure…,
//            leise ⇒ leisen…).
// Grundformen selbst stehen NICHT in der Tabelle — die findet schon der
// Wortindex. Eine Form kann zu mehreren Karten gehören (Liste).
//
// Pure Dart (kein Flutter) — genutzt von tool/vokab_index.dart.
import 'dart:convert';

import '../../../core/wort/wort_form.dart';

/// Ordner der Formen-Tabelle (wird von tool/vokab_index.dart erzeugt).
const vokabFormenOrdner = 'assets/vocab_formen';

/// Datei des Tabellenstücks, in dem [schluessel] steht (erster Buchstabe,
/// als Unicode-hex — Dateinamen ohne Umlaute).
/// Liste der vorhandenen Tabellenstücke — damit die App nie eine Datei
/// anfragt, die es gar nicht gibt (fehlend ≠ Ladefehler).
const vokabFormenStueckeDatei = '$vokabFormenOrdner/stuecke.json';

String vokabFormenDatei(String schluessel) =>
    '$vokabFormenOrdner/${schluessel.runes.first.toRadixString(16)}.json';

const _artikel = {
  'der', 'die', 'das', 'des', 'dem', 'den', //
  'ein', 'eine', 'einen', 'einem', 'einer', 'eines',
};

const _adjektivEndungen = ['e', 'en', 'er', 'es', 'em'];

/// Alle gebeugten Formen einer Karte (ohne die Grundform), als Schlüssel
/// (`wortSchluessel`), ohne Doppelte.
Set<String> formenAusKarte(Map<String, dynamic> karte) {
  final wortart = karte['wortart'] as String?;
  final details =
      (karte['details'] as Map?)?.cast<String, dynamic>() ?? const {};
  final grund = _ohneArtikel(karte['wort'] as String? ?? '');
  final formen = <String>{};

  void form(String? text) {
    final k = wortSchluessel(text ?? '');
    if (k.isNotEmpty) formen.add(k);
  }

  switch (wortart) {
    case 'verb':
      void ersteWorte(Object? knoten) {
        if (knoten is String) {
          final teile = knoten.trim().split(RegExp(r'\s+'));
          if (teile.isNotEmpty) form(teile.first);
        } else if (knoten is Map) {
          knoten.values.forEach(ersteWorte);
        }
      }
      ersteWorte(details['konjugation']);
      final stamm = (details['stammformen'] as Map?) ?? const {};
      ersteWorte(stamm['praeteritum']);
      ersteWorte(stamm['partizip2']);

    case 'nomen':
      final plural = _ohneArtikel(details['plural'] as String? ?? '');
      if (plural.isNotEmpty && plural != '-') {
        form(plural);
        final p = plural.toLowerCase();
        if (!p.endsWith('n') && !p.endsWith('s')) form('${plural}n');
      }
      final genus = details['genus'] as String?;
      final typ = details['deklinationstyp'] as String? ?? 'normal';
      if ((genus == 'der' || genus == 'das') && typ == 'normal' &&
          grund.isNotEmpty) {
        form('${grund}s');
        form('${grund}es');
      }

    case 'adjektiv':
      final st = (details['steigerung'] as Map?) ?? const {};
      final positiv = (st['positiv'] as String?) ?? grund;
      final komparativ = st['komparativ'] as String?;
      final superlativ = (st['superlativ'] as String?)
          ?.replaceFirst(RegExp(r'^am\s+'), '');
      form(komparativ);
      form(superlativ);
      for (final stamm in {
        ..._adjektivStaemme(positiv),
        ?komparativ,
        if (superlativ != null && superlativ.endsWith('en'))
          superlativ.substring(0, superlativ.length - 2),
      }) {
        for (final e in _adjektivEndungen) {
          form(stamm.endsWith('e') && e.startsWith('e')
              ? '$stamm${e.substring(1)}'
              : '$stamm$e');
        }
      }
  }

  formen.remove(wortSchluessel(grund));
  return formen;
}

/// Stämme, an die die Deklinationsendung tritt.
Set<String> _adjektivStaemme(String positiv) {
  final p = positiv.trim();
  if (p.isEmpty) return const {};
  final s = {p};
  // dunkel ⇒ dunkl-, teuer/sauer ⇒ teur-/saur- (e fällt aus).
  if (p.endsWith('el')) s.add('${p.substring(0, p.length - 2)}l');
  if (p.endsWith('euer') || p.endsWith('auer')) {
    s.add('${p.substring(0, p.length - 2)}r');
  }
  return s;
}

String _ohneArtikel(String text) {
  final teile = text.trim().split(RegExp(r'\s+'));
  if (teile.length > 1 && _artikel.contains(teile.first.toLowerCase())) {
    return teile.sublist(1).join(' ');
  }
  return text.trim();
}

/// Baut die Formen-Tabelle für alle Karten: Dateipfad → JSON-Text.
/// Sortiert, damit derselbe Kartenbestand immer dieselben Dateien ergibt.
Map<String, String> vokabFormenBauen(Iterable<Map<String, dynamic>> karten) {
  final tabelle = <String, Set<String>>{};
  for (final k in karten) {
    final id = k['id'] as String?;
    if (id == null) continue;
    for (final f in formenAusKarte(k)) {
      (tabelle[f] ??= <String>{}).add(id);
    }
  }
  final stuecke = <String, Map<String, List<String>>>{};
  for (final s in tabelle.keys.toList()..sort()) {
    (stuecke[vokabFormenDatei(s)] ??= {})[s] = tabelle[s]!.toList()..sort();
  }
  return {
    for (final e in stuecke.entries) e.key: jsonEncode(e.value),
    vokabFormenStueckeDatei: jsonEncode(stuecke.keys.toList()..sort()),
  };
}
