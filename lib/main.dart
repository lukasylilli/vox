// FILE: lib/main.dart
// PURPOSE: Entry point (Web) — Vokabel-Seeding, ProviderScope
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/services/data_seed_service.dart';
import 'core/utils/html_loader.dart';
import 'features/wortschatz/controllers/word_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    overrides: [databaseProvider.overrideWithValue(db)],
    child    : const VoxApp(),
  ));

  // CSS-Ladeanzeige aus web/index.html entfernen, sobald der erste Frame steht.
  WidgetsBinding.instance.addPostFrameCallback((_) => removeHtmlLoader());
}
