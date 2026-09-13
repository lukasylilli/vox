// FILE: lib/features/auswendiglernen/widgets/memorize_card_widget.dart
// DEPS: -
// PURPOSE: 3D flip card — front: phrase (DE), back: meaning (FA) + examples
import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class MemorizeCardWidget extends StatefulWidget {
  const MemorizeCardWidget({
    super.key,
    required this.front,
    required this.back,
    this.examples = const [],
    this.level,
  });

  final String       front;
  final String       back;
  final List<String> examples;
  final String?      level;

  @override
  State<MemorizeCardWidget> createState() => _MemorizeCardWidgetState();
}

class _MemorizeCardWidgetState extends State<MemorizeCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MemorizeCardWidget old) {
    super.didUpdateWidget(old);
    if (old.front != widget.front) {
      // New card — reset without animation
      _ctrl.reset();
      _showFront = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_ctrl.isAnimating) return;
    if (_showFront) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, _) {
          final angle     = _anim.value;
          final showFront = angle < pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform  : transform,
            alignment  : Alignment.center,
            child      : showFront
                ? _FrontFace(phrase: widget.front, level: widget.level)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _BackFace(
                      meaning : widget.back,
                      examples: widget.examples,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.phrase, this.level});
  final String  phrase;
  final String? level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width     : double.infinity,
      padding   : const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color       : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color  : scheme.shadow.withValues(alpha: 0.15),
            blurRadius: 16,
            offset : const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (level != null)
            Container(
              padding   : const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color       : scheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(level!.toUpperCase(),
                  style: TextStyle(
                    fontSize  : 11,
                    fontWeight: FontWeight.w700,
                    color     : scheme.primary,
                  )),
            ),
          if (level != null) const SizedBox(height: AppSizes.md),
          Text(
            phrase,
            style    : Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color     : scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  size : 14,
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(AppL10n.t(context, 'tap_to_reveal'),
                  style: TextStyle(
                    fontSize: 12,
                    color   : scheme.onPrimaryContainer.withValues(alpha: 0.5),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.meaning, required this.examples});
  final String       meaning;
  final List<String> examples;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width     : double.infinity,
      padding   : const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color       : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color  : scheme.shadow.withValues(alpha: 0.15),
            blurRadius: 16,
            offset : const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            meaning,
            style    : Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color     : scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            const Divider(),
            const SizedBox(height: AppSizes.sm),
            ...examples.take(2).map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $ex',
                    style: TextStyle(
                      fontSize: 13,
                      color   : scheme.onSecondaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
