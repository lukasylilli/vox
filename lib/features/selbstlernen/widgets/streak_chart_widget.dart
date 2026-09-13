// FILE: lib/features/selbstlernen/widgets/streak_chart_widget.dart
// DEPS: fl_chart, selbstlernen_controller.dart
// PURPOSE: BarChart آخر ۷ روز — سبز = تکمیل‌شده، خاکستری = نشده
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../controllers/selbstlernen_controller.dart';

class StreakChartWidget extends StatelessWidget {
  const StreakChartWidget({super.key, required this.last7Days});

  // Map of date → completion count
  final Map<DateTime, int> last7Days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = last7Days.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final bars = entries.asMap().entries.map((e) {
      final count = e.value.value;
      return BarChartGroupData(
        x         : e.key,
        barRods   : [
          BarChartRodData(
            toY      : count > 0 ? count.toDouble() : 0.2,
            color    : count > 0 ? Colors.green : scheme.outlineVariant,
            width    : 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: count > 0 ? [0] : [],
      );
    }).toList();

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY          : (entries.map((e) => e.value).fold(1, (a, b) => a > b ? a : b) + 1).toDouble(),
          barGroups     : bars,
          gridData      : const FlGridData(show: false),
          borderData    : FlBorderData(show: false),
          barTouchData  : BarTouchData(enabled: false),
          titlesData    : FlTitlesData(
            show    : true,
            topTitles   : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles  : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles   : true,
                reservedSize : 24,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  final weekday = entries[idx].key.weekday;
                  return Text(
                    dayNames[weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      color   : scheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
