// FILE: tool/vokab_qualitaet.dart
// PHASE: Q.2 — Qualitätsprüfung der Wortkarten (PLAN.md → «🔍 فاز Q»).
//
// Prüft den INHALT der Karten in assets/vocab/ auf Fehler, die
// vokabPruefeKarte (vokab_schema.dart) bewusst nicht prüft: dort steht nur die
// STRUKTUR (Pflichtfelder, id, Zielwort im Satz). Dieses Werkzeug ist ein
// reiner Bericht — es schreibt nichts und bricht keinen Build. Treffer sind
// Hinweise zum Nachsehen, keine sicheren Fehler; die Entscheidung trifft der
// Mensch bzw. Claude beim Lesen der Karte.
//
// Aufruf (im Repo-Ordner):
//   dart run tool/vokab_qualitaet.dart                 # alle Karten
//   dart run tool/vokab_qualitaet.dart --liste f.txt   # nur Pfade aus f.txt
//   dart run tool/vokab_qualitaet.dart --alle          # alle Treffer zeigen
//
// Einzige Quelle für Struktur/ID bleibt vokab_schema.dart; hier wird nichts
// davon dupliziert, nur zusätzliche Inhaltsregeln des Wort-Prompts (TEIL 0):
//   9  Beispiele: genau 2, erstes A1/A2, zweites B1/B2
//   10 Synonyme/Antonyme ≠ Zielwort, max. 3
//   2  fa-Felder persisch, en-Felder ohne persische Schrift
//   ADJEKTIV: Steigerung vollständig oder ganz null; Superlativ «am …(s)ten»;
//             gegensatzpaar «wort ↔ gegenteil»
//   13 Wortnetz verweist nicht auf die Karte selbst, keine Doppelten
import 'dart:convert';
import 'dart:io';

final _persisch = RegExp(r'[\u0600-\u06FF]');
// Drei lateinische Buchstaben hintereinander = vermutlich ein deutsches/
// englisches Wort in einem persischen Text.
final _latein = RegExp(r'[A-Za-zÄÖÜäöüß]{3,}');

void main(List<String> args) {
  final alle = args.contains('--alle');
  final listeIdx = args.indexOf('--liste');
  List<File> dateien;
  if (listeIdx >= 0 && listeIdx + 1 < args.length) {
    dateien = File(args[listeIdx + 1])
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map(File.new)
        .toList();
  } else {
    dateien = Directory('assets/vocab')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
  }
  dateien.sort((a, b) => a.path.compareTo(b.path));

  final treffer = <String, List<String>>{};
  void melde(String regel, String id, [String detail = '']) =>
      (treffer[regel] ??= []).add(detail.isEmpty ? id : '$id — $detail');

  for (final datei in dateien) {
    if (!datei.existsSync()) {
      melde('Datei fehlt', datei.path);
      continue;
    }
    Map<String, dynamic> k;
    try {
      k = jsonDecode(datei.readAsStringSync()) as Map<String, dynamic>;
    } on FormatException catch (e) {
      melde('JSON kaputt', datei.path, e.message);
      continue;
    }
    _pruefe(k, melde);
  }

  stdout.writeln('════ Qualitätsbericht (${dateien.length} Karten) ════');
  if (treffer.isEmpty) {
    stdout.writeln('Keine Hinweise.');
    return;
  }
  final regeln = treffer.keys.toList()..sort();
  for (final r in regeln) {
    final liste = treffer[r]!;
    stdout.writeln('\n── $r: ${liste.length}');
    for (final t in alle ? liste : liste.take(15)) {
      stdout.writeln('   $t');
    }
    if (!alle && liste.length > 15) {
      stdout.writeln('   … (${liste.length - 15} weitere, --alle zeigt alle)');
    }
  }
  final summe = treffer.values.fold<int>(0, (s, l) => s + l.length);
  stdout.writeln('\nHinweise gesamt: $summe');
}

