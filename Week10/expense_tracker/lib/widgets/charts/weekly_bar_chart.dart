import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../repositories/expense_repository.dart';
import '../../utils/formatters.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.series,
  });

  final List<DailyTotal> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty || series.every((entry) => entry.total == 0)) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No expenses for the last 7 days')),
      );
    }

    final maxY = series.map((entry) => entry.total).fold<double>(
        0, (previousValue, element) => element > previousValue ? element : previousValue);

    final interval = maxY == 0
        ? 1.0
        : (maxY / 4).clamp(1, double.infinity).toDouble();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = series[group.x.toInt()];
                final textStyle = Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onPrimary) ??
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
                return BarTooltipItem(
                  '${_weekdayLabel(entry.date)}\n${currency(entry.total)}',
                  textStyle,
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= series.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _weekdayLabel(series[index].date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: interval,
                getTitlesWidget: (value, _) {
                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    currency(value),
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
          ),
          barGroups: series
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.total,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              )
              .toList(),
          maxY: maxY == 0 ? 100 : (maxY * 1.2),
        ),
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}
