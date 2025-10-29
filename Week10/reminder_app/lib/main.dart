import 'package:flutter/material.dart';

import 'repositories/reminder_repository.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/timezone_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TimezoneService.instance.initialize();
  await NotificationService.instance.initialize();
  runApp(const ReminderApp());
}

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  late final ReminderRepository _repository = ReminderRepository();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(repository: _repository),
    );
  }
}
