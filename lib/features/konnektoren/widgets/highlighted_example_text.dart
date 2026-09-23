// FILE: lib/features/konnektoren/widgets/highlighted_example_text.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/deutsch_text.dart';

/// Highlights [highlight] substring inside [sentence] with accent colour.
/// Falls back to plain text if substring not found (case-sensitive search).
class HighlightedExampleText extends StatelessWidget {
  const HighlightedExampleText({
    super.key,
    required this.sentence,
    required this.highlight,
    this.style,
  });

  final String sentence;
  final String highlight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base    = style ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final accent  = Theme.of(context).colorScheme.primary;

    if (highlight.isEmpty) {
      return DeutschText(sentence, style: base);
    }

    final idx = sentence.indexOf(highlight);
    if (idx == -1) {
      return DeutschText(sentence, style: base);
    }

    final before = sentence.substring(0, idx);
    final match  = sentence.substring(idx, idx + highlight.length);
    final after  = sentence.substring(idx + highlight.length);

    return DeutschRichText(
      TextSpan(
        style   : base,
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline : TextBaseline.alphabetic,
            child    : Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color       : accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: DeutschText(
                match,
                ganzeZeile: false, // Wort mitten im Satz
                style: base.copyWith(
                  color     : accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}
