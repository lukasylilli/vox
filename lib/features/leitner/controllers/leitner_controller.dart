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
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/leitner_dao.dart';
import '../../../core/leitner/deck_baum.dart';
import '../../../core/leitner/deck_sitzung.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../../wortschatz/controllers/wortschatz_filter_controller.dart'
    show alleWortBuecherProvider, voxBuecherProvider;
import '../data/standard_decks.dart';
import '../data/wort_reihenfolge.dart';

export '../data/standard_decks.dart'
    show StandardDeck, istStandardDeck, istStandardLektion;
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

/// Wörter, die von Hand in Decks mit Wiederholung liegen.
final _imLeitnerVonHandProvider = StreamProvider<List<String>>((ref) =>
    ref.watch(leitnerDaoProvider).imLeitnerBeobachten());

/// Alle Wörter in Decks mit Wiederholung: von Hand gelegte (Reihenfolge der
/// Aufnahme), dann die aus den Daten eines Standard-Decks, das der Nutzer
/// auf «Wiederholung» gestellt hat (X.4b).
final imLeitnerProvider = FutureProvider<List<String>>((ref) async {
  final vonHand = await ref.watch(_imLeitnerVonHandProvider.future);
  final zeilen = await ref.watch(alleDecksProvider.future);
  // Die Daten der Standard-Decks (ganzer Wortindex) nur laden, wenn ein
  // Standard-Deck auf Wiederholung steht — sonst tragen sie nichts bei.
  final zeilenModi = LeitnerDao.modi(zeilen);
  final brauchtStd = zeilen.any((d) =>
      istStandardDeck(d.id) && zeilenModi[d.id] == deckModusWiederholen);
  final std =
      brauchtStd ? ref.watch(standardDecksProvider).valueOrNull : null;
  final decks = brauchtStd
      ? await ref.watch(deckListeProvider.future)
      : zeilen;
  final modi = brauchtStd ? LeitnerDao.modi(decks) : zeilenModi;
  final gesehen = <String>{};
  return [
    for (final w in vonHand)
      if (gesehen.add(w)) w,
    if (std != null)
      for (final d in decks)
        if (istStandardDeck(d.id) && modi[d.id] == deckModusWiederholen)
          for (final w in std.woerter[d.id] ?? const <String>[])
            if (gesehen.add(w)) w,
  ];
});

/// Dasselbe als Menge — für «ist dieses Wort im Leitner?» in langen Listen.
final imLeitnerMengeProvider = FutureProvider<Set<String>>(
    (ref) async => (await ref.watch(imLeitnerProvider.future)).toSet());

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

/// Heute zu üben, über alle Decks: fällige Wörter + neue nach den
/// Tageslimits (X.4, deck_sitzung.dart).
final dueCountProvider = FutureProvider<int>((ref) async =>
    (await ref.watch(deckRechnerProvider.future)).sitzungAlle().length);

/// Ist das Wort (Text-id) im Leitner?
final isInLeitnerProvider = FutureProvider.family<bool, String>(
    (ref, wortId) async =>
        (await ref.watch(imLeitnerMengeProvider.future)).contains(wortId));

// ── Decks (X.3) ───────────────────────────────────────────────────────────────

/// Alle Decks, geordnet (Ordnung, dann Name).
final alleDecksProvider = StreamProvider<List<Deck>>(
    (ref) => ref.watch(leitnerDaoProvider).decksBeobachten());

/// ids gelöschter Decks (auch Lektionen ohne Zeile).
final geloeschteDeckIdsProvider = StreamProvider<Set<String>>(
    (ref) => ref.watch(leitnerDaoProvider).geloeschteDeckIdsBeobachten());

