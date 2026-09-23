// FILE: lib/core/utils/anmelde_adresse_web.dart
// PURPOSE: Browser-Fassung — siehe anmelde_adresse.dart.
import 'package:web/web.dart' as web;

import 'anmelde_ruecklauf.dart';

void entferneAnmeldeReste() {
  final String? neu;
  try {
    neu = bereinigteAnmeldeAdresse(Uri.parse(web.window.location.href));
  } on FormatException {
    return;
  }
  if (neu == null) return;
  // `null` als Zustand: Flutters Browser-Verlauf entsteht erst beim ersten
  // Lesen des Pfads (nach runApp) und versieht den Eintrag dann selbst.
  web.window.history.replaceState(null, '', neu);
}
