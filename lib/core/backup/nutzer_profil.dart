// FILE: lib/core/backup/nutzer_profil.dart
// PHASE: فاز P / P.1 (2026-09-20)
// PURPOSE: Die persönlichen Angaben eines Nutzers — Name, Telefonnummer und
//          Adressen — als reiner Dart-Wert, samt Prüfregeln und der Regel,
//          wie zwei Stände zusammengeführt werden.
//
// ⚠️ Reines Dart (kein Flutter, kein drift, keine Ablage) — wie
//    `nutzer_zustand.dart`, zu dessen Vertrag diese Angaben seit Fassung 4
//    gehören. So bleibt alles ohne Browser prüfbar.
//
// ⚠️ **Alles ist freiwillig.** VOX braucht weder Name noch Adresse noch
//    Telefonnummer zum Lernen; die Felder existieren, damit jemand seine
//    Angaben an EINER Stelle pflegen kann. Ein leeres Profil ist der
//    Normalfall.
//
// ⚠️ **Die E-Mail-Adresse steht hier NICHT.** Sie gehört dem Anmeldebestand
//    (`auth.users`, geteilt mit Root-in) und wird dort geändert — nie zweimal
//    gespeichert.
//
// ⚠️ **Fehler sind sprachneutral** ([ProfilFehler]), wie `AuthIssue` und
//    `SicherungFehler`: Übersetzt wird in der Oberfläche über `AppL10n`.
import 'dart:convert';

const int profilMaxAdressen = 5;
const int profilMaxName = 80;
const int profilMaxFeld = 120;

/// Warum eine Eingabe nicht gespeichert werden kann.
enum ProfilFehler {
  /// Name länger als [profilMaxName].
  nameZuLang,

  /// Telefonnummer enthält andere Zeichen als Ziffern, +, Leerzeichen,
  /// Klammern, Bindestrich, Punkt, Schrägstrich — oder hat zu wenige/zu
  /// viele Ziffern.
  telefonUngueltig,

  /// Ein Adressfeld ist länger als [profilMaxFeld].
  feldZuLang,

  /// Mehr als [profilMaxAdressen] Adressen.
  zuvieleAdressen,
}

/// Persische und arabisch-indische Ziffern → ASCII. Wer auf einer
/// persischen Tastatur tippt, bekommt sonst „Telefonnummer ungültig".
String normalisiereZiffern(String text) {
  const persisch = '۰۱۲۳۴۵۶۷۸۹';
  const arabisch = '٠١٢٣٤٥٦٧٨٩';
  final b = StringBuffer();
  for (final r in text.runes) {
    final zeichen = String.fromCharCode(r);
    final p = persisch.indexOf(zeichen);
    final a = arabisch.indexOf(zeichen);
    if (p >= 0) {
      b.write(p);
    } else if (a >= 0) {
      b.write(a);
    } else {
      b.write(zeichen);
    }
  }
  return b.toString();
}

final RegExp _telefonMuster = RegExp(r'^\+?[0-9 ()./\-]+$');
final RegExp _keineZiffer = RegExp(r'[^0-9]');

/// Leer ist gültig (freiwillig). Sonst: erlaubte Zeichen und 6–15 Ziffern.
bool telefonGueltig(String eingabe) {
  final s = normalisiereZiffern(eingabe).trim();
  if (s.isEmpty) return true;
  if (!_telefonMuster.hasMatch(s)) return false;
  final ziffern = s.replaceAll(_keineZiffer, '').length;
  return ziffern >= 6 && ziffern <= 15;
}

String _text(Object? wert) => wert is String ? wert : '';

/// Eine Adresse. Alle Felder freiwillig; [bezeichnung] ist ein frei gewählter
/// Name wie „Zuhause" oder „Arbeit".
class ProfilAdresse {
  final String bezeichnung;
  final String strasse;
  final String plz;
  final String ort;
  final String land;

  const ProfilAdresse({
    this.bezeichnung = '',
    this.strasse = '',
    this.plz = '',
    this.ort = '',
    this.land = '',
  });

  /// Eine Adresse ohne Straße, PLZ, Ort und Land ist nichts wert — auch wenn
  /// nur die Bezeichnung dasteht. Solche Einträge werden beim Speichern
  /// verworfen.
  bool get istLeer =>
      strasse.trim().isEmpty &&
      plz.trim().isEmpty &&
      ort.trim().isEmpty &&
      land.trim().isEmpty;

