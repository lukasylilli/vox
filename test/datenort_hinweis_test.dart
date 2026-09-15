// FILE: test/datenort_hinweis_test.dart
// PHASE: فاز S / S.4 (2026-09-16)
// PURPOSE: Der Hinweis „wo liegen meine Daten?" muss in jedem Zustand ehrlich
//          sein. Ohne Server darf nie der Eindruck entstehen, es gäbe eine
//          Kopie; angemeldet soll keine Warnung stehen, die nicht mehr stimmt.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/features/more/screens/settings_screen.dart';

void main() {
  group('datenOrtSchluessel', () {
    test('ohne Server: nur dieser Browser', () {
      expect(
        datenOrtSchluessel(kontoAktiv: false, angemeldet: false),
        'backup_only_here',
      );
      // Ein „angemeldet" ohne Server kann es nicht geben — und darf die
      // Warnung trotzdem nie verschlucken.
      expect(
        datenOrtSchluessel(kontoAktiv: false, angemeldet: true),
        'backup_only_here',
      );
    });

    test('Server da, niemand angemeldet: auf die Anmeldung hinweisen', () {
      expect(
        datenOrtSchluessel(kontoAktiv: true, angemeldet: false),
        'backup_only_here_signin',
      );
    });

    test('angemeldet: kein Warnhinweis', () {
      expect(
        datenOrtSchluessel(kontoAktiv: true, angemeldet: true),
        isNull,
      );
    });
  });
}
