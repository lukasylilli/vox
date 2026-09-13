// FILE: lib/core/utils/formatters.dart
// STATUS: [x] LIVE (B2 — 2026-07-04)
// PURPOSE: Central formatting — Persian digits, counts, percent, dates,
//          durations. Screens never build these strings by hand.

abstract final class Formatters {
  /// فاز L: von app.dart bei Locale-Wechsel gesetzt — steuert Ziffern & Datumstexte.
  static bool useFa = true;

  // ── Persian digits ─────────────────────────────────────────────────────────

  static const _fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  /// 908 → '۹۰۸'
  static String faDigits(int n) => faDigitsStr(n.toString());

  /// Locale-aware: FA-Modus '۹۰۸', EN-Modus '908' — für UI-Zahlen verwenden.
  static String digits(int n) => useFa ? faDigits(n) : n.toString();

  /// '3/10' → '۳/۱۰' (non-digit chars pass through)
  static String faDigitsStr(String s) {
    final b = StringBuffer();
    for (final code in s.codeUnits) {
      if (code >= 0x30 && code <= 0x39) {
        b.write(_fa[code - 0x30]);
      } else {
        b.writeCharCode(code);
      }
    }
    return b.toString();
  }

  /// '۹۰۸' → '908' (reverse, for parsing user input)
  static String enDigits(String s) {
    final b = StringBuffer();
    for (final rune in s.runes) {
      // Persian ۰-۹ = U+06F0–U+06F9, Arabic ٠-٩ = U+0660–U+0669
      if (rune >= 0x06F0 && rune <= 0x06F9) {
        b.writeCharCode(0x30 + (rune - 0x06F0));
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        b.writeCharCode(0x30 + (rune - 0x0660));
      } else {
        b.writeCharCode(rune);
      }
    }
    return b.toString();
  }

  // ── Counts & labels ────────────────────────────────────────────────────────

  /// (908, 'عبارت') → '۹۰۸ عبارت'
  static String countLabel(int n, String unitFa) => '${faDigits(n)} $unitFa';

  /// (3, 10) → '۳ / ۱۰' — quiz progress
  static String outOf(int current, int total) =>
      '${faDigits(current)} / ${faDigits(total)}';

  /// 0.75 → '۷۵٪'
  static String percent(double p) =>
      '${faDigits((p * 100).round())}${useFa ? '٪' : '%'}';

  // ── Dates ──────────────────────────────────────────────────────────────────

  /// امروز / دیروز / ۳ روز پیش / ۲ هفته پیش / ۳ ماه پیش
  static String relativeDate(DateTime d, {DateTime? now}) {
    final ref  = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final day   = DateTime(d.year, d.month, d.day);
    final diff  = today.difference(day).inDays;

    if (diff <= 0) return useFa ? 'امروز' : 'Today';
    if (diff == 1) return useFa ? 'دیروز' : 'Yesterday';
    if (diff < 7) return useFa ? '${faDigits(diff)} روز پیش' : '$diff days ago';
    if (diff < 30) return useFa ? '${faDigits(diff ~/ 7)} هفته پیش' : '${diff ~/ 7} weeks ago';
    if (diff < 365) return useFa ? '${faDigits(diff ~/ 30)} ماه پیش' : '${diff ~/ 30} months ago';
    return useFa ? '${faDigits(diff ~/ 365)} سال پیش' : '${diff ~/ 365} years ago';
  }

  // ── Durations ──────────────────────────────────────────────────────────────

  /// Duration(minutes: 25) → '۲۵ دقیقه'
  static String minutesLabel(Duration d) => useFa ? '${faDigits(d.inMinutes)} دقیقه' : '${d.inMinutes} min';

  /// Duration(seconds: 95) → '۰۱:۳۵' (timer display)
  static String timer(Duration d) {
    final m = (d.inMinutes).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return faDigitsStr('$m:$s');
  }
}
