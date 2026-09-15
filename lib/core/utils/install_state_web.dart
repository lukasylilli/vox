// FILE: lib/core/utils/install_state_web.dart
// PURPOSE: Browser-Fassung — siehe install_state.dart.
// Bewusst ohne Promises/js_interop: nur matchMedia und userAgent, beide
// liefern einfache Werte. Je weniger Web-API, desto weniger kann brechen.
import 'package:web/web.dart' as web;

import 'install_hinweis.dart';

InstallHinweis erkenneInstallHinweis() {
  // Installierte Web-Apps laufen im standalone-Anzeigemodus.
  if (web.window.matchMedia('(display-mode: standalone)').matches) {
    return InstallHinweis.installiert;
  }
  final ua = web.window.navigator.userAgent.toLowerCase();
  if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
    return InstallHinweis.ios;
  }
  if (ua.contains('android')) return InstallHinweis.android;
  return InstallHinweis.desktop;
}
