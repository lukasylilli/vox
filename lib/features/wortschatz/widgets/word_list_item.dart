// FILE: lib/features/wortschatz/widgets/word_list_item.dart
// DEPS: article_color_indicator.dart, article_badge.dart, word_model.dart
// PURPOSE: One row in a word list — color bar, article badge, german, meaning, level chip
import 'package:flutter/material.dart';
import '../../../core/models/word_model.dart';
import '../../../core/widgets/article_badge.dart';
import '../../../core/widgets/vox_badge.dart';
import 'article_color_indicator.dart';
import '../../../core/l10n/app_l10n.dart';

// common prepositions that may appear as suffix in german field
const _kPrepositions = {
  'für', 'auf', 'an', 'über', 'mit', 'von', 'zu', 'bei',
  'nach', 'aus', 'in', 'um', 'gegen', 'ohne', 'durch',
  'bis', 'vor', 'hinter', 'neben', 'zwischen', 'gegenüber',
};

String stripPreposition(String german) {
  final parts = german.split(' ');
  if (parts.length >= 2 &&
      _kPrepositions.contains(parts.last.toLowerCase())) {
    return parts.sublist(0, parts.length - 1).join(' ');
  }
  return german;
}

class WordListItem extends StatelessWidget {
  const WordListItem({
    super.key,
    required this.word,
    required this.onTap,
  });

  final WordModel    word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap       : onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                ArticleColorIndicator(article: word.article),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // German word — preposition stripped for list display
                            Expanded(
                              child: Text(
                                stripPreposition(word.german),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Article badge
                            if (word.article != null) ...[
                              const SizedBox(width: 8),
                              ArticleBadge(article: word.article),
                            ],
                            // Level chip
                            if (word.level != null) ...[
                              const SizedBox(width: 6),
                              VoxBadge.level(word.level!.label, small: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Meaning — aktive Zweitsprache (فاز L)
                        Text(
                          AppL10n.meaning(context,
                              fa: word.meaningFa,
                              en: word.meaningEn ?? word.meaningFa),
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Plural (if Nomen)
                        if (word.plural != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${AppL10n.t(context, 'plural_label')} ${word.plural}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

