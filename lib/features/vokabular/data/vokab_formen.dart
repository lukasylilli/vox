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
//   · Verb (Entscheidung Lukas 2026-10-11: ALLE Formen eines Verbs stehen
//            auf der Seite des Infinitivs und die Suche findet sie):
//            details.konjugation (praesens, praeteritum, imperativ,
//            konjunktiv1, konjunktiv2 — alles, was die Karte nennt) und
//            details.stammformen (praeteritum, partizip2). Von jeder Form
//            zählt das ERSTE Wort — «biete an» ⇒ «biete»; die Partikel «an»
//            allein würde sonst auf jedes Verb zeigen. Bei trennbaren Verben
//            zusätzlich Partikel + erstes Wort zusammen («bot an» ⇒ «anbot»):
//            die Suche setzt «bot … an» genauso zusammen
//            (vokabSuchSchluessel). Dazu feste Grammatikregeln, nie geraten:
//            Partizip I und II mit den Adjektivendungen (angebotene …),
//            zu-Infinitiv («anzubieten», «zu bieten») und Gerundiv
//            («anzubietende»), Genitiv des nominalisierten Infinitivs
//            («des Anbietens»).
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
      formen.addAll(_verbFormen(grund, details, wortSchluessel));

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

/// Alle Formen eines Verbs (Schlüssel). Nur aus dem, was die Karte nennt, und
/// festen Regeln — siehe Kopfkommentar.
Set<String> _verbFormen(
  String grund,
  Map<String, dynamic> details,
  String Function(String) schluessel,
) {
  final formen = <String>{};
  void form(String? text) {
    final k = schluessel(text ?? '');
    if (k.isNotEmpty) formen.add(k);
  }

  List<String> woerter(String text) => wortBereinigt(text)
      .split(RegExp(r'\s+'))
      .map(wortBereinigt)
      .where((t) => t.isNotEmpty)
      .toList();

  final stamm = (details['stammformen'] as Map?) ?? const {};
  var infinitiv = (stamm['infinitiv'] as String?)?.trim() ?? '';
  if (infinitiv.isEmpty) infinitiv = grund;
  final infTeile = woerter(infinitiv);
  // «sich waschen» ⇒ «waschen»
  final inf = infTeile.isEmpty ? '' : infTeile.last;
  final trennbar = details['trennbar'] == true;
  final konj = (details['konjugation'] as Map?) ?? const {};

  // Partikel eines trennbaren Verbs: letztes Wort von «rufe an», wenn der
  // Infinitiv damit beginnt («anrufen»). Sonst null (kein Raten).
  String? partikel;
  if (trennbar) {
    final ich = ((konj['praesens'] as Map?)?['ich'] as String?) ?? '';
    final t = woerter(ich);
    if (t.length >= 2) {
      final p = t.last.toLowerCase();
      if (p != t.first.toLowerCase() &&
          inf.toLowerCase().startsWith(p) &&
          inf.length > p.length) {
        partikel = p;
      }
    }
  }

  void konjugierteForm(String text) {
    final t = woerter(text);
    if (t.isEmpty) return;
    form(t.first);
    if (partikel != null && t.length >= 2 && t.last.toLowerCase() == partikel) {
      form('$partikel${t.first}');
    }
  }

  void alle(Object? knoten) {
    if (knoten is String) {
      konjugierteForm(knoten);
    } else if (knoten is Map) {
      knoten.values.forEach(alle);
    }
  }

  alle(konj);
  alle(stamm['praeteritum']);

  void mitEndungen(String stammForm) {
    for (final e in _adjektivEndungen) {
      form(
        stammForm.endsWith('e') && e.startsWith('e')
            ? '$stammForm${e.substring(1)}'
            : '$stammForm$e',
      );
    }
  }

  // Partizip II: das LETZTE Wort («hat angeboten» ⇒ «angeboten»).
  final p2Teile = woerter(stamm['partizip2'] as String? ?? '');
  if (p2Teile.isNotEmpty) {
    form(p2Teile.last);
    mitEndungen(p2Teile.last);
  }
  // Partizip I («anbietend») + Endungen.
  final p1Teile = woerter(details['partizip1'] as String? ?? '');
  if (p1Teile.isNotEmpty) {
    form(p1Teile.last);
    mitEndungen(p1Teile.last);
  }

  if (inf.isNotEmpty) {
    // zu-Infinitiv und Gerundiv.
    if (partikel != null) {
      final zu = '${partikel}zu${inf.substring(partikel.length)}';
      form(zu);
      mitEndungen('${zu}d');
    } else {
      form('zu $inf');
      mitEndungen('zu ${inf}d');
    }
    // Genitiv des nominalisierten Infinitivs: «des Anbietens».
    form('${inf}s');
  }
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

/// Schlüssel, unter denen die Suche [anfrage] in der Formen-Tabelle sucht —
/// in dieser Reihenfolge, ohne Doppelte (Entscheidung Lukas 2026-10-11:
/// jede Form eines Verbs findet den Infinitiv):
///   1. die ganze Anfrage («zu gehen», «aalartige»);
///   2. bei mehreren Wörtern: letztes + erstes Wort zusammen — so steht ein
///      getrenntes Verb in der Tabelle («rief an», «rufe mich an» ⇒ «anrief»,
///      «anrufe»);
///   3. jedes Wort einzeln («hat angerufen» ⇒ «angerufen», «ist gegangen» ⇒
///      «gegangen»; das Hilfsverb findet dabei auch haben/sein — gewollt:
///      die Suche zeigt alle passenden Karten).
List<String> vokabSuchSchluessel(String anfrage) {
  final schluessel = <String>[];
  void dazu(String text) {
    final k = wortSchluessel(text);
    if (k.isNotEmpty && !schluessel.contains(k)) schluessel.add(k);
  }

  dazu(anfrage);
  final woerter = wortBereinigt(anfrage)
      .split(RegExp(r'\s+'))
      .map(wortBereinigt)
      .where((t) => t.isNotEmpty)
      .toList();
  if (woerter.length >= 2) {
    dazu('${woerter.last}${woerter.first}');
    woerter.forEach(dazu);
  }
  return schluessel;
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
