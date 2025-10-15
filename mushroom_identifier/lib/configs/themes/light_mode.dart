import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white, // Clean white background
    onSurface: Colors.black, // Text/icons on surface
    primary: Colors.orange.shade700, // Main brand color
    onPrimary: Colors.black, // Text/icons on primary
    secondary: Colors.orange.shade500, // Secondary orange
    onSecondary: Colors.black, // Text/icons on secondary
    tertiary: Colors.grey.shade100, // Cards/dialogs
    inversePrimary: Colors.black, // Inverse elements
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  iconTheme: IconThemeData(color: Colors.black),
);