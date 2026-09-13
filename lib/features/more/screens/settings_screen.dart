// FILE: lib/features/more/screens/settings_screen.dart
// DEPS: settings_controller.dart
// PURPOSE: تنظیمات اپ — تم، سرعت TTS، سطح آلمانی، هدف روزانه
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _levels    = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
  static const _languages = ['de-DE', 'de-AT', 'de-CH'];
  static const _langLabels = ['german_de', 'german_at', 'german_ch'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);
    final notifier      = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'settings_title'))),
      body  : asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (s) => ListView(
          padding : const EdgeInsets.all(AppSizes.md),
          children: [

            // ── Language ───────────────────────────────────────
            _SectionHeader(AppL10n.t(context, 'section_language')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppL10n.t(context, 'ui_language_label'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'fa',
                          label: Text('فارسی'),
                          icon : Icon(Icons.language_rounded),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text('English'),
                          icon : Icon(Icons.language_rounded),
                        ),
                      ],
                      selected          : {s.uiLanguage},
                      onSelectionChanged: (set) =>
                          notifier.setUiLanguage(set.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Theme ──────────────────────────────────────────
            _SectionHeader(AppL10n.t(context, 'section_appearance')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppL10n.t(context, 'theme_mode_label'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(AppL10n.t(context, 'theme_system')),
                            icon : const Icon(Icons.brightness_auto_rounded)),
                        ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(AppL10n.t(context, 'theme_light')),
                            icon : const Icon(Icons.light_mode_rounded)),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(AppL10n.t(context, 'theme_dark')),
                            icon : const Icon(Icons.dark_mode_rounded)),
                      ],
                      selected       : {s.themeMode},
                      onSelectionChanged: (set) =>
                          notifier.setThemeMode(set.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── TTS ────────────────────────────────────────────
            _SectionHeader(AppL10n.t(context, 'section_voice')),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title   : Text(AppL10n.t(context, 'tts_speed')),
                    subtitle: Text('${(s.ttsRate * 100).round()}%'),
                    trailing: SizedBox(
                      width: 180,
                      child: Slider(
                        value   : s.ttsRate,
                        min     : 0.1,
                        max     : 1.0,
                        divisions: 9,
                        onChanged: notifier.setTtsRate,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title   : Text(AppL10n.t(context, 'german_accent')),
                    trailing: DropdownButton<String>(
                      value   : s.ttsLanguage,
                      underline: const SizedBox(),
                      items   : List.generate(_languages.length, (i) =>
                          DropdownMenuItem(
                            value: _languages[i],
                            child: Text(_langLabels[i],
                                style: const TextStyle(fontSize: 12)),
                          )),
                      onChanged: (v) => notifier.setTtsLanguage(v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Level ──────────────────────────────────────────
            _SectionHeader(AppL10n.t(context, 'section_level')),
            Card(
              child: ListTile(
                title   : Text(AppL10n.t(context, 'current_level')),
                subtitle: Text(s.currentLevel.toUpperCase()),
                trailing: DropdownButton<String>(
                  value   : s.currentLevel,
                  underline: const SizedBox(),
                  items   : _levels.map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.toUpperCase()),
                      )).toList(),
                  onChanged: (v) => notifier.setCurrentLevel(v!),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Daily goal ─────────────────────────────────────
            _SectionHeader(AppL10n.t(context, 'section_daily_goal')),
            Card(
              child: ListTile(
                title   : Text(AppL10n.t(context, 'daily_goal')),
                subtitle: Text('${s.dailyGoalMinutes} ${AppL10n.t(context, 'minutes')}'),
                trailing: SizedBox(
                  width: 180,
                  child: Slider(
                    value   : s.dailyGoalMinutes.toDouble(),
                    min     : 5,
                    max     : 60,
                    divisions: 11,
                    label   : '${s.dailyGoalMinutes} min',
                    onChanged: (v) =>
                        notifier.setDailyGoal(v.round()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, right: 4),
        child  : Text(text,
            style: TextStyle(
              fontSize  : 12,
              fontWeight: FontWeight.w700,
              color     : Theme.of(context).colorScheme.onSurfaceVariant,
            )),
      );
}
