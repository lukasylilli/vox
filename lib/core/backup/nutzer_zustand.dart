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

/// Erhöhen, sobald sich die Form der Nutzlast ändert. `vonJson` muss ältere
/// Fassungen weiter lesen können — eine Sicherung von gestern darf nie
/// unbrauchbar werden.
const int nutzerZustandVersion = 1;

const String appKennung = 'vox';

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
      'eigen:$wort|$wortart';
}

/// Eine selbst angelegte Liste. `wortIds` nutzt dieselben Text-IDs wie oben.
class KategorieStand {
  final String id;
  final String name;
  final List<String> wortIds;

  const KategorieStand({
    required this.id,
    required this.name,
    this.wortIds = const [],
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'wortIds': wortIds};

  static KategorieStand vonJson(Map<String, dynamic> j) => KategorieStand(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        wortIds: (j['wortIds'] as List?)?.cast<String>() ?? const [],
      );
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
  /// die auf einem anderen Gerät nichts bedeutet.
  final List<Map<String, dynamic>> eigeneWoerter;

  const NutzerZustand({
    this.leitner = const {},
    this.kategorien = const [],
    this.notizen = const {},
    this.einstellungen = const {},
    this.eigeneWoerter = const [],
  });

  bool get istLeer =>
      leitner.isEmpty &&
      kategorien.isEmpty &&
      notizen.isEmpty &&
      einstellungen.isEmpty &&
      eigeneWoerter.isEmpty;

  Map<String, dynamic> toJson() => {
        'leitner': leitner.map((k, v) => MapEntry(k, v.toJson())),
        'kategorien': kategorien.map((k) => k.toJson()).toList(),
        'notizen': notizen.map((k, v) => MapEntry(k, v.toJson())),
        'einstellungen': einstellungen,
        'eigeneWoerter': eigeneWoerter,
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
      );

  // ── Zusammenführen ────────────────────────────────────────────────────
  /// Führt `anderer` in `this` — Regel des Nutzers (2026-09-15):
  /// **„höchstes Fach gewinnt"**, NICHT „jüngster Zeitstempel gewinnt".
  ///
  /// Begründung: Lernfortschritt geht nur vorwärts. Wer offline 20 Karten
  /// wiederholt und sich danach woanders anmeldet, darf diese Arbeit nicht
  /// verlieren. Bei Kategorien und Notizen wird vereinigt statt überschrieben;
  /// Einstellungen sind Gerätesache — dort gewinnt der eigene Stand.
  NutzerZustand zusammenfuehren(NutzerZustand anderer) {
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

    // Kategorien: gleiche id = dieselbe Liste, Wörter vereinigen. Der Name des
    // eigenen Standes bleibt (Umbenennen ist eine Gerätesache, kein Fortschritt).
    final katNeu = <String, KategorieStand>{
      for (final k in kategorien) k.id: k,
    };
    for (final fremd in anderer.kategorien) {
      final eigen = katNeu[fremd.id];
      if (eigen == null) {
        katNeu[fremd.id] = fremd;
        continue;
      }
      katNeu[fremd.id] = KategorieStand(
        id: fremd.id,
        name: eigen.name,
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

    return NutzerZustand(
      leitner: leitnerNeu,
      kategorien: katNeu.values.toList(),
      notizen: notizenNeu,
      einstellungen: einstellungen.isEmpty ? anderer.einstellungen : einstellungen,
      eigeneWoerter: woerterNeu.values.toList(),
    );
  }

  static String _wortSchluessel(Map<String, dynamic> w) =>
      '${w['german']}|${w['wordType']}';
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
