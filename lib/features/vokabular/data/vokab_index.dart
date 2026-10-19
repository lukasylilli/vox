// FILE: lib/features/vokabular/data/vokab_index.dart
// PHASE: فاز V, Schritt V.2 (2026-09-16)
// PURPOSE: Der WORTINDEX — eine kleine Datei mit genau den Feldern, die Liste,
//          Suche, Zähler und Symbol brauchen. Die volle Karte (Beispiele,
//          Konjugation, Wortnetz …) wird erst beim Öffnen EINES Worts geladen.
//
// WARUM: Vorher las die App beim Start JEDE Datei aus assets/vocab/ — im
// Browser ist das eine Netzanfrage je Wort. Bei ~26.200 Wörtern startet die
// App so nicht mehr (Audit 2026-09-15, sichere Grenze ~500). Jetzt: EINE
// Anfrage beim Start (~220 Byte je Wort, gemessen an den echten Karten),
// eine weitere je geöffnetem Wort.
//
// ⚠️ Reines Dart (kein Flutter): `tool/vokab_index.dart` nutzt dieselben
// Funktionen beim Bauen, die App beim Lesen — EINE Quelle für das Format.
//
// ⚠️ Der Index wird NIE von Hand geschrieben und NIE committet. Jeder
// GitHub-Workflow baut ihn direkt vor `flutter analyze` neu
// (`dart run tool/vokab_index.dart`); er kann deshalb nicht veralten.
//
// ⚠️ Wortdaten und Nutzerdaten bleiben getrennt: der Index enthält keinen
// Leitner-Stand und keine Listen — die liegen in drift (فاز S).
import 'dart:convert';

import 'vokab_schema.dart' show vokabBedeutungen, vokabId, vokabWortarten;

/// Erhöhen, sobald sich die Form des Index ändert. Die App liest nur genau
/// diese Fassung — Index und App entstehen im selben Bau, passen also immer.
const int vokabIndexVersion = 4; // 2: Einordnung (F.5) · 3: homograph_nr · 4: bedeutungen (L.4)

/// Asset-Pfad des Index (in pubspec.yaml eingetragen, in .gitignore ausgenommen).
const String vokabIndexPfad = 'assets/vocab_index.json';

/// Ordner der vollen Karten: `assets/vocab/<wortart>/<id>.json`.
const String vokabKartenOrdner = 'assets/vocab';

/// Felder aus `details`, die die Liste braucht — Symbol und Farbe entstehen im
/// GrammatikonResolver genau aus diesen Feldern.
///
/// ⚠️ Liest der Resolver ein NEUES details-Feld, gehört es hierher.
/// `test/vokab_index_test.dart` vergleicht dafür an jeder echten Karte das
/// Symbol aus der vollen Karte mit dem aus dem Index-Eintrag.
const vokabIndexDetailFelder = <String>[
  'genus',
  'typ',
  'regelmaessig',
  'trennbar',
  'modalverb',
  'kasus',
  'untertyp',
];

/// Wo die volle Karte liegt. Die App leitet den Pfad hieraus ab — deshalb
/// prüft [vokabIndexBauen], dass jede Datei genau dort liegt.
String vokabKartenPfad(String wortart, String id) =>
    '$vokabKartenOrdner/$wortart/$id.json';

