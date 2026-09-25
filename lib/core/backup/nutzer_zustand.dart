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
const int nutzerZustandVersion = 5;

const String appKennung = 'vox';

// ── Mitgliedschaft (S.5) ────────────────────────────────────────────────

/// Arten von Mitgliedschaft. Jede Stelle, die etwas aufnimmt oder entfernt,
/// schreibt ein [Mitgliedschaft]-Ereignis mit einer dieser Arten.
const String artLeitner = 'leitner'; //     id = wortId
const String artListe = 'liste'; //         id = Listen-id
const String artListenwort = 'listenwort'; // id = Listen-id, wort = wortId
const String artWort = 'wort'; //           id = Wortschlüssel `<german>|<wordType>`

/// Eine bewusste Handlung des Nutzers: etwas aufgenommen ([drin]) oder
/// entfernt — und wann.
///
/// ⚠️ **Warum es das gibt:** Zusammenführen vereinigt. Ohne diese Ereignisse
/// käme jede Entfernung beim nächsten Abgleich vom anderen Gerät zurück.
/// Regel: **die letzte Handlung gewinnt** — für die Frage „drin oder nicht".
/// Für den Lernfortschritt (das Fach) bleibt „höchstes Fach gewinnt".
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

/// Ein Wort im Leitner-Stapel.
///
/// ⚠️ Schlüssel ist bewusst eine TEXT-ID, keine Datenbank-Nummer. Die alten
/// Wortschatz-Wörter liegen in drift mit einer fortlaufenden `id`, die auf
/// einem anderen Gerät etwas ganz anderes bezeichnet. Für Sicherung und
/// Synchronisierung zählt deshalb nur eine geräteunabhängige Kennung:
/// Archivkarten `adjektiv_stolz`, eigene Wörter `eigen:<wort>|<wortart>`
/// (genau die Felder, die in `Words` zusammen eindeutig sind).
class LeitnerStand {
  final String wortId;
  final int fach; // 1–5
  final DateTime? naechsteWiederholung;
  final DateTime? letzteWiederholung;

  const LeitnerStand({
    required this.wortId,
    required this.fach,
    this.naechsteWiederholung,
    this.letzteWiederholung,
  });

  Map<String, dynamic> toJson() => {
        'wortId': wortId,
        'fach': fach,
        'naechsteWiederholung': naechsteWiederholung?.toIso8601String(),
        'letzteWiederholung': letzteWiederholung?.toIso8601String(),
      };

  static LeitnerStand vonJson(Map<String, dynamic> j) => LeitnerStand(
        wortId: j['wortId'] as String,
        fach: (j['fach'] as num?)?.toInt() ?? 1,
        naechsteWiederholung: _datum(j['naechsteWiederholung']),
        letzteWiederholung: _datum(j['letzteWiederholung']),
      );

  static String eigenesWort(String wort, String wortart) =>
      'eigen:${wortSchluessel(wort, wortart)}';

  /// Schlüssel eines Worts der Tabelle `Words` — genau ihr eindeutiger Index.
  static String wortSchluessel(String wort, String wortart) => '$wort|$wortart';
}

/// Eine selbst angelegte Liste. `wortIds` nutzt dieselben Text-IDs wie oben.
///
/// ⚠️ S.6: [id] ist fest ab Anlage und ändert sich beim Umbenennen NIE —
/// sonst verlöre ein Gerät, das offline Wörter in die Liste legt, diese
/// Wörter beim Abgleich. Der Name ist nur Anzeige; [nameAm] entscheidet,
/// welcher Name beim Zusammenführen gewinnt.
class KategorieStand {
  final String id;
  final String name;

  /// Wann [name] vergeben wurde (S.6). null = unbekannt — älter als jede
  /// Umbenennung (Fassung 2 und Listen von vor S.6).
  final DateTime? nameAm;
  final List<String> wortIds;

  const KategorieStand({
    required this.id,
    required this.name,
    this.nameAm,
    this.wortIds = const [],
  });

