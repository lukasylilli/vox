// FILE: lib/features/leitner/widgets/wende_karte.dart
// PURPOSE: Die 3D-Wende einer Lernkarte — Vorderseite, Tippen, Rückseite.
//          Gemeinsam für App-Wörter (FlashCardWidget) und Archivkarten
//          (ArchivFlashCard), damit beide sich gleich verhalten (B-13).
//          Neue Karte ⇒ neuer `key` beim Aufrufer ⇒ wieder Vorderseite.
import 'dart:math' as math;

import 'package:flutter/material.dart';

class WendeKarte extends StatefulWidget {
  const WendeKarte({
    super.key,
    required this.vorne,
    required this.hinten,
    this.onFlip,
  });

  final Widget vorne;
  final Widget hinten;

  /// Einmal, sobald die Rückseite zum ersten Mal sichtbar ist.
  final VoidCallback? onFlip;

  @override
  State<WendeKarte> createState() => _WendeKarteState();
}

class _WendeKarteState extends State<WendeKarte>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _hinten = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  void _wenden() {
    if (_ctrl.isAnimating) return;
    if (_hinten) {
      _ctrl.reverse().then((_) {
        if (mounted) setState(() => _hinten = false);
      });
    } else {
      _ctrl.forward().then((_) {
        if (!mounted) return;
        setState(() => _hinten = true);
        widget.onFlip?.call();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _wenden,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, _) {
          final winkel = _anim.value * math.pi;
          final vorne = winkel < math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(winkel),
            child: vorne
                ? widget.vorne
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.hinten,
                  ),
          );
        },
      ),
    );
  }
}
