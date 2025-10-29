import 'package:flutter/material.dart';

class AppTheme {
  static const double screenPadding = 20.0;
  static const double elementSpacing = 16.0;
  static const double cardRadius = 18.0;

  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F9EE3),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteCupertino
        : Typography.blackCupertino;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.bold),
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
