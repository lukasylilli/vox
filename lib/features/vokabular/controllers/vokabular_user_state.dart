// FILE: lib/features/vokabular/controllers/vokabular_user_state.dart
// PURPOSE: User-Zustand des Vokabular-Archivs (فاز V, Stufe ۳) — GETRENNT vom
//          read-only Karten-Content (Assets/vocab.db):
//          · Leitner-Mitgliedschaft: Wortschatz ≠ Leitner! Von ۲۵٬۰۰۰ Wörtern
//            landen NUR explizit hinzugefügte im Lernstapel (Flag, kein Auto-Import).
//          · Eigene Kategorien: benutzerdefinierte Listen (نام + Wort-IDs).
//          · Notizen je Wort.
//
// ABLAGE (seit B-11, 2026-09-15): Leitner und Listen liegen in drift —
// `ArchivLeitner`, `ArchivKategorien`, `ArchivKategorieWoerter` —, also in
// GENAU den Tabellen, die auch Sicherung (S.2) und Konto (S.3) lesen und
// schreiben. Der Zugriff läuft über `core/backup/user_state_repository.dart`;
// dieser Store kennt keine Tabelle. Notizen bleiben in SharedPreferences
// (Freitext).
//
// ⚠️ WARUM B-11: S.0b/S.0c hatten nur die Fassade auf drift umgestellt; dieser
// Store las und schrieb weiter SharedPreferences. Beim Einspielen einer
// Sicherung leerte die Fassade die alten Schlüssel — danach zeigte die App
// einen leeren Leitner-Stapel und leere Listen, obwohl alles in drift lag.
// Seit B-11 gibt es EIN Zuhause; ein Altbestand wird beim Laden über
// `uebergangAbschliessen()` übernommen (dieselbe Logik wie beim Einspielen).
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/user_state_repository.dart';
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
  late UserStateRepository _ablage;
  // Mutationen warten auf _load — sonst Race auf _prefs direkt nach Start.
  late final Future<void> _ready;

  @override
  VokabularUserState build() {
    _ready = _load();
    return const VokabularUserState();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    _ablage = UserStateRepository(ref.read(databaseProvider), _prefs);
    // Altbestand aus SharedPreferences zuerst nach drift übernehmen — sonst
    // wäre er für die App unsichtbar (B-11).
    await _ablage.uebergangAbschliessen();
    state = await _ausAblage();
  }

  /// Liest den Zustand neu aus der Ablage.
  ///
  /// Nach jedem Vorgang aufrufen, der die Ablage **an diesem Store vorbei**
  /// ändert — Sicherung einspielen (S.2), Abgleich mit dem Konto (S.3).
  /// Sonst zeigt die Wortseite bis zum nächsten Start den alten Stand.
  Future<void> neuLaden() async {
    await _ready;
    state = await _ausAblage();
  }

  Future<VokabularUserState> _ausAblage() async {
    final archiv = await _ablage.archivLesen();
    final notizenRaw = _prefs.getString(kVokabNotizenKey);
    return VokabularUserState(
      leitner: archiv.leitner.map((id, l) => MapEntry(
          id,
          VokabLeitnerEintrag(
              box: l.fach,
              nextReviewDate: l.naechsteWiederholung?.toIso8601String()))),
      kategorien: archiv.kategorien
          .map((k) =>
              VokabKategorie(id: k.id, name: k.name, wortIds: k.wortIds))
          .toList(),
      notizen: notizenRaw == null
          ? const {}
          : (jsonDecode(notizenRaw) as Map<String, dynamic>).map((k, v) =>
              MapEntry(k, VokabNotiz.fromJson(v as Map<String, dynamic>))),
    );
  }

  /// Rein → Box 1, Review sofort fällig; raus → Eintrag weg (Fortschritt weg).
  /// Rückgabe: neuer imLeitner-Zustand.
  Future<bool> toggleLeitner(String wortId) async {
    await _ready;
    final leitner = Map<String, VokabLeitnerEintrag>.from(state.leitner);
    final rein = !leitner.containsKey(wortId);
    if (rein) {
      final jetzt = DateTime.now();
      await _ablage.archivLeitnerAufnehmen(wortId, jetzt);
      leitner[wortId] = VokabLeitnerEintrag(
          box: 1, nextReviewDate: jetzt.toIso8601String());
    } else {
      await _ablage.archivLeitnerEntfernen(wortId);
      leitner.remove(wortId);
    }
    state = state.copyWith(leitner: leitner);
    return rein;
  }

  Future<VokabKategorie> createKategorie(String name) async {
    await _ready;
    final neu = VokabKategorie(
        id: 'kat_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim());
    await _ablage.archivKategorieAnlegen(neu.id, neu.name);
    state = state.copyWith(kategorien: [...state.kategorien, neu]);
    return neu;
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
    final drin = kat.wortIds.contains(wortId);
    await _ablage.archivKategorieWortSetzen(katId, wortId, !drin);
    state = state.copyWith(
        kategorien: state.kategorien.map((k) {
      if (k.id != katId) return k;
      return VokabKategorie(
          id: k.id,
          name: k.name,
          wortIds: drin
              ? k.wortIds.where((i) => i != wortId).toList()
              : [...k.wortIds, wortId]);
    }).toList());
  }
}

final vokabularUserProvider =
    NotifierProvider<VokabularUserStore, VokabularUserState>(
        VokabularUserStore.new);
