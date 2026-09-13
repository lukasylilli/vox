// FILE: lib/features/grammatik/widgets/lueckentext_widget.dart
// DEPS: lesson_model.dart (GrammarExercise)
// PURPOSE: Fill-in-the-blank exercise — sentence with TextField replacing "___"
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class LueckentextWidget extends StatefulWidget {
  const LueckentextWidget({
    super.key,
    required this.exercise,
    required this.correctAnswer,
    required this.onAnswer,
    this.showResult = false,
    this.userAnswer,
  });

  // template: "Ich ___ nach Berlin."
  final String   exercise;       // the template string
  final String   correctAnswer;
  final void Function(String answer) onAnswer;
  final bool     showResult;
  final String?  userAnswer;

  @override
  State<LueckentextWidget> createState() => _LueckentextWidgetState();
}

class _LueckentextWidgetState extends State<LueckentextWidget> {
  late final TextEditingController _ctrl;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.userAnswer ?? '');
  }

  @override
  void didUpdateWidget(LueckentextWidget old) {
    super.didUpdateWidget(old);
    if (old.exercise != widget.exercise) {
      _ctrl.clear();
      setState(() => _submitted = false);
    }
    if (widget.showResult && !old.showResult) {
      setState(() => _submitted = true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitted = true);
    widget.onAnswer(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final scheme  = theme.colorScheme;
    final parts   = widget.exercise.split('___');
    final isRight = _submitted &&
        _ctrl.text.trim().toLowerCase() ==
            widget.correctAnswer.toLowerCase();

    Color? fieldColor;
    if (_submitted) {
      fieldColor = isRight
          ? Colors.green.withValues(alpha: 0.15)
          : Colors.red.withValues(alpha: 0.15);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sentence with inline TextField
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            if (parts.isNotEmpty)
              Text(parts[0].trim(),
                  style: theme.textTheme.bodyLarge),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _ctrl,
                enabled   : !_submitted,
                textAlign : TextAlign.center,
                decoration: InputDecoration(
                  isDense       : true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  filled     : true,
                  fillColor  : fieldColor ?? scheme.surfaceContainerHighest,
                  border     : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    borderSide  : BorderSide.none,
                  ),
                  hintText: '...',
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            if (parts.length > 1)
              Text(parts[1].trim(),
                  style: theme.textTheme.bodyLarge),
          ],
        ),

        // Feedback
        if (_submitted) ...[
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(
                isRight ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isRight ? Colors.green : Colors.red,
                size : 18,
              ),
              const SizedBox(width: 6),
              if (!isRight)
                Text('${AppL10n.t(context, 'answer_label')} ${widget.correctAnswer}',
                  style: const TextStyle(
                    color     : Colors.red,
                    fontWeight: FontWeight.w600,
                  )),
              if (isRight)
                Text(AppL10n.t(context, 'correct_feedback'),
                  style: const TextStyle(
                    color     : Colors.green,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],

        // Submit button (only if not submitted)
        if (!_submitted) ...[
          const SizedBox(height: AppSizes.sm),
          VoxButton.tonal(
            label    : AppL10n.t(context, 'check'),
            onPressed: _submit,
          ),
        ],
      ],
    );
  }
}
