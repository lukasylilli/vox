// FILE: test/l10n_paritaet_test.dart
// PHASE: فاز S (2026-09-15)
// PURPOSE: Die App ist zweisprachig (FA/EN, umschaltbar in den Einstellungen).
//          Fehlt ein Schlüssel in einer Sprache, fällt AppL10n.t still auf EN
//          oder auf den Schlüsselnamen zurück — der Nutzer sieht dann rohen
//          Text wie "storage_ok_title". Dieser Test macht das sichtbar,
//          BEVOR es veröffentlicht wird.
//
// Aufbau der MaterialApp bewusst 1:1 wie in test/vokabular_test.dart —
// mit den Global*Localizations aus flutter_localizations. Die
// Default*Localizations kennen kein Farsi und lassen den Test scheitern.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/l10n/app_l10n.dart';

void main() {
  // Die Schlüssel aus فاز S. Wächst die Liste, wächst der Schutz.
  const schluessel = [
    // G7a — Grammatik-Übungen (2026-09-16)
    'uebung_start',
    'uebung_progress',
    'uebung_result',
    'uebung_repeat',
    'uebung_back',
    'uebung_reset',
    'uebung_type_hint',
    'uebung_match_hint',
    'uebung_order_hint',
    'uebung_wrong_answer',
    // G7b — Niveau-Test
    'niveautest_title',
    'niveautest_sub',
    'niveautest_start',
    'niveautest_new',
    'niveautest_passed',
    'niveautest_failed',
    // G7c — Übungen aus Beispielsätzen
    'bsp_bedeutung',
    'bsp_satzwahl',
    'bsp_richtigfalsch',
    'bsp_zuordnung',
    'bsp_satzbau',
    'bsp_true',
    'bsp_false',
    'bsp_means',
    'section_storage',
    'storage_ok_title',
    'storage_ok_sub',
    'storage_warn_title',
    'storage_warn_sub',
    'storage_how_ios',
    'storage_how_android',
    'storage_how_desktop',
    // S.2 — Sicherung (nachgetragen 2026-09-16; fehlten bisher im Schutz)
    'backup_title',
    'backup_sub',
    'backup_export',
    'backup_import',
    'backup_saved',
    'backup_restored',
    'backup_cancelled',
    'backup_merge_hint',
    'backup_words_leitner',
    'backup_words_own',
    // S.4 — ehrlicher Hinweis, wo die Daten liegen
    'backup_only_here',
    'backup_only_here_signin',
    // S.3 Schritt 2 — Konto (2026-09-15)
    'section_account',
    'account_title',
    'account_signed_in_as',
    'account_email_label',
    'account_password_label',
    'account_sign_in',
    'account_sign_up',
    'account_sign_out',
    'account_signed_out',
    'account_switch_to_signup',
    'account_switch_to_signin',
    'account_confirm_email_sent',
    // S.3 Schritt 3 — Abgleich (2026-09-15)
    'account_sync_hint',
    'account_sync_now',
    'account_sync_last',
    'account_sync_never',
    'account_sync_ok',
    'account_sync_failed',
    'account_sync_too_new',
    'auth_issue_not_configured',
    'auth_issue_email_taken',
    'auth_issue_invalid_credentials',
    'auth_issue_weak_password',
    'auth_issue_invalid_email',
    'auth_issue_signup_disabled',
    'auth_issue_email_rate_limited',
    'auth_issue_offline',
    'auth_issue_unknown',
    // P — Profil, Konto, Archive (2026-09-20)
    'auth_issue_same_password',
    'auth_issue_reauth_needed',
    'account_forgot_password',
    'account_reset_need_email',
    'account_reset_sent',
    'account_shared_hint',
    'account_email_change',
    'account_email_new_label',
    'account_email_change_sent',
    'account_sign_out_all',
    'account_signed_out_all',
    'account_password_section',
    'account_password_new_label',
    'account_password_repeat_label',
    'account_password_change',
    'account_password_changed',
    'account_password_short',
    'account_password_mismatch',
    'account_password_recovery_banner',
    'profile_title',
    'profile_tile_sub',
    'profile_local_only',
    'profile_not_signed_in',
    'profile_no_name',
    'profile_section_details',
    'profile_details_hint',
    'profile_name_label',
    'profile_phone_label',
    'profile_save',
    'profile_saved',
    'profile_addresses',
    'profile_address_add',
    'profile_address_edit',
    'profile_address_label',
    'profile_address_street',
    'profile_address_zip',
    'profile_address_city',
    'profile_address_country',
    'profile_address_none',
    'profile_address_delete_q',
    'profile_address_need_one',
    'profile_err_name_long',
    'profile_err_phone',
    'profile_err_field_long',
    'profile_err_too_many_addresses',
    'profile_section_archives',
    'profile_archive_empty',
    'profile_archive_leitner',
    'profile_archive_box',
    'profile_archive_lists',
    'profile_archive_notes',
    'profile_archive_words',
    'profile_open_leitner',
    'profile_open_lists',
    // L.1d — Konto löschen (2026-09-22)
    'account_delete',
    'account_delete_hint',
    'account_delete_title',
    'account_delete_body',
    'account_delete_confirm',
    'account_delete_done',
    'account_delete_partial',
    'account_delete_failed',
  ];

  // t() braucht einen BuildContext, die Textmap selbst ist privat — deshalb
  // über einen echten Widget-Baum lesen.
  Future<String> hole(WidgetTester tester, String sprache, String key) async {
    late String ergebnis;
    await tester.pumpWidget(MaterialApp(
      locale: Locale(sprache),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        ergebnis = AppL10n.t(context, key);
        return const SizedBox.shrink();
      }),
    ));
    return ergebnis;
  }

  testWidgets('Speicher-Texte gibt es in beiden Sprachen', (tester) async {
    for (final k in schluessel) {
      for (final sprache in ['fa', 'en']) {
        final wert = await hole(tester, sprache, k);
        expect(wert, isNot(k),
            reason: 'Schlüssel "$k" fehlt in "$sprache" — '
                'AppL10n.t fällt auf den Schlüsselnamen zurück.');
        expect(wert.trim(), isNotEmpty, reason: '"$k" ($sprache) ist leer.');
      }
    }
  });

  testWidgets('FA und EN sind wirklich verschiedene Texte', (tester) async {
    for (final k in schluessel) {
      final fa = await hole(tester, 'fa', k);
      final en = await hole(tester, 'en', k);
      expect(fa, isNot(en),
          reason: 'Für "$k" liefern FA und EN denselben Text — '
              'vermutlich fehlt der FA-Eintrag und EN ist der Fallback.');
    }
  });
}
