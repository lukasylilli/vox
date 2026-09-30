// FILE: lib/core/wort/altwort_formen.dart
// PHASE: Wunsch Lukas (2026-09-30): Suche UND Antippen finden ein Wort auch
//        in gebeugter Form — für JEDE Wortart und für BEIDE Quellen.
// PURPOSE: Gebeugte Formen der ALTEN Wörter (drift-Tabelle `Words`: Decks
//          Dativ/Akkusativ, Konnektoren, NVV, Präpositionen + eigene Wörter).
//          Das Gegenstück für die Archivkarten ist vokab_formen.dart
//          (Formen-Tabelle assets/vocab_formen/); alte Wörter stehen nicht in
//          dieser Tabelle, ihre Formen werden hier direkt aus der Zeile gelesen.
//
// QUELLEN — nur was die Zeile selbst sagt (Projektregel: nie raten):
//   · Verb: conjugationJson {präs, prät, pp} — von «präs»/«prät» zählt das
//     ERSTE Wort («gibt zurück» ⇒ «gibt»), vom Partizip das LETZTE
//     («hat empfohlen» ⇒ «empfohlen»); Alternativen mit «/» oder «,».
//   · Nomen: plural (ohne Artikel) und Dativ Plural -n (Plural nicht auf -n/-s).
//   · Andere Wortarten: keine Formen-Daten in der alten Tabelle ⇒ keine Formen.
// Die Grundform selbst gehört NICHT dazu (die findet schon die normale Suche).
import 'dart:convert';

import 'wort_form.dart';

const _artikelVorPlural = {'der', 'die', 'das'};

Set<String> altwortFormen({
  required String wortart,
  required String german,
  String? plural,
  String? conjugationJson,
}) {
  final formen = <String>{};
  void form(String text) {
    final k = wortSchluessel(text);
    if (k.isNotEmpty) formen.add(k);
  }

  List<String> varianten(String? text) => [
        for (final v in (text ?? '').split(RegExp(r'[/,]')))
          if (v.trim().isNotEmpty) v.trim(),
      ];
  List<String> woerter(String text) =>
      text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  if (wortart == 'verb' && conjugationJson != null &&
      conjugationJson.isNotEmpty) {
    Map<String, dynamic> k;
    try {
      k = (jsonDecode(conjugationJson) as Map).cast<String, dynamic>();
    } catch (_) {
      k = const {};
    }
    for (final feld in ['präs', 'prät']) {
      for (final v in varianten(k[feld] as String?)) {
        form(woerter(v).first);
      }
    }
    for (final v in varianten(k['pp'] as String?)) {
      form(woerter(v).last);
    }
  }

  if (wortart == 'nomen') {
    for (final v in varianten(plural)) {
      var t = woerter(v);
      if (t.length > 1 && _artikelVorPlural.contains(t.first.toLowerCase())) {
        t = t.sublist(1);
      }
      final p = t.join(' ');
      if (p.isEmpty || p == '-') continue;
      form(p);
      final klein = p.toLowerCase();
      if (!klein.endsWith('n') && !klein.endsWith('s')) form('${p}n');
    }
  }

  formen.remove(wortSchluessel(german));
  return formen;
}
