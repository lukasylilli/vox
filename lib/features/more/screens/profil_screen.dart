// FILE: lib/features/more/screens/profil_screen.dart
// PHASE: فاز P / P.1–P.3 (2026-09-20)
// ROUTE: /more/profil  (AppRoutes.profil) — erreichbar über Mehr → «پروفایل و حساب»
//        und über Einstellungen → Konto.
// PURPOSE: EINE Seite für alles, was dem Nutzer gehört:
//          Kopf (Name/E-Mail/Status) · Konto & Sicherheit · persönliche Angaben ·
//          Archive · Daten (Sicherung als Datei, Abgleich).
//
// ⚠️ Die Seite funktioniert **auch ohne Server**: Angaben, Archive und die
//    Sicherung als Datei sind lokal. Nur die Konto-Karten erscheinen erst, wenn
//    `kontoAktivProvider` wahr ist (Secrets gesetzt) — sonst gäbe es eine
//    Rubrik, die nie funktioniert.
// ⚠️ Kein „Konto löschen" — offene Entscheidung L.1d (siehe profil_konto_karte.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backup/nutzer_profil.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/auth_service.dart';
import '../controllers/profil_controller.dart';
import '../widgets/profil_angaben_karte.dart';
import '../widgets/profil_archiv_karte.dart';
import '../widgets/profil_konto_karte.dart';
import '../widgets/sicherung_karte.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kontoAktiv = ref.watch(kontoAktivProvider);
    final account = kontoAktiv ? ref.watch(authAccountProvider).valueOrNull : null;
    final profil = ref.watch(profilProvider).valueOrNull;
    final passwortNeu = ref.watch(passwortNeuProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'profile_title'))),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          _Kopf(profil: profil, account: account, kontoAktiv: kontoAktiv),
          const SizedBox(height: AppSizes.md),

          // Nach dem Link aus der Mail: ganz oben, damit es nicht übersehen wird.
          if (kontoAktiv && account != null && passwortNeu) ...[
            const PasswortAendernKarte(nachWiederherstellung: true),
            const SizedBox(height: AppSizes.md),
          ],

          // ── Konto & Sicherheit ──────────────────────────────────────
          if (kontoAktiv) ...[
            _Rubrik(AppL10n.t(context, 'section_account')),
            const ProfilKontoKarte(),
            if (account != null && !passwortNeu) ...[
              const SizedBox(height: AppSizes.sm),
              const PasswortAendernKarte(),
            ],
            const SizedBox(height: AppSizes.md),
          ],

          // ── Persönliche Angaben ─────────────────────────────────────
          _Rubrik(AppL10n.t(context, 'profile_section_details')),
          const ProfilAngabenKarte(),
          const SizedBox(height: AppSizes.md),

          // ── Archive ─────────────────────────────────────────────────
          _Rubrik(AppL10n.t(context, 'profile_section_archives')),
          const ProfilArchivKarte(),
          const SizedBox(height: AppSizes.md),

          // ── Daten: Sicherung als Datei ──────────────────────────────
          _Rubrik(AppL10n.t(context, 'section_storage')),
          const SicherungKarte(),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }
}

class _Rubrik extends StatelessWidget {
  const _Rubrik(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, right: 4),
        child: Text(text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
      );
}

/// Kopf: Avatar mit Anfangsbuchstabe, Name, E-Mail bzw. Status.
class _Kopf extends StatelessWidget {
  const _Kopf({
    required this.profil,
    required this.account,
    required this.kontoAktiv,
  });

  final NutzerProfil? profil;
  final AuthAccount? account;
  final bool kontoAktiv;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = (profil?.name ?? '').trim();
    final email = account?.email ?? '';
    final quelle = name.isNotEmpty ? name : email;
    // `runes` statt Index: ein Emoji als erstes Zeichen darf nicht in der
    // Mitte eines Surrogatpaars zerschnitten werden.
    final anfang =
        quelle.isEmpty ? '' : String.fromCharCode(quelle.runes.first).toUpperCase();

    final status = account != null
        ? email
        : kontoAktiv
            ? AppL10n.t(context, 'profile_not_signed_in')
            : AppL10n.t(context, 'profile_local_only');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
            child: anfang.isEmpty
                ? const Icon(Icons.person_outline)
                : Text(anfang,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty
                      ? name
                      : AppL10n.t(context, 'profile_no_name'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(status,
                    textDirection:
                        account != null ? TextDirection.ltr : null,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
