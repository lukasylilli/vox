// FILE: lib/core/services/app_logger.dart
// STATUS: [x] LIVE (B4 — 2026-07-04)
// PURPOSE: Central logging — one tagged logger instead of scattered
//          print()/debugPrint(). Debug builds log verbosely, release builds
//          keep only errors (hook point for crash reporting later).
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LogLevel { debug, info, warn, error }

class AppLogger {
  const AppLogger(this.tag);

  final String tag;

  void d(String msg) => _log(LogLevel.debug, msg);
  void i(String msg) => _log(LogLevel.info, msg);
  void w(String msg) => _log(LogLevel.warn, msg);

  void e(String msg, [Object? error, StackTrace? st]) {
    _log(LogLevel.error, error == null ? msg : '$msg — $error');
    if (st != null && kDebugMode) debugPrintStack(stackTrace: st);
  }

  void _log(LogLevel level, String msg) {
    // Release: only errors survive (later: forward to Sentry/Crashlytics here).
    if (!kDebugMode && level != LogLevel.error) return;
    debugPrint('[$tag] ${level.name}: $msg');
  }
}

/// Usage: `ref.watch(loggerProvider('RssService'))`
final loggerProvider = Provider.family<AppLogger, String>(
  (ref, tag) => AppLogger(tag),
);
