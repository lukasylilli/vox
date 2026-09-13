// FILE: lib/features/vokabular/widgets/details_renderer.dart
// PURPOSE: Rendert card.details je Wortart (SUPER-PROMPT Schema 2.0, فاز V Stufe ۴).
//          Grammatik-Terminologie (Genus, Präsens, ja/nein …) ist LERNINHALT →
//          bleibt deutsch (Regel: Deutsch unveränderlich). UI-Labels via AppL10n.
//          Perfekt wird NICHT gespeichert — PerfektBuilder leitet es ab (Regel 7).
//          Alles null-sicher: fehlende Felder → Sektion erscheint nicht.
import 'package:flutter/material.dart';
import '../../../core/grammatikon/perfekt_builder.dart';
import 'wortseite_bausteine.dart';

class DetailsRenderer extends StatelessWidget {
  final Map<String, dynamic> card;
  const DetailsRenderer({super.key, required this.card});

  Map<String, dynamic> get _d =>
      (card['details'] as Map?)?.cast<String, dynamic>() ?? const {};

  @override
  Widget build(BuildContext context) {
    return switch (card['wortart'] as String?) {
      'nomen' => _nomen(context),
      'verb' => _verb(context),
      'adjektiv' => _adjektiv(context),
      'artikel' => _artikel(context),
      'pronomen' => _pronomen(context),
      'numerale' => _numerale(context),
      'praeposition' => _praeposition(context),
      'konjunktion' => _konjunktion(context),
      'adverb' => _adverb(),
      'partikel' => _partikel(context),
      _ => const SizedBox.shrink(),
    };
  }

  // ── gemeinsame Helfer ─────────────────────────────────────────
  String? _jaNein(dynamic v) => v == true ? 'ja' : (v == false ? 'nein' : null);

  String? _liste(dynamic v) {
    final l = (v as List?)?.cast<String>() ?? const [];
    return l.isEmpty ? null : l.join(', ');
  }

  /// Muster-Liste (mit_praeposition / rektion / feste_verbindungen / …):
  /// badge = Muster, Satz = Beispiel, Übersetzung = aktive Sprache.
  Widget _musterListe(BuildContext context, String titel, dynamic items,
      {String musterKey = 'muster'}) {
    final list = (items as List?)?.cast<Map>() ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Sektion(titel: titel, children: [
      for (final m in list)
        BeispielBlock(
          badge: (m[musterKey] ?? m['verbindung'] ?? m['wendung']) as String?,
          satz: (m['beispiel'] ?? m['bedeutung'] ?? '') as String,
          uebersetzung: vokabUeb(context, m['uebersetzung']),
        ),
    ]);
  }

