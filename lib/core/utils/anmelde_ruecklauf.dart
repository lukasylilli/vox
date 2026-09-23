// FILE: lib/core/utils/anmelde_ruecklauf.dart
// PHASE: P.2 — Passwort-Link ohne Browser-Bindung (2026-09-23)
// PURPOSE: Liest, womit Supabase die Seite nach dem Klick auf einen Mail-Link
//          geöffnet hat, und baut die Adresse ohne diese Reste.
//          Rein (nur `Uri` hinein, Wert heraus) — damit ohne Browser prüfbar.
//          Die Browser-Seite (`history.replaceState`) steht in
//          `anmelde_adresse*.dart`.
//
// Warum es das braucht:
// Die Passwort-Mail wird **implizit** angefordert (`AuthService.sendPasswordReset`).
// Nach dem Klick kommt der Nutzer so zurück (am echten Server geprüft,
// 2026-09-23):
//   gültig:  …/vox/?link=passwort#access_token=…&refresh_token=…&sb=&type=recovery
//   benutzt: …/vox/?link=passwort#error=access_denied&error_code=otp_expired&…&sb=
// `supabase_flutter` löst den gültigen Link schon in `Supabase.initialize`
// ein und räumt die Adresse auf — aber nur teilweise: `sb` kennt es nicht,
// übrig bleibt `#sb=`. Ein gescheiterter Link bleibt ganz stehen.
// VOX nutzt `#/…` als Pfad (Hash-Router). Was dort steht, hielte der Router
// für eine Seite — deshalb muss es **vor dem ersten Frame** weg.
library;

import '../constants/app_links.dart';

/// Was nach dem Start von Supabase aus einem Mail-Link übrig ist.
enum AnmeldeRuecklauf {
  /// Kein Passwort-Link, oder er wurde eingelöst.
  keiner,

  /// Der Passwort-Link ließ sich nicht einlösen (abgelaufen, schon benutzt,
  /// kein Netz, kein Server). Die Profil-Seite sagt es dann.
  passwortLinkUngueltig,
}

/// Alles, was Supabase Auth an eine Rückkehr-Adresse hängt — in `?…` oder
/// `#…`. `sb` ist Supabases eigenes Erkennungszeichen, `message` kommt beim
/// ersten von zwei Klicks einer E-Mail-Änderung.
const _supabaseSchluessel = {
  'access_token',
  'refresh_token',
  'expires_in',
  'expires_at',
  'token_type',
  'type',
  'provider_token',
  'provider_refresh_token',
  'code',
  'error',
  'error_code',
  'error_description',
  'message',
  'sb',
};

/// Steht einer davon **nach** `Supabase.initialize` noch im `#…`, wurde der
/// Link nicht eingelöst: Bei Erfolg hätte `supabase_flutter` ihn entfernt.
const _nichtEingeloest = {
  'access_token',
  'error',
  'error_code',
  'error_description',
};

/// Werte aus einem `a=1&b=2`-Text. Leer, wenn der Text keiner ist — ein
/// Router-Pfad (`/wortschatz`) oder kaputte Prozent-Kodierung.
Map<String, String> _werte(String text) {
  if (text.isEmpty || text.startsWith('/')) return const {};
  try {
    return Uri.splitQueryString(text);
  } on ArgumentError {
    return const {};
  } on FormatException {
    return const {};
  }
}

/// Ob der Passwort-Link **gescheitert** ist. Nur sinnvoll **nach**
/// `Supabase.initialize` (siehe [_nichtEingeloest]).
///
/// Nur mit dem Kennzeichen aus `AppLinks.voxPasswortUrl`: Einen Fehler hängt
/// Supabase an **jeden** Mail-Link (auch an den einer E-Mail-Änderung) —
/// „Passwort-Link ungültig\" wäre dort die falsche Auskunft.
AnmeldeRuecklauf anmeldeRuecklauf(Uri adresse) {
  final query = _werte(adresse.query);
  if (query[AppLinks.passwortLinkParameter] != AppLinks.passwortLinkWert) {
    return AnmeldeRuecklauf.keiner;
  }
  final fragment = _werte(adresse.fragment);
  return fragment.keys.any(_nichtEingeloest.contains)
      ? AnmeldeRuecklauf.passwortLinkUngueltig
      : AnmeldeRuecklauf.keiner;
}

/// [adresse] ohne Supabase-Reste und ohne das Passwort-Kennzeichen — `null`,
/// wenn es nichts zu säubern gibt.
///
/// Ein `#…` mit Supabase-Schlüsseln fällt **ganz** weg: Es ist nie ein Pfad
/// dieser App (die beginnen mit `/`). Ein echter Pfad (`#/more/profil`) und
/// fremde `?…`-Werte bleiben unberührt.
String? bereinigteAnmeldeAdresse(Uri adresse) {
  final query = _werte(adresse.query);
  final restQuery = <String, String>{
    for (final eintrag in query.entries)
      if (!_supabaseSchluessel.contains(eintrag.key) &&
          eintrag.key != AppLinks.passwortLinkParameter)
        eintrag.key: eintrag.value,
  };
  final queryAendertSich = restQuery.length != query.length;
  final fragmentFaelltWeg =
      _werte(adresse.fragment).keys.any(_supabaseSchluessel.contains);

  if (!queryAendertSich && !fragmentFaelltWeg) return null;

  return Uri(
    scheme: adresse.scheme,
    userInfo: adresse.userInfo,
    host: adresse.host,
    port: adresse.hasPort ? adresse.port : null,
    path: adresse.path,
    query: queryAendertSich
        ? (restQuery.isEmpty ? null : Uri(queryParameters: restQuery).query)
        : (adresse.hasQuery ? adresse.query : null),
    fragment: fragmentFaelltWeg || !adresse.hasFragment
        ? null
        : adresse.fragment,
  ).toString();
}
