// FILE: lib/core/services/cloud_ablage_supabase.dart
// PHASE: فاز S, S.3 Schritt 3 (2026-09-15)
// PURPOSE: Die echte [CloudAblage]: Tabelle `vox_backups` in Supabase
//          (siehe supabase/vox_tables.sql — eine Zeile je Konto).
//
// ⚠️ Neben `auth_service.dart` die ZWEITE und letzte Datei, die
//    `supabase_flutter` kennt. Der Ablauf selbst (holen → zusammenführen →
//    hochladen) liegt paketfrei in `core/backup/cloud_abgleich.dart`.
//
// Abfrageform übernommen aus Root-in
// (github.com/lukasylilli/Root-in, lib/core/services/cloud_backup_service.dart):
// `select(...).eq('user_id', …).maybeSingle()` und `upsert({...})`.
// ⚠️ `updated_at` wird nie mitgeschickt — den setzt der Server (Trigger).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backup/cloud_abgleich.dart';
import '../constants/app_config.dart';
import 'auth_service.dart';

class SupabaseCloudAblage implements CloudAblage {
  const SupabaseCloudAblage(this._auth);

  final AuthService _auth;

  /// ⚠️ NICHT `backups` — die Tabelle gehört Root-in (vox_tables.sql).
  static const String _tabelle = 'vox_backups';

  SupabaseClient? get _client {
    if (!AppConfig.hasSupabaseConfig) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  bool get verfuegbar => _client != null && _auth.currentAccount != null;

  @override
  Future<CloudStand?> holen() async {
    final client = _client!;
    final konto = _auth.currentAccount!;
    final row = await client
        .from(_tabelle)
        .select('payload, schema_version, updated_at')
        .eq('user_id', konto.id)
        .maybeSingle();
    if (row == null) return null;

    final payload = row['payload'];
    final version = row['schema_version'];
    if (payload is! Map || version is! num) {
      throw const FormatException('vox_backups: unlesbare Zeile');
    }
    return CloudStand(
      payload: Map<String, dynamic>.from(payload),
      version: version.toInt(),
      aktualisiertAm: DateTime.tryParse('${row['updated_at']}'),
    );
  }

  @override
  Future<void> ablegen(Map<String, dynamic> payload, int version) async {
    final client = _client!;
    final konto = _auth.currentAccount!;
    await client.from(_tabelle).upsert({
      'user_id': konto.id,
      'payload': payload,
      'schema_version': version,
    });
  }

  /// Nur die EIGENE Zeile — die Regel `vox_backups_delete_own` in
  /// `supabase/vox_tables.sql` ließe ohnehin keine fremde zu (L.1d).
  @override
  Future<void> loeschen() async {
    final client = _client!;
    final konto = _auth.currentAccount!;
    await client.from(_tabelle).delete().eq('user_id', konto.id);
  }

  /// Nur der Zeitstempel — ohne die Sicherung herunterzuladen (wie Root-in).
  @override
  Future<DateTime?> zuletzt() async {
    final client = _client;
    final konto = _auth.currentAccount;
    if (client == null || konto == null) return null;
    final row = await client
        .from(_tabelle)
        .select('updated_at')
        .eq('user_id', konto.id)
        .maybeSingle();
    if (row == null) return null;
    return DateTime.tryParse('${row['updated_at']}');
  }
}

final cloudAblageProvider = Provider<CloudAblage>(
  (ref) => SupabaseCloudAblage(ref.watch(authServiceProvider)),
);
