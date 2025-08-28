import 'package:flutter/material.dart';
import '../components/button_component.dart';
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
  bool _isEnglish = true;

  // --- Methods to Toggle State (kept in HomeScreen for now) ---
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // --- Methods to Toggle State (kept in HomeScreen for now) ---
  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  void _doesNothing() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        actions: <Widget>[
          LanguageToggleButtonWidget(
            isEnglish: _isEnglish,
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
            ButtonComponent(
              label: "Gallery",
              fontSize: 20,
              icon: Icons.image,
              iconColor: Colors.black,
              iconSize: 20,
              onPressed: _doesNothing,
              width: 300,
              height: 150,
            ),
            const SizedBox(height: 20),

            Divider(
              height: 20,
              color: Colors.grey,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),

            const SizedBox(height: 20),
            ButtonComponent(
              label: "Camera",
              fontSize: 20,
              icon: Icons.camera,
              iconColor: Colors.black,
              iconSize: 20,
              onPressed: _doesNothing,
              width: 300,
              height: 150,
            ),

            // const SizedBox(height: 20),
            // Text("Current Theme: ${_isDarkMode ? "Dark" : "Light"}"),
            // Text("Current Language: ${_isEnglish ? "English (USA)" : "Vietnamese"}"),
          ],
        ),
      ),
    );
  }
}
