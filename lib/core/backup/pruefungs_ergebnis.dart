// FILE: lib/core/backup/pruefungs_ergebnis.dart
// PHASE: فاز T, Schritt T.1 (2026-09-25) — ersetzt G7e
// PURPOSE: Das Ergebnis EINES abgeschlossenen Tests — Grammatik-Niveau-Test
//          heute, später jeder Prüfungssimulator (ÖSD, ÖIF, Goethe, telc, DTZ,
//          Pflege/Medizin, TestDaF) und der eigene VOX-Einstufungstest.
//
// ⚠️ Reines Dart (kein Flutter, keine Ablage) — wie `nutzer_zustand.dart`,
//    zu dessen Vertrag die Ergebnisse seit Fassung 5 gehören.
//
// WARUM SO ALLGEMEIN (Entscheidung Lukas 2026-09-25): Die Testarten wachsen
// noch lange. Jeder künftige Test schreibt denselben Datensatz — nur mit
// eigener [PruefungsErgebnis.art] und eigenen [PruefungsErgebnis.teile].
// Dafür muss sich weder diese Datei noch die Sicherung noch der Konto-
// Abgleich ändern.
//
// REGELN:
//  · Ergebnisse werden **nur hinzugefügt, nie geändert oder gelöscht** —
//    wie der Lernfortschritt im Leitner. Zusammenführen = Vereinigung nach
//    [PruefungsErgebnis.id].
//  · Die id wird beim Speichern EINMAL vergeben (Zufall, geräteunabhängig).
//  · Unbrauchbare Einträge (fremde/kaputte Daten) werden beim Lesen still
//    übergangen — eine Sicherung darf daran nie scheitern.
//  · Richtige Antworten werden hier NIE gespeichert (Entscheidung Lukas: im
//    Prüfungsmodus sieht man sie nie).
//
// WIE EINE ECHTE PRÜFUNG (Entscheidung Lukas 2026-09-25, دور ۸۷):
//  · **Zeit:** Jede Prüfung hat ein Zeitlimit ([zeitLimitSekunden]). Läuft es
//    ab, endet die Prüfung sofort — Unbeantwortetes zählt 0 Punkte;
//    [zeitAbgelaufen] hält fest, dass es so endete.
//  · **Teile getrennt:** Die Punkte jeder Fertigkeit stehen einzeln in
//    [teile] und werden einzeln angezeigt ([teilReihenfolge]).
//  · **Nur als Ganzes:** Eine Prüfung wird immer vollständig abgelegt — nie
//    nur ein Teil (etwa nur Hören). Ein Simulator-Ergebnis enthält deshalb
//    immer ALLE Teile seiner Prüfung ([vollstaendig]).
//  · Das gilt für den **Prüfungsmodus**. Im **Übungsmodus** (Antwort sofort
//    sichtbar) darf man einen einzelnen Teil üben, z. B. nur Hören
//    (Lukas, دور ۸۸).
import 'dart:math' show Random;

/// Bekannte Testarten. Neue Simulatoren fügen hier ihre Kennung hinzu —
/// alte Kennungen werden nie umbenannt (sonst verwaist ihre Geschichte).
const String pruefungsArtGrammatikNiveau = 'grammatik_niveau';

/// Bekannte Teile. Ein Simulator darf eigene Teil-Namen verwenden (z. B. die
/// Modulnamen eines Instituts); diese sind nur die gemeinsamen Fertigkeiten.
const String teilLesen = 'lesen';
const String teilHoeren = 'hoeren';
const String teilSchreiben = 'schreiben';
const String teilSprechen = 'sprechen';
const String teilGrammatik = 'grammatik';
const String teilWortschatz = 'wortschatz';

/// Anzeige-Reihenfolge der Teile — wie auf echten Zeugnissen (Lesen, Hören,
/// Schreiben, Sprechen), danach die übrigen. Unbekannte Teile (Modulnamen
/// eines Instituts) folgen alphabetisch.
const List<String> teilReihenfolge = [
  teilLesen,
  teilHoeren,
  teilSchreiben,
  teilSprechen,
  teilGrammatik,
  teilWortschatz,
];

/// Punkte eines Teils. `num`, weil manche Institute halbe Punkte vergeben.
class PruefungsTeil {
  final num punkte;
  final num maxPunkte;

  const PruefungsTeil({required this.punkte, required this.maxPunkte});

  Map<String, dynamic> toJson() => {'punkte': punkte, 'max': maxPunkte};

  static PruefungsTeil? vonJson(Object? j) {
    if (j is! Map) return null;
    final p = j['punkte'];
    final m = j['max'];
    if (p is! num || m is! num || m <= 0 || p < 0 || p > m) return null;
    return PruefungsTeil(punkte: p, maxPunkte: m);
  }
}

class PruefungsErgebnis {
  /// `pr:#` + 32 Hex-Zeichen — siehe [neuePruefungsId].
  final String id;

  /// Welche Test-Art ([pruefungsArtGrammatikNiveau] …).
  final String art;

  /// Niveau des Tests (`A1` … `C2`), falls er eines hat.
  final String? niveau;

  /// Fassung des Test-INHALTS bzw. seiner Regeln. Ändert sich ein Test
  /// später (mehr Fragen, andere Punkte), steigt sie — alte Ergebnisse
  /// bleiben lesbar und als „ältere Fassung" erkennbar.
  final int fassung;

  /// Ende des Tests (UTC).
  final DateTime am;

  /// Dauer in Sekunden, falls gemessen.
  final int? dauerSekunden;

  /// Zeitlimit der Prüfung in Sekunden (`null` = ohne Limit, z. B. der
  /// Grammatik-Niveau-Test).
  final int? zeitLimitSekunden;

