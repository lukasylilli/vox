// FILE: lib/core/backup/nutzer_zustand.dart
// PHASE: فاز S, Schritt S.0a (2026-09-15)
// PURPOSE: Die EINE Beschreibung dessen, was einem Nutzer gehört — und die
//          Regeln, wie zwei Stände zusammengeführt werden.
//
// ⚠️ DIESE DATEI IST DER VERTRAG. Sie kennt bewusst weder drift noch
//    SharedPreferences noch Flutter — reines Dart, damit sie vollständig
//    prüfbar bleibt und sich nicht ändern muss, wenn die Ablage darunter
//    wechselt (S.0b) oder ein Konto dazukommt (S.3).
//
// WARUM SO: Der Nutzerzustand liegt heute in zwei Ablagen (drift +
// SharedPreferences). Ohne diese Zwischenschicht müsste jede Sicherung, jede
// Synchronisierung und jede Migration zweimal geschrieben werden — einmal je
// Ablage. Alles oberhalb kennt nur noch NutzerZustand.
//
// HÜLLE (abgestimmt mit Root-in, PLAN.md → فاز S — gleiche Hülle, andere
// Nutzlast, KEIN geteilter Code):
//   { "version": 1, "exportedAt": "<ISO>", "app": "vox", "payload": { … } }
import 'dart:convert';
import 'dart:math' show Random;

import 'nutzer_profil.dart';
import 'pruefungs_ergebnis.dart';

/// Erhöhen, sobald sich die Form der Nutzlast ändert. `vonJson` muss ältere
/// Fassungen weiter lesen können — eine Sicherung von gestern darf nie
/// unbrauchbar werden.
///
/// Fassung 2 (S.5, 2026-09-15): `mitgliedschaften` — Aufnehmen/Entfernen als
/// Ereignisse mit Zeitpunkt. Fassung 1 hat keine; sie gilt als „älter als jede
/// Handlung" und wird unverändert gelesen.
///
/// Fassung 3 (S.6, 2026-09-16): eigene Listen tragen eine feste id
/// (`eigen:#<32 Hex>`) statt ihres Namens, und `kategorien[].nameAm` sagt, wann
/// der Name vergeben wurde — beim Zusammenführen gewinnt der später vergebene
/// Name. Fassung 2 hat kein `nameAm`; ihre Namen gelten als älter als jede
/// Umbenennung. Listen von vor S.6 behalten ihre alte id `eigen:<Name>`.
///
/// Fassung 4 (P.1, 2026-09-20): `profil` — Name, Telefonnummer, Adressen
/// (`nutzer_profil.dart`). Fehlt das Feld (Fassung 1–3), gibt es kein Profil.
/// Beim Zusammenführen gewinnt der später bearbeitete Stand als Ganzes.
///
/// Fassung 5 (T.1, 2026-09-25): `pruefungen` — Ergebnisse abgeschlossener
/// Tests (`pruefungs_ergebnis.dart`). Nur hinzufügen, nie ändern; beim
/// Zusammenführen vereinigt nach id. Fehlt das Feld (Fassung 1–4) ⇒ keine.
///
/// Fassung 6 (X.2, 2026-11-17 — Leitner wie Anki, `docs/zukunft/PHASE_X.md`):
///   · Der Fortschritt gehört zu «Wort × Übung», nicht mehr zur Anwesenheit im
///     Stapel: `leitner` ist der Fortschritt der Übung [uebungBedeutung] (auch
///     für Wörter, die in keinem Deck mehr sind — Deck löschen kostet nie
///     Fortschritt), `uebungen` der aller anderen Übungen. Fächer 1–7, danach
///     [leitnerGelerntFach].
///   · `kategorien` sind jetzt die **Decks**: zusätzlich `eltern`, `modus`,
///     `neuProTag`, `ordnung`, `standAm`. «Im Leitner» heißt: Mitglied eines
///     Decks; der bisherige Stapel ist das Deck [standardDeckId].
///   · Die Ereignisart [artLeitner] gibt es nicht mehr — Aufnehmen/Entfernen
///     ist [artListenwort] am Deck.
/// Fassung 1–5 wird beim Lesen umgeschrieben ([NutzerZustand.vonJson] mit
/// `version`): jedes Wort aus `leitner` wird Mitglied von [standardDeckId],
/// jedes `leitner`-Ereignis ein `listenwort`-Ereignis an diesem Deck.
const int nutzerZustandVersion = 6;

/// Das Deck, in dem der Stapel von vor Fassung 6 liegt — und in das der
/// Leitner-Knopf ein Wort legt, solange kein anderes Deck gewählt ist.
const String standardDeckId = 'deck:leitner';
const String standardDeckName = 'Leitner';

/// Übung «Bedeutung» (deutsches Wort ⇒ Bedeutung): die bisherige Karte. Der
/// Fortschritt von vor Fassung 6 ist der Fortschritt dieser Übung.
const String uebungBedeutung = 'bedeutung';

/// Höchstes Fach. Eine richtige Antwort in diesem Fach ⇒ [leitnerGelerntFach].
const int leitnerFaecher = 7;

