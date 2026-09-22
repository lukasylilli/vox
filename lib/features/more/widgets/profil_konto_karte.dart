// FILE: lib/features/more/widgets/profil_konto_karte.dart
// PHASE: فاز P / P.2 (2026-09-20)
// PURPOSE: Konto auf der Profil-Seite:
//          · [ProfilKontoKarte]     anmelden · registrieren · Passwort vergessen ·
//                                    (angemeldet) E-Mail ändern · Abgleich · abmelden
//          · [PasswortAendernKarte] neues Passwort setzen (auch nach dem Link aus der Mail)
//
// Ging aus `_KontoKarte` in `settings_screen.dart` (S.3 Schritt 2) hervor; die
// Anmelde- und Abgleich-Teile sind unverändert übernommen.
//
// ⚠️ **Zwei Apps, EIN Anmeldebestand.** E-Mail und Passwort gehören zu
//    `auth.users`, das mit Root-in geteilt ist: Eine Änderung hier gilt dort
//    mit. Beide Karten sagen das ausdrücklich (`account_shared_hint`).
// ⚠️ **„Konto löschen" (L.1d, 2026-09-22)** löscht `auth.users` und damit das
//    Konto in BEIDEN Apps (VOX- und Root-in-Sicherung per cascade). Lukas hat
//    das für beide Apps entschieden; der Bestätigungsdialog sagt es wörtlich
//    (`account_delete_body`). Der Bestand auf dem Gerät bleibt unberührt.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backup/cloud_abgleich.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/cloud_ablage_supabase.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/konto_abgleich.dart';
import '../controllers/profil_controller.dart';
import 'konto_texte.dart';

