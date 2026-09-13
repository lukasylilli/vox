// FILE: lib/core/widgets/leitner_add_button.dart
// DEPS: leitner_controller.dart, leitner_dao.dart
// PURPOSE: Shared button — shows whether a word is in Leitner and which box
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/leitner/controllers/leitner_controller.dart';
import '../l10n/app_l10n.dart';

class LeitnerAddButton extends ConsumerWidget {
  const LeitnerAddButton({super.key, required this.wordId, this.compact = false});
  final int  wordId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(isInLeitnerProvider(wordId));

    return state.when(
      loading: () => const SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error  : (_, _) => const SizedBox.shrink(),
      data   : (inLeitner) {
        if (inLeitner) {
          return _InLeitnerButton(wordId: wordId, compact: compact);
        }
        return _AddButton(wordId: wordId, compact: compact);
      },
    );
  }
}

// ── Not in Leitner → Add button ───────────────────────────────────────────────

class _AddButton extends ConsumerWidget {
  const _AddButton({required this.wordId, required this.compact});
  final int  wordId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> add() async {
      await ref.read(leitnerDaoProvider).addWord(wordId);
      ref.invalidate(isInLeitnerProvider(wordId));
      ref.invalidate(boxCountsProvider);
      ref.invalidate(dueCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.t(context, 'added_to_leitner'))),
        );
      }
    }

    if (compact) {
      return IconButton.filled(
        tooltip  : AppL10n.t(context, 'add_to_leitner'),
        icon     : const Icon(Icons.add_circle_outline_rounded),
        onPressed: add,
      );
    }
    return FilledButton.tonalIcon(
      onPressed: add,
      icon     : const Icon(Icons.add_rounded),
      label    : Text(AppL10n.t(context, 'add_to_leitner')),
    );
  }
}

// ── Already in Leitner → shows box number, tap to remove ─────────────────────

class _InLeitnerButton extends ConsumerWidget {
  const _InLeitnerButton({required this.wordId, required this.compact});
  final int  wordId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(_cardForWordProvider(wordId));

    return cardAsync.when(
      loading: () => const SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error  : (_, _) => const SizedBox.shrink(),
      data   : (card) {
        final box = card?.boxNumber ?? 1;

        Future<void> remove() async {
          if (card == null) return;
          await ref.read(leitnerDaoProvider).removeCard(card.id);
          ref.invalidate(isInLeitnerProvider(wordId));
          ref.invalidate(boxCountsProvider);
          ref.invalidate(dueCountProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppL10n.t(context, 'removed_from_leitner'))),
            );
          }
        }

        final label = AppL10n.tf(context, 'leitner_box_n', {'n': '$box'});
        if (compact) {
          return IconButton(
            tooltip  : label,
            icon     : const Icon(Icons.check_circle_rounded),
            color    : Colors.green,
            onPressed: () => _confirmRemove(context, remove),
          );
        }
        return OutlinedButton.icon(
          onPressed: () => _confirmRemove(context, remove),
          icon     : const Icon(Icons.check_circle_rounded, color: Colors.green),
          label    : Text(label),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, Future<void> Function() remove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.t(ctx, 'remove_leitner_title')),
        content: Text(AppL10n.t(ctx, 'remove_leitner_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child    : Text(AppL10n.t(ctx, 'cancel')),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); remove(); },
            child    : Text(AppL10n.t(ctx, 'delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Per-word card provider ────────────────────────────────────────────────────

final _cardForWordProvider =
    FutureProvider.family<dynamic, int>((ref, wordId) =>
        ref.watch(leitnerDaoProvider).getByWordId(wordId));
