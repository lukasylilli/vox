// FILE: lib/features/pruefungen/widgets/exam_score_widget.dart
// DEPS: -
// PURPOSE: نتیجه آزمون — درصد، نمره، وضعیت قبول/رد، breakdown
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class ExamScoreWidget extends StatelessWidget {
  const ExamScoreWidget({
    super.key,
    required this.correct,
    required this.total,
    required this.elapsedSeconds,
    required this.timeLimitSeconds,
    required this.examTitle,
    required this.onRetry,
    required this.onDone,
  });

  final int    correct;
  final int    total;
  final int    elapsedSeconds;
  final int    timeLimitSeconds;
  final String examTitle;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final pct    = total == 0 ? 0 : (correct * 100 ~/ total);
    final passed = pct >= 60;
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        children: [
          Text(examTitle,
              style    : theme.textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.xl),

          // Score circle
          SizedBox(
            width : 150,
            height: 150,
            child : Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value      : pct / 100,
                  strokeWidth: 12,
                  color      : passed ? Colors.green : scheme.error,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$pct%',
                        style: const TextStyle(
                          fontSize  : 32,
                          fontWeight: FontWeight.w900,
                        )),
                    Text(
                      passed ? AppL10n.t(context, 'passed_check') : AppL10n.t(context, 'failed_check'),
                      style: TextStyle(
                        color     : passed ? Colors.green : scheme.error,
                        fontWeight: FontWeight.w700,
                        fontSize  : 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.xl),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: AppL10n.t(context, 'correct_label2'), value: '$correct', color: Colors.green),
              _Stat(
                  label: AppL10n.t(context, 'wrong_label'),
                  value: '${total - correct}',
                  color: scheme.error),
              _Stat(label: AppL10n.t(context, 'total_label'), value: '$total', color: scheme.primary),
              _Stat(
                  label: AppL10n.t(context, 'time_label'),
                  value: _fmt(elapsedSeconds),
                  color: scheme.secondary),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // Pass threshold info
          Container(
            padding   : const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color       : (passed ? Colors.green : scheme.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              passed
                  ? AppL10n.t(context, 'exam_passed_msg')
                  : AppL10n.t(context, 'exam_failed_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color     : passed ? Colors.green : scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

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
                  label    : AppL10n.t(context, 'finish'),
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

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize  : 22,
                fontWeight: FontWeight.w800,
                color     : color,
              )),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}
