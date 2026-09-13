// FILE: lib/features/home/screens/search_results_screen.dart
// DEPS: search_controller.dart
// PURPOSE: نتایج جستجوی جهانی — واژه، گرامر، عبارات Auswendiglernen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/search_controller.dart';
import '../../../core/widgets/vox_button.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ref.read(globalSearchProvider.notifier).search(widget.initialQuery));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(globalSearchProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller    : _ctrl,
          autofocus     : true,
          decoration    : InputDecoration(
            hintText   : AppL10n.t(context, 'global_search_hint'),
            border     : InputBorder.none,
            suffixIcon : _ctrl.text.isNotEmpty
                ? VoxIconButton(
                    icon: Icons.clear_rounded,
                    onPressed: () {
                      _ctrl.clear();
                      ref.read(globalSearchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onChanged: (q) =>
              ref.read(globalSearchProvider.notifier).search(q),
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.query.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: AppSizes.md),
                      Text(AppL10n.t(context, 'search_prompt')),
                    ],
                  ),
                )
              : state.results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: AppSizes.md),
                          Text('${AppL10n.t(context, 'empty')} «${state.query}»'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding         : const EdgeInsets.all(AppSizes.sm),
                      itemCount       : state.results.length,
                      separatorBuilder: (_, i) =>
                          const Divider(height: 1),
                      itemBuilder     : (_, i) {
                        final r = state.results[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                scheme.secondaryContainer,
                            child: Icon(
                              _iconFor(r.type),
                              color: scheme.secondary,
                              size : 18,
                            ),
                          ),
                          title   : _Highlighted(
                              text: r.title, query: state.query),
                          subtitle: Text(r.subtitle,
                              style: TextStyle(
                                  color  : scheme.onSurfaceVariant,
                                  fontSize: 12)),
                          onTap   : () => context.push(r.route),
                        );
                      },
                    ),
    );
  }

  IconData _iconFor(SearchResultType t) => switch (t) {
        SearchResultType.word            => Icons.translate_rounded,
        SearchResultType.grammarLesson   => Icons.menu_book_rounded,
        SearchResultType.memorizePhrases => Icons.format_quote_rounded,
      };
}

// Highlights matching substring
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});
  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final idx   = lower.indexOf(query.toLowerCase());
    if (idx < 0) return Text(text);

    return RichText(
      text: TextSpan(
        style   : DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text : text.substring(idx, idx + query.length),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
