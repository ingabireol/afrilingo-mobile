import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// African-inspired color palette for light mode
class LightThemeColors {
  static const primaryColor = Color(0xFF8B4513); // Brown
  static const secondaryColor = Color(0xFFC78539); // Light brown
  static const accentColor = Color(0xFF546CC3); // Blue accent
  static const backgroundColor = Color(0xFFF9F5F1); // Cream background
  static const textColor = Color(0xFF333333); // Dark text
  static const lightTextColor = Color(0xFF777777); // Light text
  static const cardColor = Color(0xFFFFFFFF); // White card background
  static const dividerColor = Color(0xFFEEEEEE); // Light divider
}

// African-inspired color palette for dark mode
class DarkThemeColors {
  static const primaryColor =
      Color(0xFFC78539); // Light brown becomes primary in dark mode
  static const secondaryColor =
      Color(0xFF8B4513); // Brown becomes secondary in dark mode
  static const accentColor =
      Color(0xFF6D8AE9); // Lighter blue accent for dark mode
  static const backgroundColor =
      Color(0xFF121212); // Darker background for better contrast
  static const textColor =
      Color(0xFFEEEEEE); // Lighter text for better readability
  static const lightTextColor =
      Color(0xFFBBBBBB); // Medium gray for secondary text
  static const cardColor = Color(0xFF1E1E1E); // Darker card background
  static const dividerColor = Color(0xFF444444); // Dark divider

  // Additional colors for dark mode
  static const errorColor = Color(0xFFFF5252); // Bright red for errors
  static const successColor = Color(0xFF81C784); // Green for success
  static const warningColor = Color(0xFFFFD54F); // Yellow for warnings
  static const surfaceColor = Color(0xFF2C2C2C); // Surface color for inputs
  static const onSurfaceColor = Color(0xFFDDDDDD); // Text on surface
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themePreferenceKey = 'isDarkMode';

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  // Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    notifyListeners();
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, _isDarkMode);
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePrefs();
    notifyListeners();
  }

  // Get current theme colors
  Color get primaryColor => _isDarkMode
      ? DarkThemeColors.primaryColor
      : LightThemeColors.primaryColor;
  Color get secondaryColor => _isDarkMode
      ? DarkThemeColors.secondaryColor
      : LightThemeColors.secondaryColor;
  Color get accentColor =>
      _isDarkMode ? DarkThemeColors.accentColor : LightThemeColors.accentColor;
  Color get backgroundColor => _isDarkMode
      ? DarkThemeColors.backgroundColor
      : LightThemeColors.backgroundColor;
  Color get textColor =>
      _isDarkMode ? DarkThemeColors.textColor : LightThemeColors.textColor;
  Color get lightTextColor => _isDarkMode
      ? DarkThemeColors.lightTextColor
      : LightThemeColors.lightTextColor;
  Color get cardColor =>
      _isDarkMode ? DarkThemeColors.cardColor : LightThemeColors.cardColor;
  Color get dividerColor => _isDarkMode
      ? DarkThemeColors.dividerColor
      : LightThemeColors.dividerColor;

  // Get ThemeData for current theme
  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: LightThemeColors.primaryColor,
        colorScheme: ColorScheme.light(
          primary: LightThemeColors.primaryColor,
          secondary: LightThemeColors.secondaryColor,
          tertiary: LightThemeColors.accentColor,
          background: LightThemeColors.backgroundColor,
        ),
        scaffoldBackgroundColor: LightThemeColors.backgroundColor,
        cardColor: LightThemeColors.cardColor,
        dividerColor: LightThemeColors.dividerColor,
        fontFamily: 'DM Serif Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'DM Serif Display',
            color: LightThemeColors.textColor,
          ),
          bodyLarge: TextStyle(
            color: LightThemeColors.textColor,
          ),
          bodyMedium: TextStyle(
            color: LightThemeColors.textColor,
          ),
        ),
        useMaterial3: true,
      );

  // Dark theme
  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: DarkThemeColors.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: DarkThemeColors.primaryColor,
          secondary: DarkThemeColors.secondaryColor,
          tertiary: DarkThemeColors.accentColor,
          background: DarkThemeColors.backgroundColor,
          error: DarkThemeColors.errorColor,
          surface: DarkThemeColors.surfaceColor,
          onSurface: DarkThemeColors.onSurfaceColor,
        ),
        scaffoldBackgroundColor: DarkThemeColors.backgroundColor,
        cardColor: DarkThemeColors.cardColor,
        dividerColor: DarkThemeColors.dividerColor,
        fontFamily: 'DM Serif Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'DM Serif Display',
            color: DarkThemeColors.textColor,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: DarkThemeColors.textColor,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: DarkThemeColors.textColor,
            fontSize: 14,
          ),
          labelLarge: TextStyle(
            color: DarkThemeColors.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DarkThemeColors.surfaceColor,
          hintStyle: TextStyle(color: DarkThemeColors.lightTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: DarkThemeColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: DarkThemeColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: DarkThemeColors.primaryColor, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DarkThemeColors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: DarkThemeColors.accentColor,
          ),
        ),
        useMaterial3: true,
      );

  // Additional color getters for convenience
  Color get errorColor => _isDarkMode ? DarkThemeColors.errorColor : Colors.red;
  Color get successColor =>
      _isDarkMode ? DarkThemeColors.successColor : Colors.green;
  Color get warningColor =>
      _isDarkMode ? DarkThemeColors.warningColor : Colors.amber;
  Color get surfaceColor =>
      _isDarkMode ? DarkThemeColors.surfaceColor : Colors.grey.shade50;
  Color get onSurfaceColor =>
      _isDarkMode ? DarkThemeColors.onSurfaceColor : LightThemeColors.textColor;
}
