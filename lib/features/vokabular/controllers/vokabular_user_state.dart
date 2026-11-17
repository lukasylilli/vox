// FILE: lib/features/vokabular/controllers/vokabular_user_state.dart
// PURPOSE: User-Zustand des Vokabular-Archivs (فاز V, Stufe ۳) — GETRENNT vom
//          read-only Karten-Content (Assets/vocab.db):
//          · Leitner-Mitgliedschaft: Wortschatz ≠ Leitner! Von ۲۵٬۰۰۰ Wörtern
//            landen NUR explizit hinzugefügte im Lernstapel (Flag, kein Auto-Import).
//          · Eigene Kategorien: benutzerdefinierte Listen (نام + Wort-IDs).
//          · Notizen je Wort.
//
// ABLAGE (seit X.2, 2026-11-17): Leitner und Listen liegen in drift —
// `LeitnerFortschritt`, `Decks`, `DeckWoerter` —, also in GENAU den Tabellen,
// die auch Sicherung (S.2) und Konto (S.3) lesen und schreiben. Der Zugriff
// läuft über `core/database/dao/leitner_dao.dart`; dieser Store kennt keine
// Tabelle. Notizen bleiben in SharedPreferences (Freitext).
//
// Was dieser Store der Wortseite zeigt:
//   · `leitner`    = Wörter in einem Deck MIT Wiederholung («im Leitner»),
//                    mit Fach und Termin der Übung «Bedeutung»;
//   · `kategorien` = die Notizbuch-Decks (die bisherigen eigenen Listen).
// Er lädt sich bei JEDER Änderung der drei Tabellen neu — egal, wer sie
// geändert hat (Leitner-Bereich, Kategorien-Seiten, Sicherung, Konto).
//
// Ein Altbestand in SharedPreferences (Geräte von vor S.0b/S.0c) wird beim
// Laden über `uebergangAbschliessen()` übernommen.
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show TableUpdateQuery;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/user_state_repository.dart';
import '../../../core/database/dao/leitner_dao.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../wortschatz/controllers/word_controller.dart' show databaseProvider;

class VokabLeitnerEintrag {
  final int box;
  final String? nextReviewDate; // ISO-8601
  const VokabLeitnerEintrag({this.box = 1, this.nextReviewDate});

  Map<String, dynamic> toJson() => {'box': box, 'nextReviewDate': nextReviewDate};
  factory VokabLeitnerEintrag.fromJson(Map<String, dynamic> j) =>
      VokabLeitnerEintrag(
          box: j['box'] as int? ?? 1,
          nextReviewDate: j['nextReviewDate'] as String?);
}

class VokabKategorie {
  final String id;
  final String name;
  final List<String> wortIds;
  const VokabKategorie(
      {required this.id, required this.name, this.wortIds = const []});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'wortIds': wortIds};
  factory VokabKategorie.fromJson(Map<String, dynamic> j) => VokabKategorie(
      id: j['id'] as String,
      name: j['name'] as String,
      wortIds: (j['wortIds'] as List?)?.cast<String>() ?? const []);
}

/// Freitext-Notiz des Nutzers zu EINEM Wort. Farben pro Wort-Token:
/// `farben[i]` = Farbname des i-ten Worts (Whitespace-Split) — nur der Name
/// wird gespeichert, die Color löst die UI auf (Puzzling: Farben zentral).
class VokabNotiz {
  final String text;
  final Map<int, String> farben;
  const VokabNotiz({this.text = '', this.farben = const {}});

