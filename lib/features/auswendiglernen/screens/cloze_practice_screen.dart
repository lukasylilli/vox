// FILE: lib/features/auswendiglernen/screens/cloze_practice_screen.dart
// DEPS: auswendiglernen_controller.dart, cloze_fill_widget.dart
// PURPOSE: تمرین جای خالی — یک آیتم در هر بار، پیشرفت + نتیجه
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vox_progress.dart';
import '../controllers/auswendiglernen_controller.dart';
import '../widgets/cloze_fill_widget.dart';
import '../../../core/widgets/vox_button.dart';

class ClozePracticeScreen extends ConsumerStatefulWidget {
  const ClozePracticeScreen({super.key, required this.categoryIndex});
  final int categoryIndex;

  @override
  ConsumerState<ClozePracticeScreen> createState() =>
      _ClozePracticeScreenState();
}

class _ClozePracticeScreenState extends ConsumerState<ClozePracticeScreen> {
  List<_PracticeItem> _items   = [];
  int  _current                = 0;
  int  _correct                = 0;
  bool _answered               = false;
  bool _done                   = false;
  bool _loaded                 = false;

  String get _category => memorizeCategories[widget.categoryIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final rows = await ref.read(categoryItemsSnapshotProvider(_category).future);
    if (!mounted) return;
    setState(() {
      _items  = rows
          .where((r) => r.phrase.split(' ').any((w) =>
              w.replaceAll(RegExp(r'[^\wäöüÄÖÜß]'), '').length >= 3))
          .map((r) => _PracticeItem(
              phrase: r.phrase,
              meaning: AppL10n.meaning(context,
                  fa: r.meaning, en: r.meaningEn ?? r.meaning)))
          .toList();
      _loaded = true;
    });
  }

  void _onResult(bool correct) {
    if (correct) setState(() => _correct++);
    setState(() => _answered = true);
  }

  void _next() {
    if (_current >= _items.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() {
        _current++;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _current  = 0;
      _correct  = 0;
      _answered = false;
      _done     = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_category)),
        body  : Center(child: Text(AppL10n.t(context, 'no_items_practice'))),
      );
    }

    if (_done) {
      final pct = _items.isEmpty ? 0 : (_correct * 100 ~/ _items.length);
      return Scaffold(
        appBar: AppBar(title: Text(_category)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width : 120,
                height: 120,
                child : Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value      : pct / 100,
                      strokeWidth: 10,
                      color      : pct >= 70 ? Colors.green : scheme.primary,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                    Text('$pct%',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(AppL10n.tf(context, 'x_of_y_correct', {'x': Formatters.faDigits(_correct), 'y': Formatters.faDigits(_items.length)}),
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSizes.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VoxButton.secondary(
                    label    : AppL10n.t(context, 'try_again'),
                    icon     : Icons.refresh_rounded,
                    onPressed: _restart,
                  ),
                  const SizedBox(width: AppSizes.md),
                  VoxButton.primary(
                    label    : AppL10n.t(context, 'done'),
                    icon     : Icons.check_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final item = _items[_current];

    return Scaffold(
      appBar: AppBar(
        title: Text(_category),
        bottom: VoxQuizProgressBar.bar(current: _current + 1, total: _items.length),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_current + 1} / ${_items.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            ClozeFillWidget(
              key     : ValueKey(_current),
              phrase  : item.phrase,
              meaning : item.meaning,
              onResult: _onResult,
            ),

            const Spacer(),

            if (_answered)
              VoxButton.primary(
                label    : _current < _items.length - 1
                    ? AppL10n.t(context, 'next')
                    : AppL10n.t(context, 'results'),
                expand   : true,
                onPressed: _next,
              ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _PracticeItem {
  const _PracticeItem({required this.phrase, required this.meaning});
  final String phrase;
  final String meaning;
}
