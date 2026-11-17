// FILE: lib/core/database/dao/leitner_dao.dart
// PHASE: X.2 (2026-11-17) — Leitner wie Anki (docs/zukunft/PHASE_X.md)
// DEPS: app_database.dart (Decks, DeckWoerter, LeitnerFortschritt),
//       core/leitner/leitner_regeln.dart (die Regeln)
// PURPOSE: Die EINE Stelle, die die drei Leitner-Tabellen liest und schreibt:
//          Decks, Wort ↔ Deck, Fortschritt «Wort × Übung». Ersetzt den alten
//          LeitnerDao (nur alte Wörter, Nummern als Schlüssel) und den
//          CategoryDao (eigene Listen) — beides sind jetzt Decks.
//
// Alle Schlüssel sind Text-ids (siehe app_database.dart). Jede bewusste
// Handlung (Deck anlegen/löschen, Wort aufnehmen/entfernen) wird als
// Mitgliedschaft festgehalten (S.5) — sonst käme sie beim Abgleich mit einem
// anderen Gerät zurück.
//
// «Im Leitner» = Mitglied mindestens eines Decks mit Wiederholung. Der
// Fortschritt wird beim Entfernen NIE gelöscht (Entscheidung Lukas
// 2026-11-03): kommt das Wort wieder in ein Deck, geht es im selben Fach
// weiter.
import 'package:drift/drift.dart';

import '../../backup/nutzer_zustand.dart'
    show artListe, artListenwort, neueEigeneListenId;
import '../../leitner/leitner_regeln.dart';
import '../app_database.dart';

LeitnerStand _stand(LeitnerFortschrittData z) => LeitnerStand(
      wortId: z.wortId,
      fach: z.fach,
      naechsteWiederholung: z.naechsteWiederholung,
      letzteWiederholung: z.letzteWiederholung,
      ersteWiederholung: z.ersteWiederholung,
    );

class LeitnerDao {
  LeitnerDao(this._db);

  final AppDatabase _db;

  // ── Decks ─────────────────────────────────────────────────────────────────

  SimpleSelectStatement<$DecksTable, Deck> get _decksGeordnet =>
      _db.select(_db.decks)
        ..orderBy([
          (t) => OrderingTerm.asc(t.ordnung),
          (t) => OrderingTerm.asc(t.name),
          (t) => OrderingTerm.asc(t.id),
        ]);

  Stream<List<Deck>> decksBeobachten() => _decksGeordnet.watch();

  Future<List<Deck>> decks() => _decksGeordnet.get();