/// ALLE Decks: die Zeilen der Datenbank und — X.4b — die Lektionen und Teile
/// der Standard-Decks, die keine Zeile haben (virtuell, nicht gelöscht).
/// Eine virtuelle Lektion
///   · hängt unter ihrem Eltern-Deck; fehlt das (gelöscht), unter dem
///     nächsten vorhandenen darüber — wie beim Löschen eines echten Decks;
///   · hat den Modus «erben» (folgt dem Deck darüber, deckModiProvider):
///     stellt der Nutzer «A1» auf Wiederholung, sind alle Lektionen von A1
///     zum Üben da.
/// Die Daten der Standard-Decks werden nur geladen, wenn es Standard-Decks
/// gibt (sonst wäre der ganze Wortindex für nichts geladen).
final deckListeProvider = FutureProvider<List<Deck>>((ref) async {
  final zeilen = await ref.watch(alleDecksProvider.future);
  if (!zeilen.any((d) => istStandardDeck(d.id))) return zeilen;
  final std = ref.watch(standardDecksProvider).valueOrNull;
  if (std == null) return zeilen;
  final weg = ref.watch(geloeschteDeckIdsProvider).valueOrNull ?? const {};
  final nachId = {for (final d in zeilen) d.id: d};
  final stdEltern = {for (final d in std.decks) d.id: d.eltern};
  final ergebnis = [...zeilen];
  // Baum-Reihenfolge von std.decks: Eltern vor Kindern ⇒ Modus vererbbar.
  for (final v in std.decks) {
    if (!v.virtuell || nachId.containsKey(v.id) || weg.contains(v.id)) {
      continue;
    }
    String? eltern = v.eltern;
    while (eltern != null && !nachId.containsKey(eltern)) {
      eltern = stdEltern[eltern];
    }
    final deck = Deck(
      id: v.id,
      name: v.name,
      elternId: eltern,
      ordnung: v.ordnung,
      modus: deckModusErben,
    );
    nachId[v.id] = deck;
    ergebnis.add(deck);
  }
  return ergebnis;
});

/// Der WIRKLICHE Modus jedes Decks (Wiederholung/Notizbuch): bei «erben»
/// der des Decks darüber (Lukas 2026-11-22). Anzeige und Rechnung lesen
/// hier, nie `deck.modus` direkt — das ist nur die eigene Einstellung.
final deckModiProvider = FutureProvider<Map<String, String>>(
    (ref) async => LeitnerDao.modi(await ref.watch(deckListeProvider.future)));

/// Alle Decks in Baum-Reihenfolge (core/leitner/deck_baum.dart).
final deckBaumProvider = FutureProvider<List<DeckKnoten<Deck>>>((ref) async {
  final decks = [...await ref.watch(deckListeProvider.future)]
    ..sort((a, b) {
      final o = a.ordnung.compareTo(b.ordnung);
      return o != 0 ? o : a.name.compareTo(b.name);
    });
  return deckBaum(decks, id: (d) => d.id, eltern: (d) => d.elternId);
});

/// Wort ↔ Deck, alle Zeilen.
final deckZuordnungenProvider = StreamProvider<List<DeckWoerterData>>(
    (ref) => ref.watch(leitnerDaoProvider).zuordnungenBeobachten());

/// ids der Decks, in denen ein Wort (Text-id) liegt — von Hand
/// hineingelegt ODER (Standard-Deck) aus den Daten des Worts.
final deckIdsVonWortProvider =
    FutureProvider.family<Set<String>, String>((ref, wortId) async => {
          for (final z in await ref.watch(deckZuordnungenProvider.future))
            if (z.wortId == wortId) z.deckId,
          if ((await ref.watch(alleDecksProvider.future))
              .any((d) => istStandardDeck(d.id)))
            ...?(await ref.watch(standardDeckIdsJeWortProvider.future))[wortId],
        });

/// Standard-Decks, in denen ein Wort aus seinen Daten liegt (nicht abwählbar
/// — es gehört dazu, solange es z. B. A1 ist).
final standardDeckIdsVonWortProvider =
    FutureProvider.family<Set<String>, String>((ref, wortId) async =>
        (await ref.watch(standardDeckIdsJeWortProvider.future))[wortId] ??
        const {});

