import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/expense.dart';

class DailyTotal {
  DailyTotal(this.date, this.total);

  final DateTime date;
  final double total;
}

class ExpenseRepository {
  ExpenseRepository(this._box);

  final Box<Expense> _box;

  List<Expense> getAll() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<void> add(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> update(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  ValueListenable<Box<Expense>> watch() => _box.listenable();

  double totalForDay(DateTime day) {
    final start = _startOfDay(day);
    final end = _endOfDay(day);
    return totalForRange(start, end);
  }

  double totalForRange(DateTime start, DateTime end) {
    return _box.values.fold<double>(0, (sum, expense) {
      if (!_isWithinRange(expense.date, start, end)) {
        return sum;
      }
      return sum + expense.amount;
    });
  }

  Map<Category, double> totalsByCategory(DateTime start, DateTime end) {
    final totals = {for (final category in Category.values) category: 0.0};
    for (final expense in _box.values) {
      if (_isWithinRange(expense.date, start, end)) {
        totals[expense.category] = totals[expense.category]! + expense.amount;
      }
    }
    return totals;
  }

  List<DailyTotal> last7DaysSeries() {
    final today = _startOfDay(DateTime.now());
    final List<DailyTotal> series = [];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final total = totalForRange(day, _endOfDay(day));
      series.add(DailyTotal(day, total));
    }
    return series;
  }

  bool _isWithinRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && !value.isAfter(end);
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
