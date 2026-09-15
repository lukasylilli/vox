// FILE: lib/core/services/auth_service.dart
// PURPOSE: Nutzerkonten (فاز S / S.3) — **einzige** Stelle im Projekt, die
//          `supabase_flutter` kennt. Die Oberfläche spricht nur mit
//          [AuthService].
//
// Herkunft: übernommen aus Root-in
// (github.com/lukasylilli/Root-in, lib/core/services/auth_service.dart).
// Der allgemeine Teil ist zeichengleich kopiert — Fehlerzuordnung, Typen,
// Rückgabeform. Abweichungen sind unten einzeln begründet.
//
// ⚠️ **Zwei Apps, EIN Anmeldebestand, getrennte Tabellen.** VOX und Root-in
// teilen sich dasselbe Supabase-Projekt und damit `auth.users`: Wer sich in
// Root-in registriert hat, meldet sich in VOX mit derselben Adresse an. Die
// **Tabellen** gehören aber je einem Repo — `profiles` und `backups` stehen
// in `supabase/schema.sql` (Root-in), `vox_backups` in
// `supabase/vox_tables.sql` (hier). Keine der beiden Apps schreibt in die
// Tabellen der anderen.
//
// Daraus folgt der wichtigste Unterschied zur Vorlage: **VOX kennt keinen
// Benutzernamen.** `profiles.username` gehört Root-in, samt Eindeutigkeits-
// Index und Namensregeln. VOX meldet mit E-Mail und Passwort an und hört
// dort auf; ein Konto ohne Root-in-Profilzeile ist hier völlig normal.
// Ebenfalls bewusst nicht übernommen: `deleteAccount()`. Es löscht
// `auth.users` und damit **auch den Root-in-Bestand** desselben Menschen —
// das ist eine Entscheidung für beide Apps zusammen, nicht für diese hier.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';

/// Warum ein Anmelde-Vorgang nicht geklappt hat — **sprachneutral**, wie
/// `SicherungFehler` in `core/backup/nutzer_zustand.dart`.
///
/// Supabase meldet auf Englisch; VOX zeigt Persisch oder Englisch (فاز L).
/// Übersetzt wird in der Oberfläche über `AppL10n`, nicht hier.
enum AuthIssue {
  /// Kein Server konfiguriert — der Aufrufer hätte nicht fragen dürfen.
  notConfigured,

  /// Diese E-Mail ist schon registriert.
  emailTaken,

  /// E-Mail oder Passwort stimmen nicht.
  invalidCredentials,

  /// Passwort erfüllt die Mindestanforderungen nicht.
  weakPassword,

  /// Die E-Mail-Adresse hat kein gültiges Format.
  invalidEmail,

  /// Registrierung ist auf dem Server abgeschaltet.
  signupDisabled,

  /// Zu viele Nachrichten an diese Adresse.
  emailRateLimited,

  /// Server nicht erreichbar — kein Netz, Projekt pausiert, Adresse gesperrt.
  offline,

  /// Alles andere. ⚠️ Muss existieren: Ein Server kann jederzeit einen Code
  /// melden, den diese Fassung der App noch nicht kennt.
  unknown,
}

/// Ordnet einen Supabase-Fehler einem [AuthIssue] zu.
///
/// ⚠️ **Es wird der `code` ausgewertet, nicht die Meldung.** Der Text ist
/// englische Prosa und kann sich jederzeit ändern; der Code ist Teil der
/// dokumentierten Schnittstelle. Wer auf `message.contains('already')` prüft,
/// baut eine Fehlerbehandlung, die beim nächsten Server-Update still bricht —
/// und still heißt hier: Der Nutzer bekommt „unbekannter Fehler" statt
/// „diese E-Mail ist schon registriert".
///
/// Als reine Funktion herausgezogen, damit sie **ohne Server prüfbar** ist.
AuthIssue authIssueFromCode(String? code) => switch (code) {
  'email_exists' || 'user_already_exists' => AuthIssue.emailTaken,
  'invalid_credentials' => AuthIssue.invalidCredentials,
  'weak_password' => AuthIssue.weakPassword,
  'validation_failed' => AuthIssue.invalidEmail,
  'signup_disabled' => AuthIssue.signupDisabled,
  'over_email_send_rate_limit' => AuthIssue.emailRateLimited,
  _ => AuthIssue.unknown,
};

/// Wer gerade angemeldet ist. `null` = niemand.
///
/// Bewusst ein eigener kleiner Typ statt Supabases `User`: So kennt die
/// Oberfläche das Paket nicht, und der Test braucht keinen echten `User`.
class AuthAccount {
  const AuthAccount({required this.id, required this.email});

  final String id;
  final String email;
}

/// Ergebnis eines Anmelde-Vorgangs: entweder ein Konto oder ein Grund.
class AuthResult {
  const AuthResult.success(this.account) : issue = null;
  const AuthResult.failure(this.issue) : account = null;

  final AuthAccount? account;
  final AuthIssue? issue;

