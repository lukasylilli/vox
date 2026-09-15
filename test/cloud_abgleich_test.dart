// FILE: test/cloud_abgleich_test.dart
// PHASE: فاز S, S.3 Schritt 3 (2026-09-15)
// PURPOSE: Der Konto-Abgleich ohne Netz: ein Server im Speicher, der die
//          Nutzlast wie `jsonb` durch JSON schickt, und zwei „Geräte".
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/backup/cloud_abgleich.dart';
import 'package:vox/core/backup/nutzer_zustand.dart';
import 'package:vox/core/backup/user_state_repository.dart';
import 'package:vox/core/database/app_database.dart';

class _Server implements CloudAblage {
  bool angemeldet = true;
  bool kaputt = false;
  String? zeile; // wie in vox_backups: eine Zeile je Konto
  int version = nutzerZustandVersion;
  int uploads = 0;

  @override
  bool get verfuegbar => angemeldet;

  @override
  Future<CloudStand?> holen() async {
    if (kaputt) throw Exception('offline');
    if (zeile == null) return null;
    return CloudStand(
      payload: (jsonDecode(zeile!) as Map).cast<String, dynamic>(),
      version: version,
      aktualisiertAm: DateTime.utc(2026, 9, 15),
    );
  }

  @override
  Future<void> ablegen(Map<String, dynamic> payload, int v) async {
    if (kaputt) throw Exception('offline');
    zeile = jsonEncode(payload);
    version = v;
    uploads++;
  }

  @override
  Future<DateTime?> zuletzt() async => DateTime.utc(2026, 9, 15, 12);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<UserStateRepository> geraet() async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return UserStateRepository(db, await SharedPreferences.getInstance());
  }

  test('ohne Anmeldung: nichts passiert, kein Fehler', () async {
    final server = _Server()..angemeldet = false;
    final e = await CloudAbgleich(await geraet(), server).abgleichen();
    expect(e.status, CloudStatus.nichtVerfuegbar);
    expect(server.uploads, 0);
  });

  test('leeres Gerät, leerer Server: nichts hochladen', () async {
    final server = _Server();
    final e = await CloudAbgleich(await geraet(), server).abgleichen();
    expect(e.status, CloudStatus.ok);
    expect(server.uploads, 0);
  });

  test('zwei Geräte: Aufnehmen und Entfernen wandern hin und zurück',
      () async {
    final server = _Server();
    final a = await geraet();
    final b = await geraet();

    await a.archivLeitnerAufnehmen('verb_helfen', DateTime(2026, 9, 1));
    expect((await CloudAbgleich(a, server).abgleichen()).status,
        CloudStatus.ok);
    expect(server.uploads, 1);

    final eb = await CloudAbgleich(b, server).abgleichen();
    expect(eb.lokalGeaendert, isTrue);
    expect((await b.lesen()).leitner.keys, contains('verb_helfen'));

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await b.archivLeitnerEntfernen('verb_helfen');
    await CloudAbgleich(b, server).abgleichen();
    await CloudAbgleich(a, server).abgleichen();
    expect((await a.lesen()).leitner.keys, isNot(contains('verb_helfen')));
  });

  test('nichts geändert: kein erneutes Hochladen', () async {
    final server = _Server();
    final a = await geraet();
    await a.archivLeitnerAufnehmen('verb_helfen', DateTime(2026, 9, 1));
    await CloudAbgleich(a, server).abgleichen();
    final e = await CloudAbgleich(a, server).abgleichen();
    expect(e.status, CloudStatus.ok);
    expect(e.lokalGeaendert, isFalse);
    expect(server.uploads, 1);
  });

  test('Kopie aus neuerer App-Fassung: weder einspielen noch überschreiben',
      () async {
    final server = _Server()
      ..zeile = '{"leitner":{}}'
      ..version = nutzerZustandVersion + 1;
    final a = await geraet();
    await a.archivLeitnerAufnehmen('verb_helfen', DateTime(2026, 9, 1));
    final e = await CloudAbgleich(a, server).abgleichen();
    expect(e.status, CloudStatus.zuNeu);
    expect(server.uploads, 0);
    expect(server.zeile, '{"leitner":{}}');
  });

  test('Server nicht erreichbar: Fehler gemeldet, Gerät unverändert',
      () async {
    final server = _Server()..kaputt = true;
    final a = await geraet();
    await a.archivLeitnerAufnehmen('verb_helfen', DateTime(2026, 9, 1));
    final e = await CloudAbgleich(a, server).abgleichen();
    expect(e.status, CloudStatus.fehlgeschlagen);
    expect((await a.lesen()).leitner.keys, contains('verb_helfen'));
  });

  test('Gleichheit hängt nicht an der Schlüsselfolge (jsonb)', () {
    expect(CloudAbgleich.gleich({'a': 1, 'b': {'x': 1, 'y': 2}},
        {'b': {'y': 2, 'x': 1}, 'a': 1}), isTrue);
    expect(CloudAbgleich.gleich({'a': 1}, {'a': 2}), isFalse);
  });
}
