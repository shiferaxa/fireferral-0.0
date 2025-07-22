import 'package:flutter/material.dart';

enum AppThemeType {
  corporate,
  modern,
  minimal,
  vibrant,
  classic,
}

class AppColors {
  // AT&T Brand Colors
  static const Color attBlue = Color(0xFF00A8E6);
  static const Color attOrange = Color(0xFFFF6900);
  static const Color attDarkBlue = Color(0xFF0066CC);
  static const Color attLightBlue = Color(0xFF4FC3F7);
  
  // AT&T Gradient colors for modern themes
  static const List<Color> modernGradient = [
    attBlue,
    attDarkBlue,
  ];
  
  static const List<Color> vibrantGradient = [
    attOrange,
    Color(0xFFFF8A50),
  ];
  
  static const List<Color> corporateGradient = [
    attBlue,
    attLightBlue,
  ];
  
  static const List<Color> classicGradient = [
    attDarkBlue,
    attBlue,
  ];
  
  static const List<Color> minimalGradient = [
    attBlue,
    attOrange,
  ];
}

class AppThemes {
  // Corporate Theme
  static ThemeData corporateLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB), // Blue
      brightness: Brightness.light,
      secondary: const Color(0xFF64748B), // Slate
      tertiary: const Color(0xFF10B981), // Emerald
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData corporateDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.attBlue,
      brightness: Brightness.dark,
      primary: AppColors.attBlue,
      secondary: AppColors.attOrange,
      tertiary: AppColors.attLightBlue,
      surface: const Color(0xFF0F1419), // Dark AT&T-inspired background
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF0F1419),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1A1F26),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.attBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // Modern Theme
  static ThemeData modernLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6), // Purple
      brightness: Brightness.light,
      secondary: const Color(0xFF06B6D4), // Cyan
      tertiary: const Color(0xFFEC4899), // Pink
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );

  static ThemeData modernDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.dark,
      secondary: const Color(0xFF0891B2),
      tertiary: const Color(0xFFDB2777),
      surface: const Color(0xFF111827),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );

  // Minimal Theme
  static ThemeData minimalLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF374151), // Gray
      brightness: Brightness.light,
      secondary: const Color(0xFFF59E0B), // Amber
      tertiary: const Color(0xFF6B7280),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
      ),
    ),
  );

  static ThemeData minimalDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF9FAFB),
      brightness: Brightness.dark,
      secondary: const Color(0xFFFCD34D),
      tertiary: const Color(0xFF9CA3AF),
      surface: const Color(0xFF111827),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF374151)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
      ),
    ),
  );

  // Vibrant Theme
  static ThemeData vibrantLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEF4444), // Red
      brightness: Brightness.light,
      secondary: const Color(0xFF8B5CF6), // Purple
      tertiary: const Color(0xFF06B6D4), // Cyan
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),
  );

  static ThemeData vibrantDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFDC2626),
      brightness: Brightness.dark,
      secondary: const Color(0xFF7C3AED),
      tertiary: const Color(0xFF0891B2),
      surface: const Color(0xFF0F0F0F),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),
  );

  // Classic Theme
  static ThemeData classicLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A), // Navy
      brightness: Brightness.light,
      secondary: const Color(0xFFD97706), // Gold
      tertiary: const Color(0xFF059669), // Forest
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  static ThemeData classicDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
      secondary: const Color(0xFFF59E0B),
      tertiary: const Color(0xFF10B981),
      surface: const Color(0xFF1F2937),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  // Theme getters
  static ThemeData getTheme(AppThemeType themeType, bool isDark) {
    switch (themeType) {
      case AppThemeType.corporate:
        return isDark ? corporateDark : corporateLight;
      case AppThemeType.modern:
        return isDark ? modernDark : modernLight;
      case AppThemeType.minimal:
        return isDark ? minimalDark : minimalLight;
      case AppThemeType.vibrant:
        return isDark ? vibrantDark : vibrantLight;
      case AppThemeType.classic:
        return isDark ? classicDark : classicLight;
    }
  }

  static String getThemeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.corporate:
        return 'Corporate';
      case AppThemeType.modern:
        return 'Modern';
      case AppThemeType.minimal:
        return 'Minimal';
      case AppThemeType.vibrant:
        return 'Vibrant';
      case AppThemeType.classic:
        return 'Classic';
    }
  }
}