// FILE: lib/core/grammatikon/perfekt_builder.dart
// PURPOSE: Baut die komplette Perfekt-Konjugation aus hilfsverb + partizip2 (فاز V).
//          Ersetzt details.konjugation.perfekt aus dem alten Schema — das
//          gespeicherte Wort-JSON braucht die Perfekt-Tabelle nicht mehr,
//          weil sie hier deterministisch abgeleitet wird.
class PerfektBuilder {
  const PerfektBuilder._();

  static const _haben = {
    'ich': 'habe', 'du': 'hast', 'er_sie_es': 'hat',
    'wir': 'haben', 'ihr': 'habt', 'sie_Sie': 'haben',
  };
  static const _sein = {
    'ich': 'bin', 'du': 'bist', 'er_sie_es': 'ist',
    'wir': 'sind', 'ihr': 'seid', 'sie_Sie': 'sind',
  };

  /// z. B. perfekt('du', 'sein', 'aufgestanden') → "bist aufgestanden"
  static String perfekt(String person, String hilfsverb, String partizip2) {
    final aux = hilfsverb == 'sein' ? _sein : _haben;
    return '${aux[person]} $partizip2';
  }

  /// Ganze Tabelle für die Anzeige in der App:
  static Map<String, String> tabelle(String hilfsverb, String partizip2) =>
      { for (final p in _haben.keys) p: perfekt(p, hilfsverb, partizip2) };
}
