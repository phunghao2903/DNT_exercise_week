import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF4F8EF3);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF3F5F9),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputDecorationTheme(base.colorScheme),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputDecorationTheme(base.colorScheme),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    final borderRadius = BorderRadius.circular(28);
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color baseFill = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest;
    final Color fillColor =
        isDark ? baseFill.withValues(alpha: 0.6) : baseFill;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
