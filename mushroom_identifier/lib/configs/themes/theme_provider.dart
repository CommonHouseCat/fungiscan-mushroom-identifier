import 'package:flutter/material.dart';
import 'light_mode.dart';
import 'dark_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData; // Current app theme
  bool _isDarkMode;

  ThemeProvider(this._isDarkMode)
      : _themeData = _isDarkMode ? darkMode : lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _isDarkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;
    _saveThemeSetting(_isDarkMode);
    notifyListeners();
  }

  Future<void> _saveThemeSetting(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}
