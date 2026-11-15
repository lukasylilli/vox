// FILE: lib/features/vokabular/data/vokab_karten_lader_web.dart
// PURPOSE: Kartentext im Browser: eine Datei neben der App
//          (<base>/karten/<wortart>/<id>.json). Der Service Worker
//          (tool/pwa/workbox_config.cjs) hält geöffnete Karten offline.
//          Siehe vokab_karten_lader.dart.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vokab_index.dart';

Future<String> vokabKarteTextLaden(String wortart, String id) async {
  final adresse = Uri.base.resolve(vokabKartenWebPfad(wortart, id));
  final antwort = await http.get(adresse);
  if (antwort.statusCode != 200) {
    throw StateError('Wortkarte $id nicht ladbar (${antwort.statusCode})');
  }
  return utf8.decode(antwort.bodyBytes);
}