/// «Gelernt»: aus dem letzten Fach heraus. Wird nie mehr wiederholt, bis der
/// Nutzer das Wort von Hand zurück in Fach 1 legt.
const int leitnerGelerntFach = leitnerFaecher + 1;

/// Deck wird wiederholt (Karten erscheinen in der täglichen Wiederholung) …
const String deckModusWiederholen = 'wiederholen';

/// … oder ist nur ein Notizbuch (nie Wiederholung, nie Erinnerung).
const String deckModusNotiz = 'notiz';

/// … oder macht, was das Deck darüber macht (Entscheidung Lukas 2026-11-22:
/// Subdecks folgen dem Eltern-Deck, bis man eines von Hand umstellt). Neue
/// Subdecks bekommen diesen Wert. Ein Deck der obersten Ebene mit «erben»
/// ist ein Notizbuch. Ältere App-Fassungen lesen den unbekannten Wert als
/// Notizbuch — lieber keine Wiederholung als eine ungewollte.
const String deckModusErben = 'erben';

/// Der WIRKLICHE Modus jedes Decks ([deckModusWiederholen] oder
/// [deckModusNotiz]): eigener Modus, bei «erben» der des nächsten Decks
/// darüber. Ein Kreis in den Eltern (nur bei kaputten Daten) bricht ab und
/// gilt als Notizbuch; ein fehlendes Eltern-Deck wie die oberste Ebene.
Map<String, String> effektiveDeckModi<T>(
  Iterable<T> decks, {
  required String Function(T) id,
  required String? Function(T) eltern,
  required String Function(T) modus,
}) {
  final roh = {for (final d in decks) id(d): d};
  final ergebnis = <String, String>{};
  String aufloesen(String start) {
    final weg = <String>[];
    String? aktuell = start;
    var wert = deckModusNotiz;
    while (aktuell != null) {
      final bekannt = ergebnis[aktuell];
      if (bekannt != null) {
        wert = bekannt;
        break;
      }
      final d = roh[aktuell];
      if (d == null || weg.contains(aktuell)) break;
      weg.add(aktuell);
      final m = modus(d);
      if (m == deckModusWiederholen || m == deckModusNotiz) {
        wert = m;
        break;
      }
      aktuell = eltern(d);
    }
    for (final w in weg) {
      ergebnis[w] = wert;
    }
    return ergebnis[start] ?? wert;
  }

  for (final k in roh.keys) {
    aufloesen(k);
  }
  return ergebnis;
}

const String appKennung = 'vox';

// ── Mitgliedschaft (S.5) ────────────────────────────────────────────────

/// Arten von Mitgliedschaft. Jede Stelle, die etwas aufnimmt oder entfernt,
/// schreibt ein [Mitgliedschaft]-Ereignis mit einer dieser Arten.
const String artListe = 'liste'; //         id = Deck-id
const String artListenwort = 'listenwort'; // id = Deck-id, wort = wortId

/// Nur noch in Ständen von vor Fassung 6 (id = wortId): beim Lesen wird
/// daraus [artListenwort] am Deck [standardDeckId].
const String artLeitnerAlt = 'leitner';
const String artWort = 'wort'; //           id = Wortschlüssel `<german>|<wordType>`

/// Eine bewusste Handlung des Nutzers: etwas aufgenommen ([drin]) oder
/// entfernt — und wann.
///
/// ⚠️ **Warum es das gibt:** Zusammenführen vereinigt. Ohne diese Ereignisse
/// käme jede Entfernung beim nächsten Abgleich vom anderen Gerät zurück.
/// Regel: **die letzte Handlung gewinnt** — für die Frage „drin oder nicht".
/// Für den Lernfortschritt (das Fach) gilt [LeitnerStand.zusammen]:
/// höchstes Fach gewinnt, außer eine falsche Antwort ist jünger. Der
/// Fortschritt selbst wird durch ein Entfernen NIE gelöscht (X.2).
class Mitgliedschaft {
  final String art;
  final String id;

  /// Nur bei [artListenwort] gesetzt, sonst leer.
  final String wort;
  final bool drin;
  final DateTime am;

  const Mitgliedschaft({
    required this.art,
    required this.id,
    this.wort = '',
    required this.drin,
    required this.am,
  });

  String get schluessel => mitgliedschaftsSchluessel(art, id, wort);

  Map<String, dynamic> toJson() => {
        'art': art,
        'id': id,
        'wort': wort,
        'drin': drin,
        'am': am.toUtc().toIso8601String(),
      };

