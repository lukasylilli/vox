// FILE: lib/features/auswendiglernen/screens/memorize_card_screen.dart
// DEPS: auswendiglernen_controller.dart, memorize_card_widget.dart
// PURPOSE: Session کارت مرور — flip card + درست/نمیدونستم + summary
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/auswendiglernen_controller.dart';
import '../widgets/memorize_card_widget.dart';
import '../../../core/widgets/vox_button.dart';

class MemorizeCardScreen extends ConsumerStatefulWidget {
  const MemorizeCardScreen({super.key, required this.categoryIndex});
  final int categoryIndex;

  @override
  ConsumerState<MemorizeCardScreen> createState() => _MemorizeCardScreenState();
}

class _MemorizeCardScreenState extends ConsumerState<MemorizeCardScreen> {
  List<_CardItem> _items   = [];
  int  _current            = 0;
  int  _known              = 0;
  bool _done               = false;
  bool _loaded             = false;

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
      _items  = rows.map((r) {
        List<String> examples = [];
        if (r.examplesJson != null && r.examplesJson!.isNotEmpty) {
          try {
            final decoded = jsonDecode(r.examplesJson!);
            if (decoded is List) examples = decoded.cast<String>();
          } catch (_) {}
        }
        return _CardItem(
          phrase   : r.phrase,
          meaning  : r.meaning,
          meaningEn: r.meaningEn,
          level    : r.level,
          examples : examples,
        );
      }).toList();
      _loaded = true;
    });
  }

  void _markKnown() {
    setState(() => _known++);
    _next();
  }

  void _markUnknown() => _next();

  void _next() {
    if (_current >= _items.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() => _current++);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _known   = 0;
      _done    = false;
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
        body  : Center(child: Text(AppL10n.t(context, 'no_items_review'))),
      );
    }

    if (_done) {
      return _SummaryScreen(
        category: _category,
        total   : _items.length,
        known   : _known,
        onRetry : _restart,
        onBack  : () => Navigator.pop(context),
      );
    }

    final item = _items[_current];

    return Scaffold(
      appBar: AppBar(
        title: Text(_category),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_current + 1) / _items.length,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            // Counter
            Text(
              '${_current + 1} / ${_items.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Card (takes most space)
            Expanded(
              child: Center(
                child: MemorizeCardWidget(
                  key     : ValueKey(_current),
                  front   : item.phrase,
                  back    : AppL10n.meaning(context,
                      fa: item.meaning, en: item.meaningEn ?? item.meaning),
                  examples: item.examples,
                  level   : item.level,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Answer buttons
            Row(
              children: [
                Expanded(
                  child: VoxButton.destructiveOutlined(
                    label    : AppL10n.t(context, 'didn_t_know'),
                    icon     : Icons.close_rounded,
                    size     : VoxButtonSize.large,
                    onPressed: _markUnknown,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: VoxButton.success(
                    label    : AppL10n.t(context, 'knew_it'),
                    icon     : Icons.check_rounded,
                    size     : VoxButtonSize.large,
                    onPressed: _markKnown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _CardItem {
  const _CardItem({
    required this.phrase,
    required this.meaning,
    required this.examples,
    this.meaningEn,
    this.level,
  });
  final String       phrase;
  final String       meaning;
  final String?      meaningEn;
  final List<String> examples;
  final String?      level;
}

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({
    required this.category,
    required this.total,
    required this.known,
    required this.onRetry,
    required this.onBack,
  });
  final String     category;
  final int        total;
  final int        known;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final pct    = total == 0 ? 0 : (known * 100 ~/ total);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
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
                      backgroundColor:
                          scheme.surfaceContainerHighest,
                    ),
                    Text('$pct%',
                        style: const TextStyle(
                          fontSize  : 28,
                          fontWeight: FontWeight.w800,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(AppL10n.tf(context, 'x_of_y_knew', {'x': '$known', 'y': '$total'}),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSizes.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VoxButton.secondary(
                    label    : AppL10n.t(context, 'try_again'),
                    icon     : Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                  const SizedBox(width: AppSizes.md),
                  VoxButton.primary(
                    label    : AppL10n.t(context, 'done'),
                    icon     : Icons.check_rounded,
                    onPressed: onBack,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
