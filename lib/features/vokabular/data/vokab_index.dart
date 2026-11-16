// FILE: lib/features/vokabular/data/vokab_index.dart
// PHASE: فاز V, Schritt V.2 (2026-09-16)
// PURPOSE: Der WORTINDEX — genau die Felder, die Liste, Suche, Zähler und
//          Symbol brauchen. Die volle Karte (Beispiele, Konjugation,
//          Wortnetz …) wird erst beim Öffnen EINES Worts geladen.
//
// IN STÜCKEN (2026-11-16, PLAN «⚠️ مقیاس»): der Index liegt nicht mehr in
// EINER Datei, sondern je Anfangsbuchstabe in einer
// (`assets/vocab_index/<a…z|0>.json`) plus Liste `stuecke.json`.
// Grund, gemessen an 22.029 Karten: die eine Datei war 5,1 MB (0,96 MB
// komprimiert) und änderte sich mit JEDER Wortrunde — jeder Nutzer lud sie
// nach jeder Runde ganz neu. Jetzt ändert eine Runde nur die Stücke ihrer
// Buchstaben (größtes Stück 0,13 MB komprimiert); der Offline-Worker lädt
// nur Geändertes nach (Revision je Datei, tool/pwa/workbox_config.cjs).
//
// WARUM: Vorher las die App beim Start JEDE Datei aus assets/vocab/ — im
// Browser ist das eine Netzanfrage je Wort. Bei ~26.200 Wörtern startet die
// App so nicht mehr (Audit 2026-09-15, sichere Grenze ~500). Jetzt: EINE
// Anfrage je Index-Stück (~220 Byte je Wort, gemessen an den echten Karten),
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

import '../../../core/wort/wort_form.dart' show ohneNomenArtikel;
import 'vokab_schema.dart' show vokabBedeutungen, vokabId, vokabWortarten;

/// Erhöhen, sobald sich die Form des Index ändert. Die App liest nur genau
/// diese Fassung — Index und App entstehen im selben Bau, passen also immer.
const int vokabIndexVersion = 6; // 2: Einordnung (F.5) · 3: homograph_nr · 4: bedeutungen (L.4) · 5: Übersichtskarten (Vier Fälle) · 6: in Stücken

/// Asset-Ordner des Index (in pubspec.yaml eingetragen, in .gitignore
/// ausgenommen): je Stück eine Datei, dazu [vokabIndexStueckeDatei].
const String vokabIndexOrdner = 'assets/vocab_index';

/// Liste der Stücke: `{version, anzahl, stuecke: [<Asset-Pfad>, …]}`. Die App
/// liest zuerst diese Datei und fragt nur Stücke an, die es gibt.
const String vokabIndexStueckeDatei = '$vokabIndexOrdner/stuecke.json';

/// Wo der Index bis Fassung 5 lag (EINE Datei). Nur der Wächter L.1a liest
/// das noch: eine veröffentlichte Seite kann diese ältere Ablage haben.
const String vokabIndexAltPfad = 'assets/vocab_index.json';

/// Name des Stücks für alle ids, die nicht mit a–z beginnen.
const String vokabIndexRestStueck = '0';

/// Stück (Asset-Pfad), in dem der Eintrag [id] der Wortart [wortart] steht:
/// erster Buchstabe der id NACH der Wortart (`nomen_bank_2` ⇒ «b»). Die id
/// kennt keine Umlaute und keinen Artikel ([vokabId]) ⇒ 26 Stücke + Rest.
/// Alle Karten einer Homograph-Familie und ihre Übersichtskarte «الف»
/// beginnen gleich und liegen deshalb immer im SELBEN Stück.
String vokabIndexStueck(String wortart, String id) {
  final rest = id.startsWith('${wortart}_') ? id.substring(wortart.length + 1) : id;
  final c = rest.isEmpty ? 0 : rest.codeUnitAt(0);
  final name = (c >= 0x61 && c <= 0x7a)
      ? String.fromCharCode(c)
      : vokabIndexRestStueck;
  return '$vokabIndexOrdner/$name.json';
}

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

