// FILE: test/verb_formen_suche_test.dart
// PHASE: Verben (Entscheidung Lukas 2026-10-11, PLAN.md «📚 روال» ⇒ ⛔ افعال):
//        ALLE Formen eines Verbs stehen auf der Seite des Infinitivs, und die
//        Suche muss von JEDER Form dorthin finden — regelmäßig, unregelmäßig,
//        trennbar, reflexiv, Modalverb, alle Zeiten und Modi, Partizipien
//        (auch dekliniert), zu-Infinitiv, getrennte Stellung, Perfekt-Phrasen.
//        Präfix-/Partikelverben sind EIGENE Karten (rufen ≠ anrufen).
//
// Wächter: wird hier etwas rot, darf keine Verbkarte mehr gebaut werden,
// bis es wieder grün ist (verbenFreigegeben in tool/naechste_woerter.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/wort/wort_form.dart';
import 'package:vox/features/vokabular/data/vokab_formen.dart';

Map<String, String> _p(List<String> f) => {
      'ich': f[0], 'du': f[1], 'er_sie_es': f[2], //
      'wir': f[3], 'ihr': f[4], 'sie_Sie': f[5],
    };

Map<String, dynamic> _verb({
  required String wort,
  bool trennbar = false,
  bool regelmaessig = false,
  bool modalverb = false,
  String reflexiv = 'nein',
  required String praet,
  required String p2,
  required String p1,
  required List<String> praesens,
  required List<String> praeteritum,
  required List<String> k1,
  required List<String> k2,
  required List<String> imp,
}) =>
    {
      'id': 'verb_${wort.replaceAll('ö', 'oe').replaceAll('ä', 'ae').replaceAll('ü', 'ue').replaceAll('ß', 'ss')}',
      'wort': wort,
      'wortart': 'verb',
      'details': {
        'trennbar': trennbar,
        'regelmaessig': regelmaessig,
        'modalverb': modalverb,
        'reflexiv': reflexiv,
        'stammformen': {'infinitiv': wort, 'praeteritum': praet, 'partizip2': p2},
        'konjugation': {
          'praesens': _p(praesens),
          'praeteritum': _p(praeteritum),
          'konjunktiv1': _p(k1),
          'konjunktiv2': _p(k2),
          'imperativ': {'du': imp[0], 'ihr': imp[1], 'Sie': imp[2]},
        },
        'partizip1': p1,
      },
    };

