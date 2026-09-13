// FILE: lib/core/grammatikon/endung_resolver.dart
// PURPOSE: Trennt ein Wort in (stamm, endung) für die farbige Anzeige (فاز V, Stufe ۲).
//          Duden-Bildsystem: Stamm bleibt in Textfarbe, grammatische Endung wird
//          farbig/fett markiert (Buch|es, klein|em, lern|te).
//          Automatik = Heuristik für Listen; auf der Wort-Seite (Stufe ۴) wird die
//          Endung IMMER explizit übergeben (dort ist die Form ohnehin bekannt).
//          (Port von endungResolver.js — React Native → Dart records.)

/// Deklinations-/Konjugationsendungen — längste zuerst (Reihenfolge ist Vertrag!).
const _endungen = [
  'sten', 'stem', 'stes', 'ster', // Superlativ dekliniert
  'est', 'end', 'ung',
  'em', 'en', 'er', 'es', 'et', 'st', 'te', 'e',
  's', 'n', 't',
];

abstract final class EndungResolver {
  /// Trennt [wort] in Stamm + Endung.
  /// - [explizit] `null` → Automatik (längste passende Endung, Stamm ≥ 2 Zeichen)
  /// - [explizit] `''`   → keine Markierung
  /// - [explizit] passt nicht ans Wortende → keine Markierung (nie falsch färben)
  static ({String stamm, String endung}) splitEndung(String wort,
      [String? explizit]) {
    if (wort.isEmpty) return (stamm: '', endung: '');

    if (explizit != null) {
      if (explizit.isNotEmpty && wort.endsWith(explizit)) {
        return (
          stamm: wort.substring(0, wort.length - explizit.length),
          endung: explizit,
        );
      }
      return (stamm: wort, endung: '');
    }

    for (final e in _endungen) {
      if (wort.length > e.length + 1 && wort.endsWith(e)) {
        return (stamm: wort.substring(0, wort.length - e.length), endung: e);
      }
    }
    return (stamm: wort, endung: '');
  }

  /// Präfix-Markierung: Partizip II ("ge|hab|t") oder trennbares Verb ("auf|stehen").
  /// Passt [praefix] nicht an den Wortanfang → keine Markierung.
  static ({String praefix, String rest}) splitPraefix(
      String wort, String? praefix) {
    if (praefix != null && praefix.isNotEmpty && wort.startsWith(praefix)) {
      return (praefix: praefix, rest: wort.substring(praefix.length));
    }
    return (praefix: '', rest: wort);
  }
}
