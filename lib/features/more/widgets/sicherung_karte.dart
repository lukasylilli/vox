// FILE: lib/features/more/widgets/sicherung_karte.dart
// PHASE: فاز S / S.2 + S.4, verschoben nach فاز P / P.3 (2026-09-20)
// PURPOSE: Karte «پشتیبان»: Sicherung als Datei schreiben und wieder
//          einlesen — mit dem ehrlichen Hinweis, wo die Daten liegen.
//
// Stand vorher `private` in `settings_screen.dart`. Seit P.3 gehört sie auf die
// Profil-Seite (`/more/profil`), wo Konto, Angaben und Daten zusammenliegen;
// als eigene Datei, damit es EINE Karte gibt und nicht zwei Kopien, die
// auseinanderlaufen. `datenOrtSchluessel` wandert mit (Test:
// `test/datenort_hinweis_test.dart`, erreichbar auch weiter über
// `settings_screen.dart`, das es weiter ausliefert).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backup/nutzer_zustand.dart';
import '../../../core/backup/user_state_repository.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/widgets/vox_button.dart';
import '../../vokabular/controllers/vokabular_user_state.dart';
import '../../wortschatz/controllers/word_controller.dart' show databaseProvider;
import '../controllers/profil_controller.dart';
import '../controllers/settings_controller.dart';

/// Welcher ehrliche Hinweis über den Ort der Daten erscheint (فاز S / S.4).
///
/// · Kein Server eingerichtet ⇒ `backup_only_here`: die Daten liegen nur in
///   diesem Browser, die Datei ist das einzige Netz.
/// · Server eingerichtet, aber niemand angemeldet ⇒ `backup_only_here_signin`.
/// · Angemeldet ⇒ `null` — die Konto-Karte sagt dann selbst, dass kopiert wird.
///
/// Reine Funktion, damit die Entscheidung ohne Browser und ohne Server
/// prüfbar bleibt (`test/datenort_hinweis_test.dart`).
String? datenOrtSchluessel({
  required bool kontoAktiv,
  required bool angemeldet,
}) {
  if (!kontoAktiv) return 'backup_only_here';
  if (!angemeldet) return 'backup_only_here_signin';
  return null;
}

/// Sicherung: Datei schreiben und wieder einlesen (فاز S / S.2).
///
/// Bewusst zwei schlichte Schaltflächen statt eines Assistenten — die Aufgabe
/// ist klein und soll auch dann verständlich sein, wenn jemand sie ein Jahr
/// später einmal braucht. Alle Rückmeldungen laufen über eine SnackBar; es
/// gibt nichts zu bestätigen, weil Einspielen nie etwas löscht.
class SicherungKarte extends ConsumerStatefulWidget {
  const SicherungKarte({super.key});

  @override
  ConsumerState<SicherungKarte> createState() => _SicherungKarteState();
}

class _SicherungKarteState extends ConsumerState<SicherungKarte> {
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

    // S.4 — ehrlich sagen, wo die Daten liegen. Der Konto-Zustand wird nur
    // beobachtet, wenn es überhaupt einen Server gibt.
    final kontoAktiv = ref.watch(kontoAktivProvider);
    final angemeldet =
        kontoAktiv && ref.watch(authAccountProvider).valueOrNull != null;
    final ortSchluessel = datenOrtSchluessel(
      kontoAktiv: kontoAktiv,
      angemeldet: angemeldet,
    );

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
            if (ortSchluessel != null) ...[
              const SizedBox(height: AppSizes.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(AppL10n.t(context, ortSchluessel),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ],
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
                      // Die Ablage wurde am Wort-Store vorbei geändert —
                      // sonst zeigt die Wortseite bis zum Neustart den
                      // alten Stand (B-11).
                      if (mounted) {
                        await ref
                            .read(vokabularUserProvider.notifier)
                            .neuLaden();
                        // Einstellungen, Profil und Archiv-Zahlen kamen
                        // ebenfalls aus der Datei (P.1).
                        ref.invalidate(settingsProvider);
                        ref.invalidate(profilProvider);
                        ref.invalidate(archivUebersichtProvider);
                      }
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
