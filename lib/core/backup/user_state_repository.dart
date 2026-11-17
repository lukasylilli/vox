// FILE: lib/core/backup/user_state_repository.dart
// PHASE: فاز S, Schritt S.0a-2 (2026-09-15)
// PURPOSE: Die Fassade — die EINZIGE Stelle, die weiß, wo der Nutzerzustand
//          wirklich liegt. Nach außen gibt es nur `NutzerZustand`
//          (core/backup/nutzer_zustand.dart).
//
// STAND X.2 (2026-11-17, Leitner wie Anki): Fortschritt («Wort × Übung»),
// Decks und ihre Wörter liegen in drift (LeitnerFortschritt, Decks,
// DeckWoerter) — gelesen und geschrieben über `LeitnerDao`. `lesen()` liest
// SharedPreferences trotzdem noch mit — Nutzer, die die App vor S.0b/S.0c
// installiert haben, können ihren Stand noch dort haben; er wird beim
// nächsten `anwenden()` automatisch übernommen (zusammengeführt, nie
// überschrieben) und der alte Schlüssel danach geleert. Notizen bleiben in
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
//    · Decks          feste id (S.6): `eigen:#<32 Hex>` für neue,
//                     `eigen:<Name>` / `kat_<Millisekunden>` für Listen von
//                     früher, `deck:leitner` für den Stapel — Umbenennen
//                     ändert sie nie
//    Die fortlaufenden drift-Nummern bleiben lokal und verlassen das Gerät nie.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../database/dao/leitner_dao.dart';
import 'nutzer_profil.dart';
import 'nutzer_zustand.dart';
import 'pruefungs_ergebnis.dart';

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

/// Persönliche Angaben (P.1) — ein JSON-Text ([NutzerProfil.zuText]). Liegt in
/// SharedPreferences; der Vertrag (`nutzer_zustand.dart`, Fassung 4) trägt ihn
/// in Datei und Cloud-Kopie.
const kProfilKey = 'vox_profil_v1';

/// Ergebnisse abgeschlossener Tests (T.1) — eine JSON-Liste
/// ([PruefungsErgebnis.listeSchreiben]). Liegt in SharedPreferences; der
/// Vertrag (Fassung 5) trägt sie in Datei und Cloud-Kopie.
const kPruefungenKey = 'vox_pruefungen_v1';

/// Alle gespeicherten Testergebnisse dieses Geräts. Unlesbares ⇒ leer.
Map<String, PruefungsErgebnis> pruefungenLesen(SharedPreferences prefs) {
  final roh = prefs.getString(kPruefungenKey);
  if (roh == null) return const {};
  try {
    return PruefungsErgebnis.listeLesen(jsonDecode(roh));
  } catch (_) {
    return const {};
  }
}