  /// `nameAm` steht nur drin, wenn es bekannt ist — so bleibt der Text einer
  /// Liste von vor S.6 unverändert, und der Konto-Abgleich lädt nicht grundlos
  /// neu hoch.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nameAm != null) 'nameAm': nameAm!.toUtc().toIso8601String(),
        'wortIds': wortIds,
      };

  static KategorieStand vonJson(Map<String, dynamic> j) => KategorieStand(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        nameAm: _datum(j['nameAm']),
        wortIds: (j['wortIds'] as List?)?.cast<String>() ?? const [],
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
  /// wortId → Leitner-Stand. Anwesenheit bedeutet „ist im Stapel".
  final Map<String, LeitnerStand> leitner;
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
    this.kategorien = const [],
    this.notizen = const {},
    this.einstellungen = const {},
    this.eigeneWoerter = const [],
    this.mitgliedschaften = const {},
    this.profil,
    this.pruefungen = const {},
  });

  bool get istLeer =>
      leitner.isEmpty &&
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

  static NutzerZustand vonJson(Map<String, dynamic> j) => NutzerZustand(
        leitner: ((j['leitner'] as Map?) ?? const {}).map((k, v) => MapEntry(
            k as String, LeitnerStand.vonJson((v as Map).cast<String, dynamic>()))),
        kategorien: ((j['kategorien'] as List?) ?? const [])
            .map((e) => KategorieStand.vonJson((e as Map).cast<String, dynamic>()))
            .toList(),
        notizen: ((j['notizen'] as Map?) ?? const {}).map((k, v) => MapEntry(
            k as String, NotizStand.vonJson((v as Map).cast<String, dynamic>()))),
        einstellungen:
            ((j['einstellungen'] as Map?) ?? const {}).cast<String, Object?>(),
        eigeneWoerter: ((j['eigeneWoerter'] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        // Fassung 1 kennt das Feld nicht ⇒ leer.
        mitgliedschaften: {
          for (final e in (j['mitgliedschaften'] as List?) ?? const [])
            if (e is Map)
              Mitgliedschaft.vonJson(e.cast<String, dynamic>()).schluessel:
                  Mitgliedschaft.vonJson(e.cast<String, dynamic>()),
        },
        // Fassung 1–3 kennt das Feld nicht ⇒ kein Profil.
        profil: j['profil'] is Map
            ? NutzerProfil.vonJson((j['profil'] as Map).cast<String, dynamic>())
            : null,
        // Fassung 1–4 kennt das Feld nicht ⇒ keine Ergebnisse.
        pruefungen: PruefungsErgebnis.listeLesen(j['pruefungen']),
      );

  // ── Zusammenführen ────────────────────────────────────────────────────
  /// Führt `anderer` in `this` — Regel des Nutzers (2026-09-15):
  /// **„höchstes Fach gewinnt"**, NICHT „jüngster Zeitstempel gewinnt".
  ///
  /// Begründung: Lernfortschritt geht nur vorwärts. Wer offline 20 Karten
  /// wiederholt und sich danach woanders anmeldet, darf diese Arbeit nicht
  /// verlieren. Bei Kategorien und Notizen wird vereinigt statt überschrieben;
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

    final leitnerNeu = Map<String, LeitnerStand>.from(leitner);
    anderer.leitner.forEach((id, fremd) {
      final eigen = leitnerNeu[id];
      if (eigen == null) {
        leitnerNeu[id] = fremd;
        return;
      }
      final sieger = fremd.fach > eigen.fach ? fremd : eigen;
      // Der spätere Wiederholungstermin gehört zum höheren Fach; die letzte
      // Wiederholung ist das jüngere der beiden Daten (reine Tatsache).
      leitnerNeu[id] = LeitnerStand(
        wortId: id,
        fach: sieger.fach,
        naechsteWiederholung: sieger.naechsteWiederholung,
        letzteWiederholung: _spaeteres(
            eigen.letzteWiederholung, fremd.letzteWiederholung),
      );
    });

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
      katNeu[fremd.id] = KategorieStand(
        id: fremd.id,
        name: fremderName ? fremd.name : eigen.name,
        nameAm: fremderName ? fremdAm : eigenAm,
        wortIds: {...eigen.wortIds, ...fremd.wortIds}.toList(),
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
    leitnerNeu.removeWhere((id, _) => entfernt(artLeitner, id) || wortWeg(id));
    katNeu.removeWhere((id, _) => entfernt(artListe, id));
    final katBereinigt = [
      for (final k in katNeu.values)
        KategorieStand(
          id: k.id,
          name: k.name,
          nameAm: k.nameAm,
          wortIds: [
            for (final w in k.wortIds)
              if (!entfernt(artListenwort, k.id, w) && !wortWeg(w)) w,
          ],
        ),
    ];

    return NutzerZustand(
      leitner: leitnerNeu,
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
    zustand: NutzerZustand.vonJson(payload.cast<String, dynamic>()),
  );
}

DateTime? _datum(Object? wert) =>
    wert is String ? DateTime.tryParse(wert) : null;

DateTime? _spaeteres(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}
