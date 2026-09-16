// FILE: lib/core/backup/user_state_repository.dart
// PHASE: فاز S, Schritt S.0a-2 (2026-09-15)
// PURPOSE: Die Fassade — die EINZIGE Stelle, die weiß, wo der Nutzerzustand
//          wirklich liegt. Nach außen gibt es nur `NutzerZustand`
//          (core/backup/nutzer_zustand.dart).
//
// STAND S.0c (2026-09-16): Archivkarten-Leitner (S.0b) UND Archiv-Listen
// (S.0c) liegen jetzt in drift (ArchivLeitner bzw. ArchivKategorien/
// ArchivKategorieWoerter), nicht mehr in SharedPreferences. `lesen()` liest
// SharedPreferences trotzdem noch mit — Nutzer, die die App vorher
// installiert haben, haben ihren Stand dort; er wird beim nächsten
// `anwenden()` automatisch übernommen (zusammengeführt, nie überschrieben)
// und der alte Schlüssel danach geleert. Notizen bleiben in
// SharedPreferences (Freitext, kein Kandidat für eine eigene Tabelle).
//
// WARUM: Ohne diese Schicht müsste jede Sicherung (S.2) und jede
// Synchronisierung (S.3) beide Ablagen einzeln kennen und alles doppelt
// schreiben. Wenn S.0b die Ablage auf drift vereinheitlicht, ändert sich NUR
// diese Datei — Export, Import und Konto bleiben unberührt.
//
// ⚠️ IDs sind immer Text und geräteunabhängig (siehe nutzer_zustand.dart):
//    · Archivkarten   `adjektiv_stolz`
//    · eigene Wörter  `eigen:<german>|<wordType>`
//    · eigene Listen  feste `uid` der Zeile (S.6): `eigen:#<32 Hex>` für neue,
//                     `eigen:<Name>` für Listen von vor S.6 — Umbenennen
//                     ändert sie nie
//    Die fortlaufenden drift-Nummern bleiben lokal und verlassen das Gerät nie.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import 'nutzer_zustand.dart';

/// SharedPreferences-Schlüssel des Wortarchivs.
///
/// ⚠️ Seit S.0b/S.0c sind [kVokabLeitnerKey] und [kVokabKategorienKey] nur
/// noch **Altbestand**: Sie werden gelesen, übernommen und danach geleert
/// (siehe [UserStateRepository.uebergangAbschliessen]). Geschrieben wird
/// dorthin nie mehr. Nur [kVokabNotizenKey] ist weiter die echte Ablage.
///
/// Die Schlüssel liegen hier und nicht im Wort-Store (`features/vokabular/…`),
/// damit `core/` kein Feature importiert (B-11, 2026-09-15).
const kVokabLeitnerKey = 'vokab_user_leitner_v1';
const kVokabKategorienKey = 'vokab_user_kategorien_v1';
const kVokabNotizenKey = 'vokab_user_notizen_v1';

/// Einstellungsschlüssel, die zum Nutzer gehören und mitgesichert werden.
/// Bewusst eine ausdrückliche Liste: so wandert nie versehentlich ein
/// technisches Flag (Seeding-Marker o. Ä.) in eine Sicherung.
const einstellungsSchluessel = <String>[
  'theme_mode',
  'tts_rate',
  'tts_language',
  'current_level',
  'daily_goal_min',
  'ui_language',
];

const _eigenPraefix = 'eigen:';

class UserStateRepository {
  UserStateRepository(this._db, this._prefs);

  final AppDatabase _db;
  final SharedPreferences _prefs;

  // ── Lesen ──────────────────────────────────────────────────────────────

