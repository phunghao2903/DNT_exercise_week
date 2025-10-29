import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth_wrapper.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authRepository = AuthRepository();
  runApp(FirebaseLoginApp(authRepository: authRepository));
}

class FirebaseLoginApp extends StatelessWidget {
  const FirebaseLoginApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return AuthRepositoryProvider(
      repository: authRepository,
      child: MaterialApp(
        title: 'Firebase Login App',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
