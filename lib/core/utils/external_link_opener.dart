// FILE: lib/core/utils/external_link_opener.dart
// PURPOSE: Öffnet eine externe URL in einem neuen Tab — nur im Browser möglich.
// Weiche (bedingter Export), analog Root-in core/services/file_pick/:
// Stub für die Dart-VM (`flutter test`), echte Implementierung im Web-Bau.
// package:web darf NICHT ungeschützt importiert werden — sonst bricht jeder
// Widget-Test, der den Router/die App aufbaut (Analyze bemerkt es nicht,
// `flutter test` schon).
export 'external_link_opener_io.dart'
    if (dart.library.js_interop) 'external_link_opener_web.dart';
