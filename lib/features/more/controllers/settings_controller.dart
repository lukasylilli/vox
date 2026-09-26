// FILE: lib/features/more/controllers/settings_controller.dart
// DEPS: shared_preferences, flutter_riverpod
// PURPOSE: App-Einstellungen — Dark Mode, TTS-Sprache, Lernlevel, Tagesziel, UI-Sprache
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/geraete_sprache.dart';

// ── Keys ─────────────────────────────────────────────────────────────────────
abstract class _K {
  static const themeMode        = 'theme_mode';      // 0=system,1=light,2=dark
  static const ttsRate          = 'tts_rate';        // double 0.1–1.0
  static const ttsLanguage      = 'tts_language';    // 'de-DE' | 'de-AT' | 'de-CH'
  static const currentLevel     = 'current_level';   // 'a1'..'c2'
  static const dailyGoalMin     = 'daily_goal_min';  // int minutes per day
  static const uiLanguage       = 'ui_language';     // 'fa' | 'en' — fehlt = Gerätesprache
}

// ── Model ─────────────────────────────────────────────────────────────────────
class AppSettings {
  const AppSettings({
    this.themeMode       = ThemeMode.system,
    this.ttsRate         = 0.5,
    this.ttsLanguage     = 'de-DE',
    this.currentLevel    = 'a1',
    this.dailyGoalMinutes = 15,
    this.uiLanguage      = GeraeteSprache.rueckfall,
  });

  final ThemeMode themeMode;
  final double    ttsRate;
  final String    ttsLanguage;
  final String    currentLevel;
  final int       dailyGoalMinutes;
  final String    uiLanguage;  // 'fa' | 'en'

  AppSettings copyWith({
    ThemeMode? themeMode,
    double?    ttsRate,
    String?    ttsLanguage,
    String?    currentLevel,
    int?       dailyGoalMinutes,
    String?    uiLanguage,
  }) =>
      AppSettings(
        themeMode           : themeMode            ?? this.themeMode,
        ttsRate             : ttsRate              ?? this.ttsRate,
        ttsLanguage         : ttsLanguage          ?? this.ttsLanguage,
        currentLevel        : currentLevel         ?? this.currentLevel,
        dailyGoalMinutes    : dailyGoalMinutes      ?? this.dailyGoalMinutes,
        uiLanguage          : uiLanguage           ?? this.uiLanguage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  AppSettings _load() => AppSettings(
        themeMode           : _gespeichertesFarbschema(),
        ttsRate             : _prefs.getDouble(_K.ttsRate) ?? 0.5,
        ttsLanguage         : _prefs.getString(_K.ttsLanguage) ?? 'de-DE',
        currentLevel        : _prefs.getString(_K.currentLevel) ?? 'a1',
        dailyGoalMinutes    : _prefs.getInt(_K.dailyGoalMin) ?? 15,
        // L.3: ohne eigene Wahl folgt die Oberfläche dem Gerät
        // (Englisch, außer das Gerät spricht Persisch) — siehe geraete_sprache.dart.
        uiLanguage          : _gespeicherteSprache() ?? GeraeteSprache.aktuell,
      );

  /// Nur eine gültige Zahl (0–2) zählt als gespeichertes Farbschema; alles
  /// andere ⇒ System. Warum (2026-09-26): Root-in liegt auf derselben
  /// Herkunft `lukasylilli.github.io` und schrieb bis Root-in PLAN 31.8 in
  /// denselben Browser-Speicher denselben Schlüssel `theme_mode` — als
  /// **Text** (`"dark"`). `getInt` warf darauf einen TypeError. Root-in hat
  /// jetzt die eigene Vorsilbe `root_in.`; diese Prüfung fängt Altbestände ab.
  ThemeMode _gespeichertesFarbschema() {
    final wert = _prefs.get(_K.themeMode);
    return (wert is int && wert >= 0 && wert < ThemeMode.values.length)
        ? ThemeMode.values[wert]
        : ThemeMode.system;
  }

  /// Nur 'fa' oder 'en' zählen als echte Wahl; alles andere wird ignoriert.
  String? _gespeicherteSprache() {
    final wert = _prefs.getString(_K.uiLanguage);
    return (wert == 'fa' || wert == 'en') ? wert : null;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_K.themeMode, mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setTtsRate(double rate) async {
    await _prefs.setDouble(_K.ttsRate, rate);
    state = AsyncData(state.value!.copyWith(ttsRate: rate));
  }

  Future<void> setTtsLanguage(String lang) async {
    await _prefs.setString(_K.ttsLanguage, lang);
    state = AsyncData(state.value!.copyWith(ttsLanguage: lang));
  }

  Future<void> setCurrentLevel(String level) async {
    await _prefs.setString(_K.currentLevel, level);
    state = AsyncData(state.value!.copyWith(currentLevel: level));
  }

  Future<void> setDailyGoal(int minutes) async {
    await _prefs.setInt(_K.dailyGoalMin, minutes);
    state = AsyncData(state.value!.copyWith(dailyGoalMinutes: minutes));
  }

  Future<void> setUiLanguage(String lang) async {
    await _prefs.setString(_K.uiLanguage, lang);
    state = AsyncData(state.value!.copyWith(uiLanguage: lang));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
