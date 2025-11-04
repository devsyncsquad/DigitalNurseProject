import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // Getters for convenience
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedModeIndex = prefs.getInt(_themeModeKey);

      if (savedModeIndex != null &&
          savedModeIndex >= 0 &&
          savedModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[savedModeIndex];
      } else {
        _themeMode = ThemeMode.light; // Default to light
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, use light mode as fallback
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      // If saving fails, we still keep the current state in memory
      // The user's choice will be lost on app restart, but that's better than crashing
      debugPrint('Failed to save theme mode: $e');
    }
  }

  // Convenience methods
  Future<void> setLightMode() => setThemeMode(ThemeMode.light);
  Future<void> setDarkMode() => setThemeMode(ThemeMode.dark);

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  // Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Light'; // Fallback for any existing system mode
    }
  }

  // Get all available theme modes for UI selection
  List<ThemeModeOption> get themeModeOptions => [
    ThemeModeOption(
      mode: ThemeMode.light,
      name: 'Light',
      description: 'Always use light theme',
    ),
    ThemeModeOption(
      mode: ThemeMode.dark,
      name: 'Dark',
      description: 'Always use dark theme',
    ),
  ];
}

class ThemeModeOption {
  final ThemeMode mode;
  final String name;
  final String description;

  const ThemeModeOption({
    required this.mode,
    required this.name,
    required this.description,
  });
}
