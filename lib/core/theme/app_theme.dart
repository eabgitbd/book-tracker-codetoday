import 'package:flutter/material.dart';

enum AppThemePreset {
  paperAndInk,
  forestLibrary,
  midnightAmoled,
  vintageParchment,
  glassLibrary,
  sketchJournal,
}

extension AppThemePresetExtension on AppThemePreset {
  String get displayName {
    switch (this) {
      case AppThemePreset.paperAndInk:
        return 'Paper & Ink';
      case AppThemePreset.forestLibrary:
        return 'Forest Library';
      case AppThemePreset.midnightAmoled:
        return 'Midnight / AMOLED';
      case AppThemePreset.vintageParchment:
        return 'Vintage Parchment';
      case AppThemePreset.glassLibrary:
        return 'Glass Library';
      case AppThemePreset.sketchJournal:
        return 'Sketch Journal';
    }
  }

  String get description {
    switch (this) {
      case AppThemePreset.paperAndInk:
        return 'Warm editorial paper with classic forest green & amber.';
      case AppThemePreset.forestLibrary:
        return 'Earthy sage, moss tones, and quiet natural surfaces.';
      case AppThemePreset.midnightAmoled:
        return 'Pure OLED black background with crisp contrast.';
      case AppThemePreset.vintageParchment:
        return 'Aged sepia paper with warm literary brown accents.';
      case AppThemePreset.glassLibrary:
        return 'Modern slate & indigo with polished clean lines.';
      case AppThemePreset.sketchJournal:
        return 'Pencil slate and quiet journal monochrome.';
    }
  }

  bool get isDark {
    return this == AppThemePreset.midnightAmoled;
  }
}

class AppTheme {
  static ThemeData getThemeData(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.paperAndInk:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF315B48), // Forest green
          onPrimary: Colors.white,
          background: const Color(0xFFF7F5EF), // Warm paper
          surface: const Color(0xFFFFFFFF),
          textPrimary: const Color(0xFF222521),
          textSecondary: const Color(0xFF6B706A),
          accent: const Color(0xFFD39A48), // Amber
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFE2DFD2),
        );

      case AppThemePreset.forestLibrary:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF2C4A3E),
          onPrimary: Colors.white,
          background: const Color(0xFFF0F4EF),
          surface: const Color(0xFFFFFFFF),
          textPrimary: const Color(0xFF1E2D24),
          textSecondary: const Color(0xFF5D7065),
          accent: const Color(0xFF7A9A60),
          cardColor: const Color(0xFFFAFCF9),
          dividerColor: const Color(0xFFD5DFD6),
        );

      case AppThemePreset.midnightAmoled:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF58A67B),
          onPrimary: const Color(0xFF101210),
          background: const Color(0xFF000000), // Pure AMOLED
          surface: const Color(0xFF121412),
          textPrimary: const Color(0xFFF4F2EA),
          textSecondary: const Color(0xFFA0A59E),
          accent: const Color(0xFFE5A952),
          cardColor: const Color(0xFF181B18),
          dividerColor: const Color(0xFF2A2E2A),
        );

      case AppThemePreset.vintageParchment:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF6E472A),
          onPrimary: Colors.white,
          background: const Color(0xFFF5EEDC),
          surface: const Color(0xFFFCF8EE),
          textPrimary: const Color(0xFF332211),
          textSecondary: const Color(0xFF7A6451),
          accent: const Color(0xFFB57032),
          cardColor: const Color(0xFFFFFDF8),
          dividerColor: const Color(0xFFDFCFAF),
        );

      case AppThemePreset.glassLibrary:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF2B4C6F),
          onPrimary: Colors.white,
          background: const Color(0xFFF1F5F9),
          surface: const Color(0xFFFFFFFF),
          textPrimary: const Color(0xFF1E293B),
          textSecondary: const Color(0xFF64748B),
          accent: const Color(0xFF38BDF8),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFE2E8F0),
        );

      case AppThemePreset.sketchJournal:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF374151),
          onPrimary: Colors.white,
          background: const Color(0xFFF9FAFB),
          surface: const Color(0xFFFFFFFF),
          textPrimary: const Color(0xFF111827),
          textSecondary: const Color(0xFF6B7280),
          accent: const Color(0xFFF59E0B),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFE5E7EB),
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required Color cardColor,
    required Color dividerColor,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: accent,
      onSecondary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: cardColor,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dividerColor.withOpacity(0.6), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light ? Colors.white : const Color(0xFF222622),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 28),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15, height: 1.4),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.3),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
