import 'package:hive/hive.dart';

import '../models/expense.dart';

class HiveBoxes {
  HiveBoxes._();

  static const String expenses = 'expenses_box';

  static Box<Expense> expensesBox() => Hive.box<Expense>(expenses);
}