/// Ordner der vollen Karten in der veröffentlichten Web-App (V.5): die
/// Dateien aus [vokabKartenOrdner] werden beim Bau nach `build/web/karten/`
/// kopiert — NICHT als Flutter-Asset, damit sie nicht im Asset-Verzeichnis
/// stehen, das jeder Nutzer beim Start lädt.
const String vokabKartenWebOrdner = 'karten';

/// Adresse einer vollen Karte relativ zur App (`<base>/karten/<wortart>/<id>.json`).
String vokabKartenWebPfad(String wortart, String id) =>
    '$vokabKartenWebOrdner/$wortart/$id.json';

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

/// (Pfad → volle Karte) → alle Index-Einträge, sortiert ([vokabIndexZusammen]).
///
/// Wirft [VokabIndexFehler], wenn eine Karte keine id/wortart/wort hat, eine
/// unbekannte Wortart trägt, nicht unter [vokabKartenPfad] liegt oder ihre id
/// doppelt vorkommt. Lieber ein roter Bau als eine Wort-Seite, die ins Leere
/// zeigt.
List<Map<String, dynamic>> vokabIndexEintraege(
    Map<String, Map<String, dynamic>> kartenNachPfad) {
  final fehler = <String>[];
  final gesehen = <String, String>{};
  final eintraege = <Map<String, dynamic>>[];
  final volleKarten = <String, Map<String, dynamic>>{};

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
    volleKarten[id] = karte;
  }
  if (fehler.isNotEmpty) throw VokabIndexFehler(fehler);

  // Homographen (Prompt-Regel 19, Lukas 2026-10-19): Karten derselben Familie
  // tragen ihre Nummer (1 = Hauptbedeutung) — die Liste zeigt sie wie der
  // Duden hochgestellt (See¹ / See²), ohne die volle Karte zu laden.
  //
  // Übersichtskarte «الف» (Entwurf Lukas 2026-11-15, Fall 1–3): jede Familie
  // bekommt zusätzlich EINE Karte, die alle Bedeutungen nebeneinander zeigt.
  // Sie entsteht nur hier aus den Bedeutungskarten — keine eigene Datei, nichts
  // steht doppelt. Jede Bedeutungskarte zeigt über `uebersicht_id` zurück.
  final ueberblicke = <Map<String, dynamic>>[];
  for (final familie in vokabHomographFamilien(eintraege).entries) {
    final ids = familie.value;
    final glieder = [
      for (final id in ids) eintraege.firstWhere((e) => e['id'] == id)
    ];
    final uebersichtId = vokabUebersichtId(familie.key);
    if (gesehen.containsKey(uebersichtId)) {
      fehler.add('id "$uebersichtId" ist für die Übersichtskarte reserviert '
          '(${gesehen[uebersichtId]})');
      continue;
    }
    for (var i = 0; i < glieder.length; i++) {
      glieder[i]['homograph_nr'] = i + 1;
      glieder[i]['uebersicht_id'] = uebersichtId;
    }
    ueberblicke.add(vokabUebersichtEintrag(
      uebersichtId,
      glieder,
      ipa: volleKarten[ids.first]?['ipa'] as String?,
    ));
  }
  if (fehler.isNotEmpty) throw VokabIndexFehler(fehler);
  eintraege.addAll(ueberblicke);

  return vokabIndexZusammen([eintraege]);
}

/// Stücke → EINE Liste in fester Reihenfolge: nach Wort (klein), bei
/// Gleichstand nach id — derselbe Bestand ergibt immer dieselbe Liste, egal
/// wie er auf Stücke verteilt ist.
List<Map<String, dynamic>> vokabIndexZusammen(
    Iterable<List<Map<String, dynamic>>> stuecke) {
  final mitSchluessel = [
    for (final stueck in stuecke)
      for (final e in stueck) (wort: (e['wort'] as String).toLowerCase(), e: e),
  ]..sort((a, b) {
      final c = a.wort.compareTo(b.wort);
      return c != 0
          ? c
          : (a.e['id'] as String).compareTo(b.e['id'] as String);
    });
  return [for (final m in mitSchluessel) m.e];
}

