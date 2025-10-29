import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChatUIApp());
}

class ChatUIApp extends StatelessWidget {
  const ChatUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chat_ui_clone',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}
