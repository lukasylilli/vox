// FILE: tool/zurueckgestellt.dart
// PURPOSE: Die zurückgestellten Wörter haben EINE Quelle:
//          tool/daten/zurueckgestellt.json (Audit 2026-11-11, Paket 5).
//          Vorher standen sie von Hand an drei Stellen, die «immer gleich»
//          sein sollten — und es nicht mehr waren («befleißen» fehlte in der
//          Tabelle).
//
//   dart tool/zurueckgestellt.dart            # docs/ZURUECKGESTELLT.md neu schreiben
//   dart tool/zurueckgestellt.dart --pruefen  # nur prüfen (exit 1, wenn veraltet)
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