/// (Pfad → volle Karte) → Dateien des Index (Asset-Pfad → Text): je Stück
/// eine ([vokabIndexStueck]) und die Liste [vokabIndexStueckeDatei].
/// Wirft [VokabIndexFehler] wie [vokabIndexEintraege].
Map<String, String> vokabIndexBauen(
    Map<String, Map<String, dynamic>> kartenNachPfad) {
  final eintraege = vokabIndexEintraege(kartenNachPfad);
  final stuecke = <String, List<Map<String, dynamic>>>{};
  for (final e in eintraege) {
    (stuecke[vokabIndexStueck(e['wortart'] as String, e['id'] as String)] ??=
            [])
        .add(e);
  }
  final dateien = stuecke.keys.toList()..sort();
  return {
    for (final d in dateien)
      d: jsonEncode({'version': vokabIndexVersion, 'karten': stuecke[d]}),
    vokabIndexStueckeDatei: jsonEncode({
      'version': vokabIndexVersion,
      'anzahl': eintraege.length,
      'stuecke': dateien,
    }),
  };
}

/// Kennung der Übersichtskarte «الف» einer Familie. Doppelter Unterstrich:
/// [vokabId] erzeugt nie «__», eine echte Karte kann die id also nicht haben.
const String vokabUebersichtEndung = '__alle';

/// id der Übersichtskarte zur Grund-id (`nomen_bank` → `nomen_bank__alle`).
String vokabUebersichtId(String grundId) => '$grundId$vokabUebersichtEndung';

/// Ist dieser Eintrag eine Übersichtskarte «الف» (keine Datei, nur Index)?
bool vokabIstUebersicht(Map<String, dynamic>? eintrag) =>
    eintrag != null && eintrag['uebersicht'] == true;

const _niveauReihe = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

