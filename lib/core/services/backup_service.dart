// FILE: lib/core/services/backup_service.dart
// PHASE: فاز S, Schritt S.2 (2026-09-15) — war bis dahin ein leerer Stub.
// PURPOSE: Sicherung als Datei schreiben und wieder einlesen.
//
// Aufteilung mit Absicht:
//   · core/backup/nutzer_zustand.dart      — was gesichert wird (Vertrag)
//   · core/backup/user_state_repository.dart — wo es liegt (Fassade)
//   · core/backup/datei_io.dart            — Datei öffnen/ablegen (Browser)
//   · diese Datei                          — nur das Zusammenspiel
// Dadurch bleibt alles außer der Dateiauswahl ohne Browser prüfbar.
//
// ⚠️ Einspielen ist IMMER ein Zusammenführen, nie ein Ersetzen: `anwenden()`
//    wendet „höchstes Fach gewinnt" an und löscht nie etwas. Eine
//    Wiederherstellung darf den Nutzer nie Fortschritt kosten — auch dann
//    nicht, wenn er versehentlich eine alte Datei wählt.
import '../backup/datei_io.dart';
import '../backup/nutzer_zustand.dart';
import '../backup/user_state_repository.dart';

/// Ergebnis eines Einspielvorgangs — für die Rückmeldung an den Nutzer.
class EinspielErgebnis {
  /// Der Nutzer hat die Dateiauswahl abgebrochen.
  final bool abgebrochen;

  /// Wann die eingelesene Sicherung erstellt wurde.
  final DateTime? erstelltAm;

  /// Wie viele Wörter danach im Leitner-Stapel liegen.
  final int leitnerWoerter;

  /// Wie viele eigene Wörter danach vorhanden sind.
  final int eigeneWoerter;

  const EinspielErgebnis({
    this.abgebrochen = false,
    this.erstelltAm,
    this.leitnerWoerter = 0,
    this.eigeneWoerter = 0,
  });

  const EinspielErgebnis.abbruch() : this(abgebrochen: true);
}

class BackupService {
  const BackupService(this._repo);

  final UserStateRepository _repo;

  /// Dateiname mit Datum, damit mehrere Sicherungen nebeneinander liegen
  /// können, ohne sich zu überschreiben.
  static String dateiname(DateTime jetzt) =>
      'vox-sicherung-${jetzt.toIso8601String().split('T').first}.json';

  /// Schreibt den aktuellen Zustand als Datei zum Nutzer.
  /// Gibt den Dateinamen zurück, damit die Oberfläche ihn nennen kann.
  Future<String> exportieren({DateTime? jetzt}) async {
    final zeit = jetzt ?? DateTime.now();
    final text = sicherungSchreiben(await _repo.lesen(), jetzt: zeit);
    final name = dateiname(zeit);
    await textDateiSpeichern(name, text);
    return name;
  }

  /// Lässt den Nutzer eine Datei wählen und führt sie mit dem aktuellen
  /// Stand zusammen.
  ///
  /// Wirft [SicherungFehler], wenn die Datei keine brauchbare VOX-Sicherung
  /// ist — die Meldung darin ist bewusst so formuliert, dass sie einem
  /// Nutzer gezeigt werden kann.
  Future<EinspielErgebnis> einspielen() async {
    final text = await textDateiWaehlen();
    if (text == null) return const EinspielErgebnis.abbruch();

    final sicherung = sicherungLesen(text); // wirft bei Unbrauchbarem
    final zusammen = await _repo.anwenden(sicherung.zustand);

    return EinspielErgebnis(
      erstelltAm: sicherung.erstelltAm,
      leitnerWoerter: zusammen.leitner.length,
      eigeneWoerter: zusammen.eigeneWoerter.length,
    );
  }
}
