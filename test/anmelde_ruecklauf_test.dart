// FILE: test/anmelde_ruecklauf_test.dart
// PURPOSE: P.2 (2026-09-23) — Rückweg aus der Passwort-Mail.
//
// Die Adressen unten sind **echte Antworten** des Supabase-Servers
// (`/auth/v1/verify`, 2026-09-23, Test-Konto danach gelöscht), nur die
// Token gekürzt. Bricht hier etwas, landet ein Nutzer nach dem Klick in der
// Mail entweder auf einer Fehlerseite des Routers oder stumm auf der
// Startseite — beides ohne Absturz, also in keinem anderen Test sichtbar.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/constants/app_links.dart';
import 'package:vox/core/utils/anmelde_ruecklauf.dart';

const _basis = 'https://lukasylilli.github.io/vox/';

/// Gültiger Link, so wie der Server ihn zurückschickt.
const _gueltig = '$_basis?link=passwort#access_token=eyJ.a.b'
    '&expires_at=1790167017&expires_in=3600&refresh_token=r1'
    '&sb=&token_type=bearer&type=recovery';

/// Derselbe Link beim zweiten Klick.
const _benutzt = '$_basis?link=passwort#error=access_denied'
    '&error_code=otp_expired'
    '&error_description=Email+link+is+invalid+or+has+expired&sb=';

/// Was `supabase_flutter` nach erfolgreichem Einlösen übrig lässt
/// (`sb` kennt es nicht).
const _nachEinloesen = '$_basis?link=passwort#sb=';

void main() {
  test('Rückkehr-Adresse steht zeichengleich so in Supabase', () {
    // ⚠️ Ändert sich dieser Text, muss er in Supabase → Authentication →
    // URL Configuration → Redirect URLs mitgeändert werden.
    expect(AppLinks.voxPasswortUrl, '$_basis?link=passwort');
  });

  group('anmeldeRuecklauf', () {
    test('eingelöster Link ⇒ keiner', () {
      expect(anmeldeRuecklauf(Uri.parse(_nachEinloesen)),
          AnmeldeRuecklauf.keiner);
    });

    test('benutzter/abgelaufener Link ⇒ ungültig', () {
      expect(anmeldeRuecklauf(Uri.parse(_benutzt)),
          AnmeldeRuecklauf.passwortLinkUngueltig);
    });

    test('Sitzung steht nach dem Start noch da ⇒ nicht eingelöst ⇒ ungültig',
        () {
      // z. B. kein Netz oder kein Server im Bau.
      expect(anmeldeRuecklauf(Uri.parse(_gueltig)),
          AnmeldeRuecklauf.passwortLinkUngueltig);
    });

    test('Fehler ohne Passwort-Kennzeichen ⇒ keiner (anderer Mail-Link)', () {
      expect(
        anmeldeRuecklauf(Uri.parse(
            '$_basis?error=access_denied&error_code=otp_expired'
            '#error=access_denied&error_code=otp_expired&sb=')),
        AnmeldeRuecklauf.keiner,
      );
    });

    test('normaler Aufruf ⇒ keiner', () {
      expect(anmeldeRuecklauf(Uri.parse(_basis)), AnmeldeRuecklauf.keiner);
      expect(anmeldeRuecklauf(Uri.parse('$_basis#/more/profil')),
          AnmeldeRuecklauf.keiner);
    });

    test('kaputte Kodierung wirft nicht', () {
      expect(anmeldeRuecklauf(Uri.parse('$_basis?link=passwort#error=%E0%A4%A')),
          isA<AnmeldeRuecklauf>());
    });
  });

  group('bereinigteAnmeldeAdresse', () {
    test('Reste nach dem Einlösen ⇒ nackte Adresse', () {
      expect(bereinigteAnmeldeAdresse(Uri.parse(_nachEinloesen)), _basis);
    });

    test('Fehler und Sitzung fallen ganz weg', () {
      expect(bereinigteAnmeldeAdresse(Uri.parse(_benutzt)), _basis);
      expect(bereinigteAnmeldeAdresse(Uri.parse(_gueltig)), _basis);
    });

    test('PKCE-Reste im ?…: auch weg', () {
      expect(bereinigteAnmeldeAdresse(Uri.parse('$_basis?code=abc')), _basis);
      expect(
        bereinigteAnmeldeAdresse(Uri.parse(
            '$_basis?error=access_denied&error_code=otp_expired'
            '#error=access_denied&sb=')),
        _basis,
      );
    });

    test('E-Mail-Änderung, erster Klick (#message=…) ⇒ weg', () {
      expect(
        bereinigteAnmeldeAdresse(Uri.parse(
            '$_basis#message=Confirmation+link+accepted&sb=')),
        _basis,
      );
    });

    test('echter Router-Pfad und fremde Werte bleiben', () {
      expect(bereinigteAnmeldeAdresse(Uri.parse('$_basis#/more/profil')),
          isNull);
      expect(bereinigteAnmeldeAdresse(Uri.parse(_basis)), isNull);
      expect(
        bereinigteAnmeldeAdresse(
            Uri.parse('$_basis?code=abc&utm=x#/wortschatz')),
        '$_basis?utm=x#/wortschatz',
      );
    });
  });
}
