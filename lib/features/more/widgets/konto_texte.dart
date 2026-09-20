// FILE: lib/features/more/widgets/konto_texte.dart
// PHASE: فاز P / P.1 (2026-09-20)
// PURPOSE: Übersetzt sprachneutrale Fehler in anzeigbare Texte.
//
// ⚠️ Übersetzt wird **hier**, nicht in den Diensten: `auth_service.dart` und
//    `nutzer_profil.dart` kennen bewusst weder `BuildContext` noch eine
//    Sprache. Vorher stand `kontoFehlerText` (damals `_kontoFehlerText`) in
//    `settings_screen.dart`; die Profil-Seite braucht es ebenfalls.
import 'package:flutter/widgets.dart';

import '../../../core/backup/nutzer_profil.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/auth_service.dart';

String kontoFehlerText(BuildContext context, AuthIssue issue) =>
    switch (issue) {
      AuthIssue.notConfigured =>
        AppL10n.t(context, 'auth_issue_not_configured'),
      AuthIssue.emailTaken => AppL10n.t(context, 'auth_issue_email_taken'),
      AuthIssue.invalidCredentials =>
        AppL10n.t(context, 'auth_issue_invalid_credentials'),
      AuthIssue.weakPassword => AppL10n.t(context, 'auth_issue_weak_password'),
      AuthIssue.invalidEmail => AppL10n.t(context, 'auth_issue_invalid_email'),
      AuthIssue.signupDisabled =>
        AppL10n.t(context, 'auth_issue_signup_disabled'),
      AuthIssue.emailRateLimited =>
        AppL10n.t(context, 'auth_issue_email_rate_limited'),
      AuthIssue.offline => AppL10n.t(context, 'auth_issue_offline'),
      AuthIssue.samePassword =>
        AppL10n.t(context, 'auth_issue_same_password'),
      AuthIssue.reauthNeeded =>
        AppL10n.t(context, 'auth_issue_reauth_needed'),
      AuthIssue.unknown => AppL10n.t(context, 'auth_issue_unknown'),
    };

String profilFehlerText(BuildContext context, ProfilFehler fehler) =>
    switch (fehler) {
      ProfilFehler.nameZuLang =>
        AppL10n.tf(context, 'profile_err_name_long',
            {'n': '$profilMaxName'}),
      ProfilFehler.telefonUngueltig =>
        AppL10n.t(context, 'profile_err_phone'),
      ProfilFehler.feldZuLang =>
        AppL10n.tf(context, 'profile_err_field_long',
            {'n': '$profilMaxFeld'}),
      ProfilFehler.zuvieleAdressen =>
        AppL10n.tf(context, 'profile_err_too_many_addresses',
            {'n': '$profilMaxAdressen'}),
    };
