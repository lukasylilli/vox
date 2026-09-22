// FILE: test/auth_service_test.dart
// PURPOSE: فاز S / S.3 — die Zuordnung Server-Fehler → sprachneutraler Grund,
//          und der Nachweis, dass ohne Konfiguration nichts passiert.
//
// Warum das einen eigenen Test verdient: Diese Zuordnung ist der Unterschied
// zwischen „diese E-Mail ist schon registriert" und „unbekannter Fehler".
// Sie kann **still** brechen — die App läuft weiter, nur die Auskunft an den
// Nutzer wird nutzlos. Ein Testlauf gegen den echten Server würde das nie
// zeigen, weil er die seltenen Fälle gar nicht erst auslöst.
//
// Die Codes stammen aus der Supabase-Dokumentation (Auth error codes),
// übernommen aus dem gleichnamigen Test in Root-in.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/constants/app_config.dart';
import 'package:vox/core/services/auth_service.dart';

void main() {
  group('authIssueFromCode', () {
    test('ordnet die dokumentierten Codes zu', () {
      expect(authIssueFromCode('email_exists'), AuthIssue.emailTaken);
      expect(authIssueFromCode('user_already_exists'), AuthIssue.emailTaken);
      expect(
        authIssueFromCode('invalid_credentials'),
        AuthIssue.invalidCredentials,
      );
      expect(authIssueFromCode('weak_password'), AuthIssue.weakPassword);
      expect(authIssueFromCode('validation_failed'), AuthIssue.invalidEmail);
      expect(authIssueFromCode('signup_disabled'), AuthIssue.signupDisabled);
      expect(
        authIssueFromCode('over_email_send_rate_limit'),
        AuthIssue.emailRateLimited,
      );
    });

    test('fällt bei unbekanntem Code auf unknown zurück', () {
      // ⚠️ Muss so sein: Der Server kann jederzeit einen Code melden, den
      // diese Fassung der App noch nicht kennt. Ein Absturz oder eine falsche
      // Zuordnung wäre schlimmer als ein ehrliches „unbekannt".
      expect(authIssueFromCode('etwas_ganz_neues'), AuthIssue.unknown);
      expect(authIssueFromCode(null), AuthIssue.unknown);
      expect(authIssueFromCode(''), AuthIssue.unknown);
    });

    test('wertet den CODE aus, nicht die englische Meldung', () {
      // Der Text ist Prosa und ändert sich ohne Ankündigung; der Code gehört
      // zur dokumentierten Schnittstelle. Wer `message.contains('already')`
      // prüft, baut etwas, das beim nächsten Server-Update still bricht.
      expect(
        authIssueFromCode('Email address already exists in the system.'),
        AuthIssue.unknown,
      );
    });
  });

  group('AuthResult', () {
    test('trennt Erfolg und Grund sauber', () {
      const ok = AuthResult.success(AuthAccount(id: 'u1', email: 'a@b.de'));
      expect(ok.isSuccess, isTrue);
      expect(ok.issue, isNull);
      expect(ok.account?.email, 'a@b.de');

      const bad = AuthResult.failure(AuthIssue.emailTaken);
      expect(bad.isSuccess, isFalse);
      expect(bad.account, isNull);
      expect(bad.issue, AuthIssue.emailTaken);
    });
  });

  group('wiederherstellungsToken', () {
    test('liest token_hash nur bei type=recovery', () {
      expect(
        wiederherstellungsToken(Uri.parse(
            'https://lukasylilli.github.io/vox/?token_hash=abc&type=recovery#/')),
        'abc',
      );
      expect(
        wiederherstellungsToken(Uri.parse(
            'https://lukasylilli.github.io/vox/?token_hash=abc&type=signup')),
        isNull,
      );
      expect(
        wiederherstellungsToken(
            Uri.parse('https://lukasylilli.github.io/vox/?code=xyz')),
        isNull,
      );
      expect(
        wiederherstellungsToken(Uri.parse(
            'https://lukasylilli.github.io/vox/?token_hash=&type=recovery')),
        isNull,
      );
    });

    test('ohne Server: verifyRecoveryToken ist false statt zu werfen',
        () async {
      expect(await const AuthService().verifyRecoveryToken('abc'), isFalse);
    });
  });

  group('Ohne Konfiguration', () {
    test('ist im Testlauf genau der Normalfall', () {
      // Kein --dart-define im Testlauf ⇒ keine Schlüssel ⇒ kein Server.
      // Wäre das anders, würden die Fälle unten echte Netzaufrufe machen.
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.hasSupabaseConfig, isFalse);
    });

    test('meldet jeder Aufruf notConfigured statt zu werfen', () async {
      // ⚠️ Es darf nichts geworfen und nichts ins Netz geschickt werden.
      const service = AuthService();

      expect(await service.initialize(), isFalse);
      expect(service.currentAccount, isNull);
      expect(
        (await service.signIn(email: 'a@b.de', password: 'x')).issue,
        AuthIssue.notConfigured,
      );
      expect(
        (await service.signUp(email: 'a@b.de', password: 'x')).issue,
        AuthIssue.notConfigured,
      );
      await service.signOut(); // darf nicht werfen
    });

    test('liefert einen leeren Strom statt eines Fehlers', () async {
      // Die Oberfläche hängt daran (`authAccountProvider`). Ein Strom, der
      // wirft, statt leer zu bleiben, würde die Einstellungsseite rot färben,
      // obwohl schlicht kein Server eingerichtet ist.
      const service = AuthService();
      expect(await service.watchAccount().toList(), isEmpty);
    });
  });
}
