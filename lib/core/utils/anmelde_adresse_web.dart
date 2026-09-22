// FILE: lib/core/utils/anmelde_adresse_web.dart
// PURPOSE: Browser-Fassung — siehe anmelde_adresse.dart.
import 'package:web/web.dart' as web;

void entferneAnmeldeParameter() {
  final ort = web.window.location;
  if (ort.search.isEmpty) return;
  web.window.history
      .replaceState(null, '', '${ort.origin}${ort.pathname}${ort.hash}');
}
