// FILE: lib/features/vokabular/data/vokab_karten_lader_io.dart
// PURPOSE: Kartentext außerhalb des Browsers (Tests, Werkzeuge): direkt aus
//          der Quelle assets/vocab/ im Projektordner. Siehe
//          vokab_karten_lader.dart.
import 'dart:io';

import 'vokab_index.dart';

Future<String> vokabKarteTextLaden(String wortart, String id) =>
    File(vokabKartenPfad(wortart, id)).readAsString();