void _pruefe(
  Map<String, dynamic> k,
  void Function(String, String, [String]) melde,
) {
  final id = k['id'] as String? ?? '?';
  final wort = (k['wort'] as String? ?? '').trim();
  final wortart = k['wortart'] as String? ?? '';
  final lemma = _ohneArtikel(wort).toLowerCase();

  // Übersetzung (Regel 2)
  final ue = k['uebersetzung'];
  if (ue is Map) {
    final fa = (ue['fa'] as List?)?.cast<Object?>() ?? const [];
    final en = (ue['en'] as List?)?.cast<Object?>() ?? const [];
    for (final f in fa) {
      final s = '$f';
      if (!_persisch.hasMatch(s)) {
        melde('fa-Übersetzung ohne persische Schrift', id, s);
      }
      if (_latein.hasMatch(s)) melde('Latein in fa-Übersetzung', id, s);
    }
    for (final e in en) {
      if (_persisch.hasMatch('$e')) {
        melde('Persisch in en-Übersetzung', id, '$e');
      }
    }
    if (fa.toSet().length < fa.length) melde('fa-Übersetzung doppelt', id);
    if (en.toSet().length < en.length) melde('en-Übersetzung doppelt', id);
  }

  // IPA
  final ipa = k['ipa'];
  if (ipa is! String || ipa.trim().isEmpty) {
    melde('IPA fehlt', id);
  } else if (RegExp(r'[0-9/\[\]]').hasMatch(ipa)) {
    melde('IPA mit Ziffern/Klammern/Schrägstrich', id, ipa);
  }

  // Beispiele (Regel 9)
  final beispiele = (k['beispiele'] as List?) ?? const [];
  final saetze = <String>{};
  for (var i = 0; i < beispiele.length; i++) {
    final b = beispiele[i] as Map;
    final satz = '${b['satz'] ?? ''}';
    final niveau = '${b['niveau'] ?? ''}';
    if (!saetze.add(satz)) melde('Beispiel doppelt', id, satz);
    if (i == 0 && !const {'A1', 'A2'}.contains(niveau)) {
      melde('1. Beispiel nicht A1/A2', id, niveau);
    }
    if (i == 1 && !const {'B1', 'B2'}.contains(niveau)) {
      melde('2. Beispiel nicht B1/B2', id, niveau);
    }
    final bu = b['uebersetzung'];
    if (bu is Map) {
      final fa = '${bu['fa'] ?? ''}';
      final en = '${bu['en'] ?? ''}';
      if (!_persisch.hasMatch(fa)) {
        melde('fa-Satz ohne persische Schrift', id, fa);
      }
      if (_persisch.hasMatch(en)) melde('Persisch im en-Satz', id, en);
      if (en.trim() == satz.trim()) melde('en-Satz = deutscher Satz', id, satz);
    }
  }

  // Synonyme / Antonyme (Regel 10)
  for (final feld in const ['synonyme', 'antonyme']) {
    final l = (k[feld] as List?) ?? const [];
    if (l.length > 3) melde('$feld: mehr als 3', id, '${l.length}');
    for (final e in l) {
      final w = _ohneArtikel('${(e as Map)['wort'] ?? ''}').toLowerCase();
      if (w == lemma) melde('$feld enthält das Zielwort', id);
    }
  }
  final syn = ((k['synonyme'] as List?) ?? const [])
      .map((e) => '${(e as Map)['wort']}'.toLowerCase())
      .toSet();
  final ant = ((k['antonyme'] as List?) ?? const [])
      .map((e) => '${(e as Map)['wort']}'.toLowerCase())
      .toSet();
  final beide = syn.intersection(ant);
  if (beide.isNotEmpty) {
    melde('Wort ist Synonym UND Antonym', id, beide.join(', '));
  }

  // Adjektiv-Details
  final details = k['details'];
  if (wortart == 'adjektiv' && details is Map) {
    final st = details['steigerung'];
    if (st is Map) {
      final komp = st['komparativ'];
      final sup = st['superlativ'];
      if ((komp == null) != (sup == null)) {
        melde('Steigerung halb leer', id, 'komp=$komp, sup=$sup');
      }
      if (komp is String && !komp.endsWith('er')) {
        melde('Komparativ endet nicht auf -er', id, komp);
      }
      // «am größten» endet auf ß + -ten, deshalb -ten statt -sten.
      if (sup is String && !(sup.startsWith('am ') && sup.endsWith('ten'))) {
        melde('Superlativ nicht «am …(s)ten»', id, sup);
      }
      final reg = details['steigerung_regelmaessig'];
      if (komp == null && reg == true) {
        melde('regelmäßig=true ohne Steigerung', id);
      }
    }
    final gp = details['gegensatzpaar'];
    if (gp is String) {
      final teile = gp.split('↔');
      if (teile.length != 2) {
        melde('gegensatzpaar ohne «↔»', id, gp);
      } else if (teile.first.trim().toLowerCase() != lemma) {
        melde('gegensatzpaar beginnt nicht mit dem Wort', id, gp);
      }
    }
  }

  // Wortnetz (Regel 13)
  final netz = k['wortnetz'];
  if (netz is Map) {
    final woerter = (netz['woerter'] as List?) ?? const [];
    final refs = <String>{};
    for (final w in woerter) {
      final ref = '${(w as Map)['id_ref'] ?? ''}';
      if (ref == id) melde('Wortnetz verweist auf sich selbst', id);
      if (!refs.add(ref)) melde('Wortnetz-Eintrag doppelt', id, ref);
    }
  }
}

String _ohneArtikel(String wort) {
  final teile = wort.trim().split(' ');
  if (teile.length > 1 &&
      const {'der', 'die', 'das'}.contains(teile.first.toLowerCase())) {
    return teile.sublist(1).join(' ');
  }
  return wort.trim();
}