final _karten = [
  _verb(
    wort: 'sein', praet: 'war', p2: 'gewesen', p1: 'seiend',
    praesens: ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
    praeteritum: ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
    k1: ['sei', 'seist', 'sei', 'seien', 'seiet', 'seien'],
    k2: ['wäre', 'wärst', 'wäre', 'wären', 'wärt', 'wären'],
    imp: ['Sei!', 'Seid!', 'Seien Sie!'],
  ),
  _verb(
    wort: 'haben', praet: 'hatte', p2: 'gehabt', p1: 'habend',
    praesens: ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
    praeteritum: ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
    k1: ['habe', 'habest', 'habe', 'haben', 'habet', 'haben'],
    k2: ['hätte', 'hättest', 'hätte', 'hätten', 'hättet', 'hätten'],
    imp: ['Hab!', 'Habt!', 'Haben Sie!'],
  ),
  _verb(
    wort: 'gehen', praet: 'ging', p2: 'gegangen', p1: 'gehend',
    praesens: ['gehe', 'gehst', 'geht', 'gehen', 'geht', 'gehen'],
    praeteritum: ['ging', 'gingst', 'ging', 'gingen', 'gingt', 'gingen'],
    k1: ['gehe', 'gehest', 'gehe', 'gehen', 'gehet', 'gehen'],
    k2: ['ginge', 'gingest', 'ginge', 'gingen', 'ginget', 'gingen'],
    imp: ['Geh!', 'Geht!', 'Gehen Sie!'],
  ),
  _verb(
    wort: 'rufen', praet: 'rief', p2: 'gerufen', p1: 'rufend',
    praesens: ['rufe', 'rufst', 'ruft', 'rufen', 'ruft', 'rufen'],
    praeteritum: ['rief', 'riefst', 'rief', 'riefen', 'rieft', 'riefen'],
    k1: ['rufe', 'rufest', 'rufe', 'rufen', 'rufet', 'rufen'],
    k2: ['riefe', 'riefest', 'riefe', 'riefen', 'riefet', 'riefen'],
    imp: ['Ruf!', 'Ruft!', 'Rufen Sie!'],
  ),
  _verb(
    wort: 'anrufen', trennbar: true, praet: 'rief an', p2: 'angerufen',
    p1: 'anrufend',
    praesens: ['rufe an', 'rufst an', 'ruft an', 'rufen an', 'ruft an', 'rufen an'],
    praeteritum: ['rief an', 'riefst an', 'rief an', 'riefen an', 'rieft an', 'riefen an'],
    k1: ['rufe an', 'rufest an', 'rufe an', 'rufen an', 'rufet an', 'rufen an'],
    k2: ['riefe an', 'riefest an', 'riefe an', 'riefen an', 'riefet an', 'riefen an'],
    imp: ['Ruf an!', 'Ruft an!', 'Rufen Sie an!'],
  ),
  _verb(
    wort: 'arbeiten', regelmaessig: true, praet: 'arbeitete', p2: 'gearbeitet',
    p1: 'arbeitend',
    praesens: ['arbeite', 'arbeitest', 'arbeitet', 'arbeiten', 'arbeitet', 'arbeiten'],
    praeteritum: ['arbeitete', 'arbeitetest', 'arbeitete', 'arbeiteten', 'arbeitetet', 'arbeiteten'],
    k1: ['arbeite', 'arbeitest', 'arbeite', 'arbeiten', 'arbeitet', 'arbeiten'],
    k2: ['arbeitete', 'arbeitetest', 'arbeitete', 'arbeiteten', 'arbeitetet', 'arbeiteten'],
    imp: ['Arbeite!', 'Arbeitet!', 'Arbeiten Sie!'],
  ),
  _verb(
    wort: 'waschen', reflexiv: 'optional', praet: 'wusch', p2: 'gewaschen',
    p1: 'waschend',
    praesens: ['wasche', 'wäschst', 'wäscht', 'waschen', 'wascht', 'waschen'],
    praeteritum: ['wusch', 'wuschst', 'wusch', 'wuschen', 'wuscht', 'wuschen'],
    k1: ['wasche', 'waschest', 'wasche', 'waschen', 'waschet', 'waschen'],
    k2: ['wüsche', 'wüschest', 'wüsche', 'wüschen', 'wüschet', 'wüschen'],
    imp: ['Wasch!', 'Wascht!', 'Waschen Sie!'],
  ),
  _verb(
    wort: 'mögen', modalverb: true, praet: 'mochte', p2: 'gemocht',
    p1: 'mögend',
    praesens: ['mag', 'magst', 'mag', 'mögen', 'mögt', 'mögen'],
    praeteritum: ['mochte', 'mochtest', 'mochte', 'mochten', 'mochtet', 'mochten'],
    k1: ['möge', 'mögest', 'möge', 'mögen', 'möget', 'mögen'],
    k2: ['möchte', 'möchtest', 'möchte', 'möchten', 'möchtet', 'möchten'],
    imp: ['–', '–', '–'],
  ),
  _verb(
    wort: 'entscheiden', praet: 'entschied', p2: 'entschieden',
    p1: 'entscheidend',
    praesens: ['entscheide', 'entscheidest', 'entscheidet', 'entscheiden', 'entscheidet', 'entscheiden'],
    praeteritum: ['entschied', 'entschiedst', 'entschied', 'entschieden', 'entschiedet', 'entschieden'],
    k1: ['entscheide', 'entscheidest', 'entscheide', 'entscheiden', 'entscheidet', 'entscheiden'],
    k2: ['entschiede', 'entschiedest', 'entschiede', 'entschieden', 'entschiedet', 'entschieden'],
    imp: ['Entscheide!', 'Entscheidet!', 'Entscheiden Sie!'],
  ),
  _verb(
    wort: 'scheiden', praet: 'schied', p2: 'geschieden', p1: 'scheidend',
    praesens: ['scheide', 'scheidest', 'scheidet', 'scheiden', 'scheidet', 'scheiden'],
    praeteritum: ['schied', 'schiedst', 'schied', 'schieden', 'schiedet', 'schieden'],
    k1: ['scheide', 'scheidest', 'scheide', 'scheiden', 'scheidet', 'scheiden'],
    k2: ['schiede', 'schiedest', 'schiede', 'schieden', 'schiedet', 'schieden'],
    imp: ['Scheide!', 'Scheidet!', 'Scheiden Sie!'],
  ),
];

