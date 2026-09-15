// FILE: lib/core/constants/app_config.dart
// PURPOSE: Werte, die beim Bauen hereingereicht werden (--dart-define) —
//          فاز S / S.3 (Konto). Einzige Stelle dafür im Projekt.
//
// Herkunft: übernommen aus Root-in
// (github.com/lukasylilli/Root-in, lib/core/constants/app_config.dart).
// Gekürzt auf das, was VOX braucht; der Kern ist zeichengleich.
//
// ⚠️ **Ein `--dart-define` ist keine Verschlüsselung.** Der Wert wird in das
// Bundle einkompiliert und lässt sich dort mit einer Textsuche in
// `main.dart.js` finden. Was er leistet: Der Wert steht nicht im
// Repository und lässt sich je Umgebung austauschen. Was er **nicht**
// leistet: ihn vor dem Nutzer verbergen.
//
// Daraus folgt die Regel für jeden künftigen Schlüssel: **Was geheim bleiben
// muss, gehört nicht in die App, sondern hinter einen Server, der es nie
// herausgibt.** Ein API-Schlüssel, den die App mitschickt, ist ein
// veröffentlichter API-Schlüssel.
//
// Der `anon`-Schlüssel von Supabase ist genau der Sonderfall, für den diese
// Regel nicht gilt: Er ist **dafür gemacht**, in Clients zu stehen. Er ist
// kein Geheimnis, sondern eine Kennung. Was fremde Zugriffe abwehrt, sind
// ausschließlich die Zugriffsregeln der Datenbank (`supabase/vox_tables.sql`
// und, für die gemeinsamen Tabellen, `supabase/schema.sql` in Root-in).
//
// ⚠️ **Der `service_role`-Schlüssel ist das Gegenteil davon.** Er umgeht jede
// dieser Regeln. Er gehört nie in diese Datei, nie in ein `--dart-define`,
// nie in das Repository — das öffentlich ist.
abstract final class AppConfig {
  /// Adresse des Supabase-Projekts, z. B. `https://<kennung>.supabase.co`.
  ///
  /// **Leer bedeutet: kein Server.** Dann gibt es keine Anmeldung, keine
  /// Kopie in der Cloud und keinen einzigen Netzaufruf dorthin — VOX verhält
  /// sich exakt wie vor S.3. Das ist der Normalfall in Tests und in Bauten
  /// ohne hinterlegte Secrets, und es darf nie etwas daran kaputtgehen.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Öffentlicher `anon`-Schlüssel des Projekts.
  ///
  /// ⚠️ **Kein Geheimnis, und das ist Absicht.** Er steht im ausgelieferten
  /// Bundle und lässt sich dort finden. Er sagt dem Server nur, *welches
  /// Projekt* gemeint ist; *welche Zeilen* jemand sehen darf, entscheiden die
  /// Regeln in der Datenbank anhand des Anmelde-Tokens. Wer diesen Schlüssel
  /// kopiert, bekommt damit **keinen** Zugriff auf fremde Daten —
  /// vorausgesetzt, die Regeln stimmen. Sie sind die einzige Verteidigung;
  /// es gibt keine zweite.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Ob beide Supabase-Werte gesetzt sind.
  ///
  /// VOX ist eine reine Web-App — es gibt keine zweite Bedingung wie eine
  /// Plattformprüfung. Deshalb ist diese Frage hier vollständig beantwortet
  /// und braucht kein eigenes `platform_support.dart` wie in Root-in.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
