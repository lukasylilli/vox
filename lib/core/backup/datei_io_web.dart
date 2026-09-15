// FILE: lib/core/backup/datei_io_web.dart
// PURPOSE: Browser-Fassung — siehe datei_io.dart.
//
// HERKUNFT: `textDateiWaehlen` ist die zeichengleiche Übernahme von
//           Root-in · lib/core/services/file_pick/pick_text_file_web.dart
//           commit ac75c36e71f161b2cd456b16d9f8d88b5317bc0c · 2026-09-15
//           (nur umbenannt, Rumpf unverändert).
//           `textDateiSpeichern` ist neu: Root-in nutzt dafür share_plus,
//           VOX hat diese Abhängigkeit nicht und ist reine Web-App —
//           ein Blob-Download kommt ohne neues Paket aus.
import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Lässt den Nutzer eine Textdatei auswählen; `null` bei Abbruch.
///
/// Im Browser gibt es keine Dateipfade. Der einzige Weg zu einer Datei des
/// Nutzers führt über ein `<input type="file">`, das angeklickt wird; erst
/// dessen `FileReader` liefert den Inhalt.
Future<String?> textDateiWaehlen() {
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    // Hinweis für den Datei-Dialog, keine Garantie: der Nutzer kann die
    // Einschränkung in jedem Browser abwählen. Geprüft wird der Inhalt
    // deshalb weiterhin beim Auswerten (sicherungLesen).
    ..accept = 'application/json,.json';

  final completer = Completer<String?>();

  // Genau einmal abschließen. Manche Browser feuern `cancel` UND danach
  // `change`; ein zweites `complete` wäre ein Fehler.
  void finish(String? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      finish(null);
      return;
    }
    final reader = web.FileReader();
    reader.onload = ((web.Event _) {
      finish((reader.result as JSString?)?.toDart);
    }).toJS;
    reader.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
            StateError('Die Datei konnte nicht gelesen werden.'));
      }
    }).toJS;
    reader.readAsText(files.item(0)!);
  }).toJS;

  // Ohne `cancel` bliebe das Future nach einem Abbruch FÜR IMMER offen — der
  // Nutzer sähe einen Ladezustand, der nie endet.
  input.oncancel = ((web.Event _) => finish(null)).toJS;

  input.click();
  return completer.future;
}

/// Legt [inhalt] als Datei [dateiname] beim Nutzer ab (normaler Download).
Future<void> textDateiSpeichern(String dateiname, String inhalt) async {
  final blob = web.Blob(
    <JSAny>[inhalt.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final a = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = dateiname;
  a.click();
  // Erst freigeben, wenn der Browser den Download begonnen hat. Sofortiges
  // Freigeben bricht ihn in manchen Browsern ab.
  unawaited(Future<void>.delayed(const Duration(seconds: 30),
      () => web.URL.revokeObjectURL(url)));
}