/// Was die App-Suche für [anfrage] an Verb-Karten findet: Formen-Tabelle über
/// alle Suchschlüssel + Grundform (Wortindex).
Set<String> _suche(String anfrage) {
  final tabelle = <String, Set<String>>{};
  for (final k in _karten) {
    for (final f in formenAusKarte(k)) {
      (tabelle[f] ??= {}).add(k['id'] as String);
    }
  }
  final treffer = <String>{};
  for (final s in vokabSuchSchluessel(anfrage)) {
    treffer.addAll(tabelle[s] ?? const {});
    for (final k in _karten) {
      if (wortSchluessel(k['wort'] as String) == s) treffer.add(k['id'] as String);
    }
  }
  return treffer;
}

void main() {
  void findet(String id, List<String> anfragen) {
    for (final a in anfragen) {
      expect(_suche(a), contains(id), reason: '«$a» muss $id finden');
    }
  }

  test('Jede Konjugationsform jedes Verbs findet seine Karte', () {
    for (final k in _karten) {
      final d = k['details'] as Map<String, dynamic>;
      final konj = d['konjugation'] as Map<String, dynamic>;
      for (final teil in konj.values) {
        for (final form in (teil as Map).values) {
          if ((form as String).contains('–')) continue;
          findet(k['id'] as String, [form]);
        }
      }
      findet(k['id'] as String, [
        (d['stammformen'] as Map)['praeteritum'] as String,
        (d['stammformen'] as Map)['partizip2'] as String,
        d['partizip1'] as String,
      ]);
    }
  });

  test('unregelmäßig, Konjunktiv, Modalverb, reflexiv', () {
    findet('verb_sein', ['bin', 'ist', 'war', 'wären', 'sei', 'seien', 'gewesen']);
    findet('verb_haben', ['hat', 'hätte', 'hattest', 'gehabt']);
    findet('verb_gehen', ['ging', 'ginge', 'gegangen', 'Geh!']);
    findet('verb_moegen', ['mag', 'möchte', 'mochte', 'möge', 'gemocht']);
    findet('verb_waschen', ['wäscht', 'wusch', 'wüsche', 'gewaschen']);
  });

  test('Partizipien dekliniert, zu-Infinitiv, Gerundiv, nominalisiert', () {
    findet('verb_anrufen', ['angerufene', 'angerufenen', 'anrufende',
        'anzurufen', 'anzurufende', 'des Anrufens']);
    findet('verb_gehen', ['gegangenen', 'gehende', 'zu gehen', 'das Gehen']);
    findet('verb_entscheiden', ['entschiedene', 'entscheidenden', 'zu entscheiden']);
    findet('verb_arbeiten', ['gearbeitet', 'arbeitende', 'zu arbeiten']);
  });

  test('getrenntes Verb und Phrasen: rief … an, hat angerufen, ist gegangen',
      () {
    findet('verb_anrufen', ['rief an', 'Ruf an!', 'rufe dich an', 'rief mich an',
        'hat angerufen', 'riefe an']);
    findet('verb_gehen', ['ist gegangen', 'wäre gegangen', 'ging weg']);
    findet('verb_haben', ['hat angerufen']); // Hilfsverb — alle Karten zeigen
  });

  test('Präfixverben sind eigene Karten (rufen ≠ anrufen, scheiden ≠ entscheiden)',
      () {
    expect(_suche('angerufen'), isNot(contains('verb_rufen')));
    expect(_suche('gerufen'), isNot(contains('verb_anrufen')));
    expect(_suche('entschied'), isNot(contains('verb_scheiden')));
    expect(_suche('geschieden'), isNot(contains('verb_entscheiden')));
    // «rief» allein gehört zu beiden — die Suche zeigt beide.
    expect(_suche('rief'), containsAll(['verb_rufen', 'verb_anrufen']));
  });

  test('Partikel allein zeigt kein Verb', () {
    expect(formenAusKarte(_karten[4]), isNot(contains('an')));
  });
}