  /// `true` = die Zeit lief ab und beendete die Prüfung (nicht alles war
  /// beantwortet). Nur gespeichert, wenn `true`.
  final bool zeitAbgelaufen;

  final num punkte;
  final num maxPunkte;

  /// `null` = der Test kennt keine Bestehensgrenze.
  final bool? bestanden;

  /// Teil → Punkte (z. B. `lesen`, `hoeren` oder Modulnamen eines Instituts).
  final Map<String, PruefungsTeil> teile;

  const PruefungsErgebnis({
    required this.id,
    required this.art,
    this.niveau,
    this.fassung = 1,
    required this.am,
    this.dauerSekunden,
    this.zeitLimitSekunden,
    this.zeitAbgelaufen = false,
    required this.punkte,
    required this.maxPunkte,
    this.bestanden,
    this.teile = const {},
  });

  /// Anteil 0…1.
  double get anteil => maxPunkte <= 0 ? 0 : (punkte / maxPunkte).toDouble();

  /// Teile in Anzeige-Reihenfolge ([teilReihenfolge], dann alphabetisch).
  List<MapEntry<String, PruefungsTeil>> get teileGeordnet {
    int rang(String k) {
      final i = teilReihenfolge.indexOf(k);
      return i < 0 ? teilReihenfolge.length : i;
    }

    return teile.entries.toList()
      ..sort((a, b) {
        final r = rang(a.key).compareTo(rang(b.key));
        return r != 0 ? r : a.key.compareTo(b.key);
      });
  }

  /// Enthält das Ergebnis jeden der [erwartet]en Teile? Ein Simulator prüft
  /// damit vor dem Speichern, dass die Prüfung als Ganzes abgelegt wurde.
  bool vollstaendig(Iterable<String> erwartet) =>
      erwartet.every(teile.containsKey);

  /// Schlüssel geordnet, optionale Felder nur wenn gesetzt — derselbe Inhalt
  /// ergibt immer denselben Text (der Konto-Abgleich vergleicht Text).
  Map<String, dynamic> toJson() {
    final teilSchluessel = teile.keys.toList()..sort();
    return {
      'id': id,
      'art': art,
      if (niveau != null) 'niveau': niveau,
      'fassung': fassung,
      'am': am.toUtc().toIso8601String(),
      if (dauerSekunden != null) 'dauer': dauerSekunden,
      if (zeitLimitSekunden != null) 'limit': zeitLimitSekunden,
      if (zeitAbgelaufen) 'zeitAbgelaufen': true,
      'punkte': punkte,
      'max': maxPunkte,
      if (bestanden != null) 'bestanden': bestanden,
      if (teile.isNotEmpty)
        'teile': {for (final k in teilSchluessel) k: teile[k]!.toJson()},
    };
  }

  /// `null` statt Ausnahme, wenn der Eintrag unbrauchbar ist.
  static PruefungsErgebnis? vonJson(Object? roh) {
    if (roh is! Map) return null;
    final j = roh.cast<String, dynamic>();
    final id = j['id'];
    final art = j['art'];
    final am = j['am'] is String ? DateTime.tryParse(j['am'] as String) : null;
    final punkte = j['punkte'];
    final max = j['max'];
    if (id is! String || id.isEmpty || art is! String || art.isEmpty) {
      return null;
    }
    if (am == null || punkte is! num || max is! num) return null;
    if (max <= 0 || punkte < 0 || punkte > max) return null;
    final niveau = j['niveau'];
    final fassung = j['fassung'];
    final dauer = j['dauer'];
    final limit = j['limit'];
    final bestanden = j['bestanden'];
    final teileRoh = j['teile'];
    final teile = <String, PruefungsTeil>{};
    if (teileRoh is Map) {
      teileRoh.forEach((k, v) {
        final t = PruefungsTeil.vonJson(v);
        if (k is String && t != null) teile[k] = t;
      });
    }
    return PruefungsErgebnis(
      id: id,
      art: art,
      niveau: niveau is String ? niveau : null,
      fassung: fassung is num && fassung >= 1 ? fassung.toInt() : 1,
      am: am.toUtc(),
      dauerSekunden: dauer is num && dauer >= 0 ? dauer.toInt() : null,
      zeitLimitSekunden: limit is num && limit > 0 ? limit.toInt() : null,
      zeitAbgelaufen: j['zeitAbgelaufen'] == true,
      punkte: punkte,
      maxPunkte: max,
      bestanden: bestanden is bool ? bestanden : null,
      teile: teile,
    );
  }

  /// Liest eine Liste; Unbrauchbares fällt still heraus.
  static Map<String, PruefungsErgebnis> listeLesen(Object? roh) => {
        if (roh is List)
          for (final e in roh)
            if (vonJson(e) case final PruefungsErgebnis p) p.id: p,
      };

  /// Geordnet nach id — gleicher Inhalt, gleicher Text.
  static List<Map<String, dynamic>> listeSchreiben(
          Map<String, PruefungsErgebnis> ergebnisse) =>
      (ergebnisse.keys.toList()..sort())
          .map((k) => ergebnisse[k]!.toJson())
          .toList();

  /// Vereinigung nach id. Gleiche id = dasselbe Ergebnis (nie geändert) ⇒
  /// der eigene Eintrag bleibt.
  static Map<String, PruefungsErgebnis> vereinigen(
          Map<String, PruefungsErgebnis> eigen,
          Map<String, PruefungsErgebnis> fremd) =>
      {...fremd, ...eigen};
}

/// Neue geräteübergreifende id: `pr:#` + 32 Hex-Zeichen (128 Bit Zufall).
String neuePruefungsId([Random? zufall]) {
  final r = zufall ?? Random.secure();
  final hex = StringBuffer();
  for (var i = 0; i < 16; i++) {
    hex.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return 'pr:#$hex';
}
