// FILE: lib/main.dart
// PURPOSE: Entry point (Web) — dauerhafter Speicher (S.1), Vokabel-Seeding, ProviderScope
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/services/auth_service.dart';
import 'core/services/data_seed_service.dart';
import 'core/utils/anmelde_adresse.dart';
import 'core/utils/anmelde_ruecklauf.dart';
import 'core/utils/html_loader.dart';
import 'core/utils/persistent_storage.dart';
import 'features/more/controllers/profil_controller.dart';
import 'features/wortschatz/controllers/word_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // فاز S / S.1: Den Browser bitten, den Speicher dieser Seite dauerhaft zu
  // behalten. Reine Bitte, keine Garantie — darf den Start nie aufhalten,
  // deshalb wie beim Seeding unten in try/catch.
  try {
    final dauerhaft = await requestPersistentStorage();
    debugPrint('Dauerhafter Speicher: $dauerhaft');
  } catch (e) {
    debugPrint('Dauerhafter Speicher konnte nicht erbeten werden: $e');
  }

  // فاز S / S.3 Schritt 2: Supabase starten, **falls** konfiguriert.
  // Ohne Secrets (Normalfall in Tests und in jedem Bau ohne --dart-define)
  // meldet initialize() einfach `false` — nie eine Ausnahme. Trotzdem hier
  // zusätzlich try/catch wie beim Seeding: ein Fehler in dieser Zeile darf
  // die App nie am Start hindern.
  try {
    final kontoBereit = await const AuthService().initialize();
    debugPrint('Supabase-Konto bereit: $kontoBereit');
  } catch (e) {
    debugPrint('Supabase-Start fehlgeschlagen: $e');
  }

  // P.2 (2026-09-23): Rückweg aus einem Mail-Link. `Supabase.initialize` hat
  // einen gültigen Passwort-Link oben schon eingelöst (Ereignis
  // `passwordRecovery`). Hier nur noch: festhalten, ob er gescheitert ist,
  // und die Adresse säubern — **vor** runApp, denn der Router liest `#…` beim
  // ersten Frame als Pfad (`#access_token=…` wäre sonst eine „Seite").
  // Beides wirft nicht; auch ohne Server nötig (ein Link kann trotzdem kommen).
  final ruecklauf = anmeldeRuecklauf(Uri.base);
  entferneAnmeldeReste();

  // Seed vocabulary from JSON files into SQLite (runs once on first launch).
  // Fehler dürfen den App-Start NIE blockieren (weißer Bildschirm) — die
  // Transaktion rollt zurück, das Flag bleibt ungesetzt → Retry beim nächsten Start.
  final db = AppDatabase();
  try {
    await DataSeedService(db).seedIfNeeded();
  } catch (e, s) {
    debugPrint('Vokabel-Seeding fehlgeschlagen: $e\n$s');
  }

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      anmeldeRuecklaufProvider.overrideWithValue(ruecklauf),
    ],
    child    : const VoxApp(),
  ));

  // CSS-Ladeanzeige aus web/index.html entfernen, sobald der erste Frame steht.
  WidgetsBinding.instance.addPostFrameCallback((_) => removeHtmlLoader());
}
