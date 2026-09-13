// FILE: lib/features/wortschatz/screens/book_list_screen.dart
// DEPS: allBooksProvider, wordDaoProvider
// PURPOSE: List of textbooks — tap to see words of that book
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/word_controller.dart';
import '../../../core/widgets/vox_button.dart';

class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'vocab_books'))),
      floatingActionButton: VoxFab.extended(
        icon     : Icons.add_rounded,
        label    : AppL10n.t(context, 'add_book'),
        onPressed: () => _addBook(context, ref),
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (books) => books.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(AppL10n.t(context, 'no_books')),
                  ],
                ),
              )
            : ListView.builder(
                padding    : const EdgeInsets.all(AppSizes.md),
                itemCount  : books.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                  child : ListTile(
                    leading : const Icon(Icons.menu_book_rounded),
                    title   : Text(books[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap   : () => context.push(
                      '/wortschatz/books/${books[i].id}',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _addBook(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.t(ctx, 'book_name')),
        content: TextField(
          controller : ctrl,
          autofocus  : true,
          decoration : InputDecoration(hintText: AppL10n.t(ctx, 'book_name_hint')),
        ),
        actions: [
          VoxButton.text(
            label    : AppL10n.t(ctx, 'cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          VoxButton.primary(
            label    : AppL10n.t(ctx, 'add'),
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await ref.read(wordDaoProvider).insertBook(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
