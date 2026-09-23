// FILE: lib/features/leitner/controllers/leitner_controller.dart
// DEPS: leitner_dao.dart, user_state_repository.dart, databaseProvider
// PURPOSE: Riverpod providers for Leitner — due cards, box counts, add/remove
//
// B-13 (2026-09-23): Der Leitner-Stapel hat ZWEI Quellen, und der
// Leitner-Bereich zeigt beide zusammen:
//   · App-Wörter (alte Datenbank, `Words`)  → Tabelle `LeitnerCards`
//     (int-id; `LeitnerAddButton`, `LeitnerDao`)
//   · Archivkarten (Wort-Prompt, assets/vocab) → Tabelle `ArchivLeitner`
//     (String-id; `WortActions` → vokabular_user_state → UserStateRepository)
// Vorher las dieser Bereich nur `LeitnerCards` — ein Wort aus „Wortschatz"
// (Archivkarte) landete zwar im Stapel, der Leitner-Bereich meldete aber
// „keine Karten". Die zwei Tabellen bleiben getrennt (Sicherung S.2, Konto
// S.3 und die Mitgliedschaften S.5 hängen an ihnen); zusammengeführt wird
// NUR hier, beim Lesen — [leitnerEintraegeProvider] ist die einzige Liste,
// aus der Zähler, Fächer, Statistik und Wiederholung lesen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/nutzer_zustand.dart' show LeitnerStand;
import '../../../core/backup/user_state_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/leitner_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final leitnerDaoProvider = Provider<LeitnerDao>((ref) =>
    LeitnerDao(ref.watch(databaseProvider)));

// ── Ein Eintrag im Stapel, egal aus welcher Quelle ────────────────────────────

sealed class LeitnerEintrag {
  const LeitnerEintrag();

  /// Fach 1–5.
  int get fach;

  /// Ab wann die Karte wieder fällig ist.
  DateTime get faellig;

  bool istFaellig(DateTime jetzt) => !faellig.isAfter(jetzt);
}

/// Wort aus der alten Datenbank (`Words`) — Karte in `LeitnerCards`.
final class AppWortEintrag extends LeitnerEintrag {
  const AppWortEintrag(this.karte);
  final LeitnerCard karte;

  @override
  int get fach => karte.boxNumber;
  @override
  DateTime get faellig => karte.nextReview;
}

/// Archivkarte (assets/vocab, Wort-Prompt) — Eintrag in `ArchivLeitner`.
final class ArchivEintrag extends LeitnerEintrag {
  const ArchivEintrag(this.stand);
  final LeitnerStand stand;

  String get wortId => stand.wortId;
  @override
  int get fach => stand.fach;
  // `nextReview` ist in der Tabelle Pflicht; null käme nur aus einem
  // fremden Stand — dann gilt die Karte als sofort fällig.
  @override
  DateTime get faellig =>
      stand.naechsteWiederholung ?? DateTime.fromMillisecondsSinceEpoch(0);
}

// ── Streams ───────────────────────────────────────────────────────────────────

final allLeitnerCardsProvider = StreamProvider<List<LeitnerCard>>((ref) =>
    ref.watch(leitnerDaoProvider).watchAll());

/// Der Archiv-Stapel — gelesen über die Fassade, die als einzige die
/// Tabelle kennt.
final archivLeitnerProvider =
    StreamProvider<List<LeitnerStand>>((ref) async* {
  final db = ref.watch(databaseProvider);
  final prefs = await SharedPreferences.getInstance();
  yield* UserStateRepository(db, prefs).archivLeitnerBeobachten();
});

/// DER Stapel: beide Quellen zusammen, dringendste zuerst (Fach, dann
/// Fälligkeit). Einzige Liste für alles im Leitner-Bereich.
final leitnerEintraegeProvider =
    FutureProvider<List<LeitnerEintrag>>((ref) async {
  final appWoerter = await ref.watch(allLeitnerCardsProvider.future);
  final archiv = await ref.watch(archivLeitnerProvider.future);
  return [
    for (final k in appWoerter) AppWortEintrag(k),
    for (final s in archiv) ArchivEintrag(s),
  ]..sort((a, b) {
      final f = a.fach.compareTo(b.fach);
      return f != 0 ? f : a.faellig.compareTo(b.faellig);
    });
});

// ── Abgeleitete Zahlen ────────────────────────────────────────────────────────

/// Fach → Anzahl (immer mit den Schlüsseln 1–5), beide Quellen.
final boxCountsProvider = FutureProvider<Map<int, int>>((ref) async {
  final eintraege = await ref.watch(leitnerEintraegeProvider.future);
  final map = {for (var i = 1; i <= 5; i++) i: 0};
  for (final e in eintraege) {
    map[e.fach] = (map[e.fach] ?? 0) + 1;
  }
  return map;
});

/// Heute fällige Karten, beide Quellen.
final dueCountProvider = FutureProvider<int>((ref) async {
  final eintraege = await ref.watch(leitnerEintraegeProvider.future);
  final jetzt = DateTime.now();
  return eintraege.where((e) => e.istFaellig(jetzt)).length;
});

final isInLeitnerProvider = FutureProvider.family<bool, int>((ref, wordId) =>
    ref.watch(leitnerDaoProvider).isInLeitner(wordId));

// ── Box metadata ──────────────────────────────────────────────────────────────

const boxLabels    = ['Tag 1', '2 Tage', '4 Tage', '8 Tage', '16 Tage'];
const boxIntervals = LeitnerDao.boxIntervals; // [1, 2, 4, 8, 16]
