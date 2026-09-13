// FILE: lib/features/selbstlernen/widgets/mountain_progress_widget.dart
// DEPS: -
// PURPOSE: CustomPainter — Bergpfad A1→C2, aktuelles Level hervorgehoben
import 'package:flutter/material.dart';

class MountainProgressWidget extends StatelessWidget {
  const MountainProgressWidget({
    super.key,
    required this.currentLevel,
    this.height = 200,
  });

  final String currentLevel; // 'a1'..'c2'
  final double height;

  static const _levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

  @override
  Widget build(BuildContext context) {
    final scheme       = Theme.of(context).colorScheme;
    final currentIndex = _levels.indexOf(currentLevel.toLowerCase());

    return SizedBox(
      width : double.infinity,
      height: height,
      child : CustomPaint(
        painter: _MountainPainter(
          currentIndex: currentIndex,
          pathColor   : scheme.primary,
          doneColor   : Colors.green,
          todoColor   : scheme.outlineVariant,
          labelColor  : scheme.onSurface,
          bgColor     : scheme.surfaceContainerLow,
        ),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  _MountainPainter({
    required this.currentIndex,
    required this.pathColor,
    required this.doneColor,
    required this.todoColor,
    required this.labelColor,
    required this.bgColor,
  });

  final int   currentIndex;
  final Color pathColor;
  final Color doneColor;
  final Color todoColor;
  final Color labelColor;
  final Color bgColor;

  static const _labels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mountain silhouette points (left to right, peak near C2)
    // Y values are inverted (lower y = higher on screen)
    final points = [
      Offset(w * 0.0,  h * 0.85), // start (A1 base)
      Offset(w * 0.18, h * 0.70), // A1
      Offset(w * 0.33, h * 0.55), // A2
      Offset(w * 0.50, h * 0.38), // B1
      Offset(w * 0.65, h * 0.22), // B2
      Offset(w * 0.80, h * 0.10), // C1
      Offset(w * 0.95, h * 0.04), // C2 (peak)
    ];

    // Draw mountain background
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final bgPath = Path()
      ..moveTo(0, h)
      ..lineTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      bgPath.lineTo(p.dx, p.dy);
    }
    bgPath
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // Draw path segments
    for (var i = 1; i < points.length; i++) {
      final segIndex = i - 1; // which level this segment leads to
      final isDone   = segIndex <= currentIndex;
      final paint    = Paint()
        ..color       = isDone ? doneColor : todoColor
        ..strokeWidth = 3
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round;
      canvas.drawLine(points[i - 1], points[i], paint);
    }

    // Draw level markers
    for (var i = 0; i < _labels.length; i++) {
      final pt      = points[i + 1]; // points[0] is base
      final isDone  = i <= currentIndex;
      final isCurr  = i == currentIndex;

      // Circle
      final circlePaint = Paint()
        ..color = isCurr ? pathColor : (isDone ? doneColor : todoColor)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isCurr ? 10 : 7, circlePaint);

      if (isCurr) {
        final ringPaint = Paint()
          ..color       = pathColor.withAlpha(80)
          ..strokeWidth = 3
          ..style       = PaintingStyle.stroke;
        canvas.drawCircle(pt, 15, ringPaint);
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text : _labels[i],
          style: TextStyle(
            fontSize  : isCurr ? 12 : 10,
            fontWeight: isCurr ? FontWeight.w800 : FontWeight.w500,
            color     : labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(pt.dx - tp.width / 2, pt.dy + 12),
      );
    }
  }

  @override
  bool shouldRepaint(_MountainPainter old) =>
      old.currentIndex != currentIndex;
}
