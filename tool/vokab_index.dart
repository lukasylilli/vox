// FILE: tool/vokab_index.dart
// PHASE: فاز V, Schritt V.2 (2026-09-16)
// PURPOSE: Baut assets/vocab_index.json aus allen Karten in assets/vocab/.
//          Dazu assets/vocab_formen.json (gebeugte Form → Karten, 2026-09-23).
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

  String text;
  try {
    text = vokabIndexBauen(karten);
  } on VokabIndexFehler catch (e) {
    fehler.addAll(e.gruende);
    text = '';
  }

  if (fehler.isNotEmpty) {
    stderr.writeln('Wortindex NICHT gebaut — ${fehler.length} Fehler:');
    for (final f in fehler) {
      stderr.writeln('  · $f');
    }
    exit(1);
  }

  File(vokabIndexPfad).writeAsStringSync(text);
  stdout.writeln('Wortindex: ${karten.length} Wörter, '
      '${text.length} Zeichen → $vokabIndexPfad');

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
