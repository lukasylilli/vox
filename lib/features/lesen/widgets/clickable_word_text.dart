// FILE: lib/features/lesen/widgets/clickable_word_text.dart
// DEPS: word_popup_card.dart, readerFontSizeProvider
// PURPOSE: Renders text with each German word tappable → shows WordPopupCard
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/lesen_controller.dart';
import 'word_popup_card.dart';

class ClickableWordText extends ConsumerWidget {
  const ClickableWordText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(readerFontSizeProvider);
    final theme    = Theme.of(context);
    final scheme   = theme.colorScheme;

    final spans = _buildSpans(
      text     : text,
      style    : theme.textTheme.bodyLarge!.copyWith(
        fontSize: fontSize,
        height  : 1.9,
      ),
      wordStyle: theme.textTheme.bodyLarge!.copyWith(
        fontSize : fontSize,
        height   : 1.9,
        color    : scheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: scheme.primary.withValues(alpha: 0.4),
      ),
      onTap: (word) => showWordPopup(context, word),
    );

    return SelectableText.rich(
      TextSpan(children: spans),
      contextMenuBuilder: (ctx, editableState) =>
          AdaptiveTextSelectionToolbar.editableText(
        editableTextState: editableState,
      ),
    );
  }

  List<TextSpan> _buildSpans({
    required String        text,
    required TextStyle     style,
    required TextStyle     wordStyle,
    required void Function(String) onTap,
  }) {
    // Split text into tokens: words, whitespace, punctuation
    final tokenRegex = RegExp(r'[a-zA-ZäöüÄÖÜß]+|[^\S\n]+|\n|[^a-zA-ZäöüÄÖÜß\s]');
    final tokens     = tokenRegex.allMatches(text).map((m) => m.group(0)!).toList();
    final wordRegex  = RegExp(r'^[a-zA-ZäöüÄÖÜß]+$');

    return tokens.map((token) {
      if (wordRegex.hasMatch(token)) {
        return TextSpan(
          text      : token,
          style     : wordStyle,
          recognizer: TapGestureRecognizer()..onTap = () => onTap(token),
        );
      }
      return TextSpan(text: token, style: style);
    }).toList();
  }
}
