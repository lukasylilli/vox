// FILE: lib/features/vokabular/widgets/kasus_beispiel_block.dart
// PURPOSE: Extra-Box der Wort-Seite NUR für Dativ/Akkusativ-Verben (Deck-spezifisch).
//          Färbt im Beispielsatz genau die annotierten Phrasen:
//          Dativ = blau, Akkusativ = lila. Rein datengetrieben (kein Raten):
//          die Phrasen stehen wörtlich im Feld card['kasus_beispiele'].
import 'package:flutter/material.dart';
import '../../../core/widgets/deutsch_text.dart';

class KasusBeispielBlock extends StatelessWidget {
  const KasusBeispielBlock({
    super.key,
    required this.satz,
    this.dativ = const [],
    this.akkusativ = const [],
    this.uebersetzung,
  });

  final String       satz;
  final List<String> dativ;
  final List<String> akkusativ;
  final String?      uebersetzung;

  static const _datLight = Color(0xFF1565C0);
  static const _akkLight = Color(0xFF6A1B9A);
  static const _datDark  = Color(0xFF82B1FF);
  static const _akkDark  = Color(0xFFCE93D8);

  @override
  Widget build(BuildContext context) {
    if (satz.isEmpty) return const SizedBox.shrink();
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final datColor = isDark ? _datDark : _datLight;
    final akkColor = isDark ? _akkDark : _akkLight;

    final base = theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500) ??
        const TextStyle();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeutschRichText(
              TextSpan(children: _spans(base, datColor, akkColor))),
          if (uebersetzung != null && uebersetzung!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(uebersetzung!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }

  List<TextSpan> _spans(TextStyle base, Color datColor, Color akkColor) {
    final marks = <_Mark>[];
    for (final p in dativ) {
      final idx = _findPhrase(satz, p);
      if (idx >= 0) marks.add(_Mark(idx, idx + p.length, datColor));
    }
    for (final p in akkusativ) {
      final idx = _findPhrase(satz, p);
      if (idx >= 0) marks.add(_Mark(idx, idx + p.length, akkColor));
    }
    if (marks.isEmpty) return [TextSpan(text: satz, style: base)];
    marks.sort((a, b) => a.start.compareTo(b.start));

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in marks) {
      if (m.start < cursor) continue;
      if (m.start > cursor) {
        spans.add(TextSpan(text: satz.substring(cursor, m.start), style: base));
      }
      spans.add(TextSpan(
        text : satz.substring(m.start, m.end),
        style: base.copyWith(
          color          : m.color,
          backgroundColor: m.color.withValues(alpha: 0.12),
          fontWeight     : FontWeight.w700,
        ),
      ));
      cursor = m.end;
    }
    if (cursor < satz.length) {
      spans.add(TextSpan(text: satz.substring(cursor), style: base));
    }
    return spans;
  }

  /// Findet `phrase` an einer Wortgrenze; -1 wenn nicht gefunden.
  int _findPhrase(String s, String phrase) {
    var from = 0;
    while (true) {
      final idx = s.indexOf(phrase, from);
      if (idx < 0) return -1;
      final beforeOk = idx == 0 || !_isWordChar(s[idx - 1]);
      final afterPos = idx + phrase.length;
      final afterOk  = afterPos >= s.length || !_isWordChar(s[afterPos]);
      if (beforeOk && afterOk) return idx;
      from = idx + 1;
    }
  }

  bool _isWordChar(String c) => RegExp(r'[0-9A-Za-zÀ-ÿ]').hasMatch(c);
}

/// Kleine Farb-Legende (Dativ ● blau · Akkusativ ● lila).
class KasusLegende extends StatelessWidget {
  const KasusLegende({super.key, this.showDativ = true, this.showAkkusativ = true});

  final bool showDativ;
  final bool showAkkusativ;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dat = isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
    final akk = isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (showDativ) ...[
            _dot(dat),
            const SizedBox(width: 4),
            const Text('Dativ', style: TextStyle(fontSize: 11)),
          ],
          if (showDativ && showAkkusativ) const SizedBox(width: 14),
          if (showAkkusativ) ...[
            _dot(akk),
            const SizedBox(width: 4),
            const Text('Akkusativ', style: TextStyle(fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _Mark {
  const _Mark(this.start, this.end, this.color);
  final int   start;
  final int   end;
  final Color color;
}
