// FILE: lib/core/services/cache_service.dart
// STATUS: [x] LIVE (B6 — 2026-07-04 · Web: 2026-09-13)
// PURPOSE: Central TTL cache for remote content (RSS news, future sync).
//          Offline-first: getStale() returns expired entries so the app
//          always has something to show without network.
//          Web: gespeichert über shared_preferences (= localStorage) statt Dateien.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _prefix = 'vox_cache:';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Fresh value or null (missing / older than [maxAge]).
  Future<String?> get(String key, {required Duration maxAge}) async {
    final entry = await _read(key);
    if (entry == null) return null;
    final age = DateTime.now().difference(entry.$1);
    return age <= maxAge ? entry.$2 : null;
  }

  /// Value regardless of age — offline fallback. Null only if never cached.
  Future<String?> getStale(String key) async => (await _read(key))?.$2;

  Future<void> put(String key, String value) async {
    final payload = jsonEncode({
      'updatedAt': DateTime.now().toIso8601String(),
      'value'    : value,
    });
    try {
      await (await _prefs).setString('$_prefix$key', payload);
    } catch (_) {
      // localStorage voll → ohne Cache weiter; der Inhalt ist trotzdem geladen.
    }
  }

  Future<void> evict(String key) async =>
      (await _prefs).remove('$_prefix$key');

  Future<void> clear() async {
    final prefs = await _prefs;
    final keys  = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  Future<(DateTime, String)?> _read(String key) async {
    try {
      final raw = (await _prefs).getString('$_prefix$key');
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        DateTime.parse(json['updatedAt'] as String),
        json['value'] as String,
      );
    } catch (_) {
      return null; // corrupt entry behaves like a miss
    }
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());
