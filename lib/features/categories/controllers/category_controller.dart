// FILE: lib/features/categories/controllers/category_controller.dart
// PHASE: X.2 (2026-11-17) — «Meine Kategorien» sind Decks
// DEPS: leitner_dao.dart (über leitner_controller.dart), databaseProvider
// PURPOSE: Provider der Seiten «Meine Kategorien». Seit X.2 ist jede eigene
//          Liste ein Deck im Notizbuch-Modus (Tabellen Decks/DeckWoerter) —
//          EIN System statt zwei (vorher: UserCategories für alte Wörter,
//          ArchivKategorien für Archivkarten). Die Seiten zeigen bis X.4
//          (Deck-Baum) die Notizbuch-Decks; das Deck «Leitner» und andere
//          Decks mit Wiederholung gehören in den Leitner-Bereich.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../leitner/controllers/leitner_controller.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../wortschatz/controllers/word_controller.dart';

/// Alle Decks, geordnet.
final alleDecksProvider = StreamProvider<List<Deck>>(
    (ref) => ref.watch(leitnerDaoProvider).decksBeobachten());

/// Die eigenen Listen: Decks im Notizbuch-Modus.
final allCategoriesProvider = FutureProvider<List<Deck>>((ref) async => [
      for (final d in await ref.watch(alleDecksProvider.future))
        if (d.modus == deckModusNotiz) d,
    ]);

/// Wort ↔ Deck, alle Zeilen.
final deckZuordnungenProvider = StreamProvider<List<DeckWoerterData>>(
    (ref) => ref.watch(leitnerDaoProvider).zuordnungenBeobachten());

/// ids der Decks, in denen ein Wort (Text-id) liegt.
final deckIdsVonWortProvider =
    FutureProvider.family<Set<String>, String>((ref, wortId) async => {
          for (final z in await ref.watch(deckZuordnungenProvider.future))
            if (z.wortId == wortId) z.deckId,
        });

/// Die Wörter eines Decks zum Anzeigen, in der Reihenfolge der Aufnahme:
/// `wert` ist ein altes Wort (`Word`) oder der Index-Eintrag einer
/// Archivkarte. Eine Karte, die diese App-Fassung (noch) nicht kennt, wird
/// nicht gezeigt — aber auch nie aus dem Deck gelöscht.
final deckWoerterProvider = StreamProvider.family<
    List<({String wortId, Object wert})>, String>((ref, deckId) async* {
  final wordDao = ref.watch(wordDaoProvider);
  await for (final ids
      in ref.watch(leitnerDaoProvider).deckWoerterBeobachten(deckId)) {
    final index = ids.any((id) => !id.startsWith('eigen:'))
        ? await ref.read(vokabIndexByIdProvider.future)
        : const <String, Map<String, dynamic>>{};
    final zeilen = <({String wortId, Object wert})>[];
    for (final id in ids) {
      final Object? wert = id.startsWith('eigen:')
          ? await wordDao.nachTextId(id)
          : index[id];
      if (wert != null) zeilen.add((wortId: id, wert: wert));
    }
    yield zeilen;
  }
});