/// Übersichtskarte «الف» aus den Bedeutungskarten einer Familie (Reihenfolge
/// = Bedeutungsnummer). Enthält nur, was Lukas für «الف» festgelegt hat:
/// Wort, Aussprache, je Bedeutung id (Artikel, Farbe, Übersetzung und Niveau
/// liest die App aus dem Eintrag dieser id) — keine Beispiele, kein Wortnetz.
/// `uebersetzung` = alle Bedeutungen zusammen, damit die Suche die Karte
/// findet; `niveau` = das leichteste, damit sie in jedem passenden Filter
/// erscheint, in dem auch eine ihrer Bedeutungen erscheint.
Map<String, dynamic> vokabUebersichtEintrag(
  String id,
  List<Map<String, dynamic>> glieder, {
  String? ipa,
}) {
  final niveaus = [
    for (final g in glieder)
      if (_niveauReihe.contains(g['niveau'])) g['niveau'] as String
  ]..sort((a, b) => _niveauReihe.indexOf(a) - _niveauReihe.indexOf(b));
  return {
    'id': id,
    'wort': ohneNomenArtikel(glieder.first['wort'] as String),
    'wortart': glieder.first['wortart'],
    'uebersicht': true,
    'bedeutungen_ids': [for (final g in glieder) g['id']],
    if (ipa != null && ipa.isNotEmpty) 'ipa': ipa,
    if (niveaus.isNotEmpty) 'niveau': niveaus.first,
    'uebersetzung': {
      for (final sprache in const ['fa', 'en'])
        sprache: [
          for (final g in glieder)
            ...(((g['uebersetzung'] as Map?)?[sprache] as List?) ?? const [])
        ],
    },
  };
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

/// Text von [vokabIndexStueckeDatei] → Asset-Pfade der Stücke (für die App).
/// Wirft [FormatException], wenn der Text keine Liste der Fassung
/// [vokabIndexVersion] ist.
List<String> vokabIndexStueckeLesen(String text) {
  final roh = jsonDecode(text);
  if (roh is! Map || roh['version'] != vokabIndexVersion) {
    throw const FormatException('Wortindex in unbekannter Fassung');
  }
  return vokabIndexStueckNamen(text);
}

/// Wie [vokabIndexStueckeLesen], aber OHNE Versionsprüfung — für den Wächter
/// L.1a, der die Liste der LIVE-Seite liest (die darf älter sein).
List<String> vokabIndexStueckNamen(String text) {
  final Object? roh;
  try {
    roh = jsonDecode(text);
  } on FormatException {
    throw const FormatException('Stückliste des Wortindex ist kein lesbares JSON');
  }
  final stuecke = roh is Map ? roh['stuecke'] : null;
  if (stuecke is! List || stuecke.any((s) => s is! String || s.isEmpty)) {
    throw const FormatException('Wortindex ohne Liste "stuecke"');
  }
  return stuecke.cast<String>();
}

/// Text EINES Stücks → Einträge (für die App). Wirft [FormatException], wenn
/// der Text kein Stück der Fassung [vokabIndexVersion] ist.
List<Map<String, dynamic>> vokabIndexStueckLesen(String text) {
  final roh = jsonDecode(text);
  if (roh is! Map || roh['version'] != vokabIndexVersion) {
    throw const FormatException('Wortindex in unbekannter Fassung');
  }
  return [
    for (final e in (roh['karten'] as List?) ?? const [])
      (e as Map).cast<String, dynamic>(),
  ];
}

/// Dateien des Index (wie von [vokabIndexBauen]) → alle Einträge, sortiert.
/// Wirft [FormatException], wenn die Liste ein Stück nennt, das fehlt.
List<Map<String, dynamic>> vokabIndexLesen(Map<String, String> dateien) {
  final liste = dateien[vokabIndexStueckeDatei];
  if (liste == null) {
    throw const FormatException('Wortindex ohne Stückliste');
  }
  return vokabIndexZusammen([
    for (final d in vokabIndexStueckeLesen(liste))
      vokabIndexStueckLesen(dateien[d] ??
          (throw FormatException('Wortindex-Stück fehlt: $d'))),
  ]);
}

// ── L.1a: Wächter für veröffentlichte ids ─────────────────────────────────
//
// Der Leitner-Stand, die Listen und die Notizen der Nutzer zeigen auf
// Archivkarten über deren Text-id (`adjektiv_stolz`). Verschwindet eine
// veröffentlichte id — gelöscht oder umbenannt —, bleibt beim Nutzer eine
// Karte ohne Wort zurück. Regel: **eine veröffentlichte id bleibt für immer.**

/// Alle ids eines Index-Textes — eines Stücks oder der einen Datei der
/// älteren Ablage ([vokabIndexAltPfad]); beide tragen die Liste `karten`.
/// Bewusst OHNE Versionsprüfung: der Vergleich
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

/// Alle ids eines Index aus seinen Dateien. [holen] liefert den Text eines
/// Asset-Pfads oder `null`, wenn es die Datei nicht gibt (HTTP 404); jeder
/// andere Fehler gehört als Ausnahme nach oben.
///
/// Liest die Ablage in Stücken; gibt es deren Liste nicht, die ältere Ablage
/// in EINER Datei ([vokabIndexAltPfad]) — so vergleicht der Wächter auch
/// gegen eine Seite, die noch vor der Aufteilung veröffentlicht wurde.
/// Wirft [FormatException], wenn keines von beiden da ist oder ein genanntes
/// Stück fehlt: lieber rot als „nichts veröffentlicht, alles erlaubt".
Future<Set<String>> vokabIndexIdsHolen(
    Future<String?> Function(String assetPfad) holen) async {
  final liste = await holen(vokabIndexStueckeDatei);
  if (liste == null) {
    final alt = await holen(vokabIndexAltPfad);
    if (alt == null) {
      throw const FormatException(
          'Kein Wortindex gefunden (weder in Stücken noch als eine Datei)');
    }
    return vokabIndexIds(alt);
  }
  final ids = <String>{};
  for (final datei in vokabIndexStueckNamen(liste)) {
    final text = await holen(datei);
    if (text == null) {
      throw FormatException('Wortindex-Stück fehlt: $datei');
    }
    ids.addAll(vokabIndexIds(text));
  }
  return ids;
}
