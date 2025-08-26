import 'package:flutter/material.dart';

class ThemeToggleButtonWidget extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;

  const ThemeToggleButtonWidget({
    super.key,
    required this.isDarkMode,
    required this.onPressed,
  });

  // --- Methods to Toggle State (kept in HomeScreen for now) ---

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
      tooltip: 'Toggle Theme',
      onPressed: onPressed,
    );
  }
}