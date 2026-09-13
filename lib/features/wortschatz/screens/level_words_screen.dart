// FILE: lib/features/wortschatz/screens/level_words_screen.dart
// DEPS: wordsByLevelProvider, WordListItem
// PURPOSE: Word list filtered by a single GermanLevel (passed as route query param)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../controllers/word_controller.dart';
import '../widgets/word_list_item.dart';

class LevelWordsScreen extends ConsumerWidget {
  const LevelWordsScreen({super.key, required this.level});

  final String level; // e.g. "a1", "b2"

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider(level));
    final label = GermanLevel.fromString(level)?.label ?? level.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.tf(context, 'vocab_of', {'x': label}))),
      body: Column(
        children: [
          // Level picker row
          _LevelPickerBar(current: level),
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
              data   : (words) => words.isEmpty
                  ? Center(child: Text(AppL10n.t(context, 'no_words_in_level')))
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

class _LevelPickerBar extends StatelessWidget {
  const _LevelPickerBar({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children       : GermanLevel.values.map((lvl) {
          final selected = lvl.name == current.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child  : ChoiceChip(
              label   : Text(lvl.label),
              selected: selected,
              onSelected: (_) => context.pushReplacement(
                '${AppRoutes.wortschatzLevel}?level=${lvl.name}',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
