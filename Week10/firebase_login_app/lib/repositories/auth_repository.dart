import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../services/firebase_auth_service.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException($message)';
}

class AuthRepository {
  AuthRepository({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  final FirebaseAuthService _authService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw AuthException('Something went wrong, please try again.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.register(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw AuthException('Something went wrong, please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (_) {
      throw AuthException('Failed to sign out, please try again.');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'The password is incorrect. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is currently disabled.';
      default:
        return exception.message ??
            'Authentication failed. Please check your connection and try again.';
    }
  }
}

class AuthRepositoryProvider extends InheritedWidget {
  const AuthRepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  final AuthRepository repository;

  static AuthRepository of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AuthRepositoryProvider>();
    assert(
      provider != null,
      'AuthRepositoryProvider not found in context. '
      'Wrap your widget tree in AuthRepositoryProvider.',
    );
    return provider!.repository;
  }

  @override
  bool updateShouldNotify(AuthRepositoryProvider oldWidget) =>
      repository != oldWidget.repository;
}
