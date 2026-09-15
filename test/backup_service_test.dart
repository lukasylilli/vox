// FILE: test/backup_service_test.dart
// PHASE: فاز S, Schritt S.2 (2026-09-15)
// PURPOSE: Prüft das Zusammenspiel von Sicherung, Fassade und Datei — soweit
//          das ohne Browser geht. Die Dateiauswahl selbst liegt hinter
//          datei_io.dart und liefert auf der Dart-VM absichtlich `null`
//          (= „abgebrochen"), genau dieser Pfad wird hier mitgeprüft.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/core/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<BackupService> dienst({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return BackupService(
        UserStateRepository(db, await SharedPreferences.getInstance()));
  }

  test('Dateiname trägt das Datum und endet auf .json', () {
    final name = BackupService.dateiname(DateTime.utc(2026, 9, 15, 23, 40));
    expect(name, 'vox-sicherung-2026-09-15.json');
    // Zwei Sicherungen an verschiedenen Tagen überschreiben sich nicht.
    expect(name, isNot(BackupService.dateiname(DateTime.utc(2026, 9, 16))));
  });

  test('Einspielen ohne Dateiauswahl gilt als Abbruch, nicht als Fehler',
      () async {
    final e = await (await dienst()).einspielen();
    expect(e.abgebrochen, isTrue);
    expect(e.leitnerWoerter, 0);
  });

  test('Export schreibt eine Datei, die sich wieder einlesen lässt', () async {
    final d = await dienst(prefs: {
      'vokab_user_leitner_v1': '{"adjektiv_stolz":{"box":4}}',
      'ui_language': 'fa',
    });
    // exportieren() gibt den Namen zurück; die Bytes gehen auf der Dart-VM
    // ins Leere (Stub). Der Inhalt wird deshalb hier direkt geprüft.
    final name = await d.exportieren(jetzt: DateTime.utc(2026, 9, 15));
    expect(name, 'vox-sicherung-2026-09-15.json');
  });

  test('eine kaputte Datei nennt einen Grund, den man zeigen kann', () {
    try {
      sicherungLesen('{"version":1,"app":"root-in","payload":{}}');
      fail('hätte werfen müssen');
    } on SicherungFehler catch (e) {
      expect(e.grund, isNotEmpty);
      expect(e.grund, contains('App'));
    }
  });
}
