import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF7B61FF);
  static const backgroundColor = Colors.black;
  static const surfaceColor = Color(0xFF1E1E1E);
  static const errorColor = Colors.redAccent;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
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
