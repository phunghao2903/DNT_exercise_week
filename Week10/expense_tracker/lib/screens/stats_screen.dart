import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/charts/category_pie_chart.dart';
import '../widgets/charts/weekly_bar_chart.dart';

enum StatsRange {
  week,
  month,
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    required this.repository,
  });

  final ExpenseRepository repository;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsRange _range = StatsRange.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: widget.repository.watch(),
        builder: (context, _, __) {
          final now = DateTime.now();
          final rangeStart = _range == StatsRange.week
              ? _startOfDay(now.subtract(Duration(days: now.weekday - 1)))
              : DateTime(now.year, now.month, 1);
          final rangeEnd = _endOfDay(now);

          final totals = widget.repository.totalsByCategory(rangeStart, rangeEnd);
          final rangeTotal = widget.repository.totalForRange(rangeStart, rangeEnd);
          final expenses = widget.repository
              .getAll()
              .where(
                (expense) =>
                    !expense.date.isBefore(rangeStart) && !expense.date.isAfter(rangeEnd),
              )
              .toList();

          final weeklySeries = widget.repository.last7DaysSeries();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.horizontalPadding,
                right: AppTheme.horizontalPadding,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _RangeSelector(
                    range: _range,
                    onChanged: (value) {
                      setState(() {
                        _range = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total'),
                                const SizedBox(height: 6),
                                Text(
                                  currency(rangeTotal),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Transactions'),
                                const SizedBox(height: 6),
                                Text(
                                  expenses.length.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'By Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CategoryPieChart(totals: totals),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Last 7 Days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: WeeklyBarChart(series: weeklySeries),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.range,
    required this.onChanged,
  });

  final StatsRange range;
  final ValueChanged<StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatsRange>(
      segments: const [
        ButtonSegment(
          value: StatsRange.week,
          label: Text('This Week'),
        ),
        ButtonSegment(
          value: StatsRange.month,
          label: Text('This Month'),
        ),
      ],
      selected: {range},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
    );
  }
}
