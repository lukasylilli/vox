// FILE: lib/features/vokabular/data/vokab_schema.dart
// PURPOSE: Schema 3.0 des SUPER-PROMPT (WORT-KONVERTER) — EINE Quelle für
//          App, Tests und tool/vokabular_import.dart (فاز V, Stufe ۵).
//          Reines Dart (kein Flutter-Import!), sonst kann das CLI-Tool es nicht laden.
//          Aufgaben: ID-Regel 5 · Batch-Parsen (Array 1–10, tolerant gegen
//          Code-Fences) · Validierung + Normalisierung mit Fehler/Warnung-Report.
//          Prinzip: fatale Fehler → Karte wird NIE geschrieben; Reparierbares
//          (falsche id, gespeichertes Perfekt, box≠1) wird normalisiert + gewarnt.
import 'dart:convert';

const vokabWortarten = {
  'nomen', 'verb', 'adjektiv', 'artikel', 'pronomen',
  'numerale', 'praeposition', 'konjunktion', 'adverb', 'partikel',
};
const vokabNiveaus = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

/// Wortarten, bei denen wortnetz = null / < 5 Einträge erlaubt ist (Regel 13).
const _wortnetzOptional = {'artikel', 'pronomen', 'partikel'};

/// Pflichtfelder in details je Wortart (TEIL 2) — fehlt eins → Warnung.
const _detailPflicht = <String, Set<String>>{
  'nomen': {'genus', 'plural', 'deklinationstyp', 'zaehlbar'},
  'verb': {'trennbar', 'regelmaessig', 'hilfsverb', 'reflexiv', 'stammformen',
      'konjugation'},
  'adjektiv': {'steigerung', 'steigerung_regelmaessig', 'gebrauch'},
  'artikel': {'typ', 'deklination'},
  'pronomen': {'untertyp', 'deklination'},
  'numerale': {'untertyp', 'deklinierbar'},
  'praeposition': {'kasus', 'bedeutungen'},
  'konjunktion': {'untertyp', 'wortstellung', 'bedeutungskategorie'},
  'adverb': {'untertyp', 'position', 'steigerbar'},
  'partikel': {'untertyp', 'funktion', 'register'},
};

/// ID-Regel 5: wortart_lemma, Kleinbuchstaben, ä→ae ö→oe ü→ue ß→ss;
/// Nomen ohne Artikel. ('nomen','der Kühlschrank') → 'nomen_kuehlschrank'.
String vokabId(String wortart, String wort) {
  var lemma = wort.trim();
  final teile = lemma.split(' ');
  if (teile.length > 1 &&
      const {'der', 'die', 'das'}.contains(teile.first.toLowerCase())) {
    lemma = teile.sublist(1).join(' ');
  }
  lemma = lemma
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(' ', '_');
  return '${wortart}_$lemma';
}

/// Konverter-Output → Liste roher Karten. Tolerant: entfernt Code-Fences
/// (Regel 1 verbietet sie, LLMs setzen sie trotzdem), akzeptiert auch ein
/// einzelnes Objekt statt Array. Wirft FormatException bei kaputtem JSON.
List<Map<String, dynamic>> vokabParseBatch(String input) {
  var s = input.trim();
  if (s.startsWith('```')) {
    s = s.replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '');
    if (s.endsWith('```')) s = s.substring(0, s.length - 3);
    s = s.trim();
  }
  final decoded = jsonDecode(s);
  final list = decoded is List ? decoded : [decoded];
  return [
    for (final e in list)
      if (e is Map<String, dynamic>)
        e
      else
        throw const FormatException('Eintrag ist kein JSON-Objekt'),
  ];
}

/// Ergebnis der Prüfung EINER Karte.
class VokabPruefung {
  /// Normalisierte Karte — null bei fatalen Fehlern (nie schreiben!).
  final Map<String, dynamic>? karte;
  final List<String> fehler;
  final List<String> warnungen;
  const VokabPruefung(this.karte, this.fehler, this.warnungen);

  bool get ok => karte != null;
}

