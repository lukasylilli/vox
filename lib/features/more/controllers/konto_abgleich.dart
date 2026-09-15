// FILE: lib/features/more/controllers/konto_abgleich.dart
// PHASE: فاز S, S.3 Schritt 3 (2026-09-15)
// PURPOSE: WANN abgeglichen wird — der Ablauf selbst steht in
//          `core/backup/cloud_abgleich.dart`.
//
// Auslöser:
//   · Anmeldung — und beim Start, wenn eine Sitzung schon besteht (Supabase
//     meldet sie beim Abonnieren als erstes Ereignis)
//   · alle [_takt] Minuten, solange die App offen ist
//   · von Hand: Einstellungen → Konto → «همگام‌سازی»
//
// ⚠️ Scheitern ist stumm. Kein Netz, Server gesperrt — die App arbeitet lokal
//    weiter, der nächste Takt versucht es erneut. Nur der Knopf meldet etwas.
// ⚠️ Nur aktiv, wenn `kontoAktivProvider` wahr ist — ohne Konfiguration gibt
//    es weder Timer noch Netzaufruf (auch nicht in Tests).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/cloud_abgleich.dart';
import '../../../core/backup/user_state_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/cloud_ablage_supabase.dart';
import '../../vokabular/controllers/vokabular_user_state.dart';
import '../../wortschatz/controllers/word_controller.dart' show databaseProvider;
import 'settings_controller.dart';

class KontoAbgleichStand {
  final bool laeuft;

  /// Letzte Sicherung laut Server.
  final DateTime? zuletzt;
  final CloudStatus? letzterStatus;

  const KontoAbgleichStand({
    this.laeuft = false,
    this.zuletzt,
    this.letzterStatus,
  });
}

class KontoAbgleich extends Notifier<KontoAbgleichStand> {
  static const Duration _takt = Duration(minutes: 5);
  Timer? _timer;

  @override
  KontoAbgleichStand build() {
    if (ref.watch(kontoAktivProvider)) {
      ref.listen<AsyncValue<AuthAccount?>>(authAccountProvider,
          (vorher, jetzt) {
        final neu = jetzt.valueOrNull;
        if (neu == null) {
          // Abgemeldet: keine Anzeige eines fremden Stands stehen lassen.
          state = const KontoAbgleichStand();
          return;
        }
        if (vorher?.valueOrNull?.id != neu.id) abgleichen();
      });
      _timer = Timer.periodic(_takt, (_) => abgleichen());
      ref.onDispose(() => _timer?.cancel());
    }
    return const KontoAbgleichStand();
  }

  /// Gleicht jetzt ab. Läuft schon einer, wird kein zweiter gestartet.
  Future<CloudStatus> abgleichen() async {
    if (state.laeuft) return CloudStatus.ok;
    if (ref.read(authServiceProvider).currentAccount == null) {
      return CloudStatus.nichtVerfuegbar;
    }
    state = KontoAbgleichStand(
        laeuft: true, zuletzt: state.zuletzt, letzterStatus: state.letzterStatus);
    var status = CloudStatus.fehlgeschlagen;
    var zuletzt = state.zuletzt;
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = UserStateRepository(ref.read(databaseProvider), prefs);
      final e =
          await CloudAbgleich(repo, ref.read(cloudAblageProvider)).abgleichen();
      status = e.status;
      zuletzt = e.zeitpunkt ?? zuletzt;
      if (e.lokalGeaendert) {
        // Die Ablage wurde an den Stores vorbei geändert.
        await ref.read(vokabularUserProvider.notifier).neuLaden();
        ref.invalidate(settingsProvider);
      }
    } catch (_) {
      status = CloudStatus.fehlgeschlagen;
    }
    state = KontoAbgleichStand(zuletzt: zuletzt, letzterStatus: status);
    return status;
  }
}

final kontoAbgleichProvider =
    NotifierProvider<KontoAbgleich, KontoAbgleichStand>(KontoAbgleich.new);

/// Hält den Abgleich am Leben, ohne dass die App bei jeder Zustandsänderung
/// neu gebaut wird (`VoxApp` beobachtet nur dies hier, nicht den Stand).
final kontoAbgleichStarterProvider = Provider<void>((ref) {
  if (!ref.watch(kontoAktivProvider)) return;
  ref.watch(kontoAbgleichProvider.notifier);
});
