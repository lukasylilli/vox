// FILE: lib/features/lesen/widgets/word_popup_card.dart
// DEPS: lesen_controller.dart (wordLookupProvider), tts_service.dart, leitner_add_button.dart
// PURPOSE: Bottom sheet shown when user taps a word in the reader
//          Shows: article+word, meaning, TTS, LeitnerAddButton, "not in DB" message
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/article_badge.dart';
import '../../../core/widgets/leitner_add_button.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../controllers/lesen_controller.dart';
import '../../../core/widgets/vox_button.dart';

/// Opens a bottom sheet popup for the given [rawWord] (as tapped in reader).
Future<void> showWordPopup(BuildContext context, String rawWord) {
  final clean = _cleanWord(rawWord);
  if (clean.isEmpty) return Future.value();
  return showModalBottomSheet(
    context           : context,
    isScrollControlled: true,
    shape             : const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _WordPopupSheet(word: clean),
  );
}

String _cleanWord(String raw) =>
    raw.replaceAll(RegExp(r'^[^a-zA-ZäöüÄÖÜß]+|[^a-zA-ZäöüÄÖÜß]+$'), '');

class _WordPopupSheet extends ConsumerWidget {
  const _WordPopupSheet({required this.word});
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordLookupProvider(word));
    final tts       = ref.watch(ttsServiceProvider);
    final theme     = Theme.of(context);
    final scheme    = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color       : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            wordAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (_, _) => _NotFound(word: word),
              data   : (found) {
                if (found == null) return _NotFound(word: word);
                final model = found.toModel();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Word + article badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.german,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (model.article != null) ...[
                          ArticleBadge(article: model.article, large: true),
                          const SizedBox(width: 8),
                        ],
                        // TTS button
                        VoxIconButton.filled(
                          icon     : tts.isPlayingText(model.displayGerman)
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          onPressed: () => ref
                              .read(ttsServiceProvider.notifier)
                              .toggle(model.displayGerman),
                        ),
                      ],
                    ),

                    if (model.plural != null)
                      Text('Pl. ${model.plural}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        )),

                    const SizedBox(height: AppSizes.md),
                    const Divider(),
                    const SizedBox(height: AppSizes.sm),

                    // Meaning — nur aktive Zweitsprache (فاز L)
                    Text(
                      AppL10n.meaning(context,
                          fa: model.meaningFa,
                          en: model.meaningEn ?? model.meaningFa),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),

                    const SizedBox(height: AppSizes.lg),

                    // Actions
                    Row(
                      children: [
                        LeitnerAddButton(wordId: model.id),
                        const Spacer(),
                        VoxButton.text(
                          label    : AppL10n.t(context, 'close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(word, style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Icon(Icons.search_off_rounded, color: scheme.onSurfaceVariant, size: 18),
            const SizedBox(width: 6),
            Text(AppL10n.t(context, 'not_in_dictionary'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              )),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        VoxButton.text(
          label    : AppL10n.t(context, 'close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
