// FILE: lib/features/lesen/screens/news_screen.dart
// DEPS: lesen_controller.dart (rssItemsProvider, rssFeedUrlProvider)
// PURPOSE: RSS news feed — list of items with title + description + copy-link
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/rss_service.dart';
import '../controllers/lesen_controller.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/klick_wort_text.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(rssItemsProvider);
    final feedUrl    = ref.watch(rssFeedUrlProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'news_title')),
        actions: [
          VoxIconButton(
            icon: Icons.swap_horiz_rounded,
            tooltip: AppL10n.t(context, 'change_source'),
            onPressed: () => _switchFeed(context, ref, feedUrl),
          ),
          VoxIconButton(
            icon: Icons.refresh_rounded,
            tooltip: AppL10n.t(context, 'reload'),
            onPressed: () => ref.invalidate(rssItemsProvider),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48),
              const SizedBox(height: AppSizes.md),
              Text(AppL10n.t(context, 'news_load_error')),
              const SizedBox(height: AppSizes.md),
              VoxButton.tonal(
                label    : AppL10n.t(context, 'retry'),
                onPressed: () => ref.invalidate(rssItemsProvider),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(child: Text(AppL10n.t(context, 'no_news')))
            : ListView.separated(
                padding        : const EdgeInsets.symmetric(vertical: AppSizes.sm),
                itemCount      : items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder    : (_, i) => _NewsCard(item: items[i]),
              ),
      ),
    );
  }

  void _switchFeed(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppL10n.t(ctx, 'select_news_source')),
        children: defaultRssFeeds.map((url) {
          final name = url.contains('tagesschau')
              ? 'Tagesschau'
              : url.contains('dw.com')
                  ? 'Deutsche Welle'
                  : url;
          return SimpleDialogOption(
            onPressed: () {
              ref.read(rssFeedUrlProvider.notifier).state = url;
              ref.invalidate(rssItemsProvider);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Icon(
                  current == url
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(name),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final RssItem item;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return ExpansionTile(
      leading: const Icon(Icons.article_rounded),
      title  : Text(
        item.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item.pubDate != null
          ? Text(
              _formatDate(item.pubDate!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.description.isNotEmpty)
                // L.5f: auch Nachrichten — jedes Wort antippbar (Popup → Wort-Seite).
                KlickWortText(item.description,
                    markiert: true, style: theme.textTheme.bodyMedium),

              const SizedBox(height: AppSizes.sm),

              if (item.link.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.link,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    VoxIconButton(
                      icon: Icons.copy_rounded, iconSize: 16,
                      tooltip: AppL10n.t(context, 'copy_link'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppL10n.t(context, 'link_copied'))),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
