// FILE: lib/core/backup/cloud_abgleich.dart
// PHASE: فاز S, S.3 Schritt 3 (2026-09-15)
// PURPOSE: Abgleich des Nutzerzustands mit der Kopie auf dem Server —
//          holen → zusammenführen → nur bei Änderung hochladen.
//
// ⚠️ Kennt KEIN Supabase. Der Server steckt hinter [CloudAblage]; die echte
//    Fassung liegt in `core/services/cloud_ablage_supabase.dart`. Dadurch ist
//    der ganze Ablauf ohne Netz prüfbar (test/cloud_abgleich_test.dart).
//
// WARUM ANDERS ALS ROOT-IN: Root-in überschreibt beim Wiederherstellen und
// fragt deshalb vorher nach. VOX führt zusammen („höchstes Fach gewinnt",
// Entfernungen über Mitgliedschaften, S.5) — dabei geht nichts verloren, was
// der Nutzer nicht selbst entfernt hat. Deshalb ist das hier ein echter
// Abgleich in beide Richtungen, ohne Rückfrage.
//
// ⚠️ Der Server ist nie das Zuhause: Die App liest immer aus dem Browser.
//    Scheitert der Abgleich, bleibt alles lokal unverändert.
import 'dart:convert';

import 'nutzer_zustand.dart';
import 'user_state_repository.dart';

/// Was auf dem Server liegt.
class CloudStand {
  final Map<String, dynamic> payload;
  final int version;
  final DateTime? aktualisiertAm; // Zeit des SERVERS, nicht des Geräts

  const CloudStand({
    required this.payload,
    required this.version,
    this.aktualisiertAm,
  });
}

/// Der Server — austauschbar, damit Tests ohne Netz laufen.
abstract class CloudAblage {
  /// Konfiguriert UND jemand angemeldet.
  bool get verfuegbar;

  /// `null` = auf dem Server liegt (noch) nichts.
  Future<CloudStand?> holen();

  Future<void> ablegen(Map<String, dynamic> payload, int version);

  /// Zeitpunkt der letzten Ablage laut Server.
  Future<DateTime?> zuletzt();
}

enum CloudStatus {
  /// Geschafft (auch: es gab nichts zu tun).
  ok,

  /// Kein Server konfiguriert oder niemand angemeldet — kein Fehler.
  nichtVerfuegbar,

  /// Server nicht erreichbar, abgewiesen oder unlesbare Daten.
  fehlgeschlagen,

  /// Die Kopie stammt aus einer NEUEREN App-Fassung. ⚠️ Dann wird weder
  /// eingespielt noch hochgeladen — Hochladen würde den neueren Stand mit
  /// einem älteren Format überschreiben.
  zuNeu,
}

class AbgleichErgebnis {
  final CloudStatus status;

  /// Letzte Ablage laut Server (sofern bekannt).
  final DateTime? zeitpunkt;

  /// Hat der Abgleich den Stand auf DIESEM Gerät verändert? Dann muss die
  /// Oberfläche neu laden.
  final bool lokalGeaendert;

  const AbgleichErgebnis(this.status,
      {this.zeitpunkt, this.lokalGeaendert = false});
}

class CloudAbgleich {
  const CloudAbgleich(this._repo, this._ablage);

  final UserStateRepository _repo;
  final CloudAblage _ablage;

  Future<AbgleichErgebnis> abgleichen() async {
    if (!_ablage.verfuegbar) {
      return const AbgleichErgebnis(CloudStatus.nichtVerfuegbar);
    }
    try {
      final fern = await _ablage.holen();
      if (fern != null && fern.version > nutzerZustandVersion) {
        return const AbgleichErgebnis(CloudStatus.zuNeu);
      }

      final lokal = await _repo.lesen();
      var stand = lokal;
      var lokalGeaendert = false;
      if (fern != null) {
        final eingehend = NutzerZustand.vonJson(fern.payload);
        final zusammen = lokal.zusammenfuehren(eingehend);
        if (!gleich(zusammen.toJson(), lokal.toJson())) {
          stand = await _repo.anwenden(eingehend);
          lokalGeaendert = true;
        }
      }

      // Nichts auf dem Server und nichts auf dem Gerät: nichts zu sichern.
      if (fern == null && stand.istLeer) {
        return AbgleichErgebnis(CloudStatus.ok,
            lokalGeaendert: lokalGeaendert);
      }
      // Server kennt schon genau diesen Stand: nicht erneut hochladen.
      if (fern != null && gleich(fern.payload, stand.toJson())) {
        return AbgleichErgebnis(CloudStatus.ok,
            zeitpunkt: fern.aktualisiertAm, lokalGeaendert: lokalGeaendert);
      }

      await _ablage.ablegen(stand.toJson(), nutzerZustandVersion);
      return AbgleichErgebnis(CloudStatus.ok,
          zeitpunkt: await _ablage.zuletzt(), lokalGeaendert: lokalGeaendert);
    } catch (_) {
      // Stumm und folgenlos: der lokale Stand ist nicht berührt worden, oder
      // `anwenden` ist vollständig gelaufen (es schreibt nur Zusammengeführtes).
      return const AbgleichErgebnis(CloudStatus.fehlgeschlagen);
    }
  }

  /// Inhaltsgleichheit zweier JSON-Stände, unabhängig von der Reihenfolge der
  /// Schlüssel (der Server legt `jsonb` mit eigener Schlüsselfolge ab).
  static bool gleich(Object? a, Object? b) =>
      jsonEncode(_geordnet(a)) == jsonEncode(_geordnet(b));

  static Object? _geordnet(Object? wert) {
    if (wert is Map) {
      final schluessel = wert.keys.map((k) => '$k').toList()..sort();
      return {for (final k in schluessel) k: _geordnet(wert[k])};
    }
    if (wert is List) return wert.map(_geordnet).toList();
    return wert;
  }
}