  Future<Deck?> deck(String id) =>
      (_db.select(_db.decks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Legt ein Deck an. Ohne [id] bekommt es eine neue feste id
  /// ([neueEigeneListenId]); mit [id] wird ein vorhandenes Deck nicht
  /// verändert (mehrfach ausführbar).
  Future<Deck> deckAnlegen(
    String name, {
    String? id,
    String? elternId,
    String modus = deckModusNotiz,
  }) async {
    final deckId = id ?? neueEigeneListenId();
    final da = await deck(deckId);
    if (da != null) return da;
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.decks).insert(DecksCompanion.insert(
          id: deckId,
          name: name.trim(),
          elternId: Value(elternId),
          modus: Value(modus),
          nameAmMs: Value(jetzt),
          standAmMs: Value(jetzt),
        ));
    await _db.mitgliedschaftMerken(artListe, deckId, drin: true);
    return (await deck(deckId))!;
  }

  /// Das Deck, in das der Leitner-Knopf legt, solange kein anderes gewählt
  /// ist — der Stapel von vor X.2. Wird beim ersten Gebrauch angelegt.
  Future<Deck> standardDeck() => deckAnlegen(standardDeckName,
      id: standardDeckId, modus: deckModusWiederholen);

  Future<void> deckUmbenennen(String id, String name) =>
      (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
        DecksCompanion(
          name: Value(name.trim()),
          nameAmMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Ändert Modus und/oder Tageslimit eines Decks. [neuProTag] als Funktion,
  /// damit «zurück auf Standard» (null) von «nicht ändern» unterscheidbar ist.
  Future<void> deckEinstellen(String id,
          {String? modus, int? Function()? neuProTag}) =>
      (_db.update(_db.decks)..where((t) => t.id.equals(id))).write(
        DecksCompanion(
          modus: modus == null ? const Value.absent() : Value(modus),
          neuProTag:
              neuProTag == null ? const Value.absent() : Value(neuProTag()),
          standAmMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Löscht ein Deck: seine Wörter verlassen es (ihr Fortschritt bleibt),
  /// seine Subdecks rücken eine Ebene nach oben.
  Future<void> deckLoeschen(String id) async {
    final weg = await deck(id);
    if (weg == null) return;
    await _db.transaction(() async {
      await (_db.update(_db.decks)..where((t) => t.elternId.equals(id))).write(
        DecksCompanion(
          elternId: Value(weg.elternId),
          standAmMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      await (_db.delete(_db.deckWoerter)..where((t) => t.deckId.equals(id)))
          .go();
      await (_db.delete(_db.decks)..where((t) => t.id.equals(id))).go();
      await _db.mitgliedschaftMerken(artListe, id, drin: false);
    });
  }

  // ── Wort ↔ Deck ───────────────────────────────────────────────────────────

  Stream<List<DeckWoerterData>> zuordnungenBeobachten() =>
      (_db.select(_db.deckWoerter)
            ..orderBy([
              (t) => OrderingTerm.asc(t.hinzuMs),
              (t) => OrderingTerm.asc(t.rowId), // gleiche Millisekunde ⇒ Einfügefolge
            ]))
          .watch();

  /// Wörter eines Decks, in der Reihenfolge der Aufnahme.
  Stream<List<String>> deckWoerterBeobachten(String deckId) =>
      (_db.select(_db.deckWoerter)
            ..where((t) => t.deckId.equals(deckId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.hinzuMs),
              (t) => OrderingTerm.asc(t.rowId), // gleiche Millisekunde ⇒ Einfügefolge
            ]))
          .watch()
          .map((z) => [for (final e in z) e.wortId]);

  Future<Set<String>> deckIdsVonWort(String wortId) async => {
        for (final z in await (_db.select(_db.deckWoerter)
              ..where((t) => t.wortId.equals(wortId)))
            .get())
          z.deckId,
      };

  /// Nimmt [wortId] in das Deck auf ([drin] wahr) oder entfernt es daraus.
  /// Der Fortschritt des Worts bleibt in beiden Fällen unberührt.
  Future<void> wortSetzen(String deckId, String wortId, bool drin) async {
    if (drin) {
      await _db.into(_db.deckWoerter).insert(
            DeckWoerterCompanion.insert(
              deckId: deckId,
              wortId: wortId,
              hinzuMs: Value(DateTime.now().millisecondsSinceEpoch),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_db.delete(_db.deckWoerter)
            ..where((t) => t.deckId.equals(deckId) & t.wortId.equals(wortId)))
          .go();
    }
    await _db.mitgliedschaftMerken(artListenwort, deckId,
        wort: wortId, drin: drin);
  }

  // ── «Im Leitner» ──────────────────────────────────────────────────────────

  JoinedSelectStatement<HasResultSet, dynamic> get _imLeitner =>
      _db.select(_db.deckWoerter).join([
        innerJoin(_db.decks, _db.decks.id.equalsExp(_db.deckWoerter.deckId)),
      ])
        ..where(_db.decks.modus.equals(deckModusWiederholen))
        ..orderBy([
          OrderingTerm.asc(_db.deckWoerter.hinzuMs),
          OrderingTerm.asc(_db.deckWoerter.rowId),
        ]);

  /// Alle Wörter in Decks mit Wiederholung, jedes einmal, in der Reihenfolge
  /// der Aufnahme.
  Stream<List<String>> imLeitnerBeobachten() => _imLeitner.watch().map((z) => {
        for (final r in z) r.readTable(_db.deckWoerter).wortId,
      }.toList());

  Future<bool> istImLeitner(String wortId) async =>
      (await (_imLeitner..where(_db.deckWoerter.wortId.equals(wortId))).get())
          .isNotEmpty;

  /// Leitner-Knopf «rein»: ins Standard-Deck.
  Future<void> aufnehmen(String wortId) async {
    final ziel = await standardDeck();
    await wortSetzen(ziel.id, wortId, true);
  }

  /// Leitner-Knopf «raus»: aus JEDEM Deck mit Wiederholung — danach ist das
  /// Wort nicht mehr im Leitner. Notizbuch-Decks behalten es.
  Future<void> entfernen(String wortId) async {
    final treffer = await (_imLeitner
          ..where(_db.deckWoerter.wortId.equals(wortId)))
        .get();
    for (final r in treffer) {
      await wortSetzen(r.readTable(_db.deckWoerter).deckId, wortId, false);
    }
  }

  // ── Fortschritt «Wort × Übung» ────────────────────────────────────────────

  Stream<Map<String, LeitnerStand>> fortschrittBeobachten(String uebung) =>
      (_db.select(_db.leitnerFortschritt)
            ..where((t) => t.uebung.equals(uebung)))
          .watch()
          .map((z) => {for (final e in z) e.wortId: _stand(e)});

  Future<LeitnerStand?> fortschritt(String wortId, String uebung) async {
    final z = await (_db.select(_db.leitnerFortschritt)
          ..where((t) => t.wortId.equals(wortId) & t.uebung.equals(uebung)))
        .getSingleOrNull();
    return z == null ? null : _stand(z);
  }

  /// Legt den Stand eines Worts in einer Übung ab (anlegen oder ersetzen).
  Future<void> fortschrittSetzen(String uebung, LeitnerStand stand) =>
      _db.into(_db.leitnerFortschritt).insertOnConflictUpdate(
            LeitnerFortschrittCompanion.insert(
              wortId: stand.wortId,
              uebung: uebung,
              fach: Value(stand.fach),
              naechsteWiederholung: Value(stand.naechsteWiederholung),
              letzteWiederholung: Value(stand.letzteWiederholung),
              ersteWiederholung: Value(stand.ersteWiederholung),
            ),
          );

  /// Ergebnis einer Wiederholung (Regeln: leitner_regeln.dart): gewusst ⇒ ein
  /// Fach weiter, aus dem 7. Fach ⇒ gelernt; nicht gewusst ⇒ Fach 1.
  Future<LeitnerStand> bewerten(String wortId, String uebung,
      {required bool gewusst, DateTime? jetzt}) async {
    final zeit = jetzt ?? DateTime.now();
    final bisher = await fortschritt(wortId, uebung);
    final neu = gewusst
        ? nachRichtig(wortId, bisher, zeit)
        : nachFalsch(wortId, zeit, stand: bisher);
    await fortschrittSetzen(uebung, neu);
    return neu;
  }

  /// Von Hand zurück in Fach 1 (auch ein gelerntes Wort) — «wieder lernen».
  Future<void> zuruecklegen(String wortId, String uebung,
          {DateTime? jetzt}) async =>
      fortschrittSetzen(
          uebung,
          nachFalsch(wortId, jetzt ?? DateTime.now(),
              stand: await fortschritt(wortId, uebung)));
}
