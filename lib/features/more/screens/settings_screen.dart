// FILE: lib/features/more/screens/settings_screen.dart
// DEPS: settings_controller.dart
// PURPOSE: تنظیمات اپ — تم، سرعت TTS، سطح آلمانی، هدف روزانه؛ حساب و داده → صفحه‌ی پروفایل (فاز P / P.3)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/install_state.dart';
import '../controllers/settings_controller.dart';

// `datenOrtSchluessel` steht seit P.3 in `widgets/sicherung_karte.dart`;
// `test/datenort_hinweis_test.dart` importiert es weiter von hier.
export '../widgets/sicherung_karte.dart' show datenOrtSchluessel;

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

            // ── Konto, Angaben, Daten → eigene Seite (فاز P / P.3) ──────
            // Sichtbar immer: auch ohne Server gibt es dort Angaben, Archive
            // und die Sicherung als Datei. Nur die Anmelde-Teile erscheinen
            // dort erst, wenn ein Server eingerichtet ist.
            const SizedBox(height: AppSizes.md),
            _SectionHeader(AppL10n.t(context, 'section_account')),
            const _ProfilKachel(),

            // ── Speicher (فاز S / S.1b) ─────────────────────────────────
            const SizedBox(height: AppSizes.md),
            _SectionHeader(AppL10n.t(context, 'section_storage')),
            const _SpeicherKarte(),
          ],
        ),
      ),
    );
  }
}

/// Eintrittskachel zur Profil-Seite (فاز P / P.3). Zeigt, wer angemeldet ist —
/// sonst, was die Seite kann.
class _ProfilKachel extends ConsumerWidget {
  const _ProfilKachel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final konto = ref.watch(kontoAktivProvider)
        ? ref.watch(authAccountProvider).valueOrNull
        : null;
    return Card(
      child: ListTile(
        leading : const Icon(Icons.account_circle_outlined),
        title   : Text(AppL10n.t(context, 'profile_title'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(konto != null
            ? konto.email
            : AppL10n.t(context, 'profile_tile_sub')),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap   : () => context.push(AppRoutes.profil),
      ),
    );
  }
}

/// Zeigt, ob VOX als Web-App auf der Startseite läuft — und wenn nicht, wie
/// man sie hinzufügt. Kein Komfort-Hinweis: installierte Web-Apps sind von
/// Safaris Sieben-Tage-Aufräumen ausgenommen (PLAN.md → فاز S).
class _SpeicherKarte extends StatelessWidget {
  const _SpeicherKarte();

  @override
  Widget build(BuildContext context) {
    final hinweis = erkenneInstallHinweis();
    if (hinweis == InstallHinweis.installiert) {
      return Card(
        child: ListTile(
          leading : const Icon(Icons.verified_user_outlined),
          title   : Text(AppL10n.t(context, 'storage_ok_title')),
          subtitle: Text(AppL10n.t(context, 'storage_ok_sub')),
        ),
      );
    }
    final anleitung = switch (hinweis) {
      InstallHinweis.ios     => 'storage_how_ios',
      InstallHinweis.android => 'storage_how_android',
      _                      => 'storage_how_desktop',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.add_to_home_screen_outlined),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(AppL10n.t(context, 'storage_warn_title'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'storage_warn_sub')),
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, anleitung),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
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