/// Fügt EIN Ergebnis hinzu (T.1). Vorhandene werden nie verändert.
Future<void> pruefungMerken(
    SharedPreferences prefs, PruefungsErgebnis ergebnis) async {
  final alle = PruefungsErgebnis.vereinigen(
      pruefungenLesen(prefs), {ergebnis.id: ergebnis});
  await prefs.setString(
      kPruefungenKey, jsonEncode(PruefungsErgebnis.listeSchreiben(alle)));
}

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
  /// Decks, Wörter und Fortschritt — dieselbe Ablage, die auch die App
  /// selbst benutzt (X.2).
  late final LeitnerDao leitner = LeitnerDao(_db);

  // ── Lesen ──────────────────────────────────────────────────────────────

  Future<NutzerZustand> lesen() async {
    final woerter = await _db.select(_db.words).get();

    // Fortschritt «Wort × Übung» — drift (X.2).
    final leitner = <String, LeitnerStand>{};
    final uebungen = <String, Map<String, LeitnerStand>>{};
    for (final z in await _db.select(_db.leitnerFortschritt).get()) {
      final stand = LeitnerStand(
        wortId: z.wortId,
        fach: z.fach,
        naechsteWiederholung: z.naechsteWiederholung,
        letzteWiederholung: z.letzteWiederholung,
      );
      if (z.uebung == uebungBedeutung) {
        leitner[z.wortId] = stand;
      } else {
        (uebungen[z.uebung] ??= {})[z.wortId] = stand;
      }
    }

    // Decks und ihre Wörter — drift (X.2). Wörter in der Reihenfolge der
    // Aufnahme.
    final zuordnung = await (_db.select(_db.deckWoerter)
          ..orderBy([
            (t) => OrderingTerm.asc(t.hinzuMs),
            (t) => OrderingTerm.asc(t.rowId), // gleiche Millisekunde ⇒ Einfügefolge
          ]))
        .get();
    DateTime? zeit(int? ms) => ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    final kategorien = <String, KategorieStand>{
      for (final d in await _db.select(_db.decks).get())
        d.id: KategorieStand(
          id: d.id,
          name: d.name,
          nameAm: zeit(d.nameAmMs),
          wortIds: [
            for (final z in zuordnung)
              if (z.deckId == d.id) z.wortId,
          ],
          eltern: d.elternId,
          modus: d.modus,
          neuProTag: d.neuProTag,
          ordnung: d.ordnung,
          standAm: zeit(d.standAmMs),
        ),
    };

    // (1b) Übergangspfad: Archivkarten-Stand, der noch in SharedPreferences
    // liegt (Geräte von vor S.0b). Dort hieß «steht drin» zugleich «ist im
    // Stapel» ⇒ Fortschritt UND Platz im Standard-Deck. Nur übernehmen, wenn
    // drift für dasselbe Wort noch nichts hat.
    final archivRoh = _prefs.getString(kVokabLeitnerKey);
    if (archivRoh != null) {
      final imStapel = <String>[];
      _jsonMap(archivRoh).forEach((wortId, v) {
        if (v is! Map) return;
        imStapel.add(wortId);
        if (leitner.containsKey(wortId)) return;
        final e = v.cast<String, dynamic>();
        leitner[wortId] = LeitnerStand(
          wortId: wortId,
          fach: (e['box'] as num?)?.toInt() ?? 1,
          naechsteWiederholung: _datum(e['nextReviewDate']),
        );
      });
      if (imStapel.isNotEmpty) {
        final deck = kategorien[standardDeckId] ??
            const KategorieStand(
                id: standardDeckId,
                name: standardDeckName,
                modus: deckModusWiederholen);
        kategorien[standardDeckId] =
            deck.mit(wortIds: {...deck.wortIds, ...imStapel}.toList());
      }
    }

    // (1c) Übergangspfad: Archiv-Listen, die noch in SharedPreferences liegen
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
      uebungen: uebungen,
      kategorien: kategorien.values.toList(),
      notizen: notizen,
      einstellungen: {
        for (final k in einstellungsSchluessel)
          if (_prefs.containsKey(k)) k: _prefs.get(k),
      },
      // P.1: fehlt oder unlesbar ⇒ null (nie eingegeben).
      profil: NutzerProfil.ausText(_prefs.getString(kProfilKey)),
      // T.1: fehlt oder unlesbar ⇒ keine Ergebnisse.
      pruefungen: pruefungenLesen(_prefs),
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
  /// gewinnt", außer nach einer späteren falschen Antwort — siehe
  /// LeitnerStand.zusammen in nutzer_zustand.dart) und legt das Ergebnis ab.
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

    // (2) Fortschritt «Wort × Übung» — der zusammengeführte Stand je Wort.
    Future<void> fortschrittAblegen(
        String uebung, Map<String, LeitnerStand> staende) async {
      for (final stand in staende.values) {
        await leitner.fortschrittSetzen(uebung, stand);
      }
    }

    await fortschrittAblegen(uebungBedeutung, zusammen.leitner);
    for (final e in zusammen.uebungen.entries) {
      await fortschrittAblegen(e.key, e.value);
    }

    // (3) Decks samt Wörtern. Name und Einstellungen im zusammengeführten
    //     Stand sind schon die gültigen (das Spätere gewinnt) — sie werden
    //     hier nur übernommen. Wörter kommen dazu; entfernt wird nur über
    //     Ereignisse (oben, 0b).
    final jetztMs = DateTime.now().millisecondsSinceEpoch;
    for (final k in zusammen.kategorien) {
      final zeile = DecksCompanion.insert(
        id: k.id,
        name: k.name,
        elternId: Value(k.eltern),
        ordnung: Value(k.ordnung),
        modus: Value(k.modus),
        neuProTag: Value(k.neuProTag),
        nameAmMs: Value(k.nameAm?.millisecondsSinceEpoch),
        standAmMs: Value(k.standAm?.millisecondsSinceEpoch),
      );
      await _db.into(_db.decks).insertOnConflictUpdate(zeile);
      for (var i = 0; i < k.wortIds.length; i++) {
        await _db.into(_db.deckWoerter).insert(
              DeckWoerterCompanion.insert(
                deckId: k.id,
                wortId: k.wortIds[i],
                // Reihenfolge des Stands erhalten.
                hinzuMs: Value(jetztMs + i),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    // Übergangsschlüssel leeren: der Stand liegt jetzt vollständig in drift.
    // Erst NACH erfolgreichem Schreiben oben — sonst könnte ein Absturz
    // dazwischen Fortschritt kosten.
    await _prefs.remove(kVokabLeitnerKey);
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

    // (6) Profil (P.1) — der zusammengeführte Stand ganz, so wie
    //     `NutzerProfil.spaeteres` ihn bestimmt hat.
    final profil = zusammen.profil;
    if (profil != null) {
      await _prefs.setString(kProfilKey, profil.zuText());
    }

    // (7) Testergebnisse (T.1) — die Vereinigung; nur schreiben, wenn es
    //     welche gibt (kein leerer Schlüssel auf Geräten ohne Tests).
    if (zusammen.pruefungen.isNotEmpty) {
      await _prefs.setString(kPruefungenKey,
          jsonEncode(PruefungsErgebnis.listeSchreiben(zusammen.pruefungen)));
    }

    return zusammen;
  }

  /// Setzt EINE Entfernung in der Ablage um (S.5). Mehrfach ausführbar.
  /// Der Fortschritt eines Worts bleibt, wenn es ein Deck verlässt (X.2).
  Future<void> _entfernen(Mitgliedschaft m) async {
    switch (m.art) {
      case artListe:
        await (_db.delete(_db.deckWoerter)..where((t) => t.deckId.equals(m.id)))
            .go();
        await (_db.delete(_db.decks)..where((t) => t.id.equals(m.id))).go();
      case artListenwort:
        await (_db.delete(_db.deckWoerter)
              ..where((t) => t.deckId.equals(m.id) & t.wortId.equals(m.wort)))
            .go();
      case artWort:
        final wortId = '$_eigenPraefix${m.id}';
        final w = await _wortNachId(wortId);
        // Nur Nutzerwörter — ein App-Wort bringt jedes Gerät selbst mit.
        // Ein gelöschtes eigenes Wort nimmt Fortschritt und Deck-Plätze mit.
        if (w != null && w.ausApp != true) {
          await (_db.delete(_db.leitnerFortschritt)
                ..where((t) => t.wortId.equals(wortId)))
              .go();
          await (_db.delete(_db.deckWoerter)
                ..where((t) => t.wortId.equals(wortId)))
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
