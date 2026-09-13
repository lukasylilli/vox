// FILE: lib/features/wortschatz/widgets/article_color_indicator.dart
// PURPOSE: Vertical color bar on left of word list items based on article
import 'package:flutter/material.dart';
import '../../../core/constants/article_colors.dart';

class ArticleColorIndicator extends StatelessWidget {
  const ArticleColorIndicator({super.key, required this.article});

  final String? article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width : 4,
      decoration: BoxDecoration(
        color       : ArticleColors.forString(article),
        borderRadius: const BorderRadius.only(
          topLeft   : Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
    );
  }
}
