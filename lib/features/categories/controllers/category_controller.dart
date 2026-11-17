// FILE: lib/features/categories/controllers/category_controller.dart
// PHASE: X.2 (2026-11-17) — «Meine Kategorien» sind Decks
// DEPS: leitner_dao.dart (über leitner_controller.dart), databaseProvider
// PURPOSE: Provider der Seiten «Meine Kategorien». Seit X.2 ist jede eigene
//          Liste ein Deck im Notizbuch-Modus (Tabellen Decks/DeckWoerter) —
//          EIN System statt zwei (vorher: UserCategories für alte Wörter,
//          ArchivKategorien für Archivkarten). Seit X.4 (2026-11-17) gibt es
//          keine eigenen Kategorien-Seiten mehr — alle Decks stehen im
//          Leitner-Bereich. Übrig ist [allCategoriesProvider] für den
//          Filter «Meine Kategorien» in «Alle Wörter» (wird in X.6 zum
//          Filter «Leitner»).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../leitner/controllers/leitner_controller.dart';

export '../../leitner/controllers/leitner_controller.dart'
    show alleDecksProvider, deckIdsVonWortProvider, deckZuordnungenProvider;

/// Die eigenen Listen: Decks im Notizbuch-Modus.
final allCategoriesProvider = FutureProvider<List<Deck>>((ref) async => [
      for (final d in await ref.watch(alleDecksProvider.future))
        if (d.modus == deckModusNotiz) d,
    ]);