  Future<NutzerZustand> lesen() async {
    final woerter = await _db.select(_db.words).get();
    final nachId = {for (final w in woerter) w.id: w};

    // Leitner aus ALLEN Quellen in eine Map.
    final leitner = <String, LeitnerStand>{};

    // (1) Archivkarten — drift (seit S.0b; vorher SharedPreferences).
    for (final k in await _db.select(_db.archivLeitner).get()) {
      leitner[k.wortId] = LeitnerStand(
        wortId: k.wortId,
        fach: k.boxNumber,
        naechsteWiederholung: k.nextReview,
        letzteWiederholung: k.lastReview,
      );
    }

    // (1b) Übergangspfad: Archivkarten-Stand, der noch in SharedPreferences
    // liegt (Geräte von vor S.0b). Nur übernehmen, wenn drift noch nichts
    // Neueres für dasselbe Wort hat — sonst „höchstes Fach gewinnt" später
    // in zusammenfuehren() sauberer lösen als hier zweimal zu vergleichen.
    final archivRoh = _prefs.getString(kVokabLeitnerKey);
    if (archivRoh != null) {
      final map = _jsonMap(archivRoh);
      map.forEach((wortId, v) {
        if (v is! Map || leitner.containsKey(wortId)) return;
        final e = v.cast<String, dynamic>();
        leitner[wortId] = LeitnerStand(
          wortId: wortId,
          fach: (e['box'] as num?)?.toInt() ?? 1,
          naechsteWiederholung: _datum(e['nextReviewDate']),
        );
      });
    }

    // (2) Eigene Wörter — drift. Die Kartennummer wird über Words aufgelöst;
    //     eine Karte ohne zugehöriges Wort wird still übersprungen.
    for (final k in await _db.select(_db.leitnerCards).get()) {
      final w = nachId[k.wordId];
      if (w == null) continue;
      final id = LeitnerStand.eigenesWort(w.german, w.wordType);
      leitner[id] = LeitnerStand(
        wortId: id,
        fach: k.boxNumber,
        naechsteWiederholung: k.nextReview,
        letzteWiederholung: k.lastReview,
      );
    }

    // Kategorien aus ALLEN Quellen.
    final kategorien = <String, KategorieStand>{};

    // (1) Archiv-Listen — drift (seit S.0c; vorher SharedPreferences).
    final archivKatZuordnung = await _db.select(_db.archivKategorieWoerter).get();
    for (final k in await _db.select(_db.archivKategorien).get()) {
      kategorien[k.id] = KategorieStand(
        id: k.id,
        name: k.name,
        wortIds: archivKatZuordnung
            .where((z) => z.kategorieId == k.id)
            .map((z) => z.wortId)
            .toList(),
      );
    }

    // (1b) Übergangspfad: Archiv-Listen, die noch in SharedPreferences liegen
    // (Geräte von vor S.0c). Nur übernehmen, wenn drift dieselbe id noch
    // nicht kennt — sonst entscheidet zusammenfuehren() später sauberer.
    final katRoh = _prefs.getString(kVokabKategorienKey);
    if (katRoh != null) {
      for (final e in _jsonListe(katRoh)) {
        final id = e['id'] as String? ?? '';
        if (id.isEmpty || kategorien.containsKey(id)) continue;
        kategorien[id] = KategorieStand(
          id: id,
          name: e['name'] as String? ?? '',
          wortIds: (e['wortIds'] as List?)?.cast<String>() ?? const [],
        );
      }
    }

    // (2) Eigene Listen — drift, wie schon vor S.0c.
    final zuordnung = await _db.select(_db.categoryWords).get();
    for (final k in await _db.select(_db.userCategories).get()) {
      final ids = zuordnung
          .where((z) => z.categoryId == k.id)
          .map((z) => nachId[z.wordId])
          .whereType<Word>()
          .map((w) => LeitnerStand.eigenesWort(w.german, w.wordType))
          .toList();
      final id = eigeneListenId(k); // S.6: feste id, nicht der Name
      final nameAmMs = k.nameAmMs;
      kategorien[id] = KategorieStand(
        id: id,
        name: k.name,
        nameAm: nameAmMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(nameAmMs, isUtc: true),
        wortIds: ids,
      );
    }

    // Notizen — nur Archiv.
    final notizen = <String, NotizStand>{};
    final notizRoh = _prefs.getString(kVokabNotizenKey);
    if (notizRoh != null) {
      _jsonMap(notizRoh).forEach((wortId, v) {
        if (v is! Map) return;
        notizen[wortId] = NotizStand.vonJson(v.cast<String, dynamic>());
      });
    }

    return NutzerZustand(
      leitner: leitner,
      kategorien: kategorien.values.toList(),
      notizen: notizen,
      einstellungen: {
        for (final k in einstellungsSchluessel)
          if (_prefs.containsKey(k)) k: _prefs.get(k),
      },
      // S.5: App-Wörter bringt jedes Gerät selbst mit — nicht sichern.
      // Verweise auf sie (Leitner, Listen) bleiben oben trotzdem erhalten.
      eigeneWoerter: woerter
          .where((w) => w.ausApp != true)
          .map(_wortZuJson)
          .toList(),
      mitgliedschaften: {
        for (final m in await _db.select(_db.mitgliedschaften).get())
          mitgliedschaftsSchluessel(m.art, m.schluessel, m.wort): Mitgliedschaft(
            art: m.art,
            id: m.schluessel,
            wort: m.wort,
            drin: m.drin,
            am: DateTime.fromMillisecondsSinceEpoch(m.amMs, isUtc: true),
          ),
      },
    );
  }

