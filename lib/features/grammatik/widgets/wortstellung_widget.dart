// FILE: lib/features/grammatik/widgets/wortstellung_widget.dart
// DEPS: app_sizes.dart
// PURPOSE: Word order exercise — tap source chips to build answer, tap answer chips to remove
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class WortstellungWidget extends StatefulWidget {
  const WortstellungWidget({
    super.key,
    required this.shuffledWords,
    required this.solution,
    required this.onAnswer,
    this.showResult = false,
  });

  final List<String>              shuffledWords;
  final String                    solution;
  final void Function(bool isCorrect, String userAnswer) onAnswer;
  final bool                      showResult;

  @override
  State<WortstellungWidget> createState() => _WortstellungWidgetState();
}

class _WortstellungWidgetState extends State<WortstellungWidget> {
  late List<String> _source;
  final List<String> _answer = [];
  bool _submitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _source = List.from(widget.shuffledWords);
  }

  @override
  void didUpdateWidget(WortstellungWidget old) {
    super.didUpdateWidget(old);
    if (old.shuffledWords != widget.shuffledWords) {
      setState(() {
        _source    = List.from(widget.shuffledWords);
        _answer.clear();
        _submitted = false;
        _isCorrect = false;
      });
    }
    if (widget.showResult && !old.showResult) _check();
  }

  void _addWord(String word) {
    if (_submitted) return;
    setState(() {
      _source.remove(word);
      _answer.add(word);
    });
  }

  void _removeWord(String word) {
    if (_submitted) return;
    setState(() {
      _answer.remove(word);
      _source.add(word);
    });
  }

  void _reset() => setState(() {
    _source  = List.from(widget.shuffledWords);
    _answer.clear();
    _submitted = false;
    _isCorrect = false;
  });

  void _check() {
    if (_answer.isEmpty) return;
    final userSentence = _answer.join(' ');
    final correct      = userSentence.trim() == widget.solution.trim();
    setState(() {
      _submitted = true;
      _isCorrect = correct;
    });
    widget.onAnswer(correct, userSentence);
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Answer area ─────────────────────────────────────────────────
        Container(
          width      : double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding    : const EdgeInsets.all(AppSizes.sm),
          decoration : BoxDecoration(
            color       : _submitted
                ? (_isCorrect
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1))
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border      : Border.all(
              color: _submitted
                  ? (_isCorrect ? Colors.green : Colors.red)
                  : scheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: _answer.isEmpty
              ? Center(
                  child: Text(AppL10n.t(context, 'arrange_words_hint'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    )),
                )
              : Wrap(
                textDirection: TextDirection.ltr, // deutsche Wortbausteine: Lesereihenfolge
                  spacing    : 6,
                  runSpacing : 4,
                  children   : _answer.map((w) => GestureDetector(
                    onTap: () => _removeWord(w),
                    child: _WordChip(
                      word    : w,
                      color   : scheme.primaryContainer,
                      textColor: scheme.onPrimaryContainer,
                    ),
                  )).toList(),
                ),
        ),

        // Feedback row
        if (_submitted) ...[
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: _isCorrect ? Colors.green : Colors.red,
                size : 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _isCorrect
                    ? Text(AppL10n.t(context, 'correct_feedback'),
                        style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w600))
                    : Text('${AppL10n.t(context, 'answer_label')} ${widget.solution}',
                        style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
              ),
              if (!_isCorrect)
                VoxButton.text(
                  label    : AppL10n.t(context, 'try_again'),
                  onPressed: _reset,
                ),
            ],
          ),
        ],

        const SizedBox(height: AppSizes.md),

        // ── Source word chips ────────────────────────────────────────────
        Wrap(
          textDirection: TextDirection.ltr, // deutsche Wortbausteine: Lesereihenfolge
          spacing   : 6,
          runSpacing: 4,
          children  : _source.map((w) => GestureDetector(
            onTap: _submitted ? null : () => _addWord(w),
            child: _WordChip(
              word     : w,
              color    : scheme.secondaryContainer,
              textColor: scheme.onSecondaryContainer,
              disabled : _submitted,
            ),
          )).toList(),
        ),

        // Check button
        if (!_submitted && _answer.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          VoxButton.tonal(
            label    : AppL10n.t(context, 'check'),
            onPressed: _check,
          ),
        ],
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.color,
    required this.textColor,
    this.disabled = false,
  });

  final String word;
  final Color  color, textColor;
  final bool   disabled;

  @override
  Widget build(BuildContext context) => Container(
    padding   : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color       : disabled ? color.withValues(alpha: 0.5) : color,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(word,
      style: TextStyle(
        color     : disabled ? textColor.withValues(alpha: 0.5) : textColor,
        fontWeight: FontWeight.w500,
      )),
  );
}