/// Validiert + normalisiert eine rohe Karte gegen Schema 3.0.
VokabPruefung vokabPruefeKarte(Map<String, dynamic> roh) {
  final fehler = <String>[];
  final warnungen = <String>[];
  // Kopie — Eingabe nie mutieren.
  final karte = jsonDecode(jsonEncode(roh)) as Map<String, dynamic>;

  final wort = karte['wort'];
  final wortart = karte['wortart'];
  final label = (wort is String && wort.isNotEmpty) ? wort : '<ohne wort>';

  // ── fatale Prüfungen ──
  if (wort is! String || wort.trim().isEmpty) {
    fehler.add('[$label] "wort" fehlt oder leer');
  }
  if (wortart is! String || !vokabWortarten.contains(wortart)) {
    fehler.add('[$label] "wortart" ungültig: $wortart');
  }
  final ueb = karte['uebersetzung'];
  if (ueb is! Map ||
      (ueb['fa'] as List?)?.isNotEmpty != true ||
      (ueb['en'] as List?)?.isNotEmpty != true) {
    fehler.add('[$label] "uebersetzung" braucht nicht-leere fa- UND en-Liste');
  }
  if (!vokabNiveaus.contains(karte['niveau'])) {
    fehler.add('[$label] "niveau" ungültig: ${karte['niveau']}');
  }
  final details = karte['details'];
  if (details is! Map) {
    fehler.add('[$label] "details" fehlt oder ist kein Objekt');
  }
  if (fehler.isNotEmpty) return VokabPruefung(null, fehler, warnungen);
  wortart as String;
  wort as String;
  details as Map;

  // ── Normalisierung + Warnungen ──
  if (karte['schema'] != '3.0') {
    warnungen.add('[$label] schema "${karte['schema']}" ≠ "3.0" — gesetzt');
    karte['schema'] = '3.0';
  }
  final abgeleitet = vokabId(wortart, wort);
  if (karte['id'] != abgeleitet) {
    warnungen.add('[$label] id "${karte['id']}" → korrigiert zu "$abgeleitet"');
    karte['id'] = abgeleitet;
  }
  if (karte['box'] != 1) {
    warnungen.add('[$label] box=${karte['box']} → 1 gesetzt');
    karte['box'] = 1;
  }
  if (karte['nextReviewDate'] != null) {
    warnungen.add('[$label] nextReviewDate → null gesetzt');
    karte['nextReviewDate'] = null;
  }

  // Beispiele (Regel 9): der Prompt erzeugt genau 2; weitere Beispiele, die
  // Lukas ausdrücklich ergänzt (z. B. adjektiv_arisch, 2026-09-25), sind
  // erlaubt — Beispiele werden nur erweitert, nie gekürzt. Weniger als 2 ⇒
  // Warnung. Zielwort muss in JEDEM Satz vorkommen.
  final beispiele = (karte['beispiele'] as List?) ?? const [];
  if (beispiele.length < 2) {
    warnungen.add('[$label] ${beispiele.length} Beispiele statt 2');
  }
  final stamm = _lueckenStamm(wortart, wort);
  for (final b in beispiele) {
    final satz = (b as Map)['satz'] as String? ?? '';
    if (satz.isEmpty) {
      warnungen.add('[$label] Beispiel ohne satz');
    } else if (stamm.length >= 3 &&
        !satz.toLowerCase().contains(stamm)) {
      warnungen.add(
          '[$label] Zielwort nicht erkennbar im Beispiel: "$satz" (Lückentext!)');
    }
  }

  // Details: Pflichtfelder + verbotene abgeleitete Formen (Regel 7).
  for (final key in _detailPflicht[wortart] ?? const <String>{}) {
    if (!details.containsKey(key)) {
      warnungen.add('[$label] details.$key fehlt');
    }
  }
  if (wortart == 'verb') {
    final konj = details['konjugation'];
    if (konj is Map && konj.containsKey('perfekt')) {
      warnungen.add('[$label] konjugation.perfekt entfernt (App baut es)');
      konj.remove('perfekt');
    }
  }
  if (wortart == 'nomen' && details.containsKey('genitiv')) {
    warnungen.add('[$label] details.genitiv entfernt (App leitet ihn ab)');
    details.remove('genitiv');
  }

  // Etymologie (Regel 12): zweisprachig {fa, en} — sonst sieht z. B. der
  // EN-Modus persische Glossen. String = altes Format (nur Warnung).
  final ety = karte['etymologie'];
  if (ety is String) {
    warnungen.add(
        '[$label] etymologie einsprachig (String) — {fa, en} erwartet');
  } else if (ety != null &&
      (ety is! Map || ety['fa'] is! String || ety['en'] is! String)) {
    warnungen.add('[$label] etymologie ungültig — {fa, en} oder null erwartet');
  }

  // Wortnetz (Regel 13): genau 5 Verweise mit id_ref; bei
  // artikel/pronomen/partikel darf es null / kürzer sein.
  final netz = karte['wortnetz'];
  if (netz == null) {
    if (!_wortnetzOptional.contains(wortart)) {
      warnungen.add('[$label] wortnetz fehlt');
    }
  } else if (netz is Map) {
    final woerter = (netz['woerter'] as List?) ?? const [];
    if (woerter.length != 5 && !_wortnetzOptional.contains(wortart)) {
      warnungen.add('[$label] wortnetz hat ${woerter.length} statt 5 Wörter');
    }
    for (final w in woerter) {
      final wMap = w as Map;
      final wWortart = wMap['wortart'] as String? ?? '';
      final wWort = wMap['wort'] as String? ?? '';
      final ref = vokabId(wWortart, wWort);
      if (wMap['id_ref'] != ref) {
        warnungen.add(
            '[$label] wortnetz "$wWort": id_ref "${wMap['id_ref']}" → "$ref"');
        wMap['id_ref'] = ref;
      }
    }
  }

  return VokabPruefung(karte, fehler, warnungen);
}

/// Stamm fürs Zielwort-im-Satz-Matching: Artikel weg, bei Verben
/// Infinitivendung -en/-n weg, klein. Heuristik — nur für Warnungen.
String _lueckenStamm(String wortart, String wort) {
  var lemma = wort.trim();
  final teile = lemma.split(' ');
  if (teile.length > 1 &&
      const {'der', 'die', 'das'}.contains(teile.first.toLowerCase())) {
    lemma = teile.sublist(1).join(' ');
  }
  lemma = lemma.toLowerCase();
  if (wortart == 'verb') {
    if (lemma.endsWith('en')) {
      lemma = lemma.substring(0, lemma.length - 2);
    } else if (lemma.endsWith('n')) {
      lemma = lemma.substring(0, lemma.length - 1);
    }
  }
  return lemma;
}
