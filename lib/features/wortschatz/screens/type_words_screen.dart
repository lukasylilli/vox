// FILE: lib/features/wortschatz/screens/type_words_screen.dart
// DEPS: wordsByTypeProvider, WordListItem
// PURPOSE: Word list filtered by WordType (passed as route query param)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/models/word_model.dart';
import '../controllers/word_controller.dart';
import '../widgets/word_list_item.dart';
import '../../../core/l10n/app_l10n.dart';

class TypeWordsScreen extends ConsumerWidget {
  const TypeWordsScreen({super.key, required this.type});

  final String type; // WordType.name, e.g. "nomen", "verb"

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByTypeProvider(type));
    final label = WordType.fromString(type).label;

    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Column(
        children: [
          // Type picker
          _TypePickerBar(current: type),
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
              data   : (words) => words.isEmpty
                  ? Center(child: Text(AppL10n.tf(context, 'no_words_of_type', {'x': label})))
                  : ListView.builder(
                      padding    : const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount  : words.length,
                      itemBuilder: (ctx, i) {
                        final model = words[i].toModel();
                        return WordListItem(
                          word : model,
                          onTap: () => context.push(
                            '/wortschatz/word/${model.id}',
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePickerBar extends StatelessWidget {
  const _TypePickerBar({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: WordType.values.map((t) {
          final selected = t.name == current.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child  : ChoiceChip(
              label    : Text(t.label),
              selected : selected,
              onSelected: (_) => context.pushReplacement(
                '${AppRoutes.wortschatzType}?type=${t.name}',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
