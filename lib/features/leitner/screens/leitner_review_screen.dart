// FILE: lib/features/leitner/screens/leitner_review_screen.dart
// DEPS: leitner_dao.dart, leitner_controller.dart, flash_card_widget.dart, word_controller.dart
// PURPOSE: Review session — flip cards, mark correct/wrong, show summary at end
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../wortschatz/controllers/word_controller.dart';
import '../controllers/leitner_controller.dart';
import '../widgets/flash_card_widget.dart';
import '../../../core/widgets/vox_button.dart';

class LeitnerReviewScreen extends ConsumerStatefulWidget {
  const LeitnerReviewScreen({super.key});

  @override
  ConsumerState<LeitnerReviewScreen> createState() => _LeitnerReviewScreenState();
}

class _LeitnerReviewScreenState extends ConsumerState<LeitnerReviewScreen> {
  List<(LeitnerCard, WordModel)> _items = [];
  int   _currentIndex = 0;
  bool  _showAnswer   = false;
  bool  _loaded       = false;
  int   _correct      = 0;
  int   _wrong        = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final dao     = ref.read(leitnerDaoProvider);
    final wordDao = ref.read(wordDaoProvider);
    final due     = await dao.getDue();

    final pairs = <(LeitnerCard, WordModel)>[];
    for (final card in due) {
      final word = await wordDao.getById(card.wordId);
      if (word != null) pairs.add((card, word.toModel()));
    }

    if (mounted) setState(() { _items = pairs; _loaded = true; });
  }

  void _onFlipped() => setState(() => _showAnswer = true);

  Future<void> _markCorrect() async {
    final (card, _) = _items[_currentIndex];
    await ref.read(leitnerDaoProvider).markCorrect(card);
    ref.invalidate(dueCountProvider);
    ref.invalidate(boxCountsProvider);
    _advance(correct: true);
  }

  Future<void> _markWrong() async {
    final (card, _) = _items[_currentIndex];
    await ref.read(leitnerDaoProvider).markWrong(card);
    ref.invalidate(dueCountProvider);
    ref.invalidate(boxCountsProvider);
    _advance(correct: false);
  }

  void _advance({required bool correct}) {
    setState(() {
      if (correct) { _correct++; } else { _wrong++; }
      _currentIndex++;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppL10n.t(context, 'leitner_review_title'))),
        body  : Center(
          child: Text(AppL10n.t(context, 'leitner_no_cards'),
              textAlign: TextAlign.center),
        ),
      );
    }
    if (_currentIndex >= _items.length) {
      return _SummaryScreen(
        correct: _correct, wrong: _wrong, total: _items.length,
      );
    }

    final (_, model) = _items[_currentIndex];
    final progress    = _currentIndex / _items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_items.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            // Score row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScoreChip(Icons.check_rounded, _correct, Colors.green),
                const SizedBox(width: AppSizes.md),
                _ScoreChip(Icons.close_rounded,  _wrong,   Colors.red),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Flash card — expands to fill available space
            Expanded(
              child: FlashCardWidget(model: model, onFlip: _onFlipped),
            ),

            const SizedBox(height: AppSizes.md),

            // Answer buttons — only visible after flip
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child   : _showAnswer
                  ? _AnswerButtons(
                      onCorrect: _markCorrect, onWrong: _markWrong,
                    )
                  : Text(AppL10n.t(context, 'flip_card_hint'),
                      textAlign: TextAlign.center),
            ),

            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

// ── Score chip ────────────────────────────────────────────────────────────────

class _ScoreChip extends StatelessWidget {
  const _ScoreChip(this.icon, this.count, this.color);
  final IconData icon;
  final int      count;
  final Color    color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 4),
      Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ],
  );
}

// ── Answer buttons ────────────────────────────────────────────────────────────

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons({required this.onCorrect, required this.onWrong});
  final VoidCallback onCorrect, onWrong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: VoxButton.destructiveOutlined(
          label    : AppL10n.t(context, 'didn_t_know'),
          icon     : Icons.close_rounded,
          size     : VoxButtonSize.large,
          onPressed: onWrong,
        ),
      ),
      const SizedBox(width: AppSizes.md),
      Expanded(
        child: VoxButton.success(
          label    : AppL10n.t(context, 'knew_it'),
          icon     : Icons.check_rounded,
          size     : VoxButtonSize.large,
          onPressed: onCorrect,
        ),
      ),
    ],
  );
}

// ── Summary screen ────────────────────────────────────────────────────────────

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({
    required this.correct, required this.wrong, required this.total,
  });
  final int correct, wrong, total;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final pct     = total > 0 ? (correct / total * 100).round() : 0;
    final isGreat = pct >= 80;

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'review_result_title'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGreat ? Icons.stars_rounded : Icons.sentiment_neutral_rounded,
                size : 80,
                color: isGreat ? Colors.amber : Colors.orange,
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                '$pct${AppL10n.t(context, 'percent_sign')} ${AppL10n.t(context, 'correct_suffix')}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isGreat ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(AppL10n.tf(context, 'x_of_y_cards_correct', {'x': '$correct', 'y': '$total'}),
                style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(AppL10n.t(context, 'correct_label2'), correct, Colors.green,
                        Icons.check_circle_rounded),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _StatCard(AppL10n.t(context, 'wrong_label'), wrong, Colors.red,
                        Icons.cancel_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              VoxButton.primary(
                label    : AppL10n.t(context, 'back'),
                icon     : Icons.home_rounded,
                size     : VoxButtonSize.large,
                expand   : true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.count, this.color, this.icon);
  final String   label;
  final int      count;
  final Color    color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding   : const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border      : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text('$count', style: theme.textTheme.headlineMedium?.copyWith(
            color: color, fontWeight: FontWeight.w800,
          )),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
