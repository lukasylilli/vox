// FILE: lib/features/vokabular/controllers/vokabular_user_state.dart
// PURPOSE: User-Zustand des Vokabular-Archivs (فاز V, Stufe ۳) — GETRENNT vom
//          read-only Karten-Content (Assets/vocab.db):
//          · Leitner-Mitgliedschaft: Wortschatz ≠ Leitner! Von ۲۵٬۰۰۰ Wörtern
//            landen NUR explizit hinzugefügte im Lernstapel (Flag, kein Auto-Import).
//          · Eigene Kategorien: benutzerdefinierte Listen (نام + Wort-IDs).
//          Persistenz: SharedPreferences (JSON) — bewusst leichtgewichtig für die
//          Testphase; V.3 migriert nach drift neben vocab.db, API bleibt gleich.
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Öffentlich, damit die Fassade (core/backup/user_state_repository.dart)
// dieselben Schlüssel benutzt und nicht eine zweite Kopie pflegt (Puzzling).
const kVokabLeitnerKey = 'vokab_user_leitner_v1';
const kVokabKategorienKey = 'vokab_user_kategorien_v1';
const kVokabNotizenKey = 'vokab_user_notizen_v1';

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
  // Mutationen warten auf _load — sonst Race auf _prefs direkt nach Start.
  late final Future<void> _ready;

  @override
  VokabularUserState build() {
    _ready = _load();
    return const VokabularUserState();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final leitnerRaw = _prefs.getString(kVokabLeitnerKey);
    final katRaw = _prefs.getString(kVokabKategorienKey);
    final notizenRaw = _prefs.getString(kVokabNotizenKey);
    state = VokabularUserState(
      leitner: leitnerRaw == null
          ? const {}
          : (jsonDecode(leitnerRaw) as Map<String, dynamic>).map((k, v) =>
              MapEntry(
                  k, VokabLeitnerEintrag.fromJson(v as Map<String, dynamic>))),
      kategorien: katRaw == null
          ? const []
          : (jsonDecode(katRaw) as List)
              .map((j) => VokabKategorie.fromJson(j as Map<String, dynamic>))
              .toList(),
      notizen: notizenRaw == null
          ? const {}
          : (jsonDecode(notizenRaw) as Map<String, dynamic>).map((k, v) =>
              MapEntry(k, VokabNotiz.fromJson(v as Map<String, dynamic>))),
    );
  }

  Future<void> _saveLeitner() => _prefs.setString(kVokabLeitnerKey,
      jsonEncode(state.leitner.map((k, v) => MapEntry(k, v.toJson()))));

  Future<void> _saveKategorien() => _prefs.setString(kVokabKategorienKey,
      jsonEncode(state.kategorien.map((k) => k.toJson()).toList()));

  /// Rein → Box 1, Review sofort fällig; raus → Eintrag weg (Fortschritt weg).
  /// Rückgabe: neuer imLeitner-Zustand.
  Future<bool> toggleLeitner(String wortId) async {
    await _ready;
    final leitner = Map<String, VokabLeitnerEintrag>.from(state.leitner);
    final rein = !leitner.containsKey(wortId);
    if (rein) {
      leitner[wortId] = VokabLeitnerEintrag(
          box: 1, nextReviewDate: DateTime.now().toIso8601String());
    } else {
      leitner.remove(wortId);
    }
    state = state.copyWith(leitner: leitner);
    await _saveLeitner();
    return rein;
  }

  Future<VokabKategorie> createKategorie(String name) async {
    await _ready;
    final neu = VokabKategorie(
        id: 'kat_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim());
    state = state.copyWith(kategorien: [...state.kategorien, neu]);
    await _saveKategorien();
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
    state = state.copyWith(
        kategorien: state.kategorien.map((k) {
      if (k.id != katId) return k;
      final drin = k.wortIds.contains(wortId);
      return VokabKategorie(
          id: k.id,
          name: k.name,
          wortIds: drin
              ? k.wortIds.where((i) => i != wortId).toList()
              : [...k.wortIds, wortId]);
    }).toList());
    await _saveKategorien();
  }
}

final vokabularUserProvider =
    NotifierProvider<VokabularUserStore, VokabularUserState>(
        VokabularUserStore.new);
