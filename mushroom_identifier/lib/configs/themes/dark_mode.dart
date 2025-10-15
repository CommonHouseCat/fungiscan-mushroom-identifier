import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.black, // Pure black background
    onSurface: Colors.white, // Text/icons on surface
    primary: Colors.greenAccent.shade400, // Vibrant green
    onPrimary: Colors.white, // Text/icons on primary
    secondary: Colors.greenAccent.shade200, // Lighter green
    onSecondary: Colors.white, // Text/icons on secondary
    tertiary: Colors.grey.shade900, // Cards/dialogs
    inversePrimary: Colors.white, // Inverse elements
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  iconTheme: IconThemeData(color: Colors.white),
);