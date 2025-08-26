import 'package:flutter/material.dart';
import '../components/language_toggle_button.dart';
import '../components/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // --- State Variables (kept in HomeScreen for now) ---
  bool _isDarkMode = false;
  bool _isVietnamese = true;

  // --- Methods to Toggle State (kept in HomeScreen for now) ---
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // --- Methods to Toggle State (kept in HomeScreen for now) ---
  void _toggleLanguage() {
    setState(() {
      _isVietnamese = !_isVietnamese;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        actions: <Widget>[
          LanguageToggleButtonWidget(
            isVietnamese: _isVietnamese,
            onPressed: _toggleLanguage,
          ),
          ThemeToggleButtonWidget(
            isDarkMode: _isDarkMode,
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("TODO Home Screen"),
            const SizedBox(height: 20),
            Text("Current Theme: ${_isDarkMode ? "Dark" : "Light"}"),
            Text("Current Language: ${_isVietnamese ? "Vietnamese" : "English (USA)"}"),
          ],
        ),
      ),
    );
  }
}
