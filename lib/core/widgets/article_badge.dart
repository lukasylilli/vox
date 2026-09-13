// FILE: lib/core/widgets/article_badge.dart
// PURPOSE: Colored pill showing der/die/das — used on word cards and detail screen
import 'package:flutter/material.dart';
import '../constants/article_colors.dart';

class ArticleBadge extends StatelessWidget {
  const ArticleBadge({super.key, required this.article, this.large = false});

  final String? article;
  final bool    large;

  @override
  Widget build(BuildContext context) {
    if (article == null || article!.isEmpty) return const SizedBox.shrink();

    final color    = ArticleColors.forString(article);
    final fontSize = large ? 14.0 : 11.0;
    final padding  = large
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 7, vertical: 2);

    return Container(
      padding   : padding,
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.15),
        border      : Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        article!,
        style: TextStyle(
          color     : color,
          fontSize  : fontSize,
          fontWeight: FontWeight.w700,
          height    : 1,
        ),
      ),
    );
  }
}