  // ── Wortarten ─────────────────────────────────────────────────
  Widget _nomen(BuildContext context) {
    final d = _d;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Genus', wert: d['genus'] as String?),
        Zeile(label: 'Plural', wert: d['plural'] as String?),
        Zeile(label: 'Deklinationstyp', wert: d['deklinationstyp'] as String?),
        Zeile(label: 'Zählbar', wert: _jaNein(d['zaehlbar'])),
      ]),
      _musterListe(context, 'Mit Präposition', d['mit_praeposition']),
      _musterListe(context, 'Nomen-Verb-Verbindungen',
          d['nomen_verb_verbindungen']),
    ]);
  }

  Widget _verb(BuildContext context) {
    final d = _d;
    final stamm = (d['stammformen'] as Map?)?.cast<String, dynamic>();
    final konj = (d['konjugation'] as Map?)?.cast<String, dynamic>();
    final praesens = (konj?['praesens'] as Map?)?.cast<String, dynamic>();
    final praeteritum = (konj?['praeteritum'] as Map?)?.cast<String, dynamic>();
    final imperativ = (konj?['imperativ'] as Map?)?.cast<String, dynamic>();
    final hilfsverb = d['hilfsverb'] as String?;
    final partizip2 = stamm?['partizip2'] as String?;

    const personen = ['ich', 'du', 'er_sie_es', 'wir', 'ihr', 'sie_Sie'];
    const labels = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie/Sie'];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Trennbar', wert: _jaNein(d['trennbar'])),
        Zeile(label: 'Regelmäßig', wert: _jaNein(d['regelmaessig'])),
        Zeile(label: 'Hilfsverb', wert: hilfsverb),
        Zeile(label: 'Reflexiv', wert: d['reflexiv'] as String?),
        Zeile(label: 'Partizip I', wert: d['partizip1'] as String?),
        Zeile(label: 'Nominalisierung', wert: d['nominalisierung'] as String?),
      ]),
      if (stamm != null)
        Sektion(titel: 'Stammformen', children: [
          Tabelle(zeilen: [
            ['Infinitiv', stamm['infinitiv'] as String?],
            ['Präteritum', stamm['praeteritum'] as String?],
            ['Partizip II', partizip2],
          ]),
        ]),
      if (praesens != null || praeteritum != null)
        Sektion(titel: 'Konjugation', children: [
          Tabelle(
            kopf: const ['', 'Präsens', 'Präteritum', 'Perfekt'],
            zeilen: [
              for (var i = 0; i < personen.length; i++)
                [
                  labels[i],
                  praesens?[personen[i]] as String?,
                  praeteritum?[personen[i]] as String?,
                  // Regel 7: Perfekt nie gespeichert — deterministisch gebaut.
                  (hilfsverb != null && partizip2 != null)
                      ? PerfektBuilder.perfekt(personen[i], hilfsverb, partizip2)
                      : null,
                ],
            ],
          ),
          if (imperativ != null) ...[
            const SizedBox(height: 10),
            Tabelle(kopf: const ['Imperativ', 'du', 'ihr', 'Sie'], zeilen: [
              [
                '',
                imperativ['du'] as String?,
                imperativ['ihr'] as String?,
                imperativ['Sie'] as String?,
              ],
            ]),
          ],
        ]),
      _musterListe(context, 'Rektion', d['rektion']),
    ]);
  }

  Widget _adjektiv(BuildContext context) {
    final d = _d;
    final st = (d['steigerung'] as Map?)?.cast<String, dynamic>();
    final dekl = (d['deklinationsbeispiele'] as List?)?.cast<String>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Gebrauch', wert: d['gebrauch'] as String?),
        Zeile(
            label: 'Steigerung regelmäßig',
            wert: _jaNein(d['steigerung_regelmaessig'])),
        Zeile(label: 'Gegensatzpaar', wert: d['gegensatzpaar'] as String?),
      ]),
      if (st != null)
        Sektion(titel: 'Steigerung', children: [
          Tabelle(kopf: const ['Positiv', 'Komparativ', 'Superlativ'], zeilen: [
            [
              st['positiv'] as String?,
              st['komparativ'] as String?,
              st['superlativ'] as String?,
            ],
          ]),
        ]),
      if (dekl != null && dekl.isNotEmpty)
        Sektion(titel: 'Deklination', children: [
          for (final b in dekl) BeispielBlock(satz: b),
        ]),
      _musterListe(context, 'Mit Präposition', d['mit_praeposition']),
    ]);
  }

  Widget _artikel(BuildContext context) {
    final d = _d;
    final dk = (d['deklination'] as Map?)?.cast<String, dynamic>() ?? const {};
    const kasusList = ['nominativ', 'akkusativ', 'dativ', 'genitiv'];
    const kasusLabels = ['Nominativ', 'Akkusativ', 'Dativ', 'Genitiv'];
    final regeln = (d['gebrauchsregeln'] as List?)?.cast<String>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Typ', wert: d['typ'] as String?),
        Zeile(label: 'Verschmelzungen', wert: _liste(d['verschmelzungen'])),
      ]),
      if (dk.isNotEmpty)
        Sektion(titel: 'Deklination', children: [
          Tabelle(
            kopf: const ['', 'm', 'f', 'n', 'pl'],
            zeilen: [
              for (var i = 0; i < kasusList.length; i++)
                [
                  kasusLabels[i],
                  ...['m', 'f', 'n', 'pl'].map((g) =>
                      ((dk[kasusList[i]] as Map?)?[g]) as String?),
                ],
            ],
          ),
        ]),
      if (regeln != null && regeln.isNotEmpty)
        Sektion(titel: 'Gebrauch', children: [
          for (final r in regeln) BeispielBlock(satz: '• $r'),
        ]),
    ]);
  }

  Widget _pronomen(BuildContext context) {
    final d = _d;
    final dk = (d['deklination'] as Map?)?.cast<String, dynamic>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Untertyp', wert: d['untertyp'] as String?),
        Zeile(label: 'Bezugsregel', wert: d['bezugsregel'] as String?),
        Zeile(label: 'Position', wert: d['position'] as String?),
        Zeile(
            label: 'Verwechslungsgefahr',
            wert: d['verwechslungsgefahr'] as String?),
      ]),
      if (dk != null)
        Sektion(titel: 'Deklination', children: [
          Tabelle(zeilen: [
            ['Nominativ', dk['nominativ'] as String?],
            ['Akkusativ', dk['akkusativ'] as String?],
            ['Dativ', dk['dativ'] as String?],
            ['Genitiv', dk['genitiv'] as String?],
          ]),
        ]),
    ]);
  }

  Widget _numerale(BuildContext context) {
    final d = _d;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Untertyp', wert: d['untertyp'] as String?),
        Zeile(label: 'Deklinierbar', wert: _jaNein(d['deklinierbar'])),
        Zeile(
            label: 'Beispiel dekliniert',
            wert: d['deklinationsbeispiel'] as String?),
        Zeile(label: 'Schreibweise', wert: d['schreibweise'] as String?),
      ]),
      _musterListe(context, 'Feste Wendungen', d['feste_wendungen'],
          musterKey: 'wendung'),
    ]);
  }

  Widget _praeposition(BuildContext context) {
    final d = _d;
    final wechsel = (d['wechsel_beispielpaar'] as Map?)?.cast<String, dynamic>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Kasus', wert: d['kasus'] as String?),
        Zeile(label: 'Verschmelzungen', wert: _liste(d['verschmelzungen'])),
        Zeile(label: 'Kontrast', wert: d['kontrast'] as String?),
      ]),
      if (d['kasus'] == 'wechsel' && wechsel != null)
        Sektion(titel: 'Wechselpräposition', children: [
          BeispielBlock(
              badge: 'Wohin? → Akkusativ',
              satz: wechsel['wohin_akk'] as String? ?? ''),
          BeispielBlock(
              badge: 'Wo? → Dativ', satz: wechsel['wo_dat'] as String? ?? ''),
        ]),
      _musterListe(context, 'Bedeutungen', d['bedeutungen'],
          musterKey: 'kategorie'),
      _musterListe(context, 'Feste Verbindungen', d['feste_verbindungen']),
    ]);
  }

  Widget _konjunktion(BuildContext context) {
    final d = _d;
    final paar = (d['beispielsatz_paar'] as Map?)?.cast<String, dynamic>();
    final alternativen = (d['alternativen'] as List?)?.cast<Map>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Grammatik', children: [
        Zeile(label: 'Untertyp', wert: d['untertyp'] as String?),
        Zeile(label: 'Wortstellung', wert: d['wortstellung'] as String?),
        Zeile(label: 'Bedeutung', wert: d['bedeutungskategorie'] as String?),
      ]),
      if (paar != null)
        Sektion(titel: 'Satzpaar', children: [
          BeispielBlock(satz: paar['satz1'] as String? ?? ''),
          BeispielBlock(satz: paar['satz2'] as String? ?? ''),
        ]),
      if (alternativen != null && alternativen.isNotEmpty)
        Sektion(titel: 'Alternativen', children: [
          for (final a in alternativen)
            BeispielBlock(
              badge:
                  '${a['wort'] ?? ''} · ${a['wortstellung'] ?? ''}'.trim(),
              satz: a['hinweis'] as String? ?? '',
            ),
        ]),
    ]);
  }

  Widget _adverb() {
    final d = _d;
    return Sektion(titel: 'Grammatik', children: [
      Zeile(label: 'Untertyp', wert: d['untertyp'] as String?),
      Zeile(label: 'Position', wert: d['position'] as String?),
      Zeile(label: 'Steigerbar', wert: _jaNein(d['steigerbar'])),
      Zeile(label: 'Steigerung', wert: d['steigerung'] as String?),
      Zeile(
          label: 'Abgrenzung Adjektiv',
          wert: d['abgrenzung_adjektiv'] as String?),
    ]);
  }

  Widget _partikel(BuildContext context) {
    final d = _d;
    final vergleich =
        (d['vergleich_ohne_partikel'] as Map?)?.cast<String, dynamic>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Sektion(titel: 'Funktion', children: [
        Zeile(label: 'Untertyp', wert: d['untertyp'] as String?),
        Zeile(label: 'Register', wert: d['register'] as String?),
        BeispielBlock(satz: d['funktion'] as String? ?? ''),
      ]),
      _musterListe(context, 'Satzmuster', d['satzmuster']),
      if (vergleich != null)
        Sektion(titel: 'Mit vs. ohne Partikel', children: [
          BeispielBlock(badge: 'ohne', satz: vergleich['ohne'] as String? ?? ''),
          BeispielBlock(badge: 'mit', satz: vergleich['mit'] as String? ?? ''),
          BeispielBlock(satz: vergleich['unterschied'] as String? ?? ''),
        ]),
    ]);
  }
}
