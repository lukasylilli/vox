// FILE: lib/features/dativ_verben/widgets/case_highlight_text.dart
//
// Färbt Dativ (blau) und Akkusativ (lila) im Beispielsatz.
// PRIMÄR datengetrieben: liegt `caseRoles` vor, werden GENAU die dort
// genannten Phrasen gefärbt (deterministisch, korrekt).
// FALLBACK: ohne Annotation greift die alte Pronomen-/Artikel-Heuristik.
import 'package:flutter/material.dart';
import '../models/dativ_verb.dart';

class CaseHighlightText extends StatelessWidget {
  const CaseHighlightText({
    super.key,
    required this.sentence,
    required this.caseType,
    this.caseRoles,
    this.style,
  });

  final String     sentence;
  final CaseType   caseType;
  final CaseRoles? caseRoles;
  final TextStyle? style;

  // Farbpalette (identisch zu CaseTypeBadge)
  static const _datLight = Color(0xFF1565C0);
  static const _akkLight = Color(0xFF6A1B9A);
  static const _datDark  = Color(0xFF82B1FF);
  static const _akkDark  = Color(0xFFCE93D8);

  // Pronomen / Artikel für den Heuristik-Fallback
  static const _dativPronouns = {
    'mir', 'dir', 'ihm', 'ihr', 'uns', 'euch', 'ihnen',
    'dem', 'der', 'den', 'einem', 'einer',
  };
  static const _akkusativPronouns = {
    'mich', 'dich', 'ihn', 'sie', 'uns', 'euch',
    'den', 'die', 'das', 'einen', 'eine', 'ein',
  };

  @override
  Widget build(BuildContext context) {
    final base   = style ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final datColor = isDark ? _datDark : _datLight;
    final akkColor = isDark ? _akkDark : _akkLight;

    final spans = (caseRoles != null && !caseRoles!.isEmpty)
        ? _annotatedSpans(base, datColor, akkColor)
        : _heuristicSpans(base, datColor, akkColor);

    return RichText(text: TextSpan(children: spans));
  }

  // ─── Datengetrieben: exakte Phrasen aus caseRoles färben ──────────────────

  List<TextSpan> _annotatedSpans(TextStyle base, Color datColor, Color akkColor) {
    // Intervalle [start, end) im Satz + Farbe sammeln
    final marks = <_Mark>[];
    for (final p in caseRoles!.dativ) {
      final idx = _findPhrase(sentence, p);
      if (idx >= 0) marks.add(_Mark(idx, idx + p.length, datColor));
    }
    for (final p in caseRoles!.akkusativ) {
      final idx = _findPhrase(sentence, p);
      if (idx >= 0) marks.add(_Mark(idx, idx + p.length, akkColor));
    }
    if (marks.isEmpty) return [TextSpan(text: sentence, style: base)];

    marks.sort((a, b) => a.start.compareTo(b.start));

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in marks) {
      if (m.start < cursor) continue; // Überlappung ignorieren (sollte nicht vorkommen)
      if (m.start > cursor) {
        spans.add(TextSpan(text: sentence.substring(cursor, m.start), style: base));
      }
      spans.add(TextSpan(
        text : sentence.substring(m.start, m.end),
        style: base.copyWith(
          color          : m.color,
          backgroundColor: m.color.withValues(alpha: 0.12),
          fontWeight     : FontWeight.w700,
        ),
      ));
      cursor = m.end;
    }
    if (cursor < sentence.length) {
      spans.add(TextSpan(text: sentence.substring(cursor), style: base));
    }
    return spans;
  }

  /// Findet `phrase` im Satz an einer Wortgrenze; -1 wenn nicht gefunden.
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

  // ─── Fallback-Heuristik (nur für nicht annotierte Verben) ─────────────────

  List<TextSpan> _heuristicSpans(TextStyle base, Color datColor, Color akkColor) {
    if (caseType == CaseType.akkusativOnlyConfusable) {
      return [TextSpan(text: sentence, style: base)];
    }

    final words = sentence.split(RegExp(r'(\s+)'));
    final spans = <TextSpan>[];

    var i = 0;
    while (i < words.length) {
      final raw   = words[i];
      final lower = raw.toLowerCase().replaceAll(RegExp(r'[?.!,;:]'), '');

      if (raw.trim().isEmpty) {
        spans.add(TextSpan(text: raw, style: base));
        i++;
        continue;
      }

      final isDat = _dativPronouns.contains(lower) && caseType != CaseType.datumOnly
          ? _isDativContext(words, i)
          : _dativPronouns.contains(lower);

      final isAkk = caseType == CaseType.dativAkkusativ &&
          !isDat &&
          _akkusativPronouns.contains(lower) &&
          !_dativPronouns.contains(lower);

      if (isDat) {
        final (group, advance) = _collectGroup(words, i);
        spans.add(TextSpan(
          text : group,
          style: base.copyWith(
            color          : datColor,
            backgroundColor: datColor.withValues(alpha: 0.12),
            fontWeight     : FontWeight.w700,
          ),
        ));
        i += advance;
      } else if (isAkk) {
        final (group, advance) = _collectGroup(words, i);
        spans.add(TextSpan(
          text : group,
          style: base.copyWith(
            color          : akkColor,
            backgroundColor: akkColor.withValues(alpha: 0.10),
            fontWeight     : FontWeight.w700,
          ),
        ));
        i += advance;
      } else {
        spans.add(TextSpan(text: raw, style: base));
        i++;
      }

      if (i < words.length && words[i].trim().isEmpty) {
        spans.add(TextSpan(text: words[i], style: base));
        i++;
      } else if (i < words.length) {
        spans.add(TextSpan(text: ' ', style: base));
      }
    }

    return spans;
  }

  (String, int) _collectGroup(List<String> words, int start) {
    var end = start + 1;
    while (end < words.length && words[end].trim().isEmpty) {
      end++;
    }
    if (end < words.length) {
      final next = words[end];
      final nextLower = next.replaceAll(RegExp(r'[?.!,;:]'), '');
      if (nextLower.isNotEmpty && nextLower[0].toUpperCase() == nextLower[0]) {
        return ('${words[start]} $next', end - start + 1);
      }
    }
    return (words[start], 1);
  }

  bool _isDativContext(List<String> words, int i) {
    final lower = words[i].toLowerCase().replaceAll(RegExp(r'[?.!,;:]'), '');
    const unambiguousDat = {'mir', 'dir', 'ihm', 'ihr', 'uns', 'euch', 'ihnen',
                             'dem', 'einem'};
    return unambiguousDat.contains(lower);
  }
}

class _Mark {
  const _Mark(this.start, this.end, this.color);
  final int   start;
  final int   end;
  final Color color;
}
