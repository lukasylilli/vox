// FILE: lib/features/more/screens/settings_screen.dart
// DEPS: settings_controller.dart
// PURPOSE: تنظیمات اپ — تم، سرعت TTS، سطح آلمانی، هدف روزانه، ایمنی داده (فاز S)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/backup/nutzer_zustand.dart';
import '../../../core/backup/user_state_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/utils/install_state.dart';
import '../../../core/widgets/vox_button.dart';
import '../../wortschatz/controllers/word_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

            // ── Meine Daten (فاز S / S.1b) ─────────────────────
            const SizedBox(height: AppSizes.md),
            _SectionHeader(AppL10n.t(context, 'section_storage')),
            const _SpeicherKarte(),
            const SizedBox(height: AppSizes.sm),
            const _SicherungKarte(),

            // ── Konto (فاز S / S.3 Schritt 2) ───────────────────
            // Erscheint nur, wenn Supabase konfiguriert ist — sonst gibt es
            // keine Rubrik, statt eine, die nichts tut.
            if (ref.watch(kontoAktivProvider)) ...[
              const SizedBox(height: AppSizes.md),
              _SectionHeader(AppL10n.t(context, 'section_account')),
              const _KontoKarte(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Übersetzt einen [AuthIssue] in einen anzeigbaren Text.
///
/// ⚠️ Übersetzung passiert **hier**, nicht in `auth_service.dart` — der
/// Dienst kennt bewusst kein `BuildContext` und keine Sprache (siehe Kopf
/// der Datei dort).
String _kontoFehlerText(BuildContext context, AuthIssue issue) => switch (issue) {
      AuthIssue.notConfigured      => AppL10n.t(context, 'auth_issue_not_configured'),
      AuthIssue.emailTaken         => AppL10n.t(context, 'auth_issue_email_taken'),
      AuthIssue.invalidCredentials => AppL10n.t(context, 'auth_issue_invalid_credentials'),
      AuthIssue.weakPassword       => AppL10n.t(context, 'auth_issue_weak_password'),
      AuthIssue.invalidEmail       => AppL10n.t(context, 'auth_issue_invalid_email'),
      AuthIssue.signupDisabled     => AppL10n.t(context, 'auth_issue_signup_disabled'),
      AuthIssue.emailRateLimited   => AppL10n.t(context, 'auth_issue_email_rate_limited'),
      AuthIssue.offline            => AppL10n.t(context, 'auth_issue_offline'),
      AuthIssue.unknown            => AppL10n.t(context, 'auth_issue_unknown'),
    };

/// Konto: anmelden, registrieren, abmelden (فاز S / S.3 Schritt 2).
///
/// Zeigt sich nur, wenn `kontoAktivProvider` wahr ist (siehe
/// `settings_screen.dart` oben) — ohne Supabase-Konfiguration existiert diese
/// Rubrik einfach nicht, statt eine zu sein, die nie funktioniert.
///
/// ⚠️ Noch **keine** Cloud-Sicherung hier — das ist S.3 Schritt 3. Diese
/// Karte kümmert sich ausschließlich um Anmeldung; `vox_backups` wird an
/// anderer Stelle angebunden, mit derselben Nutzlast wie S.2.
class _KontoKarte extends ConsumerStatefulWidget {
  const _KontoKarte();

  @override
  ConsumerState<_KontoKarte> createState() => _KontoKarteState();
}

class _KontoKarteState extends ConsumerState<_KontoKarte> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _istRegistrierung = false;
  bool _laeuft           = false;
  bool _passwortSichtbar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _melde(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _absenden() async {
    if (_laeuft) return;
    final email    = _emailController.text;
    final password = _passwordController.text;

    // Texte VOR dem await auflösen — dieselbe Regel wie bei _SicherungKarte
    // (use_build_context_synchronously): der Bildschirm kann inzwischen weg
    // sein, `context` danach anzufassen wäre sowohl ein Analyse- als auch
    // ein Sachfehler.
    final bestaetigungGesendet = AppL10n.t(context, 'account_confirm_email_sent');
    final istRegistrierung     = _istRegistrierung;

    setState(() => _laeuft = true);
    try {
      final service = ref.read(authServiceProvider);
      final result = istRegistrierung
          ? await service.signUp(email: email, password: password)
          : await service.signIn(email: email, password: password);

      if (!mounted) return;

      if (result.isSuccess) {
        _passwordController.clear();
        // Bei Registrierung mit eingeschalteter E-Mail-Bestätigung kommt ein
        // Konto ohne Sitzung zurück (siehe Kopf von signUp in
        // auth_service.dart) — currentAccount bleibt dann null, und genau
        // das ist der Fall, in dem der Hinweis auf die Bestätigungsmail
        // sichtbar sein muss statt einer stillen Erfolgsmeldung ohne Wirkung.
        if (istRegistrierung && ref.read(authServiceProvider).currentAccount == null) {
          _melde(bestaetigungGesendet);
        }
      } else {
        _melde(_kontoFehlerText(context, result.issue!));
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _abmelden() async {
    if (_laeuft) return;
    final abgemeldet = AppL10n.t(context, 'account_signed_out');
    setState(() => _laeuft = true);
    try {
      await ref.read(authServiceProvider).signOut();
    } finally {
      if (mounted) {
        setState(() => _laeuft = false);
        _melde(abgemeldet);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(authAccountProvider).valueOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: account != null
            ? _angemeldeteAnsicht(context, account)
            : _anmeldeFormular(context),
      ),
    );
  }

  Widget _angemeldeteAnsicht(BuildContext context, AuthAccount account) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_circle_outlined),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'account_signed_in_as'),
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(account.email,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          if (_laeuft)
            const Center(child: CircularProgressIndicator())
          else
            VoxButton.secondary(
              label    : AppL10n.t(context, 'account_sign_out'),
              icon     : Icons.logout_outlined,
              onPressed: _abmelden,
            ),
        ],
      );

  Widget _anmeldeFormular(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_circle_outlined),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(AppL10n.t(context, 'account_title'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: AppL10n.t(context, 'account_email_label'),
              border   : const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _passwordController,
            obscureText: !_passwortSichtbar,
            decoration: InputDecoration(
              labelText: AppL10n.t(context, 'account_password_label'),
              border   : const OutlineInputBorder(),
              suffixIcon: VoxIconButton(
                icon: _passwortSichtbar
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onPressed: () =>
                    setState(() => _passwortSichtbar = !_passwortSichtbar),
              ),
            ),
            onSubmitted: (_) => _absenden(),
          ),
          const SizedBox(height: AppSizes.md),
          if (_laeuft)
            const Center(child: CircularProgressIndicator())
          else
            VoxButton.primary(
              label    : AppL10n.t(
                  context,
                  _istRegistrierung ? 'account_sign_up' : 'account_sign_in'),
              icon     : Icons.login_outlined,
              onPressed: _absenden,
            ),
          const SizedBox(height: AppSizes.sm),
          VoxButton.text(
            label    : AppL10n.t(
                context,
                _istRegistrierung
                    ? 'account_switch_to_signin'
                    : 'account_switch_to_signup'),
            onPressed: () =>
                setState(() => _istRegistrierung = !_istRegistrierung),
          ),
        ],
      );
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

/// Sicherung: Datei schreiben und wieder einlesen (فاز S / S.2).
///
/// Bewusst zwei schlichte Schaltflächen statt eines Assistenten — die Aufgabe
/// ist klein und soll auch dann verständlich sein, wenn jemand sie ein Jahr
/// später einmal braucht. Alle Rückmeldungen laufen über eine SnackBar; es
/// gibt nichts zu bestätigen, weil Einspielen nie etwas löscht.
class _SicherungKarte extends ConsumerStatefulWidget {
  const _SicherungKarte();

  @override
  ConsumerState<_SicherungKarte> createState() => _SicherungKarteState();
}

class _SicherungKarteState extends ConsumerState<_SicherungKarte> {
  bool _laeuft = false;

  Future<BackupService> _dienst() async {
    final db = ref.read(databaseProvider);
    final prefs = await SharedPreferences.getInstance();
    return BackupService(UserStateRepository(db, prefs));
  }

  void _melde(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Texte werden VOR dem await aufgelöst. `context` nach einer
  /// Unterbrechung anzufassen ist ein Analyse-Fehler
  /// (use_build_context_synchronously) — und wäre auch sachlich falsch:
  /// der Bildschirm kann inzwischen weg sein.
  Future<void> _fuehreAus(Future<String> Function(BackupService) aktion) async {
    if (_laeuft) return;
    setState(() => _laeuft = true);
    try {
      _melde(await aktion(await _dienst()));
    } on SicherungFehler catch (e) {
      // Der Grund ist schon so formuliert, dass man ihn zeigen kann.
      _melde(e.grund);
    } catch (e) {
      _melde('$e');
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Alles, was eine Rückmeldung braucht, jetzt auflösen — siehe _fuehreAus.
    final gespeichert  = AppL10n.t(context, 'backup_saved');
    final zurueck      = AppL10n.t(context, 'backup_restored');
    final abgebrochen  = AppL10n.t(context, 'backup_cancelled');
    final imLeitner    = AppL10n.t(context, 'backup_words_leitner');
    final eigene       = AppL10n.t(context, 'backup_words_own');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.save_outlined),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(AppL10n.t(context, 'backup_title'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'backup_sub')),
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'backup_merge_hint'),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSizes.md),
            if (_laeuft)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  VoxButton.tonal(
                    label    : AppL10n.t(context, 'backup_export'),
                    icon     : Icons.download_outlined,
                    onPressed: () => _fuehreAus((d) async =>
                        '$gespeichert: ${await d.exportieren()}'),
                  ),
                  VoxButton.secondary(
                    label    : AppL10n.t(context, 'backup_import'),
                    icon     : Icons.upload_outlined,
                    onPressed: () => _fuehreAus((d) async {
                      final e = await d.einspielen();
                      if (e.abgebrochen) return abgebrochen;
                      return '$zurueck: ${e.leitnerWoerter} $imLeitner, '
                          '${e.eigeneWoerter} $eigene';
                    }),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
