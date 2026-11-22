// FILE: lib/features/leitner/widgets/deck_dialoge.dart
// PHASE: X.3/X.4 (2026-11-17) — Leitner wie Anki
// PURPOSE: Die Dialoge rund um ein Deck — EINE Stelle für Deck-Auswahl (X.3)
//          und Deck-Seiten (X.4): neues Deck/Subdeck (Name + Modus),
//          umbenennen, Tageslimit, löschen. Jeder Dialog schreibt über den
//          LeitnerDao; alle Anzeigen folgen von selbst.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/leitner/leitner_regeln.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/leitner_controller.dart';

/// Fragt Name und Modus und legt ein Deck (unter [eltern]) an. null =
/// abgebrochen.
Future<Deck?> neuesDeckAnlegen(BuildContext context, WidgetRef ref,
    {Deck? eltern}) async {
  // DAO VOR dem Dialog holen: das Widget hinter [ref] kann verschwinden,
  // solange der Dialog offen ist (z. B. wenn der Deck-Baum neu lädt).
  final dao = ref.read(leitnerDaoProvider);
  // Wirklicher Modus des Eltern-Decks (es kann selbst «erben»).
  final elternModus = eltern == null
      ? null
      : (await ref.read(deckModiProvider.future))[eltern.id] ?? eltern.modus;
  if (!context.mounted) return null;
  final neu = await showDialog<({String name, String modus})>(
    context: context,
    builder: (_) => NeuesDeckDialog(eltern: eltern, elternModus: elternModus),
  );
  if (neu == null) return null;
  // Subdeck im Modus des Eltern-Decks ⇒ «erben»: es folgt dem Eltern-Deck,
  // auch wenn das später umgestellt wird (Lukas 2026-11-22). Anders gewählt
  // ⇒ eigener Modus.
  final modus = eltern != null && neu.modus == elternModus
      ? deckModusErben
      : neu.modus;
  return dao.deckAnlegen(neu.name, elternId: eltern?.id, modus: modus);
}

/// Neuer Name für [deck].
Future<void> deckUmbenennen(
    BuildContext context, WidgetRef ref, Deck deck) async {
  final dao = ref.read(leitnerDaoProvider);
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _TextDialog(
      titel: AppL10n.t(context, 'deck_umbenennen'),
      start: deck.name,
      hinweis: AppL10n.t(context, 'deck_name_hint'),
    ),
  );
  if (name == null || name.trim().isEmpty) return;
  await dao.deckUmbenennen(deck.id, name);
}

/// Tageslimit neuer Wörter (Entscheidung Nr. 11). Leer = Standard.
Future<void> deckLimitAendern(BuildContext context, WidgetRef ref, Deck deck,
    {required bool obersteEbene}) async {
  final standard = obersteEbene ? neuProTagDeck : neuProTagSubdeck;
  final dao = ref.read(leitnerDaoProvider);
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _TextDialog(
      titel: AppL10n.t(context, 'deck_limit_titel'),
      start: deck.neuProTag?.toString() ?? '',
      hinweis: AppL10n.tf(context, 'deck_limit_standard', {'n': '$standard'}),
      info: AppL10n.t(context, 'deck_limit_info'),
      zahl: true,
    ),
  );
  if (text == null) return;
  final zahl = int.tryParse(Formatters.enDigits(text.trim()));
  await dao.deckEinstellen(deck.id,
      neuProTag: () => text.trim().isEmpty ? null : zahl?.clamp(0, 9999));
}

