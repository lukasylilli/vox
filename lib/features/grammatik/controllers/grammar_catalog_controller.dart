// FILE: lib/features/grammatik/controllers/grammar_catalog_controller.dart
// DEPS: grammar_catalog.dart, shared_preferences
// PURPOSE: Katalog laden (Asset) + Sortier-Ansicht des Nutzers persistieren.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grammar_catalog.dart';

// ── Katalog ───────────────────────────────────────────────────────────────────

final grammatikKatalogProvider = FutureProvider<GrammatikKatalog>((ref) async {
  final raw = await rootBundle.loadString('assets/data/grammatik_katalog.json');
  return GrammatikKatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

// ── Sortier-Ansicht (Niveau / Thema / Lektionen / Satzglieder) ───────────────

enum GrammatikSortMode { niveau, thema, lektionen, satzglieder }

const _sortModeKey = 'grammatik_sort_mode';

class GrammatikSortModeNotifier extends StateNotifier<GrammatikSortMode> {
  GrammatikSortModeNotifier() : super(GrammatikSortMode.niveau) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_sortModeKey);
    if (saved == null) return;
    state = GrammatikSortMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => GrammatikSortMode.niveau,
    );
  }

  Future<void> set(GrammatikSortMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortModeKey, mode.name);
  }
}

final grammatikSortModeProvider =
    StateNotifierProvider<GrammatikSortModeNotifier, GrammatikSortMode>(
        (_) => GrammatikSortModeNotifier());