  // ── Schreiben ──────────────────────────────────────────────────────────

  /// Schließt den Übergang von SharedPreferences nach drift (S.0b/S.0c)
  /// **sofort** ab, statt erst beim nächsten Einspielen.
  ///
  /// Wird vom Wort-Store beim Laden gerufen (B-11): Der Store liest seit
  /// B-11 nur noch drift. Läge ein Altbestand dann noch in SharedPreferences,
  /// sähe der Nutzer ihn nicht — deshalb wird er vorher übernommen.
  /// Ohne Altbestand passiert nichts. Dieselbe Logik wie beim Einspielen
  /// (ein leerer Stand wird zusammengeführt), kein zweiter Weg.
  Future<void> uebergangAbschliessen() async {
    if (!_prefs.containsKey(kVokabLeitnerKey) &&
        !_prefs.containsKey(kVokabKategorienKey)) {
      return;
    }
    await anwenden(const NutzerZustand());
  }


  /// Führt `eingehend` mit dem aktuellen Stand zusammen („höchstes Fach
  /// gewinnt", siehe nutzer_zustand.dart) und legt das Ergebnis ab.
  /// Nichts wird gelöscht — eine Wiederherstellung darf nie Fortschritt kosten.
  ///
  /// **Ausnahme (S.5):** Was der Nutzer auf einem Gerät ausdrücklich entfernt
  /// hat (spätere [Mitgliedschaft] mit `drin == false`), wird auch hier
  /// entfernt. Das ist kein Datenverlust, sondern seine Handlung.
  Future<NutzerZustand> anwenden(NutzerZustand eingehend) async {
    final zusammen = (await lesen()).zusammenfuehren(eingehend);

    // (0) Ereignisse ablegen — der zusammengeführte Stand enthält je Schlüssel
    //     bereits die spätere Handlung.
    for (final m in zusammen.mitgliedschaften.values) {
      await _db.mitgliedschaftMerken(m.art, m.id,
          wort: m.wort, drin: m.drin, am: m.am);
    }
    // (0b) Entfernungen hier nachvollziehen.
    for (final m in zusammen.mitgliedschaften.values) {
      if (!m.drin) await _entfernen(m);
    }

    // (1) Eigene Wörter zuerst: Leitner und Listen brauchen ihre Nummern.
    for (final w in zusammen.eigeneWoerter) {
      final companion = WordsCompanion.insert(
        german: w['german'] as String,
        wordType: w['wordType'] as String,
        meaningFa: w['meaningFa'] as String? ?? '',
        article: Value(w['article'] as String?),
        plural: Value(w['plural'] as String?),
        level: Value(w['level'] as String?),
        meaningEn: Value(w['meaningEn'] as String?),
        pronunciation: Value(w['pronunciation'] as String?),
        examplesJson: Value(w['examplesJson'] as String?),
        conjugationJson: Value(w['conjugationJson'] as String?),
        etymology: Value(w['etymology'] as String?),
        commonErrors: Value(w['commonErrors'] as String?),
        grammarNote: Value(w['grammarNote'] as String?),
        // B-12: Grammatikfelder aus B-10 — ohne sie verlöre ein Gerätewechsel
        // die Symbole für Verb/Präposition/Konnektor.
        regelmaessig: Value(w['regelmaessig'] as bool?),
        trennbar: Value(w['trennbar'] as bool?),
        grammatikDetail: Value(w['grammatikDetail'] as String?),
      );
      await _db.into(_db.words).insert(
            companion,
            onConflict: DoUpdate((_) => companion,
                target: [_db.words.german, _db.words.wordType]),
          );
    }

    // Nummern neu einlesen — die Einfügungen oben haben sie vergeben.
    final nachSchluessel = {
      for (final w in await _db.select(_db.words).get())
        LeitnerStand.eigenesWort(w.german, w.wordType): w.id,
    };

    // (2) Leitner aufteilen: Archivkarten → ArchivLeitner (drift), eigene
    //     Wörter → LeitnerCards (drift). SharedPreferences bekommt hier
    //     nichts Neues mehr — nur (1b) liest von dort noch mit.
    for (final e in zusammen.leitner.entries) {
      if (e.key.startsWith(_eigenPraefix)) {
        final wordId = nachSchluessel[e.key];
        if (wordId == null) continue; // Wort fehlt — Karte wäre sinnlos
        final vorhanden = await (_db.select(_db.leitnerCards)
              ..where((t) => t.wordId.equals(wordId)))
            .getSingleOrNull();
        final companion = LeitnerCardsCompanion.insert(
          wordId: wordId,
          boxNumber: Value(e.value.fach),
          nextReview: e.value.naechsteWiederholung ?? DateTime.now(),
          lastReview: Value(e.value.letzteWiederholung),
        );
        if (vorhanden == null) {
          await _db.into(_db.leitnerCards).insert(companion);
        } else {
          await (_db.update(_db.leitnerCards)
                ..where((t) => t.id.equals(vorhanden.id)))
              .write(companion);
        }
      } else {
        final companion = ArchivLeitnerCompanion.insert(
          wortId: e.key,
          boxNumber: Value(e.value.fach),
          nextReview: e.value.naechsteWiederholung ?? DateTime.now(),
          lastReview: Value(e.value.letzteWiederholung),
        );
        await _db.into(_db.archivLeitner).insert(
              companion,
              onConflict:
                  DoUpdate((_) => companion, target: [_db.archivLeitner.wortId]),
            );
      }
    }
    // Übergangsschlüssel leeren: der Stand liegt jetzt vollständig in drift.
    // Erst NACH erfolgreichem Schreiben oben — sonst könnte ein Absturz
    // dazwischen Fortschritt kosten.
    await _prefs.remove(kVokabLeitnerKey);

    // (3) Kategorien aufteilen: Archiv-Listen → drift (seit S.0c), eigene
    //     Listen → drift wie zuvor. SharedPreferences bekommt hier nichts
    //     Neues mehr — nur (1b) oben liest von dort noch mit.
    for (final k in zusammen.kategorien) {
      if (!k.id.startsWith(_eigenPraefix)) {
        await _db.into(_db.archivKategorien).insert(
              ArchivKategorienCompanion.insert(id: k.id, name: k.name),
              onConflict: DoUpdate(
                  (_) => ArchivKategorienCompanion.insert(id: k.id, name: k.name),
                  target: [_db.archivKategorien.id]),
            );
        for (final wortId in k.wortIds) {
          await _db.into(_db.archivKategorieWoerter).insert(
                ArchivKategorieWoerterCompanion.insert(
                    kategorieId: k.id, wortId: wortId),
                mode: InsertMode.insertOrIgnore,
              );
        }
        continue;
      }
      // S.6: über die feste id suchen, nicht über den Namen. Der Name im
      // zusammengeführten Stand ist schon der gültige (später vergebener
      // gewinnt) — er wird hier nur übernommen.
      final vorhanden = await _eigeneListe(k.id);
      final nameAmMs = k.nameAm?.millisecondsSinceEpoch;
      final int katId;
      if (vorhanden == null) {
        katId = await _db.into(_db.userCategories).insert(
              UserCategoriesCompanion.insert(
                name: k.name,
                uid: Value(k.id),
                nameAmMs: Value(nameAmMs),
              ),
            );
      } else {
        katId = vorhanden.id;
        if (vorhanden.name != k.name || vorhanden.nameAmMs != nameAmMs) {
          await (_db.update(_db.userCategories)
                ..where((t) => t.id.equals(vorhanden.id)))
              .write(UserCategoriesCompanion(
                name: Value(k.name),
                nameAmMs: Value(nameAmMs),
              ));
        }
      }
      for (final wortId in k.wortIds) {
        final nummer = nachSchluessel[wortId];
        if (nummer == null) continue;
        await _db.into(_db.categoryWords).insert(
              CategoryWordsCompanion.insert(
                  categoryId: katId, wordId: nummer),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    // Übergangsschlüssel leeren: der Stand liegt jetzt vollständig in drift.
    await _prefs.remove(kVokabKategorienKey);

    // (4) Notizen.
    await _prefs.setString(
      kVokabNotizenKey,
      jsonEncode(zusammen.notizen.map((k, v) => MapEntry(k, v.toJson()))),
    );

    // (5) Einstellungen — nur bekannte Schlüssel, Typ muss passen.
    for (final k in einstellungsSchluessel) {
      final wert = zusammen.einstellungen[k];
      if (wert is int) {
        await _prefs.setInt(k, wert);
      } else if (wert is double) {
        await _prefs.setDouble(k, wert);
      } else if (wert is bool) {
        await _prefs.setBool(k, wert);
      } else if (wert is String) {
        await _prefs.setString(k, wert);
      }
    }

    return zusammen;
  }

  /// Setzt EINE Entfernung in der Ablage um (S.5). Mehrfach ausführbar.
  Future<void> _entfernen(Mitgliedschaft m) async {
    switch (m.art) {
      case artLeitner:
        if (m.id.startsWith(_eigenPraefix)) {
          final w = await _wortNachId(m.id);
          if (w != null) {
            await (_db.delete(_db.leitnerCards)
                  ..where((t) => t.wordId.equals(w.id)))
                .go();
          }
        } else {
          await (_db.delete(_db.archivLeitner)
                ..where((t) => t.wortId.equals(m.id)))
              .go();
        }
      case artListe:
        if (m.id.startsWith(_eigenPraefix)) {
          final kat = await _eigeneListe(m.id);
          if (kat != null) {
            await (_db.delete(_db.categoryWords)
                  ..where((t) => t.categoryId.equals(kat.id)))
                .go();
            await (_db.delete(_db.userCategories)
                  ..where((t) => t.id.equals(kat.id)))
                .go();
          }
        } else {
          await (_db.delete(_db.archivKategorieWoerter)
                ..where((t) => t.kategorieId.equals(m.id)))
              .go();
          await (_db.delete(_db.archivKategorien)
                ..where((t) => t.id.equals(m.id)))
              .go();
        }
      case artListenwort:
        if (m.id.startsWith(_eigenPraefix)) {
          final kat = await _eigeneListe(m.id);
          final w = await _wortNachId(m.wort);
          if (kat != null && w != null) {
            await (_db.delete(_db.categoryWords)
                  ..where((t) =>
                      t.categoryId.equals(kat.id) & t.wordId.equals(w.id)))
                .go();
          }
        } else {
          await (_db.delete(_db.archivKategorieWoerter)
                ..where((t) =>
                    t.kategorieId.equals(m.id) & t.wortId.equals(m.wort)))
              .go();
        }
      case artWort:
        final w = await _wortNachId('$_eigenPraefix${m.id}');
        // Nur Nutzerwörter — ein App-Wort bringt jedes Gerät selbst mit.
        if (w != null && w.ausApp != true) {
          await (_db.delete(_db.leitnerCards)
                ..where((t) => t.wordId.equals(w.id)))
              .go();
          await (_db.delete(_db.categoryWords)
                ..where((t) => t.wordId.equals(w.id)))
              .go();
          await (_db.delete(_db.wordBooks)
                ..where((t) => t.wordId.equals(w.id)))
              .go();
          await (_db.delete(_db.words)..where((t) => t.id.equals(w.id))).go();
        }
    }
  }

  /// `eigen:<german>|<wordType>` → Zeile in `Words`.
  Future<Word?> _wortNachId(String wortId) async {
    if (!wortId.startsWith(_eigenPraefix)) return null;
    final schluessel = wortId.substring(_eigenPraefix.length);
    final trenner = schluessel.lastIndexOf('|');
    if (trenner < 0) return null;
    final german = schluessel.substring(0, trenner);
    final wordType = schluessel.substring(trenner + 1);
    return (_db.select(_db.words)
          ..where((t) => t.german.equals(german) & t.wordType.equals(wordType)))
        .getSingleOrNull();
  }

  /// Listen-id → Zeile in `UserCategories` — über die feste `uid` (S.6),
  /// nicht über den Namen. Eindeutig dank Index `user_categories_uid`.
  Future<UserCategory?> _eigeneListe(String listenId) =>
      (_db.select(_db.userCategories)..where((t) => t.uid.equals(listenId)))
          .getSingleOrNull();

  // ── Wortarchiv: Einzelzugriffe für den Wort-Store (B-11) ───────────────
  //
  // Der Store in `features/vokabular/controllers/vokabular_user_state.dart`
  // liest und schreibt hierüber — so kennt weiterhin NUR diese Datei die
  // Tabellen. Sicherung, Konto und App teilen damit dieselbe Ablage.

  /// Nur der Archiv-Teil: Leitner und Listen der Archivkarten.
  /// (Eigene Wörter, Notizen und Einstellungen bleiben hier leer.)
  Future<NutzerZustand> archivLesen() async {
    final zuordnung = await _db.select(_db.archivKategorieWoerter).get();
    final kategorien = await _db.select(_db.archivKategorien).get();
    // Feste Reihenfolge: ids sind `kat_<Millisekunden>`, also nach Anlage.
    kategorien.sort((a, b) => a.id.compareTo(b.id));
    return NutzerZustand(
      leitner: {
        for (final k in await _db.select(_db.archivLeitner).get())
          k.wortId: LeitnerStand(
            wortId: k.wortId,
            fach: k.boxNumber,
            naechsteWiederholung: k.nextReview,
            letzteWiederholung: k.lastReview,
          ),
      },
      kategorien: [
        for (final k in kategorien)
          KategorieStand(
            id: k.id,
            name: k.name,
            wortIds: [
              for (final z in zuordnung)
                if (z.kategorieId == k.id) z.wortId,
            ],
          ),
      ],
    );
  }

  /// Archivkarte in den Stapel: Fach 1, fällig ab [faellig].
  Future<void> archivLeitnerAufnehmen(String wortId, DateTime faellig) async {
    final companion = ArchivLeitnerCompanion.insert(
      wortId: wortId,
      boxNumber: const Value(1),
      nextReview: faellig,
    );
    await _db.into(_db.archivLeitner).insert(
          companion,
          onConflict:
              DoUpdate((_) => companion, target: [_db.archivLeitner.wortId]),
        );
    await _db.mitgliedschaftMerken(artLeitner, wortId, drin: true); // S.5
  }

  /// Archivkarte aus dem Stapel — auf ausdrücklichen Wunsch des Nutzers.
  Future<void> archivLeitnerEntfernen(String wortId) async {
    await (_db.delete(_db.archivLeitner)
          ..where((t) => t.wortId.equals(wortId)))
        .go();
    await _db.mitgliedschaftMerken(artLeitner, wortId, drin: false); // S.5
  }

  Future<void> archivKategorieAnlegen(String id, String name) async {
    await _db
        .into(_db.archivKategorien)
        .insert(ArchivKategorienCompanion.insert(id: id, name: name));
    await _db.mitgliedschaftMerken(artListe, id, drin: true); // S.5
  }

  /// Wort in eine Liste aufnehmen ([drin] wahr) oder daraus entfernen.
  Future<void> archivKategorieWortSetzen(
      String kategorieId, String wortId, bool drin) async {
    if (drin) {
      await _db.into(_db.archivKategorieWoerter).insert(
            ArchivKategorieWoerterCompanion.insert(
                kategorieId: kategorieId, wortId: wortId),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_db.delete(_db.archivKategorieWoerter)
            ..where((t) =>
                t.kategorieId.equals(kategorieId) & t.wortId.equals(wortId)))
          .go();
    }
    await _db.mitgliedschaftMerken(artListenwort, kategorieId,
        wort: wortId, drin: drin); // S.5
  }

  // ── Helfer ─────────────────────────────────────────────────────────────

  static Map<String, dynamic> _wortZuJson(Word w) => {
        // Bewusst OHNE w.id und ohne createdAt: beides ist gerätelokal.
        'german': w.german,
        'wordType': w.wordType,
        'meaningFa': w.meaningFa,
        'article': w.article,
        'plural': w.plural,
        'level': w.level,
        'meaningEn': w.meaningEn,
        'pronunciation': w.pronunciation,
        'examplesJson': w.examplesJson,
        'conjugationJson': w.conjugationJson,
        'etymology': w.etymology,
        'commonErrors': w.commonErrors,
        'grammarNote': w.grammarNote,
        'regelmaessig': w.regelmaessig,
        'trennbar': w.trennbar,
        'grammatikDetail': w.grammatikDetail,
      };

  static Map<String, dynamic> _jsonMap(String roh) {
    final d = jsonDecode(roh);
    return d is Map ? d.cast<String, dynamic>() : <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _jsonListe(String roh) {
    final d = jsonDecode(roh);
    return d is List
        ? d.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : <Map<String, dynamic>>[];
  }

  static DateTime? _datum(Object? wert) =>
      wert is String ? DateTime.tryParse(wert) : null;
}
