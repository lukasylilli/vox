// FILE: lib/core/utils/install_hinweis.dart
// PHASE: فاز S, Schritt S.1b
// PURPOSE: Nur der Aufzählungstyp — bewusst in einer eigenen Datei, damit
//          zwischen der Weiche (install_state.dart) und den beiden Fassungen
//          kein Import-Kreis entsteht.
enum InstallHinweis {
  /// Läuft bereits als installierte Web-App — nichts zu tun.
  installiert,

  /// iPhone/iPad: Teilen-Menü → „Zum Home-Bildschirm".
  ios,

  /// Android/Chrome: Menü → „App installieren".
  android,

  /// Desktop-Browser: Adressleiste → Installieren.
  desktop,
}
