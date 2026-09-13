// FILE: lib/core/database/connection/web.dart
// PURPOSE: SQLite als WebAssembly im Browser. Drift wählt automatisch die beste
//          verfügbare Speicherung (OPFS, sonst IndexedDB) — GitHub Pages setzt
//          keine COOP/COEP-Header, daher meist IndexedDB.
// ⚠️ web/sqlite3.wasm und web/drift_worker.js müssen zu den sqlite3- bzw.
//    drift-Versionen in pubspec.lock passen.
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName  : 'vox',
      sqlite3Uri    : Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    if (result.missingFeatures.isNotEmpty) {
      debugPrint('Drift: ${result.chosenImplementation} '
          '(fehlende Browser-Features: ${result.missingFeatures})');
    }
    return result.resolvedExecutor;
  }));
}
