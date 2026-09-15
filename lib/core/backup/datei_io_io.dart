// FILE: lib/core/backup/datei_io_io.dart
// PURPOSE: Nicht-Web-Fassung — bewusster Stub, kein toter Code.
//          VOX läuft nur im Browser; diesen Zweig wählt allein die Dart-VM
//          bei `flutter test`. Ohne ihn ließe sich backup_service.dart dort
//          nicht übersetzen und kein einziger Test liefe.
//
// HERKUNFT (Muster): Root-in · lib/core/services/file_pick/pick_text_file_io.dart
//           commit b784af1cd919c05f3a1922d3dba6fb8aade3ae52 · 2026-09-15
//
// `null` heißt „abgebrochen" und wird vom Aufrufer schon behandelt. Ein Wurf
// wäre hier falsch: er schlüge in Tests als Fehler durch, obwohl niemand eine
// Datei auswählen wollte.
Future<String?> textDateiWaehlen() async => null;

Future<void> textDateiSpeichern(String dateiname, String inhalt) async {}
