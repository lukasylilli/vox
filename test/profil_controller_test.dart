// FILE: test/profil_controller_test.dart
// PHASE: فاز P / P.1 (2026-09-20)
// PURPOSE: Der Notifier hinter der Profil-Seite: speichert bereinigt, mit
//          Zeitpunkt, und lehnt Ungültiges ab, ohne etwas zu schreiben.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/nutzer_profil.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/features/more/controllers/profil_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> start([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(profilProvider.future);
    return c;
  }

  test('ohne Eintrag: leeres Profil', () async {
    final c = await start();
    expect(c.read(profilProvider).value!.istLeer, isTrue);
  });

  test('speichern: bereinigt, mit Zeitpunkt, in der Ablage', () async {
    final c = await start();
    final fehler = await c.read(profilProvider.notifier).speichern(
          const NutzerProfil(
            name: '  Lukas ',
            telefon: '۰۶۶۴ ۱۲۳۴۵۶۷',
            adressen: [ProfilAdresse(), ProfilAdresse(ort: 'Dornbirn')],
          ),
        );
    expect(fehler, isNull);
    final p = c.read(profilProvider).value!;
    expect(p.name, 'Lukas');
    expect(p.telefon, '0664 1234567');
    expect(p.adressen, hasLength(1));
    expect(p.am, isNotNull);

    final prefs = await SharedPreferences.getInstance();
    expect(NutzerProfil.ausText(prefs.getString(kProfilKey))!.name, 'Lukas');
  });

  test('Ungültiges wird abgelehnt und nichts geschrieben', () async {
    final c = await start();
    final fehler = await c
        .read(profilProvider.notifier)
        .speichern(const NutzerProfil(telefon: 'abc'));
    expect(fehler, ProfilFehler.telefonUngueltig);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(kProfilKey), isFalse);
    expect(c.read(profilProvider).value!.istLeer, isTrue);
  });

  test('liest einen vorhandenen Stand beim Start', () async {
    final c = await start({
      kProfilKey:
          NutzerProfil(name: 'Vorhanden', am: DateTime.utc(2026, 9, 1)).zuText(),
    });
    expect(c.read(profilProvider).value!.name, 'Vorhanden');
  });
}
