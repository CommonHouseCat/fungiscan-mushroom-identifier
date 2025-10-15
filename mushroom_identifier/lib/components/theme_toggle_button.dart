import 'package:flutter/material.dart';

class ThemeToggleButtonWidget extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;

  const ThemeToggleButtonWidget({
    super.key,
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      onPressed: onPressed,
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}