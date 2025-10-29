import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const double gallerySpacing = 12;
  static const BorderRadius tileBorderRadius =
      BorderRadius.all(Radius.circular(12));
  static const EdgeInsets screenPadding = EdgeInsets.all(16);

  static ThemeData light() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: baseColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: baseColorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: baseColorScheme.onInverseSurface,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: tileBorderRadius,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: baseColorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: baseColorScheme.onInverseSurface,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: tileBorderRadius,
        ),
      ),
    );
  }
}
