import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';
import '../models/category.dart';
import '../models/expense.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ExpenseAdapter().typeId)) {
      Hive.registerAdapter(ExpenseAdapter());
    }

    await Hive.openBox<Expense>(HiveBoxes.expenses);
  }
}
