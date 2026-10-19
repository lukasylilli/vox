// FILE: lib/features/vokabular/data/vokab_schema.dart
// PURPOSE: Schema 3.0 des SUPER-PROMPT (WORT-KONVERTER) — EINE Quelle für
//          App, Tests und tool/vokabular_import.dart (فاز V, Stufe ۵).
//          Reines Dart (kein Flutter-Import!), sonst kann das CLI-Tool es nicht laden.
//          Aufgaben: ID-Regel 5 · Batch-Parsen (Array 1–10, tolerant gegen
//          Code-Fences) · Validierung + Normalisierung mit Fehler/Warnung-Report.
//          Einordnung (Regel 17, فاز F.5): berufe/anstoessig/zeitlich/ersatz.
//          Prinzip: fatale Fehler → Karte wird NIE geschrieben; Reparierbares
//          (falsche id, gespeichertes Perfekt, box≠1) wird normalisiert + gewarnt.
import 'dart:convert';

import '../../../core/wort/wort_form.dart';
import 'vokab_formen.dart';

const vokabWortarten = {
  'nomen', 'verb', 'adjektiv', 'artikel', 'pronomen',
  'numerale', 'praeposition', 'konjunktion', 'adverb', 'partikel',
};
const vokabNiveaus = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

// ── Einordnung (فاز F.5, Lukas 2026-10-14) — Filter «Berufe»,
//    «Respektlos», «Veraltet» in «Alle Wörter». Prompt-Regel 17.
//    Nur linguistische Angaben; Symbole/Farben der Filter rechnet die App.
//    Unbekannte Werte sind FATAL (ein falsches Etikett ist schlimmer als
//    keins). Fehlt ein Feld ganz, ist das erlaubt (ältere Karten bekommen es
//    in F.7 nachgetragen) — dann steht die Karte einfach in keinem Filter.

/// Berufsfelder (feste Reihenfolge = Reihenfolge im Filter).
const vokabBerufe = [
  'pflege_medizin', // پزشکی و پرستاری
  'it', // IT
  'technik', // برق، مکانیک و تأسیسات
  'bau', // ساختمان
  'gastro_hotel', // رستوران و هتل
  'logistik', // حمل‌ونقل و انبار
  'kinder_bildung', // مهدکودک و آموزش
  'reinigung', // نظافت
  'buero', // اداری
];

/// Stufen von «anstoessig» (Filter «بی‌احترامی»).
const vokabAnstoessigStufen = ['vulgaer', 'abwertend', 'diskriminierend'];

/// Werte von «zeitlich» (Filter «منسوخ»).
const vokabZeitlichWerte = ['veraltend', 'veraltet'];

/// Wortarten, bei denen wortnetz = null / < 5 Einträge erlaubt ist (Regel 13).
const _wortnetzOptional = {'artikel', 'pronomen', 'partikel'};

/// Pflichtfelder in details je Wortart (TEIL 2) — fehlt eins → Warnung.
const _detailPflicht = <String, Set<String>>{
  'nomen': {'genus', 'plural', 'deklinationstyp', 'zaehlbar'},
  'verb': {'trennbar', 'regelmaessig', 'modalverb', 'hilfsverb', 'reflexiv',
      'stammformen', 'konjugation'},
  'adjektiv': {'steigerung', 'steigerung_regelmaessig', 'gebrauch'},
  'artikel': {'typ', 'deklination'},
  'pronomen': {'untertyp', 'deklination'},
  'numerale': {'untertyp', 'deklinierbar'},
  'praeposition': {'kasus', 'bedeutungen'},
  'konjunktion': {'untertyp', 'wortstellung', 'bedeutungskategorie'},
  'adverb': {'untertyp', 'position', 'steigerbar'},
  'partikel': {'untertyp', 'funktion', 'register'},
};

/// Homograph-Kennung (Prompt-Regel 19, Lukas 2026-10-19): gleich
/// geschriebene Wörter derselben Wortart mit eigener Bedeutung bekommen je
/// eine EIGENE Karte. Die häufigste Bedeutung behält die normale id
/// (`nomen_see`), jede weitere hängt eine Kennung an: den Artikel, wenn das
/// Genus sich unterscheidet (die See → `nomen_see_die`), sonst eine Ziffer
/// 2–9 (die Bank «Geldinstitut» → `nomen_bank_2`). So bleiben alle schon
/// veröffentlichten ids und alle id_ref-Verweise auf die Hauptbedeutung gültig.
final vokabHomographMuster = RegExp(r'^(der|die|das|[2-9])$');

/// ID-Regel 5: wortart_lemma, Kleinbuchstaben, ä→ae ö→oe ü→ue ß→ss;
/// Nomen ohne Artikel. ('nomen','der Kühlschrank') → 'nomen_kuehlschrank'.
/// Mit [homograph] (Regel 19): ('nomen','die See', homograph: 'die') →
/// 'nomen_see_die'.
String vokabId(String wortart, String wort, {String? homograph}) {
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
  final h = homograph?.trim().toLowerCase() ?? '';
  return h.isEmpty ? '${wortart}_$lemma' : '${wortart}_${lemma}_$h';
}