  bool get isSuccess => issue == null;
}

/// Der Dienst. Alle Methoden geben [AuthResult] zurück statt zu werfen —
/// eine fehlgeschlagene Anmeldung ist ein erwarteter Verlauf, keine Ausnahme.
///
/// ⚠️ **Ohne Konfiguration passiert hier gar nichts.** Ist
/// `AppConfig.hasSupabaseConfig` falsch, wird Supabase nie gestartet und
/// jeder Aufruf meldet [AuthIssue.notConfigured], statt in einen Fehler tief
/// im Paket zu laufen. Das ist der Normalfall in Tests und in jedem Bau ohne
/// hinterlegte Secrets.
class AuthService {
  const AuthService();

  /// Startet Supabase, **falls** konfiguriert. Mehrfach aufrufbar.
  ///
  /// Wird aus `main.dart` vor dem ersten Frame aufgerufen. ⚠️ Ein Fehler hier
  /// darf den Start **nicht** verhindern: Ohne Server soll VOX laufen wie
  /// immer — genau deshalb fängt die Methode alles ab und meldet nur `false`.
  Future<bool> initialize() async {
    if (!AppConfig.hasSupabaseConfig) return false;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // Heißt in neueren Fassungen `publishableKey`; `anonKey` ist derselbe
        // Wert und nur noch als veralteter Name vorhanden. In der Supabase-
        // Oberfläche kann er als „anon public" **oder** „Publishable key"
        // auftauchen — es ist derselbe Schlüssel.
        publishableKey: AppConfig.supabaseAnonKey,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get _client {
    if (!AppConfig.hasSupabaseConfig) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      // `initialize` lief nicht oder scheiterte.
      return null;
    }
  }

  /// Das gerade angemeldete Konto. `null` = niemand.
  AuthAccount? get currentAccount {
    final user = _client?.auth.currentUser;
    if (user == null) return null;
    return AuthAccount(id: user.id, email: user.email ?? '');
  }

  /// Meldet jede Änderung des Anmelde-Zustands. Leerer Stream ohne Server.
  Stream<AuthAccount?> watchAccount() {
    final client = _client;
    if (client == null) return const Stream<AuthAccount?>.empty();
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return AuthAccount(id: user.id, email: user.email ?? '');
    });
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return const AuthResult.failure(AuthIssue.notConfigured);
    }
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const AuthResult.failure(AuthIssue.invalidCredentials);
      }
      return AuthResult.success(
        AuthAccount(id: user.id, email: user.email ?? ''),
      );
    } on AuthException catch (error) {
      return AuthResult.failure(authIssueFromCode(error.code));
    } catch (_) {
      // Netzfehler kommen nicht als AuthException heraus.
      return const AuthResult.failure(AuthIssue.offline);
    }
  }

  /// Legt ein Konto an — E-Mail und Passwort, mehr nicht.
  ///
  /// ⚠️ **Kein Benutzername.** Der gehört zu `profiles` und damit zu Root-in
  /// (siehe Kopf dieser Datei). Wer in beiden Apps unterwegs ist, hat
  /// denselben Anmeldebestand; den Namen vergibt Root-in.
  ///
  /// ⚠️ **`user` ungleich `session`.** Ist die E-Mail-Bestätigung auf dem
  /// Server eingeschaltet, kommt ein Konto ohne Sitzung zurück: registriert,
  /// aber noch nicht angemeldet. Der Aufrufer erfährt das über
  /// [AuthResult.account] plus [currentAccount] — hier wird bewusst nicht
  /// geraten, sondern nur weitergegeben, was der Server gesagt hat.
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return const AuthResult.failure(AuthIssue.notConfigured);
    }
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) return const AuthResult.failure(AuthIssue.unknown);
      return AuthResult.success(
        AuthAccount(id: user.id, email: user.email ?? ''),
      );
    } on AuthException catch (error) {
      return AuthResult.failure(authIssueFromCode(error.code));
    } catch (_) {
      return const AuthResult.failure(AuthIssue.offline);
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (_) {
      // Abmelden darf nie hängen bleiben. Die lokale Sitzung ist danach in
      // jedem Fall verworfen; ein Server, der nicht antwortet, ändert daran
      // nichts.
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => const AuthService());

/// Ob die Rubrik „Konto" in den Einstellungen überhaupt erscheint.
///
/// Führt normalerweise nur `AppConfig.hasSupabaseConfig` weiter. Als Provider,
/// damit **Tests sie einschalten können**, ohne dass ein Schlüssel im Bau
/// steckt — sonst wäre die Oberfläche dieser Phase unprüfbar, weil sie sich
/// in einem Testlauf grundsätzlich versteckt.
final kontoAktivProvider = Provider<bool>(
  (ref) => AppConfig.hasSupabaseConfig,
);

/// Der angemeldete Zustand für die Oberfläche. `null` = niemand angemeldet.
final authAccountProvider = StreamProvider<AuthAccount?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.watchAccount();
});
