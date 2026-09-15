// FILE: lib/core/parsers/connector_parser.dart
// PURPOSE: Parses the Konnektor format (marker = "K")
//
// FORMAT:
//   "weil | K | چون، زیرا | Ich gehe nicht, weil ich müde bin. | Er weint, weil..."
//   "damit | K | برای اینکه | Er lernt, damit er die Prüfung besteht."
//
// فاز B-10: optionales Untertyp-Feld direkt hinter dem Marker, damit das
// Grammatikon-Symbol (core/grammatikon/grammatikon_resolver.dart, Fall
// "konjunktion") stimmt. Bricht nichts Bestehendes: das Feld wird nur erkannt,
// wenn es einer der drei Werte ist — jeder andere Text zählt weiter als
// erstes Beispiel, genau wie vorher.
//   "weil | K | subordinierend | چون | Ich gehe nicht, weil ich müde bin."
//
// Fields: konnektor | K | [untertyp] | meaning_fa | example1 | example2...

import '../models/word_model.dart';

class ConnectorParser {
  static const _untertypen = {
    'koordinierend',
    'subordinierend',
    'konjunktionaladverb',
  };

  static WordModel? parse(String input) {
    final fields = input.split('|').map((f) => f.trim()).toList();
    if (fields.length < 3) return null;
    if (fields[1].toUpperCase() != 'K') return null;

    final konnektor = fields[0];

    // Optionales Untertyp-Feld erkennen, sonst wie bisher lesen.
    String? untertyp;
    var meaningIdx = 2;
    if (fields.length > 3 && _untertypen.contains(fields[2].toLowerCase())) {
      untertyp = fields[2].toLowerCase();
      meaningIdx = 3;
    }

    if (fields.length <= meaningIdx) return null;
    final meaningFa = fields[meaningIdx];
    if (meaningFa.isEmpty) return null;

    final examples =
        fields.sublist(meaningIdx + 1).where((e) => e.isNotEmpty).toList();

    return WordModel(
      id       : 0,
      german   : konnektor,
      wordType : WordType.konnektor,
      meaningFa: meaningFa,
      examples : examples,
      grammatikDetail: untertyp,
    );
  }
}