  static Mitgliedschaft vonJson(Map<String, dynamic> j) => Mitgliedschaft(
        art: j['art'] as String,
        id: j['id'] as String,
        wort: j['wort'] as String? ?? '',
        drin: j['drin'] as bool? ?? true,
        am: _datum(j['am']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  /// Die spätere der beiden Handlungen. Gleichstand ⇒ „drin" gewinnt:
  /// im Zweifel bleibt Fortschritt erhalten.
  static Mitgliedschaft spaetere(Mitgliedschaft a, Mitgliedschaft b) {
    final c = a.am.compareTo(b.am);
    if (c != 0) return c > 0 ? a : b;
    return a.drin ? a : b;
  }
}

/// Eindeutiger Schlüssel je Ereignis. Das Trennzeichen kommt in keiner
/// Wort- oder Listen-id vor (dort stehen `:` und `|`).
String mitgliedschaftsSchluessel(String art, String id, [String wort = '']) =>
    '$art\u0000$id\u0000$wort';

/// Fortschritt EINES Worts in EINER Übung (X.2; vorher: «ein Wort im
/// Stapel»). Ob das Wort gerade in einem Deck liegt, sagt nicht dieser Stand,
/// sondern die Mitgliedschaft im Deck ([KategorieStand.wortIds]).
///
/// ⚠️ Schlüssel ist bewusst eine TEXT-ID, keine Datenbank-Nummer. Die alten
/// Wortschatz-Wörter liegen in drift mit einer fortlaufenden `id`, die auf
/// einem anderen Gerät etwas ganz anderes bezeichnet. Für Sicherung und
/// Synchronisierung zählt deshalb nur eine geräteunabhängige Kennung:
/// Archivkarten `adjektiv_stolz`, eigene Wörter `eigen:<wort>|<wortart>`
/// (genau die Felder, die in `Words` zusammen eindeutig sind).
class LeitnerStand {
  final String wortId;
  final int fach; // 1–[leitnerFaecher]; [leitnerGelerntFach] = gelernt

  bool get gelernt => fach >= leitnerGelerntFach;
  final DateTime? naechsteWiederholung;
  final DateTime? letzteWiederholung;

  /// X.4 (2026-11-17): wann das Wort in dieser Übung zum ERSTEN Mal geübt
  /// wurde — daran zählt das Tageslimit neuer Wörter (Entscheidung Nr. 11).
  /// null = unbekannt (Stände von vor X.4) — gilt als «nicht heute».
  /// Optionales Feld: nur im JSON, wenn bekannt; ältere App-Fassungen lesen
  /// es nicht und verlieren dabei nichts außer der Tageszählung.
  final DateTime? ersteWiederholung;

  const LeitnerStand({
    required this.wortId,
    required this.fach,
    this.naechsteWiederholung,
    this.letzteWiederholung,
    this.ersteWiederholung,
  });

  Map<String, dynamic> toJson() => {
        'wortId': wortId,
        'fach': fach,
        'naechsteWiederholung': naechsteWiederholung?.toIso8601String(),
        'letzteWiederholung': letzteWiederholung?.toIso8601String(),
        if (ersteWiederholung != null)
          'ersteWiederholung': ersteWiederholung!.toIso8601String(),
      };

  static LeitnerStand vonJson(Map<String, dynamic> j) => LeitnerStand(
        wortId: j['wortId'] as String,
        fach: (j['fach'] as num?)?.toInt() ?? 1,
        naechsteWiederholung: _datum(j['naechsteWiederholung']),
        letzteWiederholung: _datum(j['letzteWiederholung']),
        ersteWiederholung: _datum(j['ersteWiederholung']),
      );

  static String eigenesWort(String wort, String wortart) =>
      'eigen:${wortSchluessel(wort, wortart)}';

  /// Schlüssel eines Worts der Tabelle `Words` — genau ihr eindeutiger Index.
  static String wortSchluessel(String wort, String wortart) => '$wort|$wortart';

  /// Führt zwei Stände **derselben** Karte zusammen (Entscheidung Lukas
  /// 2026-11-10, Regel «الف+»):
  ///
  ///   1. Grundsatz bleibt: das höhere Fach gewinnt — Fortschritt geht nicht
  ///      verloren, auch wenn er älter ist (Offline-Arbeit).
  ///   2. Ausnahme: eine **später** gegebene falsche Antwort gewinnt. Falsch
  ///      geantwortet heißt: Fach 1 **mit** Wiederholungsdatum (eine frisch
  ///      aufgenommene Karte liegt auch in Fach 1, hat aber kein Datum). Ist
  ///      dieses Datum jünger als die letzte Wiederholung des höheren Fachs,
  ///      bleibt die Karte in Fach 1.
  ///   3. Fehlt beim höheren Fach das Datum, gilt Regel 1 — im Zweifel wird
  ///      kein Fortschritt weggenommen.
  ///
  /// «Gelernt» ([leitnerGelerntFach]) ist das höchste Fach und gewinnt nach
  /// Regel 1; legt der Nutzer ein gelerntes Wort von Hand zurück in Fach 1
  /// (mit Datum), gewinnt das nach Regel 2 wie eine falsche Antwort.
  ///
  /// Das Ergebnis hängt nicht davon ab, welche Seite «eigen» ist.
  static LeitnerStand zusammen(LeitnerStand a, LeitnerStand b) {
    final hoch = b.fach > a.fach ? b : a;
    final tief = identical(hoch, a) ? b : a;
    final falschDanach = tief.fach == 1 &&
        hoch.fach > 1 &&
        tief.letzteWiederholung != null &&
        hoch.letzteWiederholung != null &&
        tief.letzteWiederholung!.isAfter(hoch.letzteWiederholung!);
    final sieger = falschDanach ? tief : hoch;
    // Der Wiederholungstermin gehört zum Sieger; die letzte Wiederholung ist
    // das jüngere der beiden Daten (reine Tatsache).
    return LeitnerStand(
      wortId: sieger.wortId,
      fach: sieger.fach,
      naechsteWiederholung: sieger.naechsteWiederholung,
      letzteWiederholung:
          _spaeteres(a.letzteWiederholung, b.letzteWiederholung),
      // Erstes Üben: das frühere der beiden bekannten Daten (Tatsache).
      ersteWiederholung:
          _frueheres(a.ersteWiederholung, b.ersteWiederholung),
    );
  }
}

DateTime? _frueheres(DateTime? a, DateTime? b) =>
    a == null ? b : (b == null || a.isBefore(b) ? a : b);

/// Ein Deck (bis Fassung 5: «eine selbst angelegte Liste»). `wortIds` nutzt
/// dieselben Text-IDs wie oben.
///
/// ⚠️ S.6: [id] ist fest ab Anlage und ändert sich beim Umbenennen NIE —
/// sonst verlöre ein Gerät, das offline Wörter in die Liste legt, diese
/// Wörter beim Abgleich. Der Name ist nur Anzeige; [nameAm] entscheidet,
/// welcher Name beim Zusammenführen gewinnt.
///
/// X.2: [eltern], [modus], [neuProTag] und [ordnung] sind die Einstellungen
/// des Decks; beim Zusammenführen gewinnen sie GEMEINSAM von der Seite mit
/// dem späteren [standAm] (ohne Zeitpunkt = älter als jede Änderung).
class KategorieStand {
  final String id;
  final String name;

  /// Wann [name] vergeben wurde (S.6). null = unbekannt — älter als jede
  /// Umbenennung (Fassung 2 und Listen von vor S.6).
  final DateTime? nameAm;
  final List<String> wortIds;

  /// id des übergeordneten Decks; null = oberste Ebene.
  final String? eltern;

  /// [deckModusWiederholen], [deckModusNotiz] oder [deckModusErben] (wie
  /// das Deck darüber). Listen von vor Fassung 6 sind Notizbücher — so
  /// beginnt durch die Umstellung keine ungewollte Wiederholung.
  final String modus;

  /// Neue Wörter pro Tag; null = Standard (oberste Ebene 50, Subdeck 10 —
  /// `core/leitner/leitner_regeln.dart`).
  final int? neuProTag;

  /// Reihenfolge unter Geschwistern (kleiner = weiter oben).
  final int ordnung;

  /// Wann [eltern]/[modus]/[neuProTag]/[ordnung] zuletzt geändert wurden.
  final DateTime? standAm;

  const KategorieStand({
    required this.id,
    required this.name,
    this.nameAm,
    this.wortIds = const [],
    this.eltern,
    this.modus = deckModusNotiz,
    this.neuProTag,
    this.ordnung = 0,
    this.standAm,
  });

  /// EIGENE Einstellung ist Wiederholung (ohne «erben» aufzulösen — den
  /// wirklichen Modus gibt [NutzerZustand.kategorienModi]).
  bool get wiederholen => modus == deckModusWiederholen;

  KategorieStand mit({
    String? name,
    DateTime? nameAm,
    List<String>? wortIds,
    String? Function()? eltern,
  }) =>
      KategorieStand(
        id: id,
        name: name ?? this.name,
        nameAm: nameAm ?? this.nameAm,
        wortIds: wortIds ?? this.wortIds,
        eltern: eltern == null ? this.eltern : eltern(),
        modus: modus,
        neuProTag: neuProTag,
        ordnung: ordnung,
        standAm: standAm,
      );

  /// Felder stehen nur drin, wenn sie vom Standard abweichen — so bleibt der
  /// Text einer Liste von vor Fassung 6 unverändert, und der Konto-Abgleich
  /// lädt nicht grundlos neu hoch.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nameAm != null) 'nameAm': nameAm!.toUtc().toIso8601String(),
        'wortIds': wortIds,
        if (eltern != null) 'eltern': eltern,
        if (modus != deckModusNotiz) 'modus': modus,
        if (neuProTag != null) 'neuProTag': neuProTag,
        if (ordnung != 0) 'ordnung': ordnung,
        if (standAm != null) 'standAm': standAm!.toUtc().toIso8601String(),
      };

  static KategorieStand vonJson(Map<String, dynamic> j) => KategorieStand(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        nameAm: _datum(j['nameAm']),
        wortIds: (j['wortIds'] as List?)?.cast<String>() ?? const [],
        eltern: j['eltern'] as String?,
        // Unbekannter Modus (neuere Fassung, Tippfehler) ⇒ Notizbuch: lieber
        // keine Wiederholung als eine ungewollte.
        modus: j['modus'] == deckModusWiederholen ||
                j['modus'] == deckModusErben
            ? j['modus'] as String
            : deckModusNotiz,
        neuProTag: (j['neuProTag'] as num?)?.toInt(),
        ordnung: (j['ordnung'] as num?)?.toInt() ?? 0,
        standAm: _datum(j['standAm']),
      );
}

/// Neue geräteübergreifende id einer eigenen Liste (S.6):
/// `eigen:#` + 32 Hex-Zeichen (128 Bit Zufall). Sie wird EINMAL bei der Anlage
/// vergeben und nie mehr geändert. Listen von vor S.6 behalten `eigen:<Name>`
/// (so trägt es die Datenbank-Migration auf Fassung 7 ein).
///
/// Das Präfix `eigen:` bleibt, weil die Fassade daran eigene Listen von
/// Archiv-Listen (`kat_<Millisekunden>`) unterscheidet.
String neueEigeneListenId([Random? zufall]) {
  final r = zufall ?? Random.secure();
  final hex = StringBuffer();
  for (var i = 0; i < 16; i++) {
    hex.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return 'eigen:#$hex';
}

/// Freitext-Notiz zu einem Wort, mit Farbe je Wort-Token.
class NotizStand {
  final String text;
  final Map<int, String> farben;

  const NotizStand({this.text = '', this.farben = const {}});

  Map<String, dynamic> toJson() => {
        'text': text,
        'farben': farben.map((k, v) => MapEntry('$k', v)),
      };

  static NotizStand vonJson(Map<String, dynamic> j) => NotizStand(
        text: j['text'] as String? ?? '',
        farben: ((j['farben'] as Map?) ?? const {}).map(
            (k, v) => MapEntry(int.parse(k as String), v as String)),
      );
}

/// Alles, was einem Nutzer gehört — unabhängig davon, wo es liegt.
class NutzerZustand {
  /// wortId → Fortschritt in der Übung [uebungBedeutung]. ⚠️ Seit Fassung 6
  /// heißt Anwesenheit NICHT mehr „ist im Stapel" — das sagen die Decks.
  final Map<String, LeitnerStand> leitner;

  /// Übung → (wortId → Fortschritt) für alle Übungen außer [uebungBedeutung].
  final Map<String, Map<String, LeitnerStand>> uebungen;

  /// Die Decks (bis Fassung 5: eigene Listen) samt ihrer Wörter.
  final List<KategorieStand> kategorien;

  /// wortId → Notiz.
  final Map<String, NotizStand> notizen;

  /// Einstellungen als flache Schlüssel-Wert-Paare (theme_mode, ui_language …).
  final Map<String, Object?> einstellungen;

  /// Selbst hinzugefügte Wörter, roh wie in `Words` — ohne die lokale `id`,
  /// die auf einem anderen Gerät nichts bedeutet. **Keine App-Wörter**
  /// (`Words.ausApp`): die bringt jedes Gerät selbst mit (S.5).
  final List<Map<String, dynamic>> eigeneWoerter;

  /// Letzte Handlung je Schlüssel ([Mitgliedschaft.schluessel]) — S.5.
  final Map<String, Mitgliedschaft> mitgliedschaften;

  /// Persönliche Angaben (P.1). `null` = nie eingegeben. ⚠️ Ein **leeres**
  /// Profil mit Zeitpunkt ist etwas anderes als `null`: es sagt „bewusst
  /// geleert" und setzt sich beim Zusammenführen gegen ältere Angaben durch.
  final NutzerProfil? profil;

  /// Ergebnisse abgeschlossener Tests, id → Ergebnis (T.1). Nur hinzufügen.
  final Map<String, PruefungsErgebnis> pruefungen;

  const NutzerZustand({
    this.leitner = const {},
    this.uebungen = const {},
    this.kategorien = const [],
    this.notizen = const {},
    this.einstellungen = const {},
    this.eigeneWoerter = const [],
    this.mitgliedschaften = const {},
    this.profil,
    this.pruefungen = const {},
  });

  /// Fortschritt einer Übung (leer, wenn es keinen gibt).
  Map<String, LeitnerStand> fortschritt(String uebung) => uebung ==
          uebungBedeutung
      ? leitner
      : uebungen[uebung] ?? const {};

  /// Alle Wörter, die in mindestens einem Deck mit Wiederholung liegen —
  /// «im Leitner».
  Set<String> get imLeitner {
    final modi = kategorienModi;
    return {
      for (final k in kategorien)
        if (modi[k.id] == deckModusWiederholen) ...k.wortIds,
    };
  }

  /// Wirklicher Modus jedes Decks (bei «erben» der des Decks darüber).
  Map<String, String> get kategorienModi => effektiveDeckModi(kategorien,
      id: (k) => k.id, eltern: (k) => k.eltern, modus: (k) => k.modus);

  bool get istLeer =>
      leitner.isEmpty &&
      uebungen.values.every((m) => m.isEmpty) &&
      kategorien.isEmpty &&
      notizen.isEmpty &&
      einstellungen.isEmpty &&
      eigeneWoerter.isEmpty &&
      mitgliedschaften.isEmpty &&
      profil == null &&
      pruefungen.isEmpty;

  /// Listen werden **geordnet** ausgegeben (nach id bzw. Schlüssel), damit
  /// derselbe Inhalt immer denselben Text ergibt — der Konto-Abgleich
  /// erkennt daran, dass nichts hochzuladen ist (S.3 Schritt 3).
  Map<String, dynamic> toJson() => {
        'leitner': leitner.map((k, v) => MapEntry(k, v.toJson())),
        // Nur Übungen mit Fortschritt: ohne sie kein Feld.
        if (uebungen.values.any((m) => m.isNotEmpty))
          'uebungen': {
            for (final u in uebungen.keys.toList()..sort())
              if (uebungen[u]!.isNotEmpty)
                u: uebungen[u]!.map((k, v) => MapEntry(k, v.toJson())),
          },
        'kategorien': ([...kategorien]..sort((a, b) => a.id.compareTo(b.id)))
            .map((k) => k.toJson())
            .toList(),
        'notizen': notizen.map((k, v) => MapEntry(k, v.toJson())),
        'einstellungen': einstellungen,
        'eigeneWoerter': ([...eigeneWoerter]
              ..sort((a, b) => _wortSchluessel(a).compareTo(_wortSchluessel(b))))
            .toList(),
        'mitgliedschaften': (mitgliedschaften.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key)))
            .map((e) => e.value.toJson())
            .toList(),
        // Nur wenn vorhanden: Sicherungen ohne Profil bleiben Byte für Byte
        // gleich (der Konto-Abgleich vergleicht den Text).
        if (profil != null) 'profil': profil!.toJson(),
        // Ebenso (T.1): ohne Ergebnisse kein Feld.
        if (pruefungen.isNotEmpty)
          'pruefungen': PruefungsErgebnis.listeSchreiben(pruefungen),
      };

