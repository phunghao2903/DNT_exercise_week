import 'package:flutter/material.dart';

import 'data/hive_boxes.dart';
import 'repositories/expense_repository.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final repository = ExpenseRepository(HiveBoxes.expensesBox());

  runApp(ExpenseTrackerApp(repository: repository));
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key, required this.repository});

  final ExpenseRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomeScreen(repository: repository),
    );
  }
}
