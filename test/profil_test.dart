// FILE: test/profil_test.dart
// PHASE: فاز P (2026-09-20)
// PURPOSE: Sichert die reine Logik der Profil-Seite ab — ohne Browser, ohne
//          Server: Prüfregeln, JSON, Zusammenführen, Vertrag Fassung 4 und die
//          neuen Anmelde-Fehlercodes.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/nutzer_profil.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/services/auth_service.dart';
import 'package:vox/features/more/widgets/profil_konto_karte.dart';

void main() {
  group('Telefon', () {
    test('leer ist gültig (freiwillig)', () {
      expect(telefonGueltig(''), isTrue);
      expect(telefonGueltig('   '), isTrue);
    });

    test('übliche Schreibweisen', () {
      expect(telefonGueltig('+43 664 1234567'), isTrue);
      expect(telefonGueltig('(0664) 123-45 67'), isTrue);
      expect(telefonGueltig('0664/1234567'), isTrue);
    });

    test('persische Ziffern zählen', () {
      expect(telefonGueltig('۰۹۱۲۳۴۵۶۷۸۹'), isTrue);
      expect(normalisiereZiffern('۰۹۱۲'), '0912');
      expect(normalisiereZiffern('٠١٢'), '012');
    });

    test('ungültig: Buchstaben, zu kurz, zu lang', () {
      expect(telefonGueltig('abc12345'), isFalse);
      expect(telefonGueltig('12345'), isFalse);
      expect(telefonGueltig('1234567890123456'), isFalse);
      expect(telefonGueltig('12+345678'), isFalse);
    });
  });

  group('Prüfen und Bereinigen', () {
    test('Name zu lang', () {
      final p = NutzerProfil(name: 'a' * (profilMaxName + 1));
      expect(p.pruefen(), ProfilFehler.nameZuLang);
      expect(NutzerProfil(name: 'a' * profilMaxName).pruefen(), isNull);
    });

    test('leere Adressen fallen beim Bereinigen weg', () {
      final p = const NutzerProfil(adressen: [
        ProfilAdresse(bezeichnung: 'Nur Titel'),
        ProfilAdresse(strasse: ' Hauptstr. 1 ', plz: '۶۸۵۰', ort: 'Dornbirn'),
      ]).bereinigt();
      expect(p.adressen, hasLength(1));
      expect(p.adressen.single.strasse, 'Hauptstr. 1');
      expect(p.adressen.single.plz, '6850');
    });

    test('zu viele Adressen', () {
      final p = NutzerProfil(adressen: [
        for (var i = 0; i <= profilMaxAdressen; i++)
          ProfilAdresse(strasse: 'Weg $i'),
      ]);
      expect(p.pruefen(), ProfilFehler.zuvieleAdressen);
    });

    test('Adressfeld zu lang', () {
      final p = NutzerProfil(
          adressen: [ProfilAdresse(ort: 'x' * (profilMaxFeld + 1))]);
      expect(p.pruefen(), ProfilFehler.feldZuLang);
    });

    test('Telefon wird geprüft', () {
      expect(const NutzerProfil(telefon: 'abc').pruefen(),
          ProfilFehler.telefonUngueltig);
    });

    test('istLeer', () {
      expect(const NutzerProfil().istLeer, isTrue);
      expect(const NutzerProfil(name: 'Lukas').istLeer, isFalse);
    });
  });

  group('JSON', () {
    test('Hin und zurück', () {
      final p = NutzerProfil(
        name: 'Lukas',
        telefon: '+43 664 1234567',
        adressen: const [
          ProfilAdresse(
              bezeichnung: 'Zuhause',
              strasse: 'Hauptstr. 1',
              plz: '6850',
              ort: 'Dornbirn',
              land: 'Österreich'),
        ],
        am: DateTime.utc(2026, 9, 19, 10),
      );
      final zurueck = NutzerProfil.ausText(p.zuText())!;
      expect(zurueck.name, 'Lukas');
      expect(zurueck.telefon, '+43 664 1234567');
      expect(zurueck.adressen.single.ort, 'Dornbirn');
      expect(zurueck.am, DateTime.utc(2026, 9, 19, 10));
    });

    test('kaputter oder leerer Text ergibt null, wirft nie', () {
      expect(NutzerProfil.ausText(null), isNull);
      expect(NutzerProfil.ausText(''), isNull);
      expect(NutzerProfil.ausText('kein json'), isNull);
      expect(NutzerProfil.ausText('[]'), isNull);
    });

    test('fremde Typen im JSON werden zu leeren Feldern', () {
      final p = NutzerProfil.vonJson({
        'name': 5,
        'telefon': null,
        'adressen': [1, 'x', {'ort': 'Wien'}],
      });
      expect(p.name, '');
      expect(p.telefon, '');
      expect(p.adressen.single.ort, 'Wien');
    });
  });

  group('Zusammenführen: der später bearbeitete Stand gewinnt', () {
    final alt = NutzerProfil(name: 'Alt', am: DateTime.utc(2026, 9, 1));
    final neu = NutzerProfil(name: 'Neu', am: DateTime.utc(2026, 9, 2));

    test('neuer gewinnt in beide Richtungen', () {
      expect(NutzerProfil.spaeteres(alt, neu)!.name, 'Neu');
      expect(NutzerProfil.spaeteres(neu, alt)!.name, 'Neu');
    });

    test('ein bewusst geleertes, neueres Profil setzt sich durch', () {
      final leer = NutzerProfil(am: DateTime.utc(2026, 9, 3));
      expect(NutzerProfil.spaeteres(neu, leer)!.istLeer, isTrue);
    });

    test('null und fehlender Zeitpunkt', () {
      expect(NutzerProfil.spaeteres(null, null), isNull);
      expect(NutzerProfil.spaeteres(null, neu)!.name, 'Neu');
      expect(NutzerProfil.spaeteres(neu, null)!.name, 'Neu');
      // ohne Zeitangabe gilt „älter als jede Änderung"
      expect(
          NutzerProfil.spaeteres(const NutzerProfil(name: 'Ohne'), neu)!.name,
          'Neu');
      expect(
          NutzerProfil.spaeteres(neu, const NutzerProfil(name: 'Ohne'))!.name,
          'Neu');
    });

    test('Gleichstand ⇒ der eigene Stand', () {
      final a = NutzerProfil(name: 'A', am: DateTime.utc(2026, 9, 1));
      final b = NutzerProfil(name: 'B', am: DateTime.utc(2026, 9, 1));
      expect(NutzerProfil.spaeteres(a, b)!.name, 'A');
    });
  });

  group('Vertrag Fassung 4', () {
    test('Version ist 4', () {
      expect(nutzerZustandVersion, 4);
    });

    test('Profil reist in der Sicherung mit', () {
      final z = NutzerZustand(
          profil: NutzerProfil(name: 'Lukas', am: DateTime.utc(2026, 9, 19)));
      final gelesen = sicherungLesen(sicherungSchreiben(z)).zustand;
      expect(gelesen.profil!.name, 'Lukas');
      expect(z.istLeer, isFalse);
    });

    test('ohne Profil kommt der Schlüssel gar nicht vor', () {
      expect(const NutzerZustand().toJson().containsKey('profil'), isFalse);
    });

    test('Sicherung aus Fassung 3 bleibt lesbar', () {
      const alt = '{"version":3,"app":"vox","exportedAt":"2026-09-16T10:00:00",'
          '"payload":{"leitner":{},"kategorien":[],"notizen":{},'
          '"einstellungen":{},"eigeneWoerter":[],"mitgliedschaften":[]}}';
      final s = sicherungLesen(alt);
      expect(s.version, 3);
      expect(s.zustand.profil, isNull);
    });

    test('zusammenfuehren nimmt das spätere Profil', () {
      final a = NutzerZustand(
          profil: NutzerProfil(name: 'A', am: DateTime.utc(2026, 9, 1)));
      final b = NutzerZustand(
          profil: NutzerProfil(name: 'B', am: DateTime.utc(2026, 9, 2)));
      expect(a.zusammenfuehren(b).profil!.name, 'B');
      expect(b.zusammenfuehren(a).profil!.name, 'B');
      expect(a.zusammenfuehren(const NutzerZustand()).profil!.name, 'A');
    });
  });

  group('Passwort-Regel der Oberfläche', () {
    test('zu kurz, ungleich, in Ordnung', () {
      expect(passwortFehlerSchluessel('kurz', 'kurz'), 'account_password_short');
      expect(passwortFehlerSchluessel('langgenug1', 'anders123'),
          'account_password_mismatch');
      expect(passwortFehlerSchluessel('langgenug1', 'langgenug1'), isNull);
    });
  });

  group('Neue Anmelde-Fehlercodes', () {
    test('werden zugeordnet', () {
      expect(authIssueFromCode('same_password'), AuthIssue.samePassword);
      expect(authIssueFromCode('reauthentication_needed'),
          AuthIssue.reauthNeeded);
      expect(authIssueFromCode('reauthentication_not_valid'),
          AuthIssue.reauthNeeded);
    });

    test('ohne Konfiguration melden die neuen Aufrufe notConfigured', () async {
      const service = AuthService();
      expect((await service.changePassword('irgendwas123')).issue,
          AuthIssue.notConfigured);
      expect((await service.changeEmail('a@b.de')).issue,
          AuthIssue.notConfigured);
      expect(await service.sendPasswordReset('a@b.de'),
          AuthIssue.notConfigured);
      await service.signOutEverywhere(); // wirft nicht
      expect(await service.watchPasswordRecovery().isEmpty, isTrue);
    });
  });
}