/// Fragt nach und löscht [deck]. Wörter verlassen es, ihr Fortschritt
/// bleibt; Subdecks rücken eine Ebene hoch (Entscheidung Nr. 7).
Future<bool> deckLoeschen(
    BuildContext context, WidgetRef ref, Deck deck) async {
  final dao = ref.read(leitnerDaoProvider);
  final ja = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppL10n.tf(ctx, 'deck_loeschen_titel', {'deck': deck.name})),
      content: Text(AppL10n.t(ctx, 'deck_loeschen_info')),
      actions: [
        VoxButton.text(
          label: AppL10n.t(ctx, 'cancel'),
          onPressed: () => Navigator.pop(ctx, false),
        ),
        VoxButton.destructive(
          key: const ValueKey('deck_loeschen_ja'),
          label: AppL10n.t(ctx, 'delete'),
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  if (ja != true) return false;
  await dao.deckLoeschen(deck.id);
  return true;
}

/// Nur Ziffern — persische (۰–۹) und arabische (٠–٩) werden zu 0–9.
/// Vorher ließ `digitsOnly` nur 0–9 durch: wer auf dem Handy mit
/// persischer Tastatur «۱۰» tippte, sah ein leeres Feld, und «Speichern»
/// setzte das Limit stillschweigend auf den Standard zurück (Lukas
/// 2026-11-22: «ich ändere 50 auf 10, speichere — nichts ändert sich»).
final _nurZiffern = TextInputFormatter.withFunction((alt, neu) {
  final text = Formatters.enDigits(neu.text).replaceAll(RegExp(r'[^0-9]'), '');
  if (text == neu.text) return neu;
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
});

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.titel,
    required this.start,
    required this.hinweis,
    this.info,
    this.zahl = false,
  });

  final String titel;
  final String start;
  final String hinweis;
  final String? info;
  final bool zahl;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _ctrl = TextEditingController(text: widget.start);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.titel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('deck_text'),
            controller: _ctrl,
            autofocus: true,
            keyboardType: widget.zahl ? TextInputType.number : null,
            inputFormatters: widget.zahl ? [_nurZiffern] : null,
            decoration: InputDecoration(hintText: widget.hinweis),
            onSubmitted: (t) => Navigator.of(context).pop(t),
          ),
          if (widget.info != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(widget.info!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
      actions: [
        VoxButton.text(
          label: AppL10n.t(context, 'cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        VoxButton.primary(
          key: const ValueKey('deck_text_ok'),
          label: AppL10n.t(context, 'save'),
          onPressed: () => Navigator.of(context).pop(_ctrl.text),
        ),
      ],
    );
  }
}

// ─── Dialog «neues Deck / neues Subdeck» ─────────────────────────────────────

class NeuesDeckDialog extends StatefulWidget {
  const NeuesDeckDialog({this.eltern, this.elternModus});

  /// Eltern-Deck (dann wird ein Subdeck angelegt) oder null.
  final Deck? eltern;

  /// Wirklicher Modus von [eltern] (Wiederholung/Notizbuch).
  final String? elternModus;

  @override
  State<NeuesDeckDialog> createState() => NeuesDeckDialogState();
}

class NeuesDeckDialogState extends State<NeuesDeckDialog> {
  final _name = TextEditingController();

  // Ein Subdeck beginnt im Modus seines Eltern-Decks; ein neues Deck der
  // obersten Ebene mit Wiederholung — wer über den Leitner-Knopf ein Deck
  // anlegt, will in aller Regel lernen. Beides ist hier umschaltbar.
  late String _modus = widget.elternModus ?? deckModusWiederholen;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _fertig() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name: name, modus: _modus));
  }

  @override
  Widget build(BuildContext context) {
    final eltern = widget.eltern;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(eltern == null
          ? AppL10n.t(context, 'deck_neu')
          : AppL10n.tf(context, 'deck_sub_neu', {'deck': eltern.name})),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('deck_name'),
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
                hintText: AppL10n.t(context, 'deck_name_hint')),
            onSubmitted: (_) => _fertig(),
          ),
          const SizedBox(height: AppSizes.md),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: deckModusWiederholen,
                icon: const Icon(Icons.repeat_rounded),
                label: Text(AppL10n.t(context, 'deck_modus_wiederholen')),
              ),
              ButtonSegment(
                value: deckModusNotiz,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(AppL10n.t(context, 'deck_modus_notiz')),
              ),
            ],
            selected: {_modus},
            onSelectionChanged: (s) => setState(() => _modus = s.single),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            AppL10n.t(
                context,
                _modus == deckModusWiederholen
                    ? 'deck_modus_wiederholen_info'
                    : 'deck_modus_notiz_info'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        VoxButton.text(
          label: AppL10n.t(context, 'cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        VoxButton.primary(
          key: const ValueKey('deck_anlegen'),
          label: AppL10n.t(context, 'create'),
          onPressed: _fertig,
        ),
      ],
    );
  }
}