  /// [version] ist die Fassung, in der [j] geschrieben wurde (Datei: Hülle,
  /// Konto: Spalte `version`). Fassung 1–5 wird hier in die Form der Fassung
  /// 6 gebracht — siehe [nutzerZustandVersion].
  static NutzerZustand vonJson(Map<String, dynamic> j,
      {int version = nutzerZustandVersion}) {
    final alt = version < 6;
    final leitner = ((j['leitner'] as Map?) ?? const {}).map((k, v) => MapEntry(
        k as String, LeitnerStand.vonJson((v as Map).cast<String, dynamic>())));
    var kategorien = ((j['kategorien'] as List?) ?? const [])
        .map((e) => KategorieStand.vonJson((e as Map).cast<String, dynamic>()))
        .toList();
    // Fassung 1 kennt das Feld nicht ⇒ leer.
    final ereignisse = <String, Mitgliedschaft>{};
    void merken(Mitgliedschaft m) {
      final da = ereignisse[m.schluessel];
      ereignisse[m.schluessel] = da == null ? m : Mitgliedschaft.spaetere(da, m);
    }

    for (final e in (j['mitgliedschaften'] as List?) ?? const []) {
      if (e is! Map) continue;
      final m = Mitgliedschaft.vonJson(e.cast<String, dynamic>());
      // Vor Fassung 6: «in den Stapel / aus dem Stapel» ⇒ Wort im Deck.
      merken(m.art == artLeitnerAlt
          ? Mitgliedschaft(
              art: artListenwort,
              id: standardDeckId,
              wort: m.id,
              drin: m.drin,
              am: m.am)
          : m);
    }
    // Vor Fassung 6 hieß «steht in `leitner`»: ist im Stapel ⇒ Mitglied des
    // Standard-Decks (mit Wiederholung — genau das war der Stapel).
    if (alt &&
        leitner.isNotEmpty &&
        !kategorien.any((k) => k.id == standardDeckId)) {
      kategorien = [
        ...kategorien,
        KategorieStand(
          id: standardDeckId,
          name: standardDeckName,
          modus: deckModusWiederholen,
          wortIds: leitner.keys.toList(),
        ),
      ];
    }
    return NutzerZustand(
      leitner: leitner,
      uebungen: {
        for (final e in ((j['uebungen'] as Map?) ?? const {}).entries)
          if (e.value is Map && e.key != uebungBedeutung)
            e.key as String: (e.value as Map).map((k, v) => MapEntry(
                k as String,
                LeitnerStand.vonJson((v as Map).cast<String, dynamic>()))),
      },
      kategorien: kategorien,
      notizen: ((j['notizen'] as Map?) ?? const {}).map((k, v) => MapEntry(
          k as String, NotizStand.vonJson((v as Map).cast<String, dynamic>()))),
      einstellungen:
          ((j['einstellungen'] as Map?) ?? const {}).cast<String, Object?>(),
      eigeneWoerter: ((j['eigeneWoerter'] as List?) ?? const [])
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      mitgliedschaften: ereignisse,
      // Fassung 1–3 kennt das Feld nicht ⇒ kein Profil.
      profil: j['profil'] is Map
          ? NutzerProfil.vonJson((j['profil'] as Map).cast<String, dynamic>())
          : null,
      // Fassung 1–4 kennt das Feld nicht ⇒ keine Ergebnisse.
      pruefungen: PruefungsErgebnis.listeLesen(j['pruefungen']),
    );
  }

