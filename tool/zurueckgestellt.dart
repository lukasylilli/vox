// FILE: tool/zurueckgestellt.dart
// PURPOSE: Die zurückgestellten Wörter haben EINE Quelle:
//          tool/daten/zurueckgestellt.json (Audit 2026-11-11, Paket 5).
//          Vorher standen sie von Hand an drei Stellen, die «immer gleich»
//          sein sollten — und es nicht mehr waren («befleißen» fehlte in der
//          Tabelle).
//
//   dart tool/zurueckgestellt.dart            # docs/ZURUECKGESTELLT.md neu schreiben
//   dart tool/zurueckgestellt.dart --pruefen  # nur prüfen (exit 1, wenn veraltet)
//   dart tool/zurueckgestellt.dart --erledigt Wort1 Wort2 …
//                                             # Vier Fälle M6: gebaute Wörter
//                                             # als erledigt markieren (Zeile
//                                             # bleibt, Wort wird nicht mehr
//                                             # übersprungen), Tabelle neu
//
// Neues Wort zurückstellen: EINE Zeile ans Ende der passenden Tabelle in der
// JSON-Datei (tabelle 1 oder 2, fortlaufende nr), dann dieses Werkzeug
// laufen lassen. tool/naechste_woerter.dart liest dieselbe Datei.
import 'dart:convert';
import 'dart:io';

const zurueckgestelltDatei = 'tool/daten/zurueckgestellt.json';
const zurueckgestelltTabelle = 'docs/ZURUECKGESTELLT.md';

/// Alle Einträge in Dateireihenfolge.
List<Map<String, dynamic>> ladeZurueckgestelltEintraege() {
  final datei = File(zurueckgestelltDatei);
  if (!datei.existsSync()) {
    stderr.writeln('$zurueckgestelltDatei fehlt — im Projektordner starten.');
    exit(1);
  }
  final wurzel = jsonDecode(datei.readAsStringSync()) as Map<String, dynamic>;
  final eintraege = (wurzel['eintraege'] as List).cast<Map<String, dynamic>>();
  final gesehen = <String>{};
  for (final e in eintraege) {
    final wort = e['wort'];
    final tabelle = e['tabelle'];
    if (wort is! String || wort.isEmpty || (tabelle != 1 && tabelle != 2)) {
      stderr.writeln('Ungültiger Eintrag in $zurueckgestelltDatei: $e');
      exit(1);
    }
    for (final feld in ['nr', 'liste', 'datum', 'grund']) {
      if (e[feld] is! String) {
        stderr.writeln('Feld «$feld» fehlt bei «$wort».');
        exit(1);
      }
    }
    if (!gesehen.add(wort)) {
      stderr.writeln('Doppelt in $zurueckgestelltDatei: «$wort».');
      exit(1);
    }
  }
  return eintraege;
}

/// Vier Fälle M6 (Lukas 2026-11-15): [woerter] sind gebaut ⇒ `erledigt: true`.
/// Gibt die Wörter zurück, die es NICHT als offene Zeile gab (Tippfehler,
/// schon erledigt) — der Aufrufer bricht dann ab, statt still zu raten.
List<String> zurueckgestelltErledigen(
    List<Map<String, dynamic>> eintraege, Iterable<String> woerter) {
  final unbekannt = <String>[];
  for (final w in woerter) {
    final e = eintraege
        .where((e) => e['wort'] == w && e['erledigt'] != true)
        .firstOrNull;
    if (e == null) {
      unbekannt.add(w);
    } else {
      e['erledigt'] = true;
    }
  }
  return unbekannt;
}

/// Die nächsten [anzahl] offenen Wörter der Vier-Fälle-Liste (Tabelle 2),
/// in Dateireihenfolge.
List<Map<String, dynamic>> vierFaelleOffen(
        List<Map<String, dynamic>> eintraege, int anzahl) =>
    eintraege
        .where((e) => e['tabelle'] == 2 && e['erledigt'] != true)
        .take(anzahl)
        .toList();

/// Wörter, die `naechste_woerter.dart` überspringt (ohne die erledigten).
Set<String> ladeZurueckgestellt() => {
      for (final e in ladeZurueckgestelltEintraege())
        if (e['erledigt'] != true) e['wort'] as String,
    };

String _zeile(Map<String, dynamic> e) {
  final zellen = [
    e['nr'],
    e['wort'],
    '`${e['liste']}`',
    e['datum'],
    e['grund'],
    if (e['tabelle'] == 1) e['entscheidung'] ?? '—',
  ];
  return '| ${zellen.join(' | ')} |';
}

/// Ein Eintrag in der Schreibweise der Datei: `{"k": v, "k2": v2}` (mit
/// Leerzeichen wie bisher — sonst änderte sich bei jedem Lauf jede Zeile).
String _zeileJson(Map e) =>
    '{${e.entries.map((x) => '${jsonEncode(x.key)}: ${jsonEncode(x.value)}').join(', ')}}';

