// FILE: lib/features/wortschatz/controllers/altwort_karte_provider.dart
// PHASE: L.4b (2026-09-24)
// PURPOSE: Paarung altes App-Wort ↔ Prompt-Karte für die Oberfläche.
//          Regeln und Logik: ../data/altwort_karte.dart (einzige Quelle).
//          Nutzer: word_detail_screen.dart (alte Seite zeigt die Karte mit),
//          wort_seite_screen.dart (Karte eines alten Worts ⇒ alte Seite),
//          wortschatz_list_screen.dart (nur EINE Zeile je Wort).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vokabular/controllers/vokabular_controller.dart';
import '../data/altwort_karte.dart';
import 'word_controller.dart';

final altwortZuordnungProvider = FutureProvider<AltwortZuordnung>((ref) async {
  final woerter = await ref.watch(allWordsProvider.future);
  final karten = await ref.watch(vokabIndexProvider.future);
  return altwortZuordnen([
    for (final w in woerter)
      AltwortEintrag(
        id: w.id,
        german: w.german,
        wordType: w.wordType,
        ausApp: w.ausApp == true,
        grammarNote: w.grammarNote,
      ),
  ], karten);
});
