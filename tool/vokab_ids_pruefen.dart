// FILE: tool/vokab_ids_pruefen.dart
// PHASE: فاز LAUNCH, Schritt L.1a (2026-09-16)
// PURPOSE: Wächter — keine veröffentlichte Wort-id darf verschwinden.
//
//   dart run tool/vokab_ids_pruefen.dart <Adresse der veröffentlichten Seite>
//   z. B.  dart run tool/vokab_ids_pruefen.dart https://lukasylilli.github.io/vox
//
// Lädt den Index der LIVE-Seite und vergleicht ihn mit dem gerade gebauten
// assets/vocab_index/. Fehlt eine id, die Nutzer schon haben konnten, endet
// der Lauf mit Exit-Code 1 — der Bau bleibt rot, nichts wird veröffentlicht.
//
// Der Index liegt seit 2026-11-16 in Stücken (vokab_index.dart). Die
// Live-Seite kann noch die ältere Ablage in EINER Datei haben — beides wird
// gelesen ([vokabIndexIdsHolen]). Nicht erreichbar oder unvollständig ⇒ rot.
//
// WARUM gegen die Live-Seite und nicht gegen den vorigen Commit: Ein roter
// Lauf veröffentlicht nichts. Verglichen mit „dem vorigen Commit" würde der
// NÄCHSTE Push die Löschung schon als Ausgangslage sehen und durchlassen.
// Die Live-Seite ist genau das, was Nutzer wirklich haben.
//
// ⚠️ Ausnahmen gibt es bewusst nicht. Muss eine Karte je wirklich weg, braucht
// es vorher eine Umzugsregel für den Leitner-Stand der Nutzer — das ist eine
// Entscheidung mit Lukas, kein Handgriff (PLAN.md → L.1a).
import 'dart:convert';
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_index.dart';

/// Holt `<basis>/assets/<assetPfad>`. `null` bei 404; jeder andere Fehler
/// (auch nach drei Versuchen) ist eine Ausnahme — nie „nichts veröffentlicht".
Future<String?> _vonLiveSeite(HttpClient client, Uri basis, String assetPfad) async {
  final uri = basis.replace(pathSegments: [
    ...basis.pathSegments.where((s) => s.isNotEmpty),
    'assets',
    ...assetPfad.split('/'),
  ]);
  Object? letzter;
  for (var versuch = 1; versuch <= 3; versuch++) {
    try {
      final anfrage = await client.getUrl(uri);
      final antwort = await anfrage.close();
      if (antwort.statusCode == 404) {
        await antwort.drain<void>();
        return null;
      }
      if (antwort.statusCode != 200) {
        await antwort.drain<void>();
        throw HttpException('HTTP ${antwort.statusCode}', uri: uri);
      }
      return await antwort.transform(utf8.decoder).join();
    } catch (e) {
      letzter = e;
      await Future<void>.delayed(Duration(seconds: 2 * versuch));
    }
  }
  throw HttpException('nicht abrufbar ($letzter)', uri: uri);
}

Future<void> main(List<String> args) async {
  final basis = args.length == 1 ? Uri.tryParse(args.single) : null;
  if (basis == null || !basis.hasScheme || basis.host.isEmpty) {
    stderr.writeln('Aufruf: dart run tool/vokab_ids_pruefen.dart '
        '<Adresse der veröffentlichten Seite>');
    exit(2);
  }
  if (!File(vokabIndexStueckeDatei).existsSync()) {
    stderr.writeln('$vokabIndexStueckeDatei fehlt — vorher '
        '`dart run tool/vokab_index.dart`.');
    exit(1);
  }

  final Set<String> veroeffentlicht;
  final Set<String> jetzt;
  final client = HttpClient();
  try {
    jetzt = await vokabIndexIdsHolen((pfad) async {
      final datei = File(pfad);
      return datei.existsSync() ? datei.readAsStringSync() : null;
    });
    veroeffentlicht =
        await vokabIndexIdsHolen((pfad) => _vonLiveSeite(client, basis, pfad));
  } on FormatException catch (e) {
    stderr.writeln('::error::Index nicht lesbar: ${e.message}');
    exit(1);
  } on HttpException catch (e) {
    stderr.writeln('::error::Veröffentlichter Wortindex nicht abrufbar: '
        '${e.message} — ${e.uri}');
    exit(1);
  } finally {
    client.close(force: true);
  }

  final verloren = vokabVerloreneIds(veroeffentlicht, jetzt);
  if (verloren.isNotEmpty) {
    stderr.writeln('⛔ ${verloren.length} veröffentlichte Wort-id(s) fehlen '
        '(gelöscht oder umbenannt):');
    for (final id in verloren) {
      stderr.writeln('  · $id');
    }
    stderr.writeln('Nutzer können diese Wörter im Leitner, in Listen oder '
        'Notizen haben. Karte(n) wiederherstellen — siehe PLAN.md → L.1a.');
    exit(1);
  }
  stdout.writeln('Wort-ids: ${veroeffentlicht.length} veröffentlicht, '
      'alle noch da; ${jetzt.length - veroeffentlicht.length} neu.');
}