  ProfilAdresse bereinigt() => ProfilAdresse(
        bezeichnung: bezeichnung.trim(),
        strasse: strasse.trim(),
        plz: normalisiereZiffern(plz).trim(),
        ort: ort.trim(),
        land: land.trim(),
      );

  ProfilFehler? pruefen() {
    for (final feld in [bezeichnung, strasse, plz, ort, land]) {
      if (feld.trim().length > profilMaxFeld) return ProfilFehler.feldZuLang;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'bezeichnung': bezeichnung,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'land': land,
      };

  static ProfilAdresse vonJson(Map<String, dynamic> j) => ProfilAdresse(
        bezeichnung: _text(j['bezeichnung']),
        strasse: _text(j['strasse']),
        plz: _text(j['plz']),
        ort: _text(j['ort']),
        land: _text(j['land']),
      );
}

/// Name, Telefonnummer, Adressen — und wann zuletzt etwas geändert wurde.
class NutzerProfil {
  final String name;
  final String telefon;
  final List<ProfilAdresse> adressen;

  /// Zeitpunkt der letzten Änderung (UTC). `null` = nie bearbeitet.
  final DateTime? am;

  const NutzerProfil({
    this.name = '',
    this.telefon = '',
    this.adressen = const [],
    this.am,
  });

  bool get istLeer =>
      name.trim().isEmpty && telefon.trim().isEmpty && adressen.isEmpty;

  NutzerProfil kopie({
    String? name,
    String? telefon,
    List<ProfilAdresse>? adressen,
    DateTime? am,
  }) =>
      NutzerProfil(
        name: name ?? this.name,
        telefon: telefon ?? this.telefon,
        adressen: adressen ?? this.adressen,
        am: am ?? this.am,
      );

  /// Getrimmt, ohne leere Adressen, Ziffern normalisiert — so wird gespeichert.
  NutzerProfil bereinigt() => NutzerProfil(
        name: name.trim(),
        telefon: normalisiereZiffern(telefon).trim(),
        adressen: [
          for (final a in adressen)
            if (!a.istLeer) a.bereinigt(),
        ],
        am: am,
      );

  /// `null` = in Ordnung. Wird auf dem **bereinigten** Wert aufgerufen.
  ProfilFehler? pruefen() {
    if (name.length > profilMaxName) return ProfilFehler.nameZuLang;
    if (!telefonGueltig(telefon)) return ProfilFehler.telefonUngueltig;
    if (adressen.length > profilMaxAdressen) return ProfilFehler.zuvieleAdressen;
    for (final a in adressen) {
      final f = a.pruefen();
      if (f != null) return f;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'telefon': telefon,
        'adressen': adressen.map((a) => a.toJson()).toList(),
        if (am != null) 'am': am!.toUtc().toIso8601String(),
      };

  static NutzerProfil vonJson(Map<String, dynamic> j) => NutzerProfil(
        name: _text(j['name']),
        telefon: _text(j['telefon']),
        adressen: [
          for (final a in (j['adressen'] as List?) ?? const [])
            if (a is Map) ProfilAdresse.vonJson(a.cast<String, dynamic>()),
        ],
        am: j['am'] is String ? DateTime.tryParse(j['am'] as String) : null,
      );

  String zuText() => jsonEncode(toJson());

  /// Liest den in der Ablage gespeicherten Text. `null`, wenn nichts oder
  /// nichts Lesbares dasteht — ein kaputter Eintrag darf den Start nie
  /// verhindern.
  static NutzerProfil? ausText(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final roh = jsonDecode(text);
      if (roh is! Map) return null;
      return vonJson(roh.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  /// Zusammenführen zweier Stände: **der später bearbeitete gewinnt — als
  /// Ganzes.** Anders als beim Lernfortschritt („höchstes Fach gewinnt")
  /// gibt es hier nichts, was nur vorwärts geht; ein Formular, das jemand
  /// zuletzt auf Gerät B ausgefüllt hat, soll nicht mit dem von Gerät A
  /// vermischt werden. Ein leer gespeichertes Profil mit neuerem Zeitpunkt
  /// gewinnt ebenfalls — sonst käme Gelöschtes vom anderen Gerät zurück.
  /// Gleichstand oder keine Zeitangabe ⇒ der eigene Stand.
  static NutzerProfil? spaeteres(NutzerProfil? eigen, NutzerProfil? fremd) {
    if (eigen == null) return fremd;
    if (fremd == null) return eigen;
    final e = eigen.am;
    final f = fremd.am;
    if (f == null) return eigen;
    if (e == null) return fremd;
    return f.isAfter(e) ? fremd : eigen;
  }
}
