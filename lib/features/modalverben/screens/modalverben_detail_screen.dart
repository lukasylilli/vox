// FILE: lib/features/modalverben/screens/modalverben_detail_screen.dart
// PURPOSE: Flashcard-Detail — Bedeutung, Konjugation (Präsens/Präteritum),
//          alle Zeitformen, Beispiele mit Tense-Badge, Notiz.
//          Sprache (FA/EN) folgt der App-Sprache aus Settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/widgets/vox_error_widget.dart';
import '../../../core/widgets/vox_loading_widget.dart';
import '../controllers/modalverben_controller.dart';
import '../models/modal_verb.dart';

class ModalverbenDetailScreen extends ConsumerWidget {
  const ModalverbenDetailScreen({
    super.key,
    required this.verbId,
    this.verb,
  });

  final String     verbId;
  final ModalVerb? verb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verbAsync = verb != null
        ? AsyncValue.data(verb!)
        : ref.watch(modalVerbenProvider).whenData(
            (list) => list.firstWhere((v) => v.id == verbId));

    return verbAsync.when(
      loading: () => const Scaffold(body: VoxLoadingWidget()),
      error  : (e, _) => Scaffold(body: VoxErrorWidget(error: e)),
      data   : (v) => _DetailView(verb: v),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.verb});
  final ModalVerb verb;

  static const _persons = [
    ('ich', 'ich'),
    ('du', 'du'),
    ('er_sie_es', 'er/sie/es'),
    ('wir', 'wir'),
    ('ihr', 'ihr'),
    ('sie_Sie', 'sie/Sie'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isEn  = Localizations.localeOf(context).languageCode == 'en';
    final note  = isEn ? verb.noteEn : verb.noteFa;

    return Scaffold(
      appBar: AppBar(title: Text(verb.infinitive)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
        children: [
          // ── Bedeutung ────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verb.infinitive,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color     : VoxColors.typeVerb,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn ? verb.meaningEn : verb.meaningFa,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Konjugation Präsens + Präteritum ────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Konjugation'),
                  const SizedBox(height: 8),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(children: [
                        const SizedBox.shrink(),
                        _cellHeader(context, 'Präsens'),
                        _cellHeader(context, 'Präteritum'),
                      ]),
                      for (final (key, label) in _persons)
                        TableRow(children: [
                          _cell(context, label, muted: true),
                          _cell(context, verb.praesens[key] ?? ''),
                          _cell(context, verb.praeteritum[key] ?? ''),
                        ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Weitere Zeitformen ───────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Zeitformen'),
                  const SizedBox(height: 8),
                  if (verb.perfekt.isNotEmpty)
                    _formRow(context, 'Perfekt', verb.perfekt),
                  _formRow(context, 'Perfekt + Verb', verb.perfektErsatz),
                  _formRow(context, 'Plusquamperfekt', verb.plusquamperfekt),
                  _formRow(context, 'Futur I', verb.futur1),
                  _formRow(context, 'Konjunktiv II', verb.konjunktiv2),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Beispiele ────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Beispiele'),
                  const SizedBox(height: 8),
                  for (final ex in verb.examples) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color       : cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        ex.tense,
                        style: TextStyle(
                          fontSize  : 10,
                          fontWeight: FontWeight.w700,
                          color     : cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ex.de,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isEn ? ex.en : ex.fa,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // ── Notiz ────────────────────────────────────────────────────────
          if (note.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Card(
              color: cs.tertiaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 18, color: cs.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(note, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String label) => Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color     : Theme.of(context).colorScheme.primary,
            ),
      );

  Widget _cellHeader(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  Widget _cell(BuildContext context, String text, {bool muted = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: muted
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : null,
                fontWeight: muted ? null : FontWeight.w600,
              ),
        ),
      );

  Widget _formRow(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
}
