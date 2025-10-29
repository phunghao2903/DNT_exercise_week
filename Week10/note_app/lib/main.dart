import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/note_detail_page.dart';
import 'presentation/providers/note_provider.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteProvider>(
          create: (_) => NoteProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Note App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/detail': (context) => const NoteDetailPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            return MaterialPageRoute(
              builder: (context) => const NoteDetailPage(),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}
