// FILE: lib/features/lesen/screens/text_reader_screen.dart
// DEPS: lesen_controller.dart, clickable_word_text.dart, reader_toolbar.dart, tts_service.dart
// PURPOSE: Full-screen reader — clickable words + TTS + font size toolbar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/lesen_controller.dart';
import '../widgets/clickable_word_text.dart';
import '../widgets/reader_toolbar.dart';

class TextReaderScreen extends ConsumerWidget {
  const TextReaderScreen({super.key, required this.textId});
  final int textId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAsync = ref.watch(textByIdProvider(textId));

    return textAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('${AppL10n.t(context, 'error')}: $e'))),
      data: (readingText) {
        if (readingText == null) {
          return Scaffold(body: Center(child: Text(AppL10n.t(context, 'text_not_found'))));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(readingText.title),
            bottom: ReaderToolbar(fullText: readingText.content),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    readingText.level.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Clickable text body
                ClickableWordText(text: readingText.content),

                const SizedBox(height: AppSizes.xl),

                // Hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      AppL10n.t(context, 'tap_word_hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}
