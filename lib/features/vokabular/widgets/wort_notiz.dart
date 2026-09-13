// FILE: lib/features/vokabular/widgets/wort_notiz.dart
// PURPOSE: Freitext-Notiz des Nutzers auf der Wort-Seite (user state, NICHT
//          Karten-Content): beliebiger Text; Farbe pro Wort wählbar — Wort im
//          Feld antippen (oder markieren), dann Farbpunkt tippen. Farben gelten
//          NUR für Wörter in der Notiz. Persistenz: VokabNotiz (text + Wort-
//          Index→Farbname) in vokabular_user_state (SharedPreferences).
//          Puzzling: nur VoxButton/VoxIconButton; Farbnamen→Color zentral hier.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../controllers/vokabular_user_state.dart';
import 'wortseite_bausteine.dart';

/// Farbname (gespeichert) → Color — auf hellem UND dunklem Grund lesbar.
const notizFarben = <String, Color>{
  'blau'  : Color(0xFF2196F3),
  'rot'   : Color(0xFFE53935),
  'gelb'  : Color(0xFFF9A825),
  'gruen' : Color(0xFF43A047),
  'orange': Color(0xFFFB8C00),
  'lila'  : Color(0xFFAB47BC),
};

final _runs = RegExp(r'\S+|\s+');

/// Text + farben → Spans; Wort-Index zählt nur Nicht-Whitespace-Runs
/// (dieselbe Zerlegung wie beim Einfärben — eine Quelle).
List<TextSpan> notizSpans(String text, Map<int, String> farben) {
  final spans = <TextSpan>[];
  var wortIndex = 0;
  for (final m in _runs.allMatches(text)) {
    final s = m.group(0)!;
    if (s.trim().isEmpty) {
      spans.add(TextSpan(text: s));
    } else {
      final farbe = notizFarben[farben[wortIndex]];
      spans.add(TextSpan(
          text: s,
          style: farbe == null
              ? null
              : TextStyle(color: farbe, fontWeight: FontWeight.w600)));
      wortIndex++;
    }
  }
  return spans;
}

/// Wort-Indizes im Bereich [start, end] — collapsed Cursor trifft das Wort,
/// in dem er steht; Markierung trifft alle überlappten Wörter.
Set<int> notizWortIndizes(String text, int start, int end) {
  final indizes = <int>{};
  var wortIndex = 0;
  for (final m in _runs.allMatches(text)) {
    if (m.group(0)!.trim().isNotEmpty) {
      final trifft = start == end
          ? (start >= m.start && start <= m.end)
          : (start < m.end && end > m.start);
      if (trifft) indizes.add(wortIndex);
      wortIndex++;
    }
  }
  return indizes;
}

/// TextEditingController, der die Wörter live nach `farben` einfärbt.
/// (Composing-Unterstreichung wird bewusst weggelassen — Farben > IME-Deko.)
class _NotizController extends TextEditingController {
  Map<int, String> farben;
  _NotizController({super.text, required this.farben});

  void setzeFarben(Map<int, String> neu) {
    farben = neu;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return TextSpan(style: style, children: notizSpans(text, farben));
  }
}

/// Sektion «Meine Notiz» der Wort-Seite: Anzeige + Editor-Einstieg.
class WortNotizSektion extends ConsumerWidget {
  final String wortId;
  const WortNotizSektion({super.key, required this.wortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notiz =
        ref.watch(vokabularUserProvider.select((s) => s.notizen[wortId]));
    final theme = Theme.of(context);

    if (notiz == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: VoxButton.tonal(
          label: AppL10n.t(context, 'notiz_schreiben'),
          icon: Icons.edit_note_rounded,
          expand: true,
          onPressed: () => _oeffneEditor(context, null),
        ),
      );
    }

    return Sektion(titel: AppL10n.t(context, 'meine_notiz'), children: [
      Text.rich(
        TextSpan(children: notizSpans(notiz.text, notiz.farben)),
        style: theme.textTheme.bodyMedium,
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: VoxIconButton(
          icon: Icons.edit_rounded,
          iconSize: 20,
          tooltip: AppL10n.t(context, 'edit'),
          onPressed: () => _oeffneEditor(context, notiz),
        ),
      ),
    ]);
  }

  void _oeffneEditor(BuildContext context, VokabNotiz? bestehend) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NotizSheet(wortId: wortId, bestehend: bestehend),
    );
  }
}

class _NotizSheet extends ConsumerStatefulWidget {
  final String wortId;
  final VokabNotiz? bestehend;
  const _NotizSheet({required this.wortId, this.bestehend});

  @override
  ConsumerState<_NotizSheet> createState() => _NotizSheetState();
}

class _NotizSheetState extends ConsumerState<_NotizSheet> {
  late final _NotizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _NotizController(
        text: widget.bestehend?.text ?? '',
        farben: Map<int, String>.from(widget.bestehend?.farben ?? const {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Färbt die Wörter an der aktuellen Cursorposition/Markierung;
  /// farbName null = zurück auf Standardfarbe.
  void _faerbe(String? farbName) {
    final sel = _controller.selection;
    if (!sel.isValid) return;
    final indizes = notizWortIndizes(_controller.text, sel.start, sel.end);
    if (indizes.isEmpty) return;
    final neu = Map<int, String>.from(_controller.farben);
    for (final i in indizes) {
      farbName == null ? neu.remove(i) : neu[i] = farbName;
    }
    _controller.setzeFarben(neu);
  }

  Future<void> _speichern() async {
    // Farben von inzwischen gelöschten Wörtern nicht mitspeichern.
    final wortAnzahl = RegExp(r'\S+').allMatches(_controller.text).length;
    final farben = {
      for (final e in _controller.farben.entries)
        if (e.key < wortAnzahl) e.key: e.value,
    };
    await ref.read(vokabularUserProvider.notifier).setzeNotiz(
        widget.wortId, VokabNotiz(text: _controller.text, farben: farben));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _loeschen() async {
    await ref
        .read(vokabularUserProvider.notifier)
        .setzeNotiz(widget.wortId, null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            AppL10n.t(context, 'meine_notiz'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
                hintText: AppL10n.t(context, 'notiz_hint')),
          ),
          const SizedBox(height: 10),
          Text(AppL10n.t(context, 'notiz_farbe_hint'),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Row(children: [
            VoxIconButton(
              icon: Icons.format_color_reset_rounded,
              iconSize: 24,
              tooltip: 'Standard',
              onPressed: () => _faerbe(null),
            ),
            for (final e in notizFarben.entries)
              VoxIconButton(
                icon: Icons.circle,
                color: e.value,
                iconSize: 24,
                tooltip: e.key,
                onPressed: () => _faerbe(e.key),
              ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            if (widget.bestehend != null)
              VoxButton.text(
                label: AppL10n.t(context, 'delete'),
                onPressed: _loeschen,
              ),
            const Spacer(),
            VoxButton.text(
              label: AppL10n.t(context, 'cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            VoxButton.primary(
              label: AppL10n.t(context, 'save'),
              onPressed: _speichern,
            ),
          ]),
        ],
      ),
    );
  }
}