// ── Standard-Decks (X.4b, Entscheidung Nr. 16) ────────────────────────────────

/// Welche Standard-Decks es gibt und ihre Wörter — aus denselben Daten wie
/// der Filter von «Alle Wörter» (leitner/data/standard_decks.dart).
final standardDecksProvider = FutureProvider<StandardDecks>((ref) async {
  final karten = await ref.watch(vokabIndexProvider.future);
  final woerter = await ref.watch(allWordsProvider.future);
  final buecher = await ref.watch(voxBuecherProvider.future);
  final altBuecher = await ref.watch(allBooksProvider.future);
  final wortBuecher = await ref.watch(alleWortBuecherProvider.future);
  final reihenfolge = wortReihenfolgeLesen(
      await rootBundle.loadString(wortReihenfolgeAsset, cache: false));
  final textId = {
    for (final w in woerter) w.id: LeitnerStand.eigenesWort(w.german, w.wordType),
  };
  final altBuchId = {for (final b in altBuecher) b.name: b.id};
  return standardDecksBerechnen(
    reihenfolge: reihenfolge,
    karten: karten,
    altWoerter: [
      for (final w in woerter)
        (
          wortId: textId[w.id]!,
          niveau: w.level,
          wortart: w.wordType,
          ausApp: w.ausApp == true,
        ),
    ],
    buecher: [
      for (final b in buecher)
        (
          id: b.id,
          name: b.name,
          woerter: [
            ...b.karten,
            if (b.altBuch != null && altBuchId[b.altBuch] != null)
              for (final z in wortBuecher)
                if (z.bookId == altBuchId[b.altBuch]) ?textId[z.wordId],
          ],
        ),
    ],
  );
});

/// Umgekehrt: Wort → Standard-Decks.
final standardDeckIdsJeWortProvider =
    FutureProvider<Map<String, Set<String>>>(
        (ref) async => (await ref.watch(standardDecksProvider.future)).gruppen);

/// Legt fehlende Standard-Decks an (nie gelöschte, nie veränderte). Wird
/// beim Öffnen des Leitners und der Deck-Auswahl beobachtet — so hat der
/// Nutzer beim ersten Mal ohne eigenes Zutun seine Decks, und ein neues
/// Buch oder ein neuer Beruf erscheint, sobald es Wörter hat.
final standardDecksEinrichtenProvider = FutureProvider<void>((ref) async {
  final std = await ref.watch(standardDecksProvider.future);
  await ref.read(leitnerDaoProvider).standardDecksAnlegen([
    for (final d in std.decks)
      // Lektionen und Teile bleiben ohne Zeile (deckListeProvider).
      if (!d.virtuell)
        (id: d.id, name: d.name, eltern: d.eltern, ordnung: d.ordnung),
  ]);
});

/// Gelöschte Standard-Decks — zum Zurückholen.
final geloeschteStandardDecksProvider =
    FutureProvider<List<StandardDeck>>((ref) async {
  final std = await ref.watch(standardDecksProvider.future);
  final da = {for (final d in await ref.watch(alleDecksProvider.future)) d.id};
  final weg = await ref.watch(geloeschteDeckIdsProvider.future);
  return [
    for (final d in std.decks)
      if (!da.contains(d.id) && weg.contains(d.id)) d,
  ];
});