  Map<String, dynamic> toJson() =>
      {'text': text, 'farben': farben.map((k, v) => MapEntry('$k', v))};
  factory VokabNotiz.fromJson(Map<String, dynamic> j) => VokabNotiz(
      text: j['text'] as String? ?? '',
      farben: ((j['farben'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(int.parse(k as String), v as String)));
}

class VokabularUserState {
  /// wortId → Leitner-Eintrag; Anwesenheit im Map = imLeitner.
  final Map<String, VokabLeitnerEintrag> leitner;
  final List<VokabKategorie> kategorien;

  /// wortId → Freitext-Notiz (fehlt = keine Notiz).
  final Map<String, VokabNotiz> notizen;
  const VokabularUserState(
      {this.leitner = const {},
      this.kategorien = const [],
      this.notizen = const {}});

  bool imLeitner(String wortId) => leitner.containsKey(wortId);

  VokabularUserState copyWith(
          {Map<String, VokabLeitnerEintrag>? leitner,
          List<VokabKategorie>? kategorien,
          Map<String, VokabNotiz>? notizen}) =>
      VokabularUserState(
          leitner: leitner ?? this.leitner,
          kategorien: kategorien ?? this.kategorien,
          notizen: notizen ?? this.notizen);
}

class VokabularUserStore extends Notifier<VokabularUserState> {
  late SharedPreferences _prefs;
  late LeitnerDao _dao;
  // Mutationen warten auf _load — sonst Race auf _prefs direkt nach Start.
  late final Future<void> _ready;

  @override
  VokabularUserState build() {
    _ready = _load();
    return const VokabularUserState();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    _prefs = await SharedPreferences.getInstance();
    _dao = LeitnerDao(db);
    // Altbestand aus SharedPreferences zuerst nach drift übernehmen — sonst
    // wäre er für die App unsichtbar (B-11).
    await UserStateRepository(db, _prefs).uebergangAbschliessen();
    state = await _ausAblage();
    // Jede Änderung an Decks, Wörtern oder Fortschritt — von wo auch immer —
    // erscheint hier, ohne dass jemand `neuLaden()` rufen muss.
    // Gebündelt: das Einspielen einer Sicherung schreibt Tausende Zeilen —
    // dafür wird EINMAL neu gelesen, nicht je Zeile.
    Timer? warten;
    final abo = db
        .tableUpdates(TableUpdateQuery.onAllTables(
            [db.decks, db.deckWoerter, db.leitnerFortschritt]))
        .listen((_) {
      warten?.cancel();
      warten = Timer(const Duration(milliseconds: 80),
          () async => state = await _ausAblage());
    });
    ref.onDispose(() {
      warten?.cancel();
      abo.cancel();
    });
  }

  /// Liest den Zustand neu aus der Ablage (z. B. nach dem Einspielen einer
  /// Sicherung, die auch Notizen ändert).
  Future<void> neuLaden() async {
    await _ready;
    state = await _ausAblage();
  }

  Future<VokabularUserState> _ausAblage() async {
    final db = ref.read(databaseProvider);
    final decks = await _dao.decks();
    final zuordnung = await db.select(db.deckWoerter).get();
    final wiederholen = {
      for (final d in decks)
        if (d.modus == deckModusWiederholen) d.id,
    };
    final fortschritt = {
      for (final z in await (db.select(db.leitnerFortschritt)
            ..where((t) => t.uebung.equals(uebungBedeutung)))
          .get())
        z.wortId: z,
    };
    final notizenRaw = _prefs.getString(kVokabNotizenKey);
    return VokabularUserState(
      leitner: {
        for (final z in zuordnung)
          if (wiederholen.contains(z.deckId))
            z.wortId: VokabLeitnerEintrag(
                box: (fortschritt[z.wortId]?.fach ?? 1)
                    .clamp(1, leitnerGelerntFach),
                nextReviewDate: fortschritt[z.wortId]
                    ?.naechsteWiederholung
                    ?.toIso8601String()),
      },
      kategorien: [
        for (final d in decks)
          if (d.modus == deckModusNotiz)
            VokabKategorie(id: d.id, name: d.name, wortIds: [
              for (final z in zuordnung)
                if (z.deckId == d.id) z.wortId,
            ]),
      ],
      notizen: notizenRaw == null
          ? const {}
          : (jsonDecode(notizenRaw) as Map<String, dynamic>).map((k, v) =>
              MapEntry(k, VokabNotiz.fromJson(v as Map<String, dynamic>))),
    );
  }

  /// Rein → ins Standard-Deck «Leitner»; raus → aus jedem Deck mit
  /// Wiederholung. Der Fortschritt des Worts bleibt in beiden Fällen (X.2).
  /// Rückgabe: neuer imLeitner-Zustand.
  Future<bool> toggleLeitner(String wortId) async {
    await _ready;
    final rein = !state.leitner.containsKey(wortId);
    if (rein) {
      await _dao.aufnehmen(wortId);
    } else {
      await _dao.entfernen(wortId);
    }
    state = await _ausAblage();
    return rein;
  }

  Future<VokabKategorie> createKategorie(String name) async {
    await _ready;
    final deck = await _dao.deckAnlegen(name);
    state = await _ausAblage();
    return VokabKategorie(id: deck.id, name: deck.name);
  }

  Future<void> _saveNotizen() => _prefs.setString(kVokabNotizenKey,
      jsonEncode(state.notizen.map((k, v) => MapEntry(k, v.toJson()))));

  /// Notiz speichern; leerer Text (oder null) → Notiz löschen.
  Future<void> setzeNotiz(String wortId, VokabNotiz? notiz) async {
    await _ready;
    final notizen = Map<String, VokabNotiz>.from(state.notizen);
    if (notiz == null || notiz.text.trim().isEmpty) {
      notizen.remove(wortId);
    } else {
      notizen[wortId] = notiz;
    }
    state = state.copyWith(notizen: notizen);
    await _saveNotizen();
  }

  Future<void> toggleWortInKategorie(String katId, String wortId) async {
    await _ready;
    final kat = state.kategorien.where((k) => k.id == katId).firstOrNull;
    if (kat == null) return;
    await _dao.wortSetzen(katId, wortId, !kat.wortIds.contains(wortId));
    state = await _ausAblage();
  }
}

final vokabularUserProvider =
    NotifierProvider<VokabularUserStore, VokabularUserState>(
        VokabularUserStore.new);