/// Volle Karte → Index-Eintrag. Gleiche Schlüssel wie die Karte, damit
/// WortCard und Suche beides ohne Unterschied lesen.
///
/// Bewusst NICHT enthalten: `box`/`nextReviewDate` (Lernstand gehört dem
/// Nutzer, nicht dem Wort) und alles, was nur die Wort-Seite zeigt.
Map<String, dynamic> vokabIndexEintrag(Map<String, dynamic> karte) {
  final details =
      (karte['details'] as Map?)?.cast<String, dynamic>() ?? const {};
  final ueb =
      (karte['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
  return {
    'id': karte['id'],
    'wort': karte['wort'],
    'wortart': karte['wortart'],
    if (karte['niveau'] != null) 'niveau': karte['niveau'],
    'uebersetzung': {
      for (final sprache in const ['fa', 'en'])
        if (ueb[sprache] != null) sprache: ueb[sprache],
    },
    'details': {
      for (final feld in vokabIndexDetailFelder)
        if (details[feld] != null) feld: details[feld],
    },
    // Bedeutungen (Regel 20): Liste und Lernkarte nummerieren sie, ohne die
    // volle Karte zu laden. Nur wenn es mindestens zwei gibt.
    'bedeutungen': ?vokabBedeutungen(karte),
    // Einordnung (فاز F.5) — für die Filter Berufe/Respektlos/Veraltet;
    // nur wenn gesetzt, damit der Index klein bleibt. «anstoessig» nur mit
    // der Stufe (die Erklärung zeigt die Wort-Seite aus der vollen Karte).
    if ((karte['berufe'] as List?)?.isNotEmpty ?? false)
      'berufe': karte['berufe'],
    if (karte['anstoessig'] is Map)
      'anstoessig': {'stufe': (karte['anstoessig'] as Map)['stufe']},
    if (karte['zeitlich'] != null) 'zeitlich': karte['zeitlich'],
  };
}

/// Wird geworfen, wenn aus den Karten kein verlässlicher Index entsteht.
/// Enthält ALLE Gründe auf einmal, nicht nur den ersten.
class VokabIndexFehler implements Exception {
  final List<String> gruende;
  const VokabIndexFehler(this.gruende);
  @override
  String toString() => 'VokabIndexFehler:\n${gruende.join('\n')}';
}

/// (Pfad → volle Karte) → Index-Text.
///
/// Wirft [VokabIndexFehler], wenn eine Karte keine id/wortart/wort hat, eine
/// unbekannte Wortart trägt, nicht unter [vokabKartenPfad] liegt oder ihre id
/// doppelt vorkommt. Lieber ein roter Bau als eine Wort-Seite, die ins Leere
/// zeigt.
String vokabIndexBauen(Map<String, Map<String, dynamic>> kartenNachPfad) {
  final fehler = <String>[];
  final gesehen = <String, String>{};
  final eintraege = <Map<String, dynamic>>[];

  final pfade = kartenNachPfad.keys.toList()..sort();
  for (final pfad in pfade) {
    final karte = kartenNachPfad[pfad]!;
    final id = karte['id'];
    final wortart = karte['wortart'];
    final wort = karte['wort'];
    if (id is! String || id.isEmpty) {
      fehler.add('$pfad: "id" fehlt');
      continue;
    }
    if (wortart is! String || !vokabWortarten.contains(wortart)) {
      fehler.add('$pfad: "wortart" ungültig: $wortart');
      continue;
    }
    if (wort is! String || wort.isEmpty) {
      fehler.add('$pfad: "wort" fehlt');
      continue;
    }
    final erwartet = vokabKartenPfad(wortart, id);
    if (pfad != erwartet) {
      fehler.add('$pfad: gehört nach $erwartet');
      continue;
    }
    final frueher = gesehen[id];
    if (frueher != null) {
      fehler.add('$pfad: id "$id" gibt es schon ($frueher)');
      continue;
    }
    gesehen[id] = pfad;
    eintraege.add(vokabIndexEintrag(karte));
  }
  if (fehler.isNotEmpty) throw VokabIndexFehler(fehler);

  // Homographen (Prompt-Regel 19, Lukas 2026-10-19): Karten derselben Familie
  // tragen ihre Nummer (1 = Hauptbedeutung) — die Liste zeigt sie wie der
  // Duden hochgestellt (See¹ / See²), ohne die volle Karte zu laden.
  for (final ids in vokabHomographFamilien(eintraege).values) {
    for (var i = 0; i < ids.length; i++) {
      eintraege.firstWhere((e) => e['id'] == ids[i])['homograph_nr'] = i + 1;
    }
  }

  // Feste Reihenfolge: nach Wort (klein), bei Gleichstand nach id — derselbe
  // Bestand ergibt immer denselben Text.
  eintraege.sort((a, b) {
    final c = (a['wort'] as String)
        .toLowerCase()
        .compareTo((b['wort'] as String).toLowerCase());
    return c != 0 ? c : (a['id'] as String).compareTo(b['id'] as String);
  });
  return jsonEncode({
    'version': vokabIndexVersion,
    'anzahl': eintraege.length,
    'karten': eintraege,
  });
}

/// Grund-id einer Karte OHNE Homograph-Kennung: `nomen_see` für «der See»
/// UND «die See». Gleiche Grund-id ⇒ dieselbe Familie (Regel 19).
String vokabGrundId(Map<String, dynamic> karte) =>
    vokabId(karte['wortart'] as String? ?? '', karte['wort'] as String? ?? '');

/// Homograph-Familien (Prompt-Regel 19): Grund-id → ids aller Karten mit
/// dieser Grund-id, NUR wenn es mehr als eine gibt. Reihenfolge = Nummer:
/// zuerst die Hauptbedeutung (id ohne Kennung), dann die übrigen nach id —
/// derselbe Bestand ergibt immer dieselben Nummern.
/// Das Erkennen geschieht nur im Code; die Karten tragen dafür nichts.
Map<String, List<String>> vokabHomographFamilien(
    Iterable<Map<String, dynamic>> karten) {
  final nachGrund = <String, List<String>>{};
  for (final k in karten) {
    final id = k['id'] as String?;
    if (id == null || id.isEmpty) continue;
    (nachGrund[vokabGrundId(k)] ??= []).add(id);
  }
  nachGrund.removeWhere((_, ids) => ids.length < 2);
  for (final e in nachGrund.entries) {
    e.value.sort((a, b) {
      if (a == e.key) return -1;
      if (b == e.key) return 1;
      return a.compareTo(b);
    });
  }
  return nachGrund;
}

/// Index-Text → Einträge (für die App). Wirft [FormatException], wenn der
/// Text keine Index-Fassung [vokabIndexVersion] ist.
List<Map<String, dynamic>> vokabIndexLesen(String text) {
  final roh = jsonDecode(text);
  if (roh is! Map || roh['version'] != vokabIndexVersion) {
    throw const FormatException('Wortindex in unbekannter Fassung');
  }
  return [
    for (final e in (roh['karten'] as List?) ?? const [])
      (e as Map).cast<String, dynamic>(),
  ];
}

// ── L.1a: Wächter für veröffentlichte ids ─────────────────────────────────
//
// Der Leitner-Stand, die Listen und die Notizen der Nutzer zeigen auf
// Archivkarten über deren Text-id (`adjektiv_stolz`). Verschwindet eine
// veröffentlichte id — gelöscht oder umbenannt —, bleibt beim Nutzer eine
// Karte ohne Wort zurück. Regel: **eine veröffentlichte id bleibt für immer.**

/// Alle ids eines Index-Textes. Bewusst OHNE Versionsprüfung: der Vergleich
/// läuft gegen den Index der LIVE-Seite, und der darf eine ältere Fassung
/// haben. Wirft [FormatException], wenn der Text gar kein Index ist — dann
/// lieber rot als „nichts veröffentlicht, alles erlaubt".
Set<String> vokabIndexIds(String text) {
  final Object? roh;
  try {
    roh = jsonDecode(text);
  } on FormatException {
    throw const FormatException('Wortindex ist kein lesbares JSON');
  }
  final karten = roh is Map ? roh['karten'] : null;
  if (karten is! List) {
    throw const FormatException('Wortindex ohne Liste "karten"');
  }
  final ids = <String>{};
  for (final e in karten) {
    final id = e is Map ? e['id'] : null;
    if (id is! String || id.isEmpty) {
      throw const FormatException('Wortindex-Eintrag ohne id');
    }
    ids.add(id);
  }
  return ids;
}

/// ids, die [veroeffentlicht] waren und in [neu] fehlen — sortiert.
/// Leer = alles in Ordnung.
List<String> vokabVerloreneIds(Set<String> veroeffentlicht, Set<String> neu) =>
    (veroeffentlicht.difference(neu).toList()..sort());
