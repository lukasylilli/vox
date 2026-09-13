// FILE: lib/features/grammatik/widgets/quiz_result_widget.dart
// DEPS: app_sizes.dart
// PURPOSE: Quiz result card — score, percentage, list of wrong answers
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class QuizResultWidget extends StatelessWidget {
  const QuizResultWidget({
    super.key,
    required this.correct,
    required this.total,
    required this.wrongAnswers,
    required this.onRetry,
    required this.onDone,
  });

  final int                     correct;
  final int                     total;
  final List<WrongItem>         wrongAnswers;
  final VoidCallback            onRetry;
  final VoidCallback            onDone;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final pct     = total > 0 ? (correct / total * 100).round() : 0;
    final isGreat = pct >= 80;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child  : Column(
        children: [
          // Score circle
          _ScoreCircle(pct: pct, isGreat: isGreat),
          const SizedBox(height: AppSizes.md),
          Text(
            AppL10n.tf(context, 'x_of_y_correct', {'x': '$correct', 'y': '$total'}),
            style: theme.textTheme.titleMedium,
          ),

          if (wrongAnswers.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Align(
              alignment: Alignment.centerRight,
              child: Text(AppL10n.t(context, 'mistakes_label'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.red,
                )),
            ),
            const SizedBox(height: AppSizes.sm),
            ...wrongAnswers.map((w) => Container(
              margin    : const EdgeInsets.only(bottom: 8),
              padding   : const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color       : Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close_rounded, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.question,
                          style: theme.textTheme.bodySmall),
                        Text('${AppL10n.t(context, 'answer_label')} ${w.correct}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          )),
                        if (w.userAnswer.isNotEmpty)
                          Text('${AppL10n.t(context, 'your_answer_label')} ${w.userAnswer}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],

          const SizedBox(height: AppSizes.xl),
          Row(
            children: [
              Expanded(
                child: VoxButton.secondary(
                  label    : AppL10n.t(context, 'try_again'),
                  icon     : Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: VoxButton.primary(
                  label    : AppL10n.t(context, 'done'),
                  icon     : Icons.check_rounded,
                  onPressed: onDone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.pct, required this.isGreat});
  final int  pct;
  final bool isGreat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isGreat ? Colors.green : Colors.orange;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width : 120,
          height: 120,
          child : CircularProgressIndicator(
            value          : pct / 100,
            strokeWidth    : 10,
            backgroundColor: color.withValues(alpha: 0.15),
            color          : color,
          ),
        ),
        Text('$pct${AppL10n.t(context, 'percent_sign')}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color     : color,
          )),
      ],
    );
  }
}

// ── Wrong item model (used internally) ───────────────────────────────────────

class _WrongItem {
  const _WrongItem({
    required this.question,
    required this.correct,
    required this.userAnswer,
  });
  final String question, correct, userAnswer;
}

// Public factory so screens can build the list without importing _WrongItem
class WrongItem extends _WrongItem {
  const WrongItem({
    required super.question,
    required super.correct,
    required super.userAnswer,
  });
}