  // ── Zusammenführen ────────────────────────────────────────────────────
  /// Führt `anderer` in `this` — Regel des Nutzers (2026-09-15):
  /// **„höchstes Fach gewinnt"**, NICHT „jüngster Zeitstempel gewinnt".
  /// Seit 2026-11-10 mit einer Ausnahme: eine **später** gegebene falsche
  /// Antwort (Fach 1) gewinnt — siehe [LeitnerStand.zusammen]. Vorher kam
  /// jede falsche Antwort beim nächsten Abgleich aus der Cloud zurück.
  ///
  /// Begründung: Wer offline 20 Karten wiederholt und sich danach woanders
  /// anmeldet, darf diese Arbeit nicht verlieren. Bei Kategorien und Notizen wird vereinigt statt überschrieben;
  /// Einstellungen sind Gerätesache — dort gewinnt der eigene Stand.
  ///
  /// **Entfernungen (S.5):** Ob etwas überhaupt drin ist, entscheidet die
  /// jeweils letzte [Mitgliedschaft] — auch über beide Stände hinweg. Einträge
  /// ohne Ereignis gelten als älter als jede Handlung.
  NutzerZustand zusammenfuehren(NutzerZustand anderer) {
    final ereignisse = Map<String, Mitgliedschaft>.from(mitgliedschaften);
    anderer.mitgliedschaften.forEach((k, fremd) {
      final eigen = ereignisse[k];
      ereignisse[k] =
          eigen == null ? fremd : Mitgliedschaft.spaetere(eigen, fremd);
    });
    bool entfernt(String art, String id, [String wort = '']) =>
        ereignisse[mitgliedschaftsSchluessel(art, id, wort)]?.drin == false;

    // Fortschritt je Übung: dieselbe Regel für jede ([LeitnerStand.zusammen]).
    Map<String, LeitnerStand> fortschrittZusammen(
        Map<String, LeitnerStand> eigener, Map<String, LeitnerStand> fremder) {
      final neu = Map<String, LeitnerStand>.from(eigener);
      fremder.forEach((id, fremd) {
        final eigen = neu[id];
        neu[id] = eigen == null ? fremd : LeitnerStand.zusammen(eigen, fremd);
      });
      return neu;
    }

    final leitnerNeu = fortschrittZusammen(leitner, anderer.leitner);
    final uebungenNeu = <String, Map<String, LeitnerStand>>{
      for (final u in {...uebungen.keys, ...anderer.uebungen.keys})
        u: fortschrittZusammen(
            uebungen[u] ?? const {}, anderer.uebungen[u] ?? const {}),
    };

    // Kategorien: gleiche id = dieselbe Liste, Wörter vereinigen.
    // Name (S.6): der später vergebene gewinnt; ohne bekannten Zeitpunkt oder
    // bei Gleichstand bleibt der eigene.
    final katNeu = <String, KategorieStand>{
      for (final k in kategorien) k.id: k,
    };
    for (final fremd in anderer.kategorien) {
      final eigen = katNeu[fremd.id];
      if (eigen == null) {
        katNeu[fremd.id] = fremd;
        continue;
      }
      final fremdAm = fremd.nameAm;
      final eigenAm = eigen.nameAm;
      final fremderName =
          fremdAm != null && (eigenAm == null || fremdAm.isAfter(eigenAm));
      // Einstellungen (X.2): gemeinsam von der Seite mit dem späteren standAm.
      final fremdStand = fremd.standAm;
      final eigenStand = eigen.standAm;
      final e = fremdStand != null &&
              (eigenStand == null || fremdStand.isAfter(eigenStand))
          ? fremd
          : eigen;
      katNeu[fremd.id] = KategorieStand(
        id: fremd.id,
        name: fremderName ? fremd.name : eigen.name,
        nameAm: fremderName ? fremdAm : eigenAm,
        wortIds: {...eigen.wortIds, ...fremd.wortIds}.toList(),
        eltern: e.eltern,
        modus: e.modus,
        neuProTag: e.neuProTag,
        ordnung: e.ordnung,
        standAm: e.standAm,
      );
    }

    // Notizen: eigener Text gewinnt, fremde Notizen zu Wörtern ohne eigene
    // Notiz kommen dazu. Nie zusammenkleben — das ergäbe Kauderwelsch.
    final notizenNeu = Map<String, NotizStand>.from(anderer.notizen)
      ..addAll(notizen);

    // Eigene Wörter: nach (wort|wortart) eindeutig, eigener Stand gewinnt.
    final woerterNeu = <String, Map<String, dynamic>>{
      for (final w in anderer.eigeneWoerter) _wortSchluessel(w): w,
    };
    for (final w in eigeneWoerter) {
      woerterNeu[_wortSchluessel(w)] = w;
    }

    // Entfernungen anwenden (S.5). Ein entferntes eigenes Wort nimmt seine
    // Leitner-Karte und seine Listenplätze mit.
    woerterNeu.removeWhere((k, _) => entfernt(artWort, k));
    bool wortWeg(String wortId) =>
        wortId.startsWith('eigen:') &&
        entfernt(artWort, wortId.substring('eigen:'.length));
    // Fortschritt bleibt, auch wenn das Wort aus jedem Deck entfernt wurde
    // (Entscheidung Lukas 2026-11-03: Deck löschen kostet nie Fortschritt).
    // Nur ein gelöschtes eigenes Wort nimmt seinen Fortschritt mit.
    leitnerNeu.removeWhere((id, _) => wortWeg(id));
    for (final m in uebungenNeu.values) {
      m.removeWhere((id, _) => wortWeg(id));
    }
    uebungenNeu.removeWhere((_, m) => m.isEmpty);
    katNeu.removeWhere((id, _) => entfernt(artListe, id));
    final katBereinigt = [
      for (final k in katNeu.values)
        k.mit(
          wortIds: [
            for (final w in k.wortIds)
              if (!entfernt(artListenwort, k.id, w) && !wortWeg(w)) w,
          ],
          // Übergeordnetes Deck gelöscht (oder nie angekommen) ⇒ das Deck
          // rückt auf die oberste Ebene, statt unsichtbar zu werden.
          eltern: () => katNeu.containsKey(k.eltern) ? k.eltern : null,
        ),
    ];

    return NutzerZustand(
      leitner: leitnerNeu,
      uebungen: uebungenNeu,
      kategorien: katBereinigt,
      notizen: notizenNeu,
      einstellungen: einstellungen.isEmpty ? anderer.einstellungen : einstellungen,
      eigeneWoerter: woerterNeu.values.toList(),
      mitgliedschaften: ereignisse,
      profil: NutzerProfil.spaeteres(profil, anderer.profil),
      // Ergebnisse (T.1): nur hinzufügen ⇒ Vereinigung, nichts geht verloren.
      pruefungen: PruefungsErgebnis.vereinigen(pruefungen, anderer.pruefungen),
    );
  }