/// Eigenname (Prompt-Regel 18, Lukas 2026-09-24/2026-10-19): Städte,
/// Länder, Regionen, Flüsse, Gebirge … bekommen eine KURZE Nomen-Karte —
/// nur IPA, Bedeutung (fa/en) und Artikel/Genus. Keine Beispiele, kein
/// Wortnetz, keine Synonyme/Komposita/Etymologie. Kennzeichen:
/// `details.eigenname == true`.
bool vokabIstEigenname(Map<String, dynamic> karte) {
  final d = karte['details'];
  return karte['wortart'] == 'nomen' && d is Map && d['eigenname'] == true;
}

/// Pflichtfelder in details einer Eigenname-Karte (statt der Nomen-Liste).
const _eigennamePflicht = {'eigenname', 'genus', 'mit_artikel'};

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
  _pruefeEinordnung(karte, label, fehler, warnungen);
  // Regel 19: Homograph-Kennung — falsch ⇒ falsche id ⇒ fatal.
  final homograph = karte['homograph'];
  if (homograph != null) {
    if (homograph is! String || !vokabHomographMuster.hasMatch(homograph)) {
      fehler.add('[$label] "homograph" ungültig: $homograph '
          '(der/die/das oder 2–9)');
    } else if (const {'der', 'die', 'das'}.contains(homograph) &&
        (wortart != 'nomen' ||
            (details is Map && details['genus'] != homograph))) {
      fehler.add('[$label] "homograph" "$homograph" passt nicht zu '
          'wortart/genus — Artikel-Kennung nur bei Nomen mit diesem Genus');
    }
  }
  // Regel 18: Eigenname nur als Nomen; Genus muss sicher sein.
  if (details is Map && details['eigenname'] != null) {
    if (details['eigenname'] != true || wortart != 'nomen') {
      fehler.add('[$label] details.eigenname nur als true bei wortart nomen');
    } else if (!const {'der', 'die', 'das'}.contains(details['genus'])) {
      fehler.add('[$label] Eigenname ohne gültiges genus (der/die/das)');
    }
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
  final abgeleitet =
      vokabId(wortart, wort, homograph: karte['homograph'] as String?);
  final eigenname = vokabIstEigenname(karte);
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
  if (beispiele.length < 2 && !eigenname) {
    warnungen.add('[$label] ${beispiele.length} Beispiele statt 2');
  }
  final stamm = _lueckenStamm(wortart, wort);
  // Verben: der Satz zeigt meist eine KONJUGIERTE Form («ging», «rief … an»)
  // — gilt als erkennbar, wenn ein Wort des Satzes eine Form der Karte ist
  // (dieselbe Formenliste wie die Suche, Regel 16).
  final verbFormen = wortart == 'verb'
      ? {...formenAusKarte(karte), wortSchluessel(wort)}
      : const <String>{};
  bool verbFormImSatz(String satz) {
    final w = satz
        .split(RegExp(r'\s+'))
        .map(wortSchluessel)
        .where((t) => t.isNotEmpty)
        .toList();
    for (final t in w) {
      if (verbFormen.contains(t)) return true;
      for (final p in w) {
        if (p != t && verbFormen.contains('$p$t')) return true;
      }
    }
    return false;
  }

  for (final b in beispiele) {
    final satz = (b as Map)['satz'] as String? ?? '';
    if (satz.isEmpty) {
      warnungen.add('[$label] Beispiel ohne satz');
    } else if (stamm.length >= 3 &&
        !satz.toLowerCase().contains(stamm) &&
        !(wortart == 'verb' && verbFormImSatz(satz))) {
      warnungen.add(
          '[$label] Zielwort nicht erkennbar im Beispiel: "$satz" (Lückentext!)');
    }
  }

  // Details: Pflichtfelder + verbotene abgeleitete Formen (Regel 7).
  for (final key in eigenname
      ? _eigennamePflicht
      : _detailPflicht[wortart] ?? const <String>{}) {
    if (!details.containsKey(key)) {
      warnungen.add('[$label] details.$key fehlt');
    }
  }
  if (eigenname) {
    // Regel 18: «mit_artikel» sagt, ob der Name mit Artikel gebraucht wird
    // (die Schweiz) oder ohne (Aachen) — das Lemma muss dazu passen.
    final mitArtikel = details['mit_artikel'];
    final hatArtikel = wort.trim().toLowerCase().startsWith('${details['genus']} ');
    if (mitArtikel is! bool) {
      warnungen.add('[$label] details.mit_artikel muss true/false sein');
    } else if (mitArtikel != hatArtikel) {
      warnungen.add('[$label] Lemma passt nicht zu mit_artikel=$mitArtikel '
          '(mit Artikel: «die Schweiz», ohne: «Aachen»)');
    }
  }
  if (wortart == 'verb') {
    final konj = details['konjugation'];
    if (konj is Map && konj.containsKey('perfekt')) {
      warnungen.add('[$label] konjugation.perfekt entfernt (App baut es)');
      konj.remove('perfekt');
    }
    // Regel 16 (Lukas 2026-10-11): alle Formen auf einer Karte — die Suche
    // findet nur, was die Karte nennt (vokab_formen.dart).
    if (konj is Map) {
      for (final teil in const [
        'praesens', 'praeteritum', 'konjunktiv1', 'konjunktiv2', 'imperativ',
      ]) {
        if (!konj.containsKey(teil)) {
          warnungen.add('[$label] konjugation.$teil fehlt (Regel 16)');
        }
      }
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
    if (!_wortnetzOptional.contains(wortart) && !eigenname) {
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
      final ref = vokabId(wWortart, wWort,
          homograph: wMap['homograph'] as String?);
      if (wMap['id_ref'] != ref) {
        warnungen.add(
            '[$label] wortnetz "$wWort": id_ref "${wMap['id_ref']}" → "$ref"');
        wMap['id_ref'] = ref;
      }
    }
  }

  return VokabPruefung(karte, fehler, warnungen);
}

/// Regel 17 (فاز F.5): berufe · anstoessig · zeitlich · ersatz.
/// Fehlt ein Feld ⇒ nichts. Unbekannter Wert ⇒ Fehler (fatal).
/// Normalisiert: doppelte Berufe weg (Reihenfolge wie [vokabBerufe]),
/// ersatz.id_ref nach ID-Regel 5.
void _pruefeEinordnung(Map<String, dynamic> karte, String label,
    List<String> fehler, List<String> warnungen) {
  if (karte.containsKey('berufe')) {
    final b = karte['berufe'];
    if (b is! List) {
      fehler.add('[$label] "berufe" muss eine Liste sein');
    } else {
      final unbekannt =
          b.where((x) => x is! String || !vokabBerufe.contains(x)).toList();
      if (unbekannt.isNotEmpty) {
        fehler.add('[$label] "berufe" unbekannt: $unbekannt '
            '(erlaubt: ${vokabBerufe.join(', ')})');
      } else {
        final sauber = [
          for (final x in vokabBerufe)
            if (b.contains(x)) x,
        ];
        if (sauber.length != b.length || !_gleich(sauber, b)) {
          warnungen.add('[$label] berufe sortiert/entdoppelt: $sauber');
          karte['berufe'] = sauber;
        }
      }
    }
  }

  final a = karte['anstoessig'];
  if (a != null) {
    if (a is! Map || !vokabAnstoessigStufen.contains(a['stufe'])) {
      fehler.add('[$label] "anstoessig" ungültig — null oder '
          '{stufe: ${vokabAnstoessigStufen.join('|')}, erklaerung: {fa, en}}');
    } else {
      final e = a['erklaerung'];
      if (e is! Map ||
          e['fa'] is! String ||
          (e['fa'] as String).trim().isEmpty ||
          e['en'] is! String ||
          (e['en'] as String).trim().isEmpty) {
        warnungen.add('[$label] anstoessig.erklaerung braucht fa + en '
            '(warum anstößig, was stattdessen)');
      }
    }
  }

  final z = karte['zeitlich'];
  if (z != null && !vokabZeitlichWerte.contains(z)) {
    fehler.add('[$label] "zeitlich" ungültig: $z '
        '(null | ${vokabZeitlichWerte.join(' | ')})');
  }

  final ersatz = karte['ersatz'];
  if (ersatz != null) {
    if (ersatz is! Map ||
        ersatz['wort'] is! String ||
        (ersatz['wort'] as String).trim().isEmpty ||
        !vokabWortarten.contains(ersatz['wortart'])) {
      fehler.add('[$label] "ersatz" ungültig — null oder '
          '{wort, wortart, uebersetzung: {fa, en}, id_ref}');
    } else {
      final ref = vokabId(ersatz['wortart'] as String, ersatz['wort'] as String,
          homograph: ersatz['homograph'] as String?);
      if (ersatz['id_ref'] != ref) {
        warnungen.add(
            '[$label] ersatz.id_ref "${ersatz['id_ref']}" → "$ref"');
        ersatz['id_ref'] = ref;
      }
      if (a == null && z == null) {
        warnungen.add('[$label] ersatz ohne anstoessig/zeitlich — wozu?');
      }
    }
  } else if (z == 'veraltet') {
    warnungen.add('[$label] zeitlich = veraltet, aber kein ersatz '
        '(heutiges Wort fehlt)');
  }
}

bool _gleich(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
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
