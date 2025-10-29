import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../utils/formatters.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.totals,
  });

  final Map<Category, double> totals;

  @override
  Widget build(BuildContext context) {
    final hasData = totals.values.any((value) => value > 0);

    if (!hasData) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No expenses for this range')),
      );
    }

    final totalAmount = totals.values.fold<double>(0, (sum, value) => sum + value);
    final sections = totals.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PieChartSectionData(
            color: entry.key.color,
            value: entry.value,
            title:
                '${((entry.value / totalAmount) * 100).toStringAsFixed(0)}%',
            radius: 70,
            titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        )
        .toList();

    return SizedBox(
      height: 260,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: totals.entries
                .where((entry) => entry.value > 0)
                .map(
                  (entry) => _LegendItem(
                    color: entry.key.color,
                    label: entry.key.label,
                    value: currency(entry.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
