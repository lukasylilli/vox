// FILE: lib/features/more/controllers/settings_controller.dart
// DEPS: shared_preferences, flutter_riverpod
// PURPOSE: App-Einstellungen — Dark Mode, TTS-Sprache, Lernlevel, Tagesziel, UI-Sprache
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ─────────────────────────────────────────────────────────────────────
abstract class _K {
  static const themeMode        = 'theme_mode';      // 0=system,1=light,2=dark
  static const ttsRate          = 'tts_rate';        // double 0.1–1.0
  static const ttsLanguage      = 'tts_language';    // 'de-DE' | 'de-AT' | 'de-CH'
  static const currentLevel     = 'current_level';   // 'a1'..'c2'
  static const dailyGoalMin     = 'daily_goal_min';  // int minutes per day
  static const uiLanguage       = 'ui_language';     // 'fa' | 'en'
}

// ── Model ─────────────────────────────────────────────────────────────────────
class AppSettings {
  const AppSettings({
    this.themeMode       = ThemeMode.system,
    this.ttsRate         = 0.5,
    this.ttsLanguage     = 'de-DE',
    this.currentLevel    = 'a1',
    this.dailyGoalMinutes = 15,
    this.uiLanguage      = 'fa',
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
        themeMode           : ThemeMode.values[_prefs.getInt(_K.themeMode) ?? 0],
        ttsRate             : _prefs.getDouble(_K.ttsRate) ?? 0.5,
        ttsLanguage         : _prefs.getString(_K.ttsLanguage) ?? 'de-DE',
        currentLevel        : _prefs.getString(_K.currentLevel) ?? 'a1',
        dailyGoalMinutes    : _prefs.getInt(_K.dailyGoalMin) ?? 15,
        uiLanguage          : _prefs.getString(_K.uiLanguage) ?? 'fa',
      );

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
