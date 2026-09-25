// FILE: lib/features/pruefungen/controllers/pruefungs_ergebnisse_controller.dart
// PHASE: فاز T, Schritt T.1 (2026-09-25)
// PURPOSE: Die gespeicherten Testergebnisse dieses Nutzers — lesen und EIN
//          neues hinzufügen. Jeder Test (heute der Grammatik-Niveau-Test,
//          später jeder Simulator und der VOX-Einstufungstest) speichert über
//          [PruefungsErgebnisseNotifier.merken]. Später lesen daraus: die
//          Verlaufsliste der Tests, die Medaillen (T.10) und — nur für den
//          VOX-Einstufungstest — der Lernpfad.
//
// ⚠️ Ablage: im Browser (SharedPreferences, `kPruefungenKey`), von dort in
//    Sicherungsdatei und Konto-Abgleich (Vertrag Fassung 5). Nie löschen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/pruefungs_ergebnis.dart';
import '../../../core/backup/user_state_repository.dart';

class PruefungsErgebnisseNotifier
    extends AsyncNotifier<List<PruefungsErgebnis>> {
  @override
  Future<List<PruefungsErgebnis>> build() async =>
      _geordnet(pruefungenLesen(await SharedPreferences.getInstance()));

  /// Speichert ein abgeschlossenes Ergebnis. Scheitert das Speichern, bleibt
  /// der Test trotzdem gültig angezeigt — das Ergebnis fehlt dann nur im
  /// Verlauf (lieber das als ein Absturz am Testende).
  Future<void> merken(PruefungsErgebnis ergebnis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await pruefungMerken(prefs, ergebnis);
      state = AsyncData(_geordnet(pruefungenLesen(prefs)));
    } catch (_) {
      // bewusst still — siehe oben
    }
  }

  /// Neueste zuerst.
  static List<PruefungsErgebnis> _geordnet(Map<String, PruefungsErgebnis> m) =>
      m.values.toList()..sort((a, b) => b.am.compareTo(a.am));
}

final pruefungsErgebnisseProvider = AsyncNotifierProvider<
    PruefungsErgebnisseNotifier,
    List<PruefungsErgebnis>>(PruefungsErgebnisseNotifier.new);
