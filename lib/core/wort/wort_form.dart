// FILE: lib/core/wort/wort_form.dart
// DEPS: — (reines Dart, kein Flutter)
// PURPOSE: EINE Quelle für «welches Wort ist das?» — Bereinigung eines
//          angetippten Worts und der SCHLÜSSEL, mit dem ein Text-Wort und ein
//          Wörterbuch-Eintrag verglichen werden (L.5f: Klick auf ein Wort).
//
// REGELN (bewusst klein — lieber kein Treffer als ein falscher):
//   · Vergleich ohne Groß/Klein: «Reisen» (Nomen) und «reisen» (Verb) haben
//     denselben Schlüssel und werden BEIDE gezeigt, nie einer geraten.
//   · Ein führender Artikel (der/die/das) zählt nur bei Mehrwort-Einträgen
//     nicht mit: «die Angst» → «angst». Das einzelne Wort «die» bleibt «die».
//   · Eine nachgestellte Präposition zählt nicht mit: «warten auf» → «warten»
//     (so steht es in der alten Wortdatenbank).
//   · KEINE Formenerkennung (ging → gehen, Häuser → Haus): sie wäre geraten.
//     Was nicht als Grundform vorkommt, wird «nicht im Wörterbuch» gezeigt —
//     mit dem Weg in die Suche.
//
// ⚠️ `stripPreposition` lag früher in word_list_item.dart und wohnt seit L.5f
//    hier (eine Quelle); word_list_item.dart reicht sie unverändert weiter.

/// Buchstaben, aus denen ein Wort besteht: lateinisch inkl. Umlaute, ß und
/// Akzente (U+00C0–U+024F ohne × und ÷). Als Zeichenklassen-Inhalt gedacht.
const String wortBuchstaben =
    r'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u024F';

// Präpositionen, die in der alten Wortdatenbank hinter dem Wort stehen können.
const Set<String> _praepositionen = {
  'für', 'auf', 'an', 'über', 'mit', 'von', 'zu', 'bei',
  'nach', 'aus', 'in', 'um', 'gegen', 'ohne', 'durch',
  'bis', 'vor', 'hinter', 'neben', 'zwischen', 'gegenüber',
};

const Set<String> _artikel = {'der', 'die', 'das'};

/// «warten auf» → «warten». Nur bei mindestens zwei Wörtern und nur, wenn das
/// letzte Wort eine bekannte Präposition ist.
String stripPreposition(String german) {
  final parts = german.split(' ');
  if (parts.length >= 2 && _praepositionen.contains(parts.last.toLowerCase())) {
    return parts.sublist(0, parts.length - 1).join(' ');
  }
  return german;
}

final RegExp _randOhneBuchstaben =
    RegExp('^[^$wortBuchstaben]+|[^$wortBuchstaben]+\$');
final RegExp _leerraum = RegExp(r'\s+');

/// Satzzeichen, Ziffern und Leerraum am Rand entfernen: «(Haus),» → «Haus».
String wortBereinigt(String roh) => roh.replaceAll(_randOhneBuchstaben, '');

/// Vergleichsschlüssel für ein angetipptes Wort UND für einen Eintrag
/// (siehe Regeln oben). Leer, wenn kein Buchstabe drin ist.
String wortSchluessel(String wort) {
  var teile = wortBereinigt(wort)
      .split(_leerraum)
      .where((t) => t.isNotEmpty)
      .toList();
  if (teile.length >= 2 && _artikel.contains(teile.first.toLowerCase())) {
    teile = teile.sublist(1);
  }
  return stripPreposition(teile.join(' ')).toLowerCase();
}
