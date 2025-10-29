import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const base = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF5F8DFF),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCE6FF),
      onPrimaryContainer: Color(0xFF07206A),
      secondary: Color(0xFFFFB3B3),
      onSecondary: Color(0xFF4B1A1A),
      secondaryContainer: Color(0xFFFFE5E5),
      onSecondaryContainer: Color(0xFF311212),
      tertiary: Color(0xFF88E0D0),
      onTertiary: Color(0xFF00382F),
      tertiaryContainer: Color(0xFFCFFAEF),
      onTertiaryContainer: Color(0xFF00382F),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: Color(0xFFF7F8FC),
      onBackground: Color(0xFF1A1B20),
      surface: Colors.white,
      onSurface: Color(0xFF1A1B20),
      surfaceVariant: Color(0xFFE2E6F0),
      onSurfaceVariant: Color(0xFF424757),
      outline: Color(0xFF737887),
      outlineVariant: Color(0xFFC3C8D5),
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF2F3036),
      onInverseSurface: Color(0xFFF1F2F7),
      inversePrimary: Color(0xFFB8C7FF),
      surfaceTint: Color(0xFF5F8DFF),
    );

    return _baseTheme(base);
  }

  static ThemeData dark() {
    const base = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB8C7FF),
      onPrimary: Color(0xFF001B5A),
      primaryContainer: Color(0xFF1E336F),
      onPrimaryContainer: Color(0xFFDCE6FF),
      secondary: Color(0xFFFFB1C1),
      onSecondary: Color(0xFF4B1D2B),
      secondaryContainer: Color(0xFF662F40),
      onSecondaryContainer: Color(0xFFFFD9E1),
      tertiary: Color(0xFF9CE6D8),
      onTertiary: Color(0xFF00382F),
      tertiaryContainer: Color(0xFF005044),
      onTertiaryContainer: Color(0xFFCFFAEF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      background: Color(0xFF10131A),
      onBackground: Color(0xFFE0E2E9),
      surface: Color(0xFF171A22),
      onSurface: Color(0xFFE0E2E9),
      surfaceVariant: Color(0xFF424757),
      onSurfaceVariant: Color(0xFFC3C8D5),
      outline: Color(0xFF8D91A1),
      outlineVariant: Color(0xFF2D303D),
      shadow: Colors.black54,
      scrim: Colors.black87,
      inverseSurface: Color(0xFFE0E2E9),
      onInverseSurface: Color(0xFF1A1B20),
      inversePrimary: Color(0xFF5F8DFF),
      surfaceTint: Color(0xFFB8C7FF),
    );

    return _baseTheme(base);
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    final baseTypography = Typography.material2021(platform: TargetPlatform.android);
    final textTheme = (scheme.brightness == Brightness.light
            ? baseTypography.black
            : baseTypography.white)
        .apply(fontFamily: 'Roboto');

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
