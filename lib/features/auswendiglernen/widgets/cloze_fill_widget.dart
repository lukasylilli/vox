// FILE: lib/features/auswendiglernen/widgets/cloze_fill_widget.dart
// DEPS: -
// PURPOSE: جمله با یک کلمه خالی — کاربر کلمه را تایپ می‌کند
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class ClozeFillWidget extends StatefulWidget {
  const ClozeFillWidget({
    super.key,
    required this.phrase,
    required this.meaning,
    this.onResult,
  });

  final String   phrase;
  final String   meaning;
  final void Function(bool correct)? onResult;

  @override
  State<ClozeFillWidget> createState() => _ClozeFillWidgetState();
}

class _ClozeFillWidgetState extends State<ClozeFillWidget> {
  late String       _blanked;
  late String       _answer;
  late List<String> _parts;
  final _ctrl      = TextEditingController();
  bool  _answered  = false;
  bool  _correct   = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(ClozeFillWidget old) {
    super.didUpdateWidget(old);
    if (old.phrase != widget.phrase) {
      _ctrl.clear();
      setState(() {
        _answered = false;
        _correct  = false;
        _prepare();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _prepare() {
    final words = widget.phrase.split(' ');
    // Pick a content word (length >= 3) to blank
    final candidates = <int>[];
    for (var i = 0; i < words.length; i++) {
      final clean = words[i].replaceAll(RegExp(r'[^\wäöüÄÖÜß]'), '');
      if (clean.length >= 3) candidates.add(i);
    }
    final idx = candidates.isNotEmpty
        ? candidates[Random().nextInt(candidates.length)]
        : 0;
    _answer  = words[idx].replaceAll(RegExp(r'[^\wäöüÄÖÜß]'), '');
    final blankedWords = List<String>.from(words);
    blankedWords[idx] = '___';
    _blanked = blankedWords.join(' ');
    _parts   = _blanked.split('___');
  }

  void _check() {
    final correct = _ctrl.text.trim().toLowerCase() == _answer.toLowerCase();
    setState(() {
      _answered = true;
      _correct  = correct;
    });
    widget.onResult?.call(correct);
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phrase with blank
        Container(
          width     : double.infinity,
          padding   : const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color       : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            children : [
              Text(_parts[0],
                  style: theme.textTheme.bodyLarge),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                padding    : const EdgeInsets.symmetric(horizontal: 4),
                decoration : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _answered
                          ? (_correct ? Colors.green : Colors.red)
                          : scheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                child: _answered
                    ? Text(
                        _correct ? _answer : _ctrl.text,
                        style: TextStyle(
                          color     : _correct ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize  : 16,
                        ),
                      )
                    : SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _ctrl,
                          decoration: const InputDecoration(
                            border     : InputBorder.none,
                            isDense    : true,
                            contentPadding: EdgeInsets.symmetric(vertical: 2),
                          ),
                          onSubmitted: (_) => _answered ? null : _check(),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
              ),
              if (_parts.length > 1) Text(_parts[1], style: theme.textTheme.bodyLarge),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.sm),

        // Meaning hint
        Text(
          widget.meaning,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Feedback
        if (_answered && !_correct) ...[
          Row(
            children: [
              const Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Text('${AppL10n.t(context, 'answer_label')} $_answer',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        if (_answered && _correct) ...[
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(AppL10n.t(context, 'correct_feedback'),
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],

        if (!_answered)
          VoxButton.tonal(
            label    : AppL10n.t(context, 'check'),
            expand   : true,
            onPressed: _check,
          ),
      ],
    );
  }
}
