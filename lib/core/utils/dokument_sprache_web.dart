// FILE: lib/core/utils/dokument_sprache_web.dart
// PURPOSE: Browser-Fassung — siehe dokument_sprache.dart.
import 'package:web/web.dart' as web;

void setzeDokumentSprache(String sprachcode) {
  final wurzel = web.document.documentElement;
  if (wurzel == null || wurzel.getAttribute('lang') == sprachcode) return;
  wurzel.setAttribute('lang', sprachcode);
}
