// FILE: lib/features/vokabular/widgets/wort_actions.dart
// PURPOSE: Die drei Aktionen eines Vokabular-Worts (فاز V, Stufe ۳):
//          🔊 Audio (TtsService, vorhanden) | Leitner-Toggle (Flag, KEIN Auto-
//          Import — Wortschatz ≠ Leitner) | Kategorien (BottomSheet, eigene Listen).
//          kompakt=true → Icon-Reihe für Listen; sonst große Buttons (Wort-Seite).
//          Puzzling: nur VoxButton/VoxIconButton/AudioPlayButton — keine rohen Buttons.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/audio_play_button.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/vokabular_user_state.dart';

class WortActions extends ConsumerWidget {
  final Map<String, dynamic> card;
  final bool kompakt;

  const WortActions({super.key, required this.card, this.kompakt = false});

  String get _id => card['id'] as String? ?? '';
  String get _wort => card['wort'] as String? ?? '';

  Future<void> _leitnerToggle(BuildContext context, WidgetRef ref) async {
    final rein =
        await ref.read(vokabularUserProvider.notifier).toggleLeitner(_id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppL10n.t(
            context, rein ? 'added_to_leitner' : 'removed_from_leitner'))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imLeitner = ref.watch(
        vokabularUserProvider.select((s) => s.imLeitner(_id)));
    final scheme = Theme.of(context).colorScheme;

    if (kompakt) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        AudioPlayButton(text: _wort, size: 20),
        VoxIconButton(
          icon: imLeitner
              ? Icons.inventory_2_rounded
              : Icons.inventory_2_outlined,
          color: imLeitner ? scheme.primary : null,
          iconSize: 20,
          tooltip: AppL10n.t(context, imLeitner ? 'in_leitner' : 'add_to_leitner'),
          onPressed: () => _leitnerToggle(context, ref),
        ),
        VoxIconButton(
          icon: Icons.label_outline_rounded,
          iconSize: 20,
          tooltip: AppL10n.t(context, 'my_categories'),
          onPressed: () => _zeigeKategorien(context),
        ),
      ]);
    }

    return Row(children: [
      AudioPlayButton(text: _wort, size: 28),
      const SizedBox(width: 8),
      Expanded(
        child: imLeitner
            ? VoxButton.success(
                label: AppL10n.t(context, 'in_leitner'),
                icon: Icons.check_rounded,
                onPressed: () => _leitnerToggle(context, ref),
              )
            : VoxButton.tonal(
                label: AppL10n.t(context, 'add_to_leitner'),
                icon: Icons.inventory_2_outlined,
                onPressed: () => _leitnerToggle(context, ref),
              ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: VoxButton.secondary(
          label: AppL10n.t(context, 'my_categories'),
          icon: Icons.label_outline_rounded,
          onPressed: () => _zeigeKategorien(context),
        ),
      ),
    ]);
  }

  void _zeigeKategorien(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _KategorienSheet(wortId: _id, wort: _wort),
    );
  }
}

/// BottomSheet: Wort zu eigenen Kategorien hinzufügen/entfernen + neue erstellen.
class _KategorienSheet extends ConsumerStatefulWidget {
  final String wortId;
  final String wort;
  const _KategorienSheet({required this.wortId, required this.wort});

  @override
  ConsumerState<_KategorienSheet> createState() => _KategorienSheetState();
}

class _KategorienSheetState extends ConsumerState<_KategorienSheet> {
  final _neuController = TextEditingController();

  @override
  void dispose() {
    _neuController.dispose();
    super.dispose();
  }

  Future<void> _erstellen() async {
    final name = _neuController.text.trim();
    if (name.isEmpty) return;
    await ref.read(vokabularUserProvider.notifier).createKategorie(name);
    _neuController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final kategorien =
        ref.watch(vokabularUserProvider.select((s) => s.kategorien));
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppL10n.tf(context, 'kategorien_sheet_title', {'wort': widget.wort}),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (kategorien.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(AppL10n.t(context, 'no_categories_yet'),
                  style: theme.textTheme.bodySmall),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final k in kategorien)
                    CheckboxListTile(
                      title: Text(k.name),
                      value: k.wortIds.contains(widget.wortId),
                      onChanged: (_) => ref
                          .read(vokabularUserProvider.notifier)
                          .toggleWortInKategorie(k.id, widget.wortId),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _neuController,
                decoration: InputDecoration(
                    hintText: AppL10n.t(context, 'new_category_hint')),
                onSubmitted: (_) => _erstellen(),
              ),
            ),
            const SizedBox(width: 8),
            VoxIconButton.filled(
                icon: Icons.add_rounded, onPressed: _erstellen),
          ]),
          const SizedBox(height: 16),
          VoxButton.primary(
            label: AppL10n.t(context, 'done'),
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
