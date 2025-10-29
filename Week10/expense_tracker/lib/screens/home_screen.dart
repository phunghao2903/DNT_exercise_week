import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_view.dart';
import '../widgets/expense_form.dart';
import '../widgets/expense_tile.dart';
import 'stats_screen.dart';

enum ExpenseFilter {
  all,
  today,
  week,
  month,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
  });

  final ExpenseRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseFilter _filter = ExpenseFilter.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StatsScreen(repository: widget.repository),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: widget.repository.watch(),
        builder: (context, _, __) {
          final allExpenses = widget.repository.getAll();
          final expenses = _applyFilter(allExpenses);
          final todayTotal = widget.repository.totalForDay(DateTime.now());

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _TotalCard(amount: todayTotal),
                _FilterSelector(
                  filter: _filter,
                  onChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                if (expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: EmptyView(),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.horizontalPadding,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ExpenseTile(
                          expense: expense,
                          onEdit: () => _editExpense(expense),
                          onDelete: () => _confirmDelete(expense),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Expense> _applyFilter(List<Expense> expenses) {
    switch (_filter) {
      case ExpenseFilter.all:
        return expenses;
      case ExpenseFilter.today:
        final now = DateTime.now();
        return expenses.where((expense) {
          return _isSameDay(expense.date, now);
        }).toList();
      case ExpenseFilter.week:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((expense) {
          return !_isBeforeDay(expense.date, startOfWeek) &&
              !_isAfterDay(expense.date, now);
        }).toList();
      case ExpenseFilter.month:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return expenses.where((expense) {
          return !_isBeforeDay(expense.date, startOfMonth) &&
              !_isAfterDay(expense.date, now);
        }).toList();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isBeforeDay(DateTime value, DateTime min) {
    final normalized = DateTime(value.year, value.month, value.day);
    final normalizedMin = DateTime(min.year, min.month, min.day);
    return normalized.isBefore(normalizedMin);
  }

  bool _isAfterDay(DateTime value, DateTime max) {
    final normalized = DateTime(value.year, value.month, value.day);
    final normalizedMax = DateTime(max.year, max.month, max.day);
    return normalized.isAfter(normalizedMax);
  }

  Future<void> _addExpense() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ExpenseForm(
          onSubmit: (expense) async {
            await widget.repository.add(expense);
          },
        );
      },
    );
  }

  Future<void> _editExpense(Expense expense) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ExpenseForm(
          initialExpense: expense,
          onSubmit: (updated) async {
            await widget.repository.update(updated);
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete expense'),
          content: Text('Delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await widget.repository.delete(expense.id);
    }
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.horizontalPadding,
        16,
        AppTheme.horizontalPadding,
        12,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Today',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              currency(amount),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  const _FilterSelector({
    required this.filter,
    required this.onChanged,
  });

  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.horizontalPadding,
        vertical: 8,
      ),
      child: SegmentedButton<ExpenseFilter>(
        segments: const [
          ButtonSegment(
            value: ExpenseFilter.all,
            label: Text('All'),
          ),
          ButtonSegment(
            value: ExpenseFilter.today,
            label: Text('Today'),
          ),
          ButtonSegment(
            value: ExpenseFilter.week,
            label: Text('This Week'),
          ),
          ButtonSegment(
            value: ExpenseFilter.month,
            label: Text('This Month'),
          ),
        ],
        selected: {filter},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            onChanged(selection.first);
          }
        },
      ),
    );
  }
}
