// FILE: lib/features/praepositionen/screens/praep_cluster_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_loading_widget.dart';
import '../../../core/widgets/vox_error_widget.dart';
import '../controllers/praepositionen_controller.dart';
import '../models/praep_cluster.dart';
import '../../../core/widgets/vox_button.dart';

class PraepClusterDetailScreen extends ConsumerWidget {
  const PraepClusterDetailScreen({super.key, required this.clusterId});
  final int clusterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(praepClusterProvider);

    return allAsync.when(
      loading: () => const Scaffold(body: VoxLoadingWidget()),
      error  : (e, _) => Scaffold(body: VoxErrorWidget(error: e)),
      data   : (all) {
        final cluster = all.firstWhere(
          (c) => c.id == clusterId,
          orElse: () => all.first,
        );
        final idx = all.indexOf(cluster);

        return Scaffold(
          appBar: AppBar(title: Text(AppL10n.meaning(context, fa: cluster.meaningFa, en: cluster.meaningEn))),
          body: _DetailBody(
            cluster: cluster,
            onPrev : idx > 0
                ? () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => PraepClusterDetailScreen(
                            clusterId: all[idx - 1].id),
                      ),
                    )
                : null,
            onNext : idx < all.length - 1
                ? () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => PraepClusterDetailScreen(
                            clusterId: all[idx + 1].id),
                      ),
                    )
                : null,
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.cluster,
    this.onPrev,
    this.onNext,
  });
  final PraepCluster  cluster;
  final VoidCallback? onPrev, onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c      = cluster;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        // ── Header ───────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppL10n.meaning(context,
                              fa: c.meaningFa, en: c.meaningEn),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                _CefrBadge(level: c.cefrLevel),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // ── Members table ────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.t(context, 'family_members'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSizes.sm),
                ...c.members.map((m) => _MemberRow(member: m, scheme: scheme)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // ── Examples ─────────────────────────────────────────────
        if (c.examples.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'examples'),
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSizes.sm),
                  ...c.examples.map((e) => _ExampleTile(example: e,
                      scheme: scheme)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
        ],

        // ── Navigation ───────────────────────────────────────────
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: VoxButton.secondary(
                label    : AppL10n.t(context, 'previous'),
                icon     : Icons.arrow_back_rounded,
                onPressed: onPrev,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: VoxButton.secondary(
                label    : AppL10n.t(context, 'next'),
                icon     : Icons.arrow_forward_rounded,
                onPressed: onNext,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
      ],
    );
  }
}

// ─── Member row ───────────────────────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.scheme});
  final PraepMember member;
  final ColorScheme scheme;

  static IconData _iconFor(String wc) => switch (wc) {
        'verb'      => Icons.play_arrow_rounded,
        'adjective' => Icons.star_rounded,
        'noun'      => Icons.article_rounded,
        _           => Icons.label_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(_iconFor(member.wordClass),
              size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text : member.lemma,
                style: const TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              const TextSpan(text: '  '),
              TextSpan(
                text : member.preposition,
                style: TextStyle(
                    color     : scheme.primary,
                    fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text : '  +${member.grammaticalCase[0].toUpperCase()}'
                    '${member.grammaticalCase.substring(1)}',
                style: TextStyle(
                    fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ])),
          ),
          if (member.note.isNotEmpty)
            Tooltip(
              message: member.note,
              child  : Icon(Icons.info_outline_rounded,
                  size: 16, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

// ─── Example tile ─────────────────────────────────────────────────────────────

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example, required this.scheme});
  final PraepExample example;
  final ColorScheme  scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HighlightedText(
            sentence : example.de,
            highlight: example.memberPreposition,
            color    : scheme.primary,
          ),
          const SizedBox(height: 2),
          // nur aktive Zweitsprache (فاز L)
          Text(
              AppL10n.meaning(context, fa: example.fa, en: example.en),
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.sentence,
    required this.highlight,
    required this.color,
  });
  final String sentence, highlight;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    final lower  = sentence.toLowerCase();
    final hLower = ' ${highlight.toLowerCase()} ';
    final idx    = lower.indexOf(hLower);

    if (idx == -1) {
      return Text(sentence,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500));
    }
    final start = idx + 1;
    final end   = start + highlight.length;
    return Text.rich(TextSpan(children: [
      if (start > 0) TextSpan(text: sentence.substring(0, start)),
      TextSpan(
        text : sentence.substring(start, end),
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 15),
      ),
      if (end < sentence.length) TextSpan(text: sentence.substring(end)),
    ], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)));
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});
  final String level;

  static Color _color(String level) => VoxColors.cefr(level);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding    : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration : BoxDecoration(
        color       : _color(level).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border      : Border.all(color: _color(level).withValues(alpha: 0.5)),
      ),
      child: Text(
        level,
        style: TextStyle(
            fontSize  : 12,
            fontWeight: FontWeight.w700,
            color     : _color(level)),
      ),
    );
  }
}
