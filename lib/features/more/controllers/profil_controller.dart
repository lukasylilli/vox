// FILE: lib/features/more/controllers/profil_controller.dart
// PHASE: فاز P / P.1–P.3 (2026-09-20)
// PURPOSE: Zustand hinter der Profil-Seite (`/more/profil`):
//          · [profilProvider]        Name, Telefon, Adressen (SharedPreferences)
//          · [archivUebersichtProvider] Zahlen zu Leitner, Listen, Notizen, eigenen Wörtern
//          · [passwortNeuProvider]   „Neues Passwort setzen" nach dem Link aus der Mail
//
// ⚠️ Die persönlichen Angaben liegen **im Browser** (Zuhause, siehe PLAN →
//    فاز S: „drei Orte, EIN Zuhause") und reisen von dort in die Sicherungs-
//    Datei und — nur bei angemeldetem Konto — in die eigene Zeile von
//    `vox_backups`. Nichts davon geht an Root-in oder in `profiles`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/nutzer_profil.dart';
import '../../../core/backup/user_state_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/anmelde_adresse.dart';
import '../../wortschatz/controllers/word_controller.dart' show databaseProvider;

// ── Persönliche Angaben ──────────────────────────────────────────────────

class ProfilNotifier extends AsyncNotifier<NutzerProfil> {
  @override
  Future<NutzerProfil> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NutzerProfil.ausText(prefs.getString(kProfilKey)) ??
        const NutzerProfil();
  }

  /// Speichert `neu` — bereinigt und mit dem Zeitpunkt der Änderung.
  ///
  /// Wirft **nicht**: Wer speichern will, hat vorher [NutzerProfil.pruefen]
  /// gefragt. Gibt den Fehler trotzdem zurück, falls doch etwas durchrutscht
  /// (`null` = gespeichert) — lieber nichts speichern als etwas Ungültiges.
  Future<ProfilFehler?> speichern(NutzerProfil neu) async {
    final sauber = neu.bereinigt();
    final fehler = sauber.pruefen();
    if (fehler != null) return fehler;
    final prefs = await SharedPreferences.getInstance();
    final mitZeit = sauber.kopie(am: DateTime.now().toUtc());
    await prefs.setString(kProfilKey, mitZeit.zuText());
    state = AsyncData(mitZeit);
    return null;
  }
}

final profilProvider =
    AsyncNotifierProvider<ProfilNotifier, NutzerProfil>(ProfilNotifier.new);

// ── Archive ──────────────────────────────────────────────────────────────

/// Was der Nutzer bisher angelegt hat — nur Zahlen, für die Karte
/// «آرشیو من» auf der Profil-Seite.
class ArchivUebersicht {
  const ArchivUebersicht({
    required this.leitnerKarten,
    required this.proFach,
    required this.listen,
    required this.notizen,
    required this.eigeneWoerter,
  });

  /// Wörter im Leitner-Kasten (alle Fächer zusammen).
  final int leitnerKarten;

  /// Fach → Anzahl Karten. Nur Fächer, in denen etwas liegt; aufsteigend.
  final Map<int, int> proFach;

  /// Eigene Listen.
  final int listen;
  final int notizen;
  final int eigeneWoerter;

  bool get istLeer =>
      leitnerKarten == 0 && listen == 0 && notizen == 0 && eigeneWoerter == 0;
}

/// Liest den Nutzerzustand über **dieselbe** Ablage wie Sicherung und Konto
/// (`UserStateRepository`) — keine zweite Zählweise, die abweichen könnte.
final archivUebersichtProvider =
    FutureProvider.autoDispose<ArchivUebersicht>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final zustand =
      await UserStateRepository(ref.read(databaseProvider), prefs).lesen();

  final zaehler = <int, int>{};
  for (final karte in zustand.leitner.values) {
    zaehler[karte.fach] = (zaehler[karte.fach] ?? 0) + 1;
  }
  final faecher = zaehler.keys.toList()..sort();

  return ArchivUebersicht(
    leitnerKarten: zustand.leitner.length,
    proFach: {for (final f in faecher) f: zaehler[f]!},
    listen: zustand.kategorien.length,
    notizen: zustand.notizen.length,
    eigeneWoerter: zustand.eigeneWoerter.length,
  );
});

// ── Passwort zurücksetzen ────────────────────────────────────────────────

/// Wahr, sobald der Nutzer über den Link aus der Mail zurückgekommen ist und
/// ein neues Passwort setzen soll. Die Profil-Seite zeigt dann ganz oben die
/// Karte «رمز جدید»; nach Erfolg wird es wieder falsch.
final passwortNeuProvider = StateProvider<bool>((ref) => false);

/// Hält das Abonnement auf das Wiederherstellungs-Ereignis am Leben
/// (`VoxApp` beobachtet dies wie `kontoAbgleichStarterProvider`). Ohne Server:
/// nichts.
///
/// ⚠️ Navigiert **nicht** selbst — das macht `app.dart`, damit dieser Provider
/// den Router nicht kennen muss (sonst Import-Kreis über die Profil-Seite).
final passwortWiederherstellungStarterProvider = Provider<void>((ref) {
  if (!ref.watch(kontoAktivProvider)) return;
  final service = ref.read(authServiceProvider);
  final abo = service.watchPasswordRecovery().listen((_) {
    ref.read(passwortNeuProvider.notifier).state = true;
  });
  ref.onDispose(abo.cancel);

  // Link mit `token_hash` (2026-09-22): einlösen, dann die Adresse säubern —
  // der Token gilt nur einmal, ein Neuladen soll ihn nicht erneut versuchen.
  final token = wiederherstellungsToken(Uri.base);
  if (token == null) return;
  entferneAnmeldeParameter();
  service.verifyRecoveryToken(token).then((ok) {
    if (ok) {
      ref.read(passwortNeuProvider.notifier).state = true;
    } else {
      ref.read(passwortLinkUngueltigProvider.notifier).state = true;
    }
  });
});

/// Wahr, wenn ein Wiederherstellungs-Link nicht eingelöst werden konnte
/// (abgelaufen, schon benutzt, kein Netz). Die Profil-Seite sagt es dann,
/// statt dass die App stumm auf der Startseite landet.
final passwortLinkUngueltigProvider = StateProvider<bool>((ref) => false);
