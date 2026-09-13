// FILE: lib/core/database/connection/connection.dart
// PURPOSE: Weiche für die Standard-DB-Verbindung. VOX ist eine reine Web-App:
//          im Browser läuft SQLite als WebAssembly (web.dart). Auf der Dart-VM
//          (`flutter test`) gibt es keine Standard-Verbindung — Tests nutzen
//          AppDatabase.forTesting(NativeDatabase.memory()).
export 'unsupported.dart' if (dart.library.js_interop) 'web.dart';
