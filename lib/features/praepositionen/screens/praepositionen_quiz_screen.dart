// FILE: lib/features/praepositionen/screens/praepositionen_quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/vox_progress.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../models/praep_cluster.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class PraepositonenQuizScreen extends StatefulWidget {
  const PraepositonenQuizScreen({super.key, required this.clusters});
  final List<PraepCluster> clusters;

  @override
  State<PraepositonenQuizScreen> createState() =>
      _PraepositonenQuizScreenState();
}

class _PraepositonenQuizScreenState extends State<PraepositonenQuizScreen> {
  final _rng     = Random();
  int  _current  = 0;
  int  _correct  = 0;
  int? _selected;
  bool _answered = false;

  late List<_QuizItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildItems();
  }

  List<_QuizItem> _buildItems() {
    final all = <_QuizItem>[];
    for (final cluster in widget.clusters) {
      for (final member in cluster.members) {
        // Build 4 options from all unique prepositions in dataset
        final allPreps = widget.clusters
            .expand((c) => c.members.map((m) => m.preposition))
            .toSet()
            .toList()
          ..shuffle(_rng);
        final opts = <String>[member.preposition];
        for (final p in allPreps) {
          if (opts.length >= 4) break;
          if (p != member.preposition) opts.add(p);
        }
        opts.shuffle(_rng);
        all.add(_QuizItem(
          lemma       : member.lemma,
          preposition : member.preposition,
          gCase       : member.grammaticalCase,
          options     : opts,
          meaningFa   : cluster.meaningFa,
          meaningEn   : cluster.meaningEn,
          exampleDe   : cluster.examples
              .where((e) => e.memberLemma == member.lemma)
              .map((e) => e.de)
              .firstOrNull ?? '',
          exampleFa: cluster.examples
              .where((e) => e.memberLemma == member.lemma)
              .map((e) => e.fa)
              .firstOrNull ?? '',
          exampleEn: cluster.examples
              .where((e) => e.memberLemma == member.lemma)
              .map((e) => e.en)
              .firstOrNull ?? '',
        ));
      }
    }
    all.shuffle(_rng);
    return all.take(40).toList();
  }

  _QuizItem get _item => _items[_current];

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (_item.options[i] == _item.preposition) _correct++;
    });
  }

  void _next() {
    if (_current < _items.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    VoxDialog.quizResult(
      context,
      correct : _correct,
      total   : _items.length,
      onBack  : () => Navigator.pop(context),
      onRepeat: () => setState(() {
                _items    = _buildItems();
                _current  = 0;
                _correct  = 0;
                _selected = null;
                _answered = false;
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final item   = _item;

    return Scaffold(
      appBar: AppBar(
        title : VoxQuizProgressBar.title(current: _current + 1, total: _items.length),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _items.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            // ── Question card ─────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    Text(
                      item.lemma,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppL10n.meaning(context, fa: item.meaningFa, en: item.meaningEn),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppL10n.t(context, 'which_preposition'),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Options ───────────────────────────────────────────
            ...List.generate(item.options.length, (i) {
              final isCorrect = item.options[i] == item.preposition;
              return VoxOptionButton(
                label    : item.options[i],
                istDeutsch: true, // Präpositionen
                state    : _answered
                    ? (isCorrect
                        ? VoxOptionState.correct
                        : _selected == i
                            ? VoxOptionState.wrong
                            : VoxOptionState.idle)
                    : (_selected == i
                        ? VoxOptionState.selected
                        : VoxOptionState.idle),
                onPressed: _answered ? null : () => _select(i),
              );
            }),

            const Spacer(),

            // ── Case info & example after answer ─────────────────
            if (_answered) ...[
              Card(
                color: scheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    children: [
                      Text(
                        '${item.preposition} + ${item.gCase[0].toUpperCase()}'
                        '${item.gCase.substring(1)}',
                        style: TextStyle(
                            color     : scheme.primary,
                            fontWeight: FontWeight.w700),
                      ),
                      if (item.exampleDe.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        DeutschText(item.exampleDe, ganzeZeile: false, // zentriert
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(AppL10n.meaning(context, fa: item.exampleFa,
                            en: item.exampleEn.isNotEmpty ? item.exampleEn : item.exampleFa),
                            style: TextStyle(
                                color: scheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              VoxButton.primary(
                label    : _current < _items.length - 1 ? AppL10n.t(context, 'next') : AppL10n.t(context, 'result'),
                icon     : Icons.arrow_forward_rounded,
                size     : VoxButtonSize.large,
                expand   : true,
                onPressed: _next,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuizItem {
  const _QuizItem({
    required this.lemma,
    required this.preposition,
    required this.gCase,
    required this.options,
    required this.meaningFa,
    required this.meaningEn,
    required this.exampleDe,
    required this.exampleFa,
    required this.exampleEn,
  });
  final String       lemma;
  final String       preposition;
  final String       gCase;
  final List<String> options;
  final String       meaningFa;
  final String meaningEn;
  final String       exampleDe;
  final String       exampleFa;
  final String exampleEn;
}
