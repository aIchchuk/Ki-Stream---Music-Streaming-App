import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF8B80F9);
  static const backgroundColor = Colors.transparent;
  static const realBackgroundColor =
      Colors.black; // Keep original for reference if needed
  static const surfaceColor = Color(0xFF1E1E1E);
  static const errorColor = Colors.redAccent;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: Colors.grey,
      surface: surfaceColor,
      error: errorColor,
    ),
    useMaterial3: true,
  );
}
