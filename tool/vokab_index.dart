// FILE: tool/vokab_index.dart
// PHASE: فاز V, Schritt V.2 (2026-09-16)
// PURPOSE: Baut den Wortindex assets/vocab_index/ (in Stücken je
//          Anfangsbuchstabe, 2026-11-16) aus allen Karten in assets/vocab/.
//          Dazu assets/vocab_formen/ (gebeugte Form → Karten, 2026-09-23).
//
//   dart run tool/vokab_index.dart
//
// Läuft in JEDEM GitHub-Workflow direkt vor `flutter analyze` — der Index wird
// nie von Hand geschrieben und nie committet (.gitignore), kann also nicht
// veralten. Format und Prüfregeln: lib/features/vokabular/data/vokab_index.dart.
//
// Exit-Code 1, wenn eine Karte nicht lesbar ist oder falsch liegt — dann bleibt
// der Bau rot, und nichts Kaputtes wird veröffentlicht.
import 'dart:convert';
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_formen.dart';
import 'package:vox/features/vokabular/data/vokab_index.dart';

void main() {
  final ordner = Directory(vokabKartenOrdner);
  if (!ordner.existsSync()) {
    stderr.writeln('Ordner $vokabKartenOrdner fehlt — im Projektordner starten.');
    exit(1);
  }

  final karten = <String, Map<String, dynamic>>{};
  final fehler = <String>[];
  final dateien = ordner
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final datei in dateien) {
    final pfad = datei.path.replaceAll('\\', '/');
    try {
      final roh = jsonDecode(datei.readAsStringSync());
      if (roh is Map) {
        karten[pfad] = roh.cast<String, dynamic>();
      } else {
        fehler.add('$pfad: kein JSON-Objekt');
      }
    } catch (e) {
      fehler.add('$pfad: nicht lesbar ($e)');
    }
  }

  Map<String, String> index;
  try {
    index = vokabIndexBauen(karten);
  } on VokabIndexFehler catch (e) {
    fehler.addAll(e.gruende);
    index = const {};
  }

  if (fehler.isNotEmpty) {
    stderr.writeln('Wortindex NICHT gebaut — ${fehler.length} Fehler:');
    for (final f in fehler) {
      stderr.writeln('  · $f');
    }
    exit(1);
  }

  // Ordner immer ganz neu: kein Stück eines früheren Baus bleibt liegen.
  final ordnerIndex = Directory(vokabIndexOrdner);
  if (ordnerIndex.existsSync()) ordnerIndex.deleteSync(recursive: true);
  ordnerIndex.createSync(recursive: true);
  // Die eine Datei der älteren Ablage (bis 2026-11-16) wird nicht mehr
  // gelesen — ein liegengebliebener Rest auf einem Rechner soll nicht täuschen.
  final alt = File(vokabIndexAltPfad);
  if (alt.existsSync()) alt.deleteSync();
  var zeichen = 0;
  for (final e in index.entries) {
    File(e.key).writeAsStringSync(e.value);
    zeichen += e.value.length;
  }
  stdout.writeln('Wortindex: ${karten.length} Wörter, $zeichen Zeichen, '
      '${index.length - 1} Stücke → $vokabIndexOrdner/');

  // Gebeugte Formen → Karten (Wort-Popup: «aalartige» ⇒ «aalartig»).
  final ordnerFormen = Directory(vokabFormenOrdner);
  if (ordnerFormen.existsSync()) ordnerFormen.deleteSync(recursive: true);
  ordnerFormen.createSync(recursive: true);
  final stuecke = vokabFormenBauen(karten.values);
  for (final e in stuecke.entries) {
    File(e.key).writeAsStringSync(e.value);
  }
  stdout.writeln('Formen-Tabelle: ${stuecke.length} Dateien → $vokabFormenOrdner/');
}
