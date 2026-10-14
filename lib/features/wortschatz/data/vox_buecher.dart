// FILE: lib/features/wortschatz/data/vox_buecher.dart
// PHASE: فاز F.4 (Entscheidung Lukas, 2026-10-14)
// PURPOSE: Die fertigen VOX-Bücher — EINE Quelle: assets/buecher/buecher.json.
//          Bücher macht nur VOX (Claude trägt die Wortlisten von Lukas ein,
//          z. B. «A1 Starten wir»); der Nutzer kann sie nicht löschen oder
//          ändern. Für eigene Listen gibt es «Meine Kategorien».
//          Ein Buch gehört zu:
//            · Karten (assets/vocab/) über `karten` (ids),
//            · alten mitgelieferten Wörtern über `alt_buch` = Name des Decks in
//              der drift-Tabelle Books (DataSeedService).
//          Vom Nutzer früher selbst angelegte Bücher (Tabelle Books, Menü
//          «Bücher» bis F.4) zeigt der Filter NICHT — Entscheidung Lukas:
//          keine Übernahme in Kategorien.
//
// Rein (ohne Flutter) — test/vox_buecher_test.dart.
import 'dart:convert';

/// Pfad der Bücherliste (pubspec: assets/buecher/).
const voxBuecherAsset = 'assets/buecher/buecher.json';

class VoxBuch {
  const VoxBuch({
    required this.id,
    required this.name,
    this.altBuch,
    this.karten = const [],
  });

  /// Feste id — nie ändern (der gespeicherte Filter merkt sie sich).
  final String id;
  final String name;

  /// Name des mitgelieferten Decks in der alten Tabelle Books, oder null.
  final String? altBuch;

  /// ids der Karten (assets/vocab/), in der Reihenfolge der Wortliste.
  final List<String> karten;
}

/// Liest buecher.json. Fehlerhafte Einträge werfen [FormatException] —
/// test/vox_buecher_test.dart prüft die echte Datei, damit das nie in die
/// App gelangt.
List<VoxBuch> voxBuecherLesen(String roh) {
  final json = jsonDecode(roh);
  if (json is! Map<String, dynamic> || json['buecher'] is! List) {
    throw const FormatException('buecher.json: «buecher» fehlt');
  }
  final ids = <String>{};
  final liste = <VoxBuch>[];
  for (final e in json['buecher'] as List) {
    if (e is! Map<String, dynamic>) {
      throw const FormatException('buecher.json: Eintrag ist kein Objekt');
    }
    final id = e['id'];
    final name = e['name'];
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw FormatException('buecher.json: ungültige id «$id»');
    }
    if (!ids.add(id)) {
      throw FormatException('buecher.json: id «$id» doppelt');
    }
    if (name is! String || name.trim().isEmpty) {
      throw FormatException('buecher.json: Buch «$id» ohne Namen');
    }
    final alt = e['alt_buch'];
    final karten = e['karten'] ?? const [];
    if (alt != null && alt is! String) {
      throw FormatException('buecher.json: alt_buch von «$id»');
    }
    if (karten is! List || karten.any((k) => k is! String)) {
      throw FormatException('buecher.json: karten von «$id»');
    }
    liste.add(VoxBuch(
      id: id,
      name: name.trim(),
      altBuch: alt as String?,
      karten: List.unmodifiable(karten.cast<String>()),
    ));
  }
  return liste;
}
