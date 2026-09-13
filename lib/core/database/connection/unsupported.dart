// FILE: lib/core/database/connection/unsupported.dart
// PURPOSE: Fallback außerhalb des Browsers. Der Fehler fällt erst bei der
//          ersten Abfrage (nicht beim Konstruieren), damit Widget-Tests ohne
//          DB-Zugriff weiterlaufen.
import 'package:drift/drift.dart';

QueryExecutor openConnection() => LazyDatabase(
      () async => throw UnsupportedError(
        'VOX ist eine Web-App — außerhalb des Browsers '
        'AppDatabase.forTesting(...) verwenden.',
      ),
    );