void _melde(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

// ─────────────────────────────────────────────────────────────────────────
// Konto
// ─────────────────────────────────────────────────────────────────────────

class ProfilKontoKarte extends ConsumerStatefulWidget {
  const ProfilKontoKarte({super.key});

  @override
  ConsumerState<ProfilKontoKarte> createState() => _ProfilKontoKarteState();
}

class _ProfilKontoKarteState extends ConsumerState<ProfilKontoKarte> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _neueEmailController = TextEditingController();

  bool _istRegistrierung = false;
  bool _laeuft = false;
  bool _passwortSichtbar = false;
  bool _emailFeldOffen = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _neueEmailController.dispose();
    super.dispose();
  }

  void _zeige(String text) {
    if (!mounted) return;
    _melde(context, text);
  }

  /// Texte werden VOR dem await aufgelöst (`use_build_context_synchronously`)
  /// — dieselbe Regel wie überall in dieser Datei.
  Future<void> _absenden() async {
    if (_laeuft) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    final bestaetigungGesendet =
        AppL10n.t(context, 'account_confirm_email_sent');
    final istRegistrierung = _istRegistrierung;

    setState(() => _laeuft = true);
    try {
      final service = ref.read(authServiceProvider);
      final result = istRegistrierung
          ? await service.signUp(email: email, password: password)
          : await service.signIn(email: email, password: password);

      if (!mounted) return;

      if (result.isSuccess) {
        _passwordController.clear();
        // Registrierung mit eingeschalteter E-Mail-Bestätigung: Konto ohne
        // Sitzung (siehe signUp in auth_service.dart) — dann muss der Hinweis
        // auf die Bestätigungsmail sichtbar sein.
        if (istRegistrierung &&
            ref.read(authServiceProvider).currentAccount == null) {
          _zeige(bestaetigungGesendet);
        }
      } else {
        _zeige(kontoFehlerText(context, result.issue!));
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _passwortVergessen() async {
    if (_laeuft) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _zeige(AppL10n.t(context, 'account_reset_need_email'));
      return;
    }
    final gesendet = AppL10n.t(context, 'account_reset_sent');
    setState(() => _laeuft = true);
    try {
      final issue = await ref.read(authServiceProvider).sendPasswordReset(email);
      if (!mounted) return;
      _zeige(issue == null ? gesendet : kontoFehlerText(context, issue));
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _emailAendern() async {
    if (_laeuft) return;
    final neu = _neueEmailController.text.trim();
    if (neu.isEmpty) return;
    final gesendet = AppL10n.t(context, 'account_email_change_sent');
    setState(() => _laeuft = true);
    try {
      final result = await ref.read(authServiceProvider).changeEmail(neu);
      if (!mounted) return;
      if (result.isSuccess) {
        _neueEmailController.clear();
        setState(() => _emailFeldOffen = false);
        _zeige(gesendet);
      } else {
        _zeige(kontoFehlerText(context, result.issue!));
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _abmelden({required bool ueberall}) async {
    if (_laeuft) return;
    final abgemeldet = AppL10n.t(
        context, ueberall ? 'account_signed_out_all' : 'account_signed_out');
    setState(() => _laeuft = true);
    try {
      final service = ref.read(authServiceProvider);
      if (ueberall) {
        await service.signOutEverywhere();
      } else {
        await service.signOut();
      }
    } finally {
      if (mounted) {
        setState(() => _laeuft = false);
        _melde(context, abgemeldet);
      }
    }
  }

  /// „Konto löschen" (L.1d): so vollständig, wie der Server es gerade
  /// zulässt — und danach genau das sagen, was geschehen ist (wie Root-in).
  Future<void> _kontoLoeschen() async {
    if (_laeuft) return;
    final bestaetigt = await VoxDialog.confirm(
      context,
      title: AppL10n.t(context, 'account_delete_title'),
      message: AppL10n.t(context, 'account_delete_body'),
      confirmLabel: 'account_delete_confirm',
      cancelLabel: 'cancel',
    );
    if (!mounted) return;
    if (!bestaetigt) return;

    // ⚠️ Alles, was nach dem Löschen noch gebraucht wird, JETZT greifen: Mit
    // dem Abmelden baut die Karte auf „abgemeldet" um; die Rückmeldung darf
    // daran nicht hängen.
    final messenger = ScaffoldMessenger.of(context);
    final auth = ref.read(authServiceProvider);
    final ablage = ref.read(cloudAblageProvider);
    final geloescht = AppL10n.t(context, 'account_delete_done');
    final teilweise = AppL10n.t(context, 'account_delete_partial');
    final fehlgeschlagen = AppL10n.t(context, 'account_delete_failed');

    setState(() => _laeuft = true);
    var meldung = fehlgeschlagen;
    try {
      switch (await auth.deleteAccount()) {
        case AccountDeletion.deleted:
          meldung = geloescht;
        case AccountDeletion.unavailable:
          // Die Funktion fehlt auf dem Server. Dann das, was der öffentliche
          // Schlüssel darf — die eigene VOX-Sicherung — und ehrlich sagen,
          // was fehlt. ⚠️ ABMELDEN gehört dazu: Sonst lädt der automatische
          // Abgleich beim nächsten Takt alles wieder hoch.
          try {
            await ablage.loeschen();
            await auth.signOut();
            meldung = teilweise;
          } catch (_) {
            // Nichts gelöscht, weiter angemeldet — die Meldung sagt es.
          }
        case AccountDeletion.failed:
          break;
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(meldung)));
  }

  /// Von Hand abgleichen (S.3 Schritt 3). Der automatische Abgleich bleibt
  /// stumm — nur hier gibt es eine Rückmeldung.
  Future<void> _jetztAbgleichen() async {
    final texte = {
      CloudStatus.ok: AppL10n.t(context, 'account_sync_ok'),
      CloudStatus.fehlgeschlagen: AppL10n.t(context, 'account_sync_failed'),
      CloudStatus.zuNeu: AppL10n.t(context, 'account_sync_too_new'),
      CloudStatus.nichtVerfuegbar:
          AppL10n.t(context, 'auth_issue_not_configured'),
    };
    final status = await ref.read(kontoAbgleichProvider.notifier).abgleichen();
    _zeige(texte[status]!);
  }

  String _zeitText(BuildContext context, DateTime zeit) {
    final l = MaterialLocalizations.of(context);
    final lokal = zeit.toLocal();
    return '${l.formatShortDate(lokal)} · '
        '${l.formatTimeOfDay(TimeOfDay.fromDateTime(lokal))}';
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(authAccountProvider).valueOrNull;
    final abgleich = ref.watch(kontoAbgleichProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: account != null
            ? _angemeldeteAnsicht(context, account, abgleich)
            : _anmeldeFormular(context),
      ),
    );
  }

  Widget _angemeldeteAnsicht(BuildContext context, AuthAccount account,
          KontoAbgleichStand abgleich) =>
      Column(
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
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: AppSizes.sm),
          Text(AppL10n.t(context, 'account_shared_hint'),
              style: Theme.of(context).textTheme.bodySmall),

          // ── E-Mail ändern ──
          const SizedBox(height: AppSizes.sm),
          if (_emailFeldOffen) ...[
            TextField(
              controller: _neueEmailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: AppL10n.t(context, 'account_email_new_label'),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _emailAendern(),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: [
              VoxButton.primary(
                label: AppL10n.t(context, 'account_email_change'),
                icon: Icons.mark_email_read_outlined,
                loading: _laeuft,
                onPressed: _emailAendern,
              ),
              VoxButton.text(
                label: AppL10n.t(context, 'cancel'),
                onPressed: () => setState(() => _emailFeldOffen = false),
              ),
            ]),
          ] else
            VoxButton.text(
              label: AppL10n.t(context, 'account_email_change'),
              icon: Icons.alternate_email,
              onPressed: () => setState(() => _emailFeldOffen = true),
            ),

          // ── Abgleich ──
          const SizedBox(height: AppSizes.md),
          Text(AppL10n.t(context, 'account_sync_hint'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.sm),
          Text(abgleich.zuletzt == null
              ? AppL10n.t(context, 'account_sync_never')
              : '${AppL10n.t(context, 'account_sync_last')}: '
                  '${_zeitText(context, abgleich.zuletzt!)}'),
          const SizedBox(height: AppSizes.sm),
          VoxButton.tonal(
            label: AppL10n.t(context, 'account_sync_now'),
            icon: Icons.sync,
            loading: abgleich.laeuft,
            onPressed: _jetztAbgleichen,
          ),

          // ── Abmelden ──
          const SizedBox(height: AppSizes.md),
          if (_laeuft)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: [
              VoxButton.secondary(
                label: AppL10n.t(context, 'account_sign_out'),
                icon: Icons.logout_outlined,
                onPressed: () => _abmelden(ueberall: false),
              ),
              VoxButton.text(
                label: AppL10n.t(context, 'account_sign_out_all'),
                icon: Icons.devices_outlined,
                onPressed: () => _abmelden(ueberall: true),
              ),
            ]),

          // ── Konto löschen (L.1d) ──
          const SizedBox(height: AppSizes.md),
          const Divider(),
          const SizedBox(height: AppSizes.sm),
          Text(AppL10n.t(context, 'account_delete_hint'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.sm),
          VoxButton.destructiveOutlined(
            key: const ValueKey('konto_loeschen'),
            label: AppL10n.t(context, 'account_delete'),
            icon: Icons.delete_forever_outlined,
            onPressed: _laeuft ? null : _kontoLoeschen,
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
          const SizedBox(height: AppSizes.sm),
          Text(AppL10n.t(context, 'account_sync_hint'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: AppL10n.t(context, 'account_email_label'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _passwordController,
            obscureText: !_passwortSichtbar,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: AppL10n.t(context, 'account_password_label'),
              border: const OutlineInputBorder(),
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
              label: AppL10n.t(context,
                  _istRegistrierung ? 'account_sign_up' : 'account_sign_in'),
              icon: Icons.login_outlined,
              onPressed: _absenden,
            ),
          const SizedBox(height: AppSizes.sm),
          VoxButton.text(
            label: AppL10n.t(
                context,
                _istRegistrierung
                    ? 'account_switch_to_signin'
                    : 'account_switch_to_signup'),
            onPressed: () =>
                setState(() => _istRegistrierung = !_istRegistrierung),
          ),
          if (!_istRegistrierung)
            VoxButton.text(
              label: AppL10n.t(context, 'account_forgot_password'),
              icon: Icons.lock_reset_outlined,
              onPressed: _passwortVergessen,
            ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────
// Passwort ändern
// ─────────────────────────────────────────────────────────────────────────

/// Mindestlänge auf der Oberfläche. Der Server hat seine eigene Regel
/// (`AuthIssue.weakPassword`); diese hier ist bewusst strenger, damit
/// niemand ein 6-stelliges Passwort wählt, das der Server gerade noch
/// durchließe.
const int passwortMindestLaenge = 8;

/// Reine Funktion, damit die Regel ohne Oberfläche prüfbar bleibt
/// (`test/profil_test.dart`). `null` = in Ordnung, sonst der L10n-Schlüssel.
String? passwortFehlerSchluessel(String neu, String wiederholt) {
  if (neu.length < passwortMindestLaenge) return 'account_password_short';
  if (neu != wiederholt) return 'account_password_mismatch';
  return null;
}

class PasswortAendernKarte extends ConsumerStatefulWidget {
  const PasswortAendernKarte({super.key, this.nachWiederherstellung = false});

  /// Wahr, wenn der Nutzer über den Link aus der Mail hier ist: ganz oben,
  /// mit einem erklärenden Satz statt der Überschrift.
  final bool nachWiederherstellung;

  @override
  ConsumerState<PasswortAendernKarte> createState() =>
      _PasswortAendernKarteState();
}

class _PasswortAendernKarteState extends ConsumerState<PasswortAendernKarte> {
  final _neuController = TextEditingController();
  final _wiederholtController = TextEditingController();
  bool _sichtbar = false;
  bool _laeuft = false;

  @override
  void dispose() {
    _neuController.dispose();
    _wiederholtController.dispose();
    super.dispose();
  }

  Future<void> _speichern() async {
    if (_laeuft) return;
    final lokal = passwortFehlerSchluessel(
        _neuController.text, _wiederholtController.text);
    if (lokal != null) {
      _melde(context, AppL10n.t(context, lokal));
      return;
    }
    final geaendert = AppL10n.t(context, 'account_password_changed');
    setState(() => _laeuft = true);
    try {
      final result = await ref
          .read(authServiceProvider)
          .changePassword(_neuController.text);
      if (!mounted) return;
      if (result.isSuccess) {
        _neuController.clear();
        _wiederholtController.clear();
        ref.read(passwortNeuProvider.notifier).state = false;
        _melde(context, geaendert);
      } else {
        _melde(context, kontoFehlerText(context, result.issue!));
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sichtbarkeit = VoxIconButton(
      icon: _sichtbar
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      onPressed: () => setState(() => _sichtbar = !_sichtbar),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(AppL10n.t(context, 'account_password_section'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: AppSizes.sm),
            if (widget.nachWiederherstellung) ...[
              Text(AppL10n.t(context, 'account_password_recovery_banner'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSizes.sm),
            ],
            Text(AppL10n.t(context, 'account_shared_hint'),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _neuController,
              obscureText: !_sichtbar,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: AppL10n.t(context, 'account_password_new_label'),
                border: const OutlineInputBorder(),
                suffixIcon: sichtbarkeit,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _wiederholtController,
              obscureText: !_sichtbar,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: AppL10n.t(context, 'account_password_repeat_label'),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _speichern(),
            ),
            const SizedBox(height: AppSizes.md),
            VoxButton.primary(
              label: AppL10n.t(context, 'account_password_change'),
              icon: Icons.lock_reset_outlined,
              loading: _laeuft,
              onPressed: _speichern,
            ),
          ],
        ),
      ),
    );
  }
}
