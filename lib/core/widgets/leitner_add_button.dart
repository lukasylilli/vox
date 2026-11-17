// FILE: lib/core/widgets/leitner_add_button.dart
// DEPS: leitner_controller.dart, leitner_dao.dart
// PURPOSE: Shared button — shows whether a word is in Leitner and which box
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/leitner/controllers/leitner_controller.dart';
import '../l10n/app_l10n.dart';
import '../leitner/leitner_regeln.dart';

class LeitnerAddButton extends ConsumerWidget {
  const LeitnerAddButton({super.key, required this.wordId, this.compact = false});

  /// Nummer des alten Worts (Tabelle `Words`). Der Leitner kennt seit X.2
  /// nur Text-ids — [altWortIdProvider] übersetzt.
  final int  wordId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const laedt = SizedBox(
      width: 22, height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    final wortId = ref.watch(altWortIdProvider(wordId)).valueOrNull;
    if (wortId == null) {
      return ref.watch(altWortIdProvider(wordId)).isLoading
          ? laedt
          : const SizedBox.shrink();
    }
    return ref.watch(isInLeitnerProvider(wortId)).when(
      loading: () => laedt,
      error  : (_, _) => const SizedBox.shrink(),
      data   : (inLeitner) => inLeitner
          ? _InLeitnerButton(wortId: wortId, compact: compact)
          : _AddButton(wortId: wortId, compact: compact),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton({required this.wortId, required this.compact});
  final String wortId;
  final bool   compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> add() async {
      // Die Anzeige folgt von selbst: alle Zähler lesen Ströme der Tabellen.
      await ref.read(leitnerDaoProvider).aufnehmen(wortId);
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

class _InLeitnerButton extends ConsumerWidget {
  const _InLeitnerButton({required this.wortId, required this.compact});
  final String wortId;
  final bool   compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stand = ref
        .watch(leitnerFortschrittProvider(uebungBedeutung))
        .valueOrNull?[wortId];
    final box = anzeigeFach(stand).clamp(1, leitnerFaecher);

    Future<void> remove() async {
      // Nur aus dem Leitner — der Fortschritt des Worts bleibt (X.2).
      await ref.read(leitnerDaoProvider).entfernen(wortId);
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
