// FILE: lib/features/wortschatz/screens/book_words_screen.dart
// DEPS: wordsByBookProvider, WordListItem
// PURPOSE: Words belonging to a specific book (by bookId)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_l10n.dart';
import '../controllers/word_controller.dart';
import '../widgets/word_list_item.dart';

class BookWordsScreen extends ConsumerWidget {
  const BookWordsScreen({super.key, required this.bookId, this.bookName});

  final int     bookId;
  final String? bookName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByBookProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: Text(bookName ?? AppL10n.t(context, 'book_label'))),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (words) => words.isEmpty
            ? Center(child: Text(AppL10n.t(context, 'no_words_in_book')))
            : ListView.builder(
                padding    : const EdgeInsets.only(top: 8, bottom: 24),
                itemCount  : words.length,
                itemBuilder: (ctx, i) {
                  final model = words[i].toModel();
                  return WordListItem(
                    word : model,
                    onTap: () => context.push('/wortschatz/word/${model.id}'),
                  );
                },
              ),
      ),
    );
  }
}