/// Die Rechnung «was ist heute dran, wie weit ist jedes Deck» (X.4,
/// core/leitner/deck_sitzung.dart) — aus Decks, Zuordnungen und dem
/// Fortschritt der Übung «Bedeutung» (bis X.5 die einzige Übung).
final deckRechnerProvider = FutureProvider<DeckRechner>((ref) async {
  final decks = await ref.watch(deckListeProvider.future);
  final zuordnung = await ref.watch(deckZuordnungenProvider.future);
  final fortschritt =
      await ref.watch(leitnerFortschrittProvider(uebungBedeutung).future);
  // Standard-Decks: Wörter aus den Daten, dazu was der Nutzer von Hand
  // hineingelegt hat. Fehlen die Daten noch (lädt), zählen nur die Zeilen.
  final std = decks.any((d) => istStandardDeck(d.id))
      ? ref.watch(standardDecksProvider).valueOrNull
      : null;
  final woerter = <String, List<String>>{
    for (final e in (std?.woerter ?? const <String, List<String>>{}).entries)
      e.key: [...e.value],
  };
  for (final z in zuordnung) {
    final l = woerter[z.deckId] ??= [];
    if (!istStandardDeck(z.deckId) || !l.contains(z.wortId)) l.add(z.wortId);
  }
  final modi = LeitnerDao.modi(decks);
  return DeckRechner(
    decks: [
      for (final d in decks)
        DeckDaten(
            id: d.id,
            eltern: d.elternId,
            modus: modi[d.id] ?? deckModusNotiz,
            neuProTag: d.neuProTag,
            // Lektionen/Teile werden der Reihe nach gelernt (deck_sitzung).
            lektion: istStandardLektion(d.id)),
    ],
    woerterJeDeck: woerter,
    fortschritt: fortschritt,
    jetzt: DateTime.now(),
  );
});

/// Heute zu übende Wörter (Text-ids): eines Decks samt Subdecks, oder —
/// mit `null` — aller Decks.
final leitnerSitzungProvider =
    FutureProvider.family<List<String>, String?>((ref, deckId) async {
  final r = await ref.watch(deckRechnerProvider.future);
  return deckId == null ? r.sitzungAlle() : r.sitzung(deckId);
});

/// Die Wörter EINES Decks (ohne Subdecks) zum Anzeigen: `wert` ist ein
/// altes Wort (`Word`) oder der Index-Eintrag einer Archivkarte. Erst die
/// Wörter aus den Daten (Standard-Deck), dann die von Hand hineingelegten in
/// der Reihenfolge der Aufnahme. Eine Karte, die diese App-Fassung (noch)
/// nicht kennt, wird nicht gezeigt — aber auch nie aus dem Deck gelöscht.
/// `vonHand` = darf aus dem Deck genommen werden.
final deckWoerterProvider = StreamProvider.family<
    List<({String wortId, Object wert, bool vonHand})>,
    String>((ref, deckId) async* {
  final ausDaten = istStandardDeck(deckId)
      ? (await ref.watch(standardDecksProvider.future)).woerter[deckId] ??
          const <String>[]
      : const <String>[];
  final index = await ref.watch(vokabIndexByIdProvider.future);
  final alt = {
    for (final w in await ref.watch(allWordsProvider.future))
      LeitnerStand.eigenesWort(w.german, w.wordType): w,
  };
  Object? wert(String id) => id.startsWith('eigen:') ? alt[id] : index[id];
  await for (final vonHand
      in ref.watch(leitnerDaoProvider).deckWoerterBeobachten(deckId)) {
    final gesehen = <String>{};
    yield [
      for (final id in ausDaten)
        if (gesehen.add(id) && wert(id) != null)
          (wortId: id, wert: wert(id)!, vonHand: false),
      for (final id in vonHand)
        if (gesehen.add(id) && wert(id) != null)
          (wortId: id, wert: wert(id)!, vonHand: true),
    ];
  }
});

/// Text-id eines alten Worts (Tabelle `Words`) aus seiner Nummer.
final altWortIdProvider = FutureProvider.family<String?, int>(
    (ref, wordId) => ref.watch(databaseProvider).wortIdVon(wordId));

// ── Box metadata ──────────────────────────────────────────────────────────────

const boxLabels = [
  'Tag 1', '2 Tage', '4 Tage', '8 Tage', '16 Tage', '32 Tage', '64 Tage', //
];
const boxIntervals = leitnerFachTage; // [1, 2, 4, 8, 16, 32, 64]