  static String _wortSchluessel(Map<String, dynamic> w) =>
      LeitnerStand.wortSchluessel('${w['german']}', '${w['wordType']}');
}

// ── Hülle ───────────────────────────────────────────────────────────────

/// Gelesene Sicherung samt Kopfdaten.
class Sicherung {
  final int version;
  final DateTime? erstelltAm;
  final String app;
  final NutzerZustand zustand;

  const Sicherung({
    required this.version,
    required this.app,
    required this.zustand,
    this.erstelltAm,
  });
}

/// Wird geworfen, wenn eine Datei keine brauchbare VOX-Sicherung ist.
class SicherungFehler implements Exception {
  final String grund;
  const SicherungFehler(this.grund);
  @override
  String toString() => 'SicherungFehler: $grund';
}

/// Zustand → Text zum Speichern in einer Datei.
String sicherungSchreiben(NutzerZustand zustand, {DateTime? jetzt}) =>
    const JsonEncoder.withIndent('  ').convert({
      'version': nutzerZustandVersion,
      'exportedAt': (jetzt ?? DateTime.now()).toIso8601String(),
      'app': appKennung,
      'payload': zustand.toJson(),
    });

/// Text → Sicherung. Wirft [SicherungFehler] mit einem Grund, den man einem
/// Nutzer zeigen kann, statt still etwas Leeres zurückzugeben.
Sicherung sicherungLesen(String text) {
  Object? roh;
  try {
    roh = jsonDecode(text);
  } catch (_) {
    throw const SicherungFehler('Die Datei ist kein lesbares JSON.');
  }
  if (roh is! Map) {
    throw const SicherungFehler('Die Datei enthält kein Sicherungs-Objekt.');
  }
  final map = roh.cast<String, dynamic>();
  final version = (map['version'] as num?)?.toInt();
  if (version == null) {
    throw const SicherungFehler('Der Datei fehlt die Versionsangabe.');
  }
  if (version > nutzerZustandVersion) {
    throw SicherungFehler(
        'Diese Sicherung stammt aus einer neueren Fassung der App '
        '(Version $version). Bitte die App aktualisieren.');
  }
  final app = map['app'] as String? ?? '';
  if (app != appKennung) {
    throw SicherungFehler(
        'Diese Sicherung gehört zu einer anderen App ("$app").');
  }
  final payload = map['payload'];
  if (payload is! Map) {
    throw const SicherungFehler('Der Datei fehlen die eigentlichen Daten.');
  }
  return Sicherung(
    version: version,
    app: app,
    erstelltAm: _datum(map['exportedAt']),
    zustand: NutzerZustand.vonJson(payload.cast<String, dynamic>(),
        version: version),
  );
}

DateTime? _datum(Object? wert) =>
    wert is String ? DateTime.tryParse(wert) : null;

DateTime? _spaeteres(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}
