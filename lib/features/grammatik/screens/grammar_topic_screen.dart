// FILE: lib/features/grammatik/screens/grammar_topic_screen.dart
// PURPOSE: EIN generischer Screen für alle eigenständigen Grammatik-Themen
//          (Passiv, zu/dass, Tempusformen, Kasus, Modalverben, ...).
//          Level-Sektionen (VoxBadge.level) aufklappbar; Sprache (FA/EN)
//          folgt der App-Sprache aus den Einstellungen.
//          route: /grammatik/thema/:topicId — Themen in grammar_topic.dart.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/vox_badge.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../../../core/widgets/vox_error_widget.dart';
import '../../../core/widgets/vox_loading_widget.dart';
import '../models/grammar_topic.dart';
import '../../../core/widgets/deutsch_text.dart';

final grammarTopicProvider =
    FutureProvider.family<List<GrammarTopicSection>, String>((ref, asset) async {
  final raw  = await rootBundle.loadString(asset);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return (json['sections'] as List)
      .cast<Map<String, dynamic>>()
      .map(GrammarTopicSection.fromJson)
      .toList();
});

class GrammarTopicScreen extends ConsumerWidget {
  const GrammarTopicScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = grammarTopics[topicId];
    if (meta == null) {
      return Scaffold(
        appBar: AppBar(),
        body  : const VoxEmptyState.noData(),
      );
    }

    final sectionsAsync = ref.watch(grammarTopicProvider(meta.assetPath));

    return Scaffold(
      appBar: AppBar(title: DeutschText(meta.titleDe, ganzeZeile: false)),
      body: sectionsAsync.when(
        loading: () => const VoxLoadingWidget(),
        error  : (e, _) => VoxErrorWidget(error: e),
        data   : (sections) => ListView.builder(
          padding    : const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
          itemCount  : sections.length,
          itemBuilder: (_, i) =>
              _SectionCard(section: sections[i], initiallyExpanded: i == 0),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    this.initiallyExpanded = false,
  });

  final GrammarTopicSection section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isEn  = Localizations.localeOf(context).languageCode == 'en';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child : ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding      : const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: 2),
        childrenPadding  : const EdgeInsets.fromLTRB(
            AppSizes.md, 0, AppSizes.md, AppSizes.md),
        leading: VoxBadge.level(section.level),
        title  : Text(
          isEn ? section.titleEn : section.titleFa,
          style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? section.explanationEn : section.explanationFa,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          if (section.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width  : double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color       : cs.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final ex in section.examples) ...[
                    Text(
                      ex.de,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isEn ? ex.en : ex.fa,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
