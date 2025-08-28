import 'package:flutter/material.dart';

class LanguageToggleButtonWidget extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onPressed;

  const LanguageToggleButtonWidget({
    super.key,
    required this.isEnglish,
    required this.onPressed,
  });

  // --- Methods to Toggle State (kept in HomeScreen for now) ---

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isEnglish ? Icons.flag_circle_outlined : Icons.flag_outlined), // TODO: replace with png later
      tooltip: 'Toggle Language',
      onPressed: onPressed,
    );
  }
}
