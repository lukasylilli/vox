// FILE: lib/features/leitner/controllers/leitner_controller.dart
// PHASE: X.2 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// DEPS: leitner_dao.dart, core/leitner/leitner_regeln.dart, databaseProvider
// PURPOSE: Riverpod-Provider des Leitner-Bereichs.
//
// Seit X.2 gibt es EINEN Stapel (vorher zwei Tabellen, die hier beim Lesen
// zusammengelegt wurden): «im Leitner» ist jedes Wort, das in einem Deck mit
// Wiederholung liegt; sein Fach kommt aus dem Fortschritt «Wort × Übung».
// Bis X.5 (Übungsarten) fragt die Wiederholung die Übung «Bedeutung» ab —
// der Fortschritt von vor X.2 ist genau der dieser Übung.
//
// [leitnerEintraegeProvider] ist die einzige Liste, aus der Zähler, Fächer,
// Statistik und Wiederholung lesen.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dao/leitner_dao.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../../core/leitner/leitner_regeln.dart' as regeln;
import '../../wortschatz/controllers/word_controller.dart';

// ── DAO provider ──────────────────────────────────────────────────────────────

final leitnerDaoProvider = Provider<LeitnerDao>((ref) =>
    LeitnerDao(ref.watch(databaseProvider)));

// ── Ein Wort im Leitner ───────────────────────────────────────────────────────

class LeitnerEintrag {
  const LeitnerEintrag(this.wortId, this.stand);

  /// Text-id: Archivkarte `adjektiv_stolz` oder altes Wort
  /// `eigen:<german>|<wordType>`.
  final String wortId;

  /// Fortschritt in der Übung «Bedeutung»; null = noch nie geübt (neu).
  final LeitnerStand? stand;

  /// Altes Wort aus der Tabelle `Words` (sonst: Archivkarte).
  bool get istAltesWort => wortId.startsWith('eigen:');

  /// Fach 1–7; ein neues Wort steht in Fach 1.
  int get fach => anzeigeFach(stand);

  bool get gelernt => stand?.gelernt ?? false;

  /// Ab wann wieder fällig. Neu oder ohne Termin ⇒ sofort.
  DateTime get faellig =>
      stand?.naechsteWiederholung ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool istFaellig(DateTime jetzt) => regeln.istFaellig(stand, jetzt);
}

// ── Streams ───────────────────────────────────────────────────────────────────

/// Alle Wörter in Decks mit Wiederholung, in der Reihenfolge der Aufnahme.
final imLeitnerProvider = StreamProvider<List<String>>((ref) =>
    ref.watch(leitnerDaoProvider).imLeitnerBeobachten());

/// Fortschritt einer Übung: wortId → Stand.
final leitnerFortschrittProvider =
    StreamProvider.family<Map<String, LeitnerStand>, String>((ref, uebung) =>
        ref.watch(leitnerDaoProvider).fortschrittBeobachten(uebung));

/// DER Stapel: jedes Wort im Leitner mit seinem Stand, dringendste zuerst
/// (Fach, dann Fälligkeit). Einzige Liste für alles im Leitner-Bereich.
final leitnerEintraegeProvider =
    FutureProvider<List<LeitnerEintrag>>((ref) async {
  final woerter = await ref.watch(imLeitnerProvider.future);
  final stand =
      await ref.watch(leitnerFortschrittProvider(uebungBedeutung).future);
  return [
    for (final id in woerter) LeitnerEintrag(id, stand[id]),
  ]..sort((a, b) {
      final f = a.fach.compareTo(b.fach);
      return f != 0 ? f : a.faellig.compareTo(b.faellig);
    });
});

// ── Abgeleitete Zahlen ────────────────────────────────────────────────────────

/// Fach → Anzahl (immer mit den Schlüsseln 1–7). Gelernte Wörter liegen in
/// keinem Fach mehr — siehe [gelerntCountProvider].
final boxCountsProvider = FutureProvider<Map<int, int>>((ref) async {
  final eintraege = await ref.watch(leitnerEintraegeProvider.future);
  final map = {for (var i = 1; i <= leitnerFaecher; i++) i: 0};
  for (final e in eintraege) {
    if (!e.gelernt) map[e.fach] = (map[e.fach] ?? 0) + 1;
  }
  return map;
});

/// Wörter im Leitner, die aus dem letzten Fach heraus sind.
final gelerntCountProvider = FutureProvider<int>((ref) async =>
    (await ref.watch(leitnerEintraegeProvider.future))
        .where((e) => e.gelernt)
        .length);

/// Heute fällige Karten.
final dueCountProvider = FutureProvider<int>((ref) async {
  final eintraege = await ref.watch(leitnerEintraegeProvider.future);
  final jetzt = DateTime.now();
  return eintraege.where((e) => e.istFaellig(jetzt)).length;
});

/// Ist das Wort (Text-id) im Leitner?
final isInLeitnerProvider = FutureProvider.family<bool, String>(
    (ref, wortId) async =>
        (await ref.watch(imLeitnerProvider.future)).contains(wortId));

/// Text-id eines alten Worts (Tabelle `Words`) aus seiner Nummer.
final altWortIdProvider = FutureProvider.family<String?, int>(
    (ref, wordId) => ref.watch(databaseProvider).wortIdVon(wordId));

// ── Box metadata ──────────────────────────────────────────────────────────────

const boxLabels = [
  'Tag 1', '2 Tage', '4 Tage', '8 Tage', '16 Tage', '32 Tage', '64 Tage', //
];
const boxIntervals = leitnerFachTage; // [1, 2, 4, 8, 16, 32, 64]