/// Dateiform wie bisher: Kopf, dann je Eintrag EINE Zeile (kleine Diffs).
String _alsDatei(Map<String, dynamic> wurzel) {
  final b = StringBuffer('{\n');
  for (final k in wurzel.keys.where((k) => k != 'eintraege')) {
    b.writeln('${jsonEncode(k)}: ${jsonEncode(wurzel[k])},');
  }
  final e = wurzel['eintraege'] as List;
  b.writeln('"eintraege": [');
  for (var i = 0; i < e.length; i++) {
    b.writeln('${_zeileJson(e[i] as Map)}${i < e.length - 1 ? ',' : ''}');
  }
  b.writeln(']');
  b.writeln('}');
  return b.toString();
}

/// Der vollständige Text von docs/ZURUECKGESTELLT.md.
String zurueckgestelltAlsTabelle(List<Map<String, dynamic>> eintraege) {
  final t1 = eintraege.where((e) => e['tabelle'] == 1).toList();
  final t2 = eintraege.where((e) => e['tabelle'] == 2).toList();
  final b = StringBuffer()
    ..writeln('# ZURÜCKGESTELLT — کلمه‌هایی که (هنوز) کارت نگرفته‌اند')
    ..writeln()
    ..writeln('> ⚙️ **این فایل ساخته‌ی ابزار است — با دست عوضش نکن.** '
        'تنها منبع: `tool/daten/zurueckgestellt.json`؛ ساختن دوباره: '
        '`dart tool/zurueckgestellt.dart`. (تا 2026-11-11 جدول‌ها با دست در '
        'سه جا نگه داشته می‌شدند.)')
    ..writeln('> قاعده‌ها، دلیل وجود، زمان بررسی و تصمیم‌های Lukas: '
        '`docs/zukunft/WOERTER_ENDSTUFEN.md` و `docs/zukunft/VIER_FAELLE.md`؛ '
        'این‌جا فقط ردیف‌ها.')
    ..writeln('> شمار: جدول ۱ = ${t1.length} ردیف · جدول ۲ = ${t2.length} ردیف · '
        'جمع = ${eintraege.length}.')
    ..writeln()
    ..writeln('## فهرست')
    ..writeln('- [جدول ۱ — 🏁 کلمه‌های ساخته‌نشده (نامطمئن، ناسزا، منسوخ، '
        'فعل دوگانه …)](#جدول-۱)')
    ..writeln('- [جدول ۲ — 📋 فهرست چهار حالت (اسم‌های '
        'چندمعنی/هم‌نویسه/صفت‌گونه)](#جدول-۲)')
    ..writeln()
    ..writeln('<a id="جدول-۱"></a>')
    ..writeln('## جدول ۱ — 🏁 کلمه‌های ساخته‌نشده')
    ..writeln()
    ..writeln('| # | کلمه | فهرست | تاریخ | دلیل | تصمیم Lukas |')
    ..writeln('|---|---|---|---|---|---|');
  t1.map(_zeile).forEach(b.writeln);
  b
    ..writeln()
    ..writeln('<a id="جدول-۲"></a>')
    ..writeln('## جدول ۲ — 📋 فهرست چهار حالت («الف) کلمه‌های فهرست‌ها که '
        'ساخته نشدند»)')
    ..writeln()
    ..writeln('| # | کلمه | فهرست | تاریخ | حالت / دلیل |')
    ..writeln('|---|---|---|---|---|');
  t2.map(_zeile).forEach(b.writeln);
  return b.toString();
}

void main(List<String> args) {
  final eintraege = ladeZurueckgestelltEintraege();
  final i = args.indexOf('--erledigt');
  if (i >= 0) {
    final woerter = args.sublist(i + 1);
    final unbekannt = zurueckgestelltErledigen(eintraege, woerter);
    if (unbekannt.isNotEmpty) {
      stderr.writeln('Keine offene Zeile für: ${unbekannt.join(', ')} — '
          'nichts geändert.');
      exit(1);
    }
    final datei = File(zurueckgestelltDatei);
    final wurzel = jsonDecode(datei.readAsStringSync()) as Map<String, dynamic>;
    wurzel['eintraege'] = eintraege;
    datei.writeAsStringSync(_alsDatei(wurzel));
    File(zurueckgestelltTabelle)
        .writeAsStringSync(zurueckgestelltAlsTabelle(eintraege));
    stdout.writeln('${woerter.length} erledigt; Tabelle neu geschrieben.');
    return;
  }
  final soll = zurueckgestelltAlsTabelle(eintraege);
  final datei = File(zurueckgestelltTabelle);
  final ist = datei.existsSync() ? datei.readAsStringSync() : '';
  if (args.contains('--pruefen')) {
    if (ist != soll) {
      stderr.writeln('$zurueckgestelltTabelle ist veraltet — '
          '`dart tool/zurueckgestellt.dart` ausführen.');
      exit(1);
    }
    stdout.writeln('$zurueckgestelltTabelle ist aktuell '
        '(${eintraege.length} Zeilen).');
    return;
  }
  if (ist == soll) {
    stdout.writeln('$zurueckgestelltTabelle war schon aktuell '
        '(${eintraege.length} Zeilen).');
    return;
  }
  datei.writeAsStringSync(soll);
  stdout.writeln('$zurueckgestelltTabelle geschrieben '
      '(${eintraege.length} Zeilen).');
}
